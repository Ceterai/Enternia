import json
import wiki.load
import wiki.extract


def run():
    items = wiki.extract.ItemLib()
    loot = wiki.extract.LootLib()
    chests = wiki.extract.ChestLib()
    recipes: dict[str, list[str]] = wiki.load.json('/data/FullDatabase.database.patch')[0]['value']['recipeDatabase']
    tenants = wiki.extract.TenantLib()
    npcs = wiki.extract.NPCLib()
    monsters = wiki.extract.MonsterLib()
    trees = wiki.extract.TreeLib()

    def many(method, uids: list[str], **kwargs):
        items: list[str] = []
        for uid in uids:
            items.extend(method(uid, **kwargs))
        return sorted(set(items))

    def get_item_info(item_id):
        return {
            'path': (p := items.raw[item_id]['path'] if item_id in items.raw else None),
            'rarity': items.get_rarity(item_id),
            'power': items.get_power(item_id),
            'price': items.get_price(item_id),
            'icon': items.get_icon(item_id),
            'upgradeable': items.get_upgrade(item_id),
            'tags': items.get_tags(item_id),
            'colony': items.get_colony_tags(item_id),
            'unlocks_bps': items.get_learned_bps(item_id),
            'unlocked_by': items.get_bp_sources(item_id),
            'pickup_msgs': items.get_messages(item_id),
            'used_in_recipes': recipes.get(item_id, []),
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
                'tables_explicit': loot.find_loot_that_drops_obj(item_id, True),
                'tables': (l := loot.find_loot_that_drops_obj(item_id)),
                'chests': (c := chests.get_chests_per_loots(l)),
                'chest_objects': chests.get_objs_by_chests(c),
                'shops': items.get_shops_by_item_id(item_id),
                'merchants': npcs.get_npcs_by_shop_item_id(item_id),
                'rent': many(tenants.get_tenants_by_rent_loot_id, l),
                'monsters': many(monsters.get_by_loot_id, l, loot_type='default'),
                'monsters_hunt': many(monsters.get_by_loot_id, l, loot_type='bow'),
                'monsters_bugnet': many(monsters.get_by_loot_id, l, loot_type='bugnet'),
                'npcs': many(npcs.get_npcs_by_loot_id, l),
                'rewards': many(items.get_reward_bags_by_loot_id, l),
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
    more_ids: list[str] = []
    for item_id in items.raw:
        more_ids.extend(recipes.get(item_id, []))
        more_ids.extend(items.get_learned_bps(item_id))
    more_ids = sorted(set(uid for uid in more_ids if uid not in items.raw.keys() and not uid.startswith('ct_')))
    more = dict(sorted({item_id: get_item_info(item_id) for item_id in more_ids}.items()))
    # Cleanup
    result = cleanup(result)
    more = cleanup(more)

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
    result = {'items': result, 'vanilla_items': more, 'tags': dict(sorted(tags.items()))}


    with open(wiki.load.ROOT + '/data/alta_database.json', 'w', encoding="utf-8") as db:
        db.write('// Alta Universal Information & Knowledge Accumulation (Alta UIKA)\n')
        db.write('// A system that shows where an item comes from and where it can be used. Added in 2.3.4e.\n')
        json.dump(result, db, indent=4, ensure_ascii=False)
        db.write('\n')
