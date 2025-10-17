import json
import wiki.load
import wiki.extract


items = wiki.extract.ItemLib()
loot = wiki.extract.LootLib()
chests = wiki.extract.ChestLib()
recipes = wiki.extract.RecipeLib()
recipes2: dict[str, list[str]] = wiki.load.json('/data/FullDatabase.database.patch')[0]['value']
tenants = wiki.extract.TenantLib()
npcs = wiki.extract.NPCLib()
monsters = wiki.extract.MonsterLib()
trees = wiki.extract.TreeLib()
msgs = wiki.extract.RadioLib()
effects = wiki.extract.EffectLib()
weather = wiki.extract.CockpitLib()
biomes = wiki.extract.BiomeLib()
shops = wiki.extract.ShopLib(items)


def generate_data():

    def many(method, uids: list[str], **kwargs):
        result_items: list[str] = []
        for uid in uids:
            result_items.extend(method(uid, **kwargs))
        return sorted(set(result_items))

    def many_levels(method, uids: dict, **kwargs):
        result_items: list[str] = []
        for uid in uids:
            result_items.extend(method(uid, levels=uids[uid], **kwargs))
        return sorted(set(result_items))

    def get_item_info(item_id):
        return {
            'path': (p := items.raw[item_id]['path'] if item_id in items.raw else None),
            'rarity': items.get_rarity(item_id),
            'power': items.get_power(item_id),
            'price': items.get_price(item_id),
            'icon': items.get_icon(item_id),
            'upgrade': items.get_upgrade(item_id),
            'downgrade': items.get_downgrade(item_id),
            'tags': items.get_tags(item_id),
            'colony': items.get_colony_tags(item_id),
            'unlocks_bps': items.get_learned_bps(item_id),
            'unlocked_by': items.get_bp_sources(item_id),
            'pickup_msgs': items.get_messages(item_id),
            'used_in_recipes': recipes2['recipeDatabase'].get(item_id, []),
            'loot': {
                # 'drops': loot.find_obj_loot_of_obj_raw(items.raw[item_id]),  # for objects
                'tree_drops': [],  # for grown tree saplings (both stem and leaves)
                'produces': [],  # crops
                'rewards': [],
                'ferments': [],
                'sells': [],
            },
            'sources': {
                'crafting': [],
                'tables_explicit': list(loot.find_loot_that_drops_obj(item_id, True)),
                'tables': list((l := loot.find_loot_that_drops_obj(item_id))),
                'chests': (c := chests.get_chests_per_loots(l)),
                'chest_objects': chests.get_objs_by_chests(c),
                'shops': items.get_shops_by_item_id(item_id),
                'merchants': (m := npcs.get_npcs_by_shop_item_id(item_id)),
                'merchant_tenants': many(tenants.get_tenants_by_npc_id, m),
                'rent': many(tenants.get_tenants_by_rent_loot_id, l),
                'monsters': many(monsters.get_by_loot_id, l, loot_type='default'),
                'monsters_hunt': many(monsters.get_by_loot_id, l, loot_type='bow'),
                'monsters_bugnet': many(monsters.get_by_loot_id, l, loot_type='bugnet'),
                'npcs': (n := many(npcs.get_npcs_by_loot_id, l)),
                'npc_tenants': many(tenants.get_tenants_by_npc_id, n),
                'rewards': many_levels(items.get_reward_bags_by_loot_id, l),
                'trees': (t := trees.get_by_item_id(item_id)),
                'tree_saplings': items.get_saplings_by_tree_ids(t),
                'breakables': items.get_breakables_by_item_id(item_id),
                'breakables_pools': many(items.get_breakables_by_loot_id, l),
                'crops': many(items.get_crops_by_loot_id, l),
            },
        }

    def cleanup(db: dict):
        return {
            i: {
                j: (db[i][j] if type(db[i][j]) != dict else {
                    k: db[i][j][k]
                    for k in db[i][j] if db[i][j][k]
                })
                for j in db[i] if db[i][j]
            }
            for i in db
        }

    result = dict(sorted({item_id: get_item_info(item_id) for item_id in items.raw}.items()))
    # Vanilla Items
    more_ids: list[str] = []
    for item_id in items.raw:
        more_ids.extend(recipes2.get(item_id, []))
        more_ids.extend(items.get_learned_bps(item_id))
    more_ids = sorted(set(uid for uid in more_ids if uid not in items.raw.keys() and not uid.startswith('ct_')))
    more = dict(sorted({item_id: get_item_info(item_id) for item_id in more_ids}.items()))

    # Tenants
    result_tenants: dict[str, dict[str, list]] = { }
    for tenant_id in tenants.raw:
        result_tenants[tenant_id] = {
            'path': (tenants.raw[tenant_id]['path'] if tenant_id in tenants.raw else None),
            'visits_outpost': npcs.raw.get(tenants.raw[tenant_id]['type'], {}).get('visits_outpost', False),
        }

    # Effects
    result_effects: dict[str, dict[str, list]] = { }
    for effect_id in effects.raw:
        result_effects[effect_id] = {
            'path': (effects.raw[effect_id]['path'] if effect_id in effects.raw else None),
            'icon': effects.get_icon(effect_id),
            'items': items.get_items_by_effect_id(effect_id),
        }

    # Biomes
    result_biomes: dict[str, dict[str, list]] = { }
    for biome_id in biomes.raw:
        result_biomes[biome_id] = {
            'path': (biomes.raw[biome_id]['path'] if biome_id in biomes.raw else None),
        }

    # Cleanup
    for i in range(2):
        result = cleanup(result)
        more = cleanup(more)
        result_tenants = cleanup(result_tenants)
        result_effects = cleanup(result_effects)
        result_biomes = cleanup(result_biomes)

    # Tags
    tags: dict[str, dict[str, list]] = { }
    for item_id in items.raw:
        for tag in items.get_tags(item_id):
            if tag in tags:
                tags[tag]['items'].append(item_id)
                tags[tag]['items'] = sorted(tags[tag]['items'])
            else:
                tags[tag] = {'items': [item_id], 'objects': [], 'tenants': []}
        for tag in items.get_colony_tags(item_id):
            if tag in tags:
                tags[tag]['objects'].append(item_id)
                tags[tag]['objects'] = sorted(tags[tag]['objects'])
            else:
                tags[tag] = {'items': [], 'objects': [item_id], 'tenants': []}
    for tenant_id in tenants.raw:
        for tag in tenants.raw[tenant_id]['colonyTagCriteria']:
            if tag in tags:
                tags[tag]['tenants'].append(tenant_id)
                tags[tag]['tenants'] = sorted(tags[tag]['tenants'])
            else:
                tags[tag] = {'items': [], 'objects': [], 'tenants': [tenant_id]}
    print(f'Found {len(tags)} unique tags.')
    return {'items': result, 'vanilla_items': more, 'tenants': result_tenants, 'effects': result_effects, 'tags': dict(sorted(tags.items())), 'biomes': result_biomes}


def run():

    result = generate_data()

    affected_files = [wiki.load.ROOT + '/data/alta_database.json']
    with open(wiki.load.ROOT + '/data/alta_database.json', 'w', encoding="utf-8") as db:
        db.write('// Alta Universal Information & Knowledge Accumulation (Alta UIKA)\n')
        db.write('// A system that shows where an item comes from and where it can be used. Added in 2.3.4e.\n')
        json.dump(result, db, indent=4, ensure_ascii=False)
        db.write('\n')
    
    return result, affected_files
    
