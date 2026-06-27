-- =============================================================
-- เทพปกรณัม — schema_gacha_v1.sql
-- gacha_pull RPC — server-authoritative pull with pity
-- รันหลัง schema_core_v2.sql (ต้องมี items และ player_items ก่อน)
-- =============================================================

create or replace function public.gacha_pull(
  p_player_id uuid,
  p_count     int default 1
) returns jsonb language plpgsql security definer as $$
declare
  v_player    public.players;
  v_cost      int;
  v_pity      int;
  v_items     jsonb := '[]'::jsonb;
  v_item      public.items;
  v_rarity    text;
  v_roll      float;
  v_acc       float;
  i           int;
  v_inserted  uuid;
begin
  -- Auth check
  if auth.uid() is null then
    raise exception 'Unauthorized';
  end if;

  -- Validate count
  if p_count not in (1, 10) then
    raise exception 'count must be 1 or 10';
  end if;

  -- Load player
  select * into v_player from public.players
    where id = p_player_id and user_id = auth.uid();
  if not found then
    raise exception 'Player not found';
  end if;

  -- Cost check
  v_cost := case when p_count = 1 then 100 else 900 end;
  if v_player.gems < v_cost then
    raise exception 'Not enough gems (need %, have %)', v_cost, v_player.gems;
  end if;

  -- Deduct gems
  update public.players
    set gems = gems - v_cost, updated_at = now()
    where id = p_player_id;

  v_pity := v_player.gacha_pity;

  -- Pull loop
  for i in 1..p_count loop
    -- Roll rarity
    if v_pity >= 49 then
      -- Pity guaranteed epic+
      v_roll := random() * 100.0;
      if    v_roll < 75.0  then v_rarity := 'epic';
      elsif v_roll < 95.0  then v_rarity := 'legendary';
      else                      v_rarity := 'mythic';
      end if;
    else
      v_roll := random() * 100.0;
      if    v_roll < 45.0  then v_rarity := 'common';
      elsif v_roll < 70.0  then v_rarity := 'uncommon';
      elsif v_roll < 88.0  then v_rarity := 'rare';
      elsif v_roll < 97.0  then v_rarity := 'epic';
      elsif v_roll < 99.7  then v_rarity := 'legendary';
      else                      v_rarity := 'mythic';
      end if;
    end if;

    v_pity := v_pity + 1;
    if v_rarity in ('epic', 'legendary', 'mythic') then
      v_pity := 0;
    end if;

    -- Pick random item of this rarity (gacha-eligible types)
    select * into v_item from public.items
      where rarity = v_rarity
        and item_type in ('skill_node', 'weapon', 'armor', 'rune', 'ore')
      order by random()
      limit 1;

    if not found then
      -- Fallback to common if no item at this rarity exists yet
      select * into v_item from public.items
        where rarity = 'common'
          and item_type in ('skill_node', 'weapon', 'armor', 'rune', 'ore')
        order by random()
        limit 1;
    end if;

    if found then
      -- Add to player inventory
      insert into public.player_items (player_id, item_id, quantity, is_identified, storage_type)
        values (p_player_id, v_item.id, 1, false, 'bag')
        returning id into v_inserted;

      v_items := v_items || jsonb_build_object(
        'player_item_id', v_inserted,
        'item_id',    v_item.id,
        'name_th',    v_item.name_th,
        'name_en',    v_item.name_en,
        'item_type',  v_item.item_type,
        'rarity',     v_item.rarity
      );
    end if;
  end loop;

  -- Save updated pity
  update public.players
    set gacha_pity = v_pity, updated_at = now()
    where id = p_player_id;

  return jsonb_build_object(
    'items',          v_items,
    'pity',           v_pity,
    'gems_remaining', v_player.gems - v_cost
  );
end;
$$;

grant execute on function public.gacha_pull to authenticated;
