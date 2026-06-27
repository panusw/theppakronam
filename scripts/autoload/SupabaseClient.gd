extends Node
## Singleton — Supabase REST API wrapper using Godot HTTPRequest.
## All stat-sensitive operations must go through server-side RPC functions.
## Client sends action → server validates → returns result.
##
## Credentials: copy supabase.cfg.example → supabase.cfg and fill in your values.
## supabase.cfg is gitignored and never committed.

var supabase_url: String = ""
var supabase_anon_key: String = ""

var _http: HTTPRequest
var _queue: Array[Dictionary] = []
var _busy: bool = false

signal request_completed(data: Variant)
signal request_failed(code: int, message: String)


func _ready() -> void:
	_load_config()
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_raw_completed)


func _load_config() -> void:
	var cfg := ConfigFile.new()
	var path := "res://supabase.cfg"
	if cfg.load(path) != OK:
		push_warning("SupabaseClient: supabase.cfg not found — copy supabase.cfg.example and fill in your credentials")
		return
	supabase_url     = cfg.get_value("supabase", "url",      "")
	supabase_anon_key = cfg.get_value("supabase", "anon_key", "")
	if supabase_url.is_empty() or supabase_anon_key.is_empty():
		push_warning("SupabaseClient: supabase.cfg is missing url or anon_key")


func is_configured() -> bool:
	return not supabase_url.is_empty() and not supabase_anon_key.is_empty()


func _make_headers(upsert: bool = false) -> PackedStringArray:
	var prefer := "resolution=merge-duplicates,return=representation" if upsert \
		else "return=representation"
	return PackedStringArray([
		"Content-Type: application/json",
		"apikey: " + supabase_anon_key,
		"Authorization: Bearer " + GameState.auth_token,
		"Prefer: " + prefer,
	])


# --- Public API ---

func db_get(table: String, query: String = "") -> void:
	_enqueue("/rest/v1/" + table + query, HTTPClient.METHOD_GET, {})


func db_post(table: String, body: Dictionary) -> void:
	_enqueue("/rest/v1/" + table, HTTPClient.METHOD_POST, body)


func db_patch(table: String, query: String, body: Dictionary) -> void:
	_enqueue("/rest/v1/" + table + query, HTTPClient.METHOD_PATCH, body)


func db_upsert(table: String, body: Dictionary) -> void:
	_enqueue("/rest/v1/" + table, HTTPClient.METHOD_POST, body, true)


func call_rpc(func_name: String, params: Dictionary) -> void:
	_enqueue("/rest/v1/rpc/" + func_name, HTTPClient.METHOD_POST, params)


func auth_signup(email: String, password: String) -> void:
	_enqueue("/auth/v1/signup", HTTPClient.METHOD_POST,
		{"email": email, "password": password})


func auth_login(email: String, password: String) -> void:
	_enqueue("/auth/v1/token?grant_type=password", HTTPClient.METHOD_POST,
		{"email": email, "password": password})


func auth_logout() -> void:
	_enqueue("/auth/v1/logout", HTTPClient.METHOD_POST, {})


# --- Internal queue ---

func _enqueue(endpoint: String, method: int, body: Dictionary, upsert: bool = false) -> void:
	if not is_configured():
		push_error("SupabaseClient: not configured — fill in supabase.cfg")
		request_failed.emit(0, "Supabase not configured")
		return
	_queue.append({"endpoint": endpoint, "method": method, "body": body, "upsert": upsert})
	if not _busy:
		_flush()


func _flush() -> void:
	if _queue.is_empty():
		_busy = false
		return
	_busy = true
	var req: Dictionary = _queue.pop_front()
	var url: String = supabase_url + req["endpoint"]
	var body_str: String = JSON.stringify(req["body"]) if not req["body"].is_empty() else ""
	_http.request(url, _make_headers(req.get("upsert", false)), req["method"], body_str)


func _on_raw_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_busy = false
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit(result, "Network error")
		_flush()
		return
	if response_code >= 400:
		request_failed.emit(response_code, body.get_string_from_utf8())
		_flush()
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK:
		request_completed.emit(json.get_data())
	else:
		request_failed.emit(0, "JSON parse error")
	_flush()
