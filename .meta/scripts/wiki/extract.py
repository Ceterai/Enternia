import math
import wiki.load


class AbstractLib:

    def __init__(self):
        self.ext = ''

    def get_tables(self, paths: list[str]):
        raw: dict[str] = {}
        for path in paths:
            if path.endswith(f'{self.ext}.patch'):
                patch_list = wiki.load.json(path)
                raw.update(wiki.load.decode_patch_list(patch_list))
            elif wiki.load.ext(path) == self.ext:
                obj = wiki.load.json(path)
                raw.update(obj)
        return raw

    def get_path(self, patch: dict) -> str:
        return patch.get('path', '')

    def get_pathname(self, patch: dict) -> str:
        return self.get_path(patch).replace('/', '')

    def get_value(self, patch: dict, default={}) -> dict:
        return patch.get('value', default)


class CockpitLib(AbstractLib):

    def __init__(self):
        self.patches = wiki.load.get_patches(wiki.load.json(wiki.load.COCKPIT_CONFIG))
        self.tables = self.get_all_tables()
        self.weather = self.get_weather()
        print(f'- Generated {len(self.weather)} weather entries')

    def is_weather(self, path: str):
        return path[:17] == '/displayWeathers/'

    def get_all_tables(self):
        tables: dict[str] = {}
        for patch in self.patches:
            tables.update({self.get_path(patch): self.get_value(patch)})
        return tables

    def get_weather(self):
        return { k.replace('/displayWeathers/', ''): self.tables[k] for k in self.tables if self.is_weather(k)}


class ChestLib(AbstractLib):

    def __init__(self):
        self.ext = 'treasurechests'
        self.tables: dict[str, list[dict]] = self.get_tables(wiki.load.filepaths_in_dirs(wiki.load.dirs(wiki.load.LOOT_PATHS)))
        print(f'- Generated {len(self.tables)} chests')

    def get_loot(self) -> dict[str, set[dict[str, str]]]:
        return { k: { r.get('minimumLevel'): r.get('treasurePool') for r in self.tables[k] } for k in self.tables }

    def get_chests_per_loot(self, loot_table_id: str):
        chests: list[str] = []
        for chest in (chest_loot := self.get_loot()):
            for level in chest_loot[chest]:
                if chest_loot[chest][level] == loot_table_id:
                    chests.append(chest)
        return sorted(set(chests))

    def get_chests_per_loots(self, loot_table_ids: list[str]):
        chests: list[str] = []
        for loot_table_id in loot_table_ids:
            chests.extend(self.get_chests_per_loot(loot_table_id))
        return sorted(set(chests))

    def get_objs_per_chest(self):
        result = {}
        for k in self.tables:
            chests = []
            for r in self.tables[k]:
                chests.extend(r.get('containers'))
            result.update({k: chests})
        return result

    def get_objs_flat(self):
        chests = []
        for r in (k := self.get_objs_per_chest()):
            chests.extend(k[r])
        return chests

    def get_chests_per_obj(self):
        result = {}
        for k in self.tables:
            for r in self.tables[k]:
                for c in r.get('containers'):
                    result[c] = result.get(c, []) + [k]
        return result

    def get_pools_per_obj(self):
        result: dict[str, dict[str, dict[str, list[str]]]] = {}
        for k in self.tables:
            for r in self.tables[k]:
                for c in r.get('containers'):
                    result[c] = result.get(c, {})
                    result[c][k] = result[c].get(k, {})
                    result[c][k][r.get('minimumLevel')] = result[c][k].get(r.get('minimumLevel'), [])
                    result[c][k][r.get('minimumLevel')] = result[c][k][r.get('minimumLevel')] + [r.get('treasurePool')]
        return result

    def get_objs_by_chest(self, chest_uid: str) -> list[str]:
        return self.get_objs_per_chest().get(chest_uid, [])

    def get_objs_by_chests(self, chest_uids: list[str]) -> list[str]:
        obj_uids = []
        for chest_uid in chest_uids:
            obj_uids.extend(self.get_objs_by_chest(chest_uid))
        return sorted(set(obj_uids))

    def get_pools_by_obj(self, uid: str):
        return self.get_pools_per_obj().get(uid, {})

    def get_pools_by_obj_flat(self, uid: str):
        result: list[str] = []
        pools = self.get_pools_by_obj(uid)
        for chest_uid in pools:
            for level in pools[chest_uid]:
                result.extend(pools[chest_uid][level])
        return result


class RadioLib(AbstractLib):

    def __init__(self):
        self.ext = 'radiomessages'
        self.tables: dict[str, dict] = self.get_tables(wiki.load.filepaths_in_dirs(wiki.load.dirs(wiki.load.RADIO_PATHS)))
        self.msgs = {table: self.tables[table]['text'] for table in self.tables}
        print(f'- Generated {len(self.tables)} radio messages')


class ItemLib:

    def __init__(self):
        self.exts = [
            'consumable', 'item', 'object', 'activeitem', 'head', 'back', 'chest', 'legs',
            'thrownitem', 'augment', 'harvestingtool', 'miningtool', 'flashlight', 'tillingtool',
        ]
        self.id_params = [ 'itemName', 'objectName', ]
        self.defs = wiki.load.json('/items/buildscripts/alta/defaults.config')
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.ITEM_PATHS)
        self.tips = wiki.load.json('/items/buildscripts/ct_texts.config')

    def get_tables(self, paths: list[str]):
        raw: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) in self.exts:
                obj = wiki.load.json(path)
                for id_param in self.id_params:
                    if obj.get(id_param):
                        obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                        obj['build'] = obj.get('build') or {}
                        if 'builder' in obj:
                            builder = obj['builder'].replace('.lua', '').split('/')[-1]
                            if builder in self.defs:
                                obj = dict(self.merge(self.defs[builder], obj))
                            if builder == 'tool' and not obj.get('price') and not obj.get('build', {}).get('price'):
                                obj['build']['price'] = 720 if obj.get('twoHanded') else 480
                        obj = self.get_defaults(obj, obj['path'], obj.get('race'))
                        raw.update({obj[id_param]: obj})
            elif wiki.load.ext(path) == 'codex':
                obj = wiki.load.json(path)
                if obj.get('id') and obj.get('itemConfig'):
                    obj.update(obj.get('itemConfig'))
                    obj.pop('itemConfig')
                    obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                    obj = self.get_defaults(obj, obj['path'], obj.get('race'))
                    raw.update({obj['id'] + '-codex': obj})
        print(f'- Generated {len(raw)} items')
        return raw

    def merge(self, dict1: dict, dict2: dict):
        for k in set(dict1.keys()).union(dict2.keys()):
            if k in dict1 and k in dict2:
                if isinstance(dict1[k], dict) and isinstance(dict2[k], dict):
                    yield (k, dict(self.merge(dict1[k], dict2[k])))
                else:
                    yield (k, dict2[k])
            elif k in dict1:
                yield (k, dict1[k])
            else:
                yield (k, dict2[k])
    
    def get_defaults(self, config, category, race):
        config = dict(self.merge((self.defs['species'].get(race or 'default') or {}).get(category or 'default') or {}, config))
        config = dict(self.merge(self.defs['species']['default'].get(category or 'default') or {}, config))
        config = dict(self.merge(self.defs['default'], config))
        return config
    
    def get_learned_bps(self, item_id: str) -> list[str]:
        return sorted(self.raw[item_id].get('learnBlueprintsOnPickup', [])) if item_id in self.raw else []
    
    def get_bp_sources(self, item_id: str) -> list[str]:
        sources: list[str] = []
        for iid in self.raw:
            if item_id in self.get_learned_bps(iid):
                sources.append(iid)
        return sorted(sources)
    
    def get_all_bp_sources(self) -> dict[str, list[str]]:
        sources: dict[str, list[str]] = {}
        for item_id in self.raw:
            sources.update({item_id: self.get_bp_sources(item_id)})
        return {item_id: sources[item_id] for item_id in sources if sources[item_id]}
    
    def get_all_learned_bps(self) -> dict[str, list[str]]:
        sources: dict[str, list[str]] = {}
        for item_id in self.raw:
            sources.update({item_id: self.get_learned_bps(item_id)})
        return {item_id: sources[item_id] for item_id in sources if sources[item_id]}

    def get_messages(self, item_id: str) -> list[str]:
        if item_id in self.raw:
            tags = self.raw[item_id].get("itemTags", [])
            messages: list[str] = self.raw[item_id].get('radioMessagesOnPickup', [])
            for v in tags:
                if v == 'gsr': messages.append('ct_gsr_msg')
                elif v == 'set': messages.append('ct_set_msg')
                elif v == 'loot': messages.append('ct_loot_crate_msg')
                elif v == 'datamass': messages.append('ct_datamass_msg')
                elif v == 'ebook': messages.append('ct_ebook_msg')
                elif v == 'faradea': messages.append('ct_faradea_msg')
                elif v == 'haven': messages.append('ct_haven_msg')
                elif v == 'warped': messages.append('ct_warped_msg')
                elif v == 'eds': messages.append('ct_eds_msg')
                elif v == 'shield': messages.append('ct_alta_shield_msg')
                elif v == 'weapon': messages.append('ct_alta_weapon_msg')
                elif v == 'energy_shielder': messages.append('ct_energy_shielder_msg')
                elif v == 'drone' or v == 'droid': messages.append('ct_robot_spawner_msg')
            return sorted(messages)
        return []

    def get_tags(self, item_id: str) -> list[str]:
        if item_id in self.raw and self.raw[item_id].get("itemTags"):
            tags: list[str] = self.raw[item_id].get("itemTags", [])
            tags.extend([self.raw[item_id].get("race"), (self.get_rarity(item_id) or '').lower(), self.raw[item_id].get("elementalType")])
            return sorted(set([tag for tag in tags if tag]))
        return []

    def get_colony_tags(self, item_id: str) -> list[str]:
        if item_id in self.raw and self.raw[item_id].get("colonyTags"):
            tags: list[str] = self.raw[item_id].get("colonyTags", [])
            tags.extend([self.raw[item_id].get("race"), (self.get_rarity(item_id) or '').lower(), self.raw[item_id].get("elementalType")])
            return sorted(set([tag for tag in tags if tag]))
        return []

    def get_level(self, item_id: str) -> str|None:
        if item_id in self.raw:
            return self.raw[item_id].get("level", 0)

    def get_rarity(self, item_id: str) -> str|None:
        if item_id in self.raw:
            return self.raw[item_id].get("rarity") or self.tips['rarityTypes'][str(self.get_level(item_id))]

    def get_icon(self, item_id: str) -> str|None:
        if item_id in self.raw:
            icon: str = self.raw[item_id].get("inventoryIcon", self.raw[item_id].get("icon")) or self.raw[item_id].get("animationParts", {}).get("blade")
            if icon and not icon.startswith('/'):
                icon = wiki.load.os.path.dirname(self.raw[item_id]['path']) + '/' + icon
            return icon

    def get_bonus(self, item_id: str) -> str|None:
        if item_id in self.raw:
            return self.raw[item_id].get("shortdescription", self.raw[item_id].get("title", "")).count("")
        return 0

    def get_upgrade(self, item_id: str) -> bool|None:
        if item_id in self.raw:
            return bool(self.raw[item_id].get("upgradeParameters"))

    def get_price(self, item_id: str) -> str|None:
        if item_id in self.raw:
            price = self.raw[item_id].get("price") or self.raw[item_id].get("build", {}).get("price")
            if not self.raw[item_id].get("fixedPrice", False):
                price = price * (0.5 * self.get_level(item_id) + 0.5)
                price = price + (math.floor((price / 100) + 0.5) * 10 * self.get_bonus(item_id))
            return round(price)

    def get_power(self, item_id: str) -> str|None:
        if item_id in self.raw:
            return round(self.raw[item_id].get('power', (
                (self.get_price(item_id) or 1) / (self.raw[item_id].get("price") or self.raw[item_id].get("build", {}).get("price") or (self.get_price(item_id) or 1))
            )), 2)
    
    def get_reward_bags_by_loot_id(self, loot_id: str):
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get("treasure", {}).get("pool"):
                if self.raw[item].get("treasure", {}).get("pool") == loot_id:
                    items.append(item)
        return sorted(set(items))
    
    def get_shops_by_item_id(self, item_id: str):
        items: list[str] = []
        for item in self.raw:
            if type(self.raw[item].get("interactData")) == dict:
                if self.raw[item].get("interactData", {}).get("items"):
                    for entry in self.raw[item].get("interactData", {}).get("items"):
                        if entry.get("item") == item_id:
                            items.append(item)
        return sorted(set(items))

    def get_breakables_by_item_id(self, item_id: str) -> list[list]:
        items: list[str] = []
        for item in self.raw:
            drops = self.raw[item].get('breakDropOptions', []) + self.raw[item].get('smashDropOptions', [])
            for option in drops:
                for drop in option:
                    if drop[0] == item_id:
                            items.append(item)
        return sorted(set(items))

    def get_breakables_by_loot_id(self, loot_id: str) -> list[list]:
        items: list[str] = []
        for item in self.raw:
            drops = [self.raw[item].get('breakDropPool'), self.raw[item].get('smashDropPool')]
            for option in drops:
                if option == loot_id:
                    items.append(item)
        return sorted(set(items))

    def get_crops_by_loot_id(self, loot_id: str) -> list[list]:
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('stages'):
                if self.raw[item].get('stages')[-1].get('harvestPool') == loot_id:
                    items.append(item)
        return sorted(set(items))
    
    def get_saplings_by_tree_ids(self, tree_part_ids: list[str]):
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get("treePool"):
                for entry in self.raw[item]["treePool"]:
                    if entry.get('fixedStem') in tree_part_ids or entry.get('fixedFoliage') in tree_part_ids:
                        items.append(item)
            else:
                if self.raw[item].get('fixedStem') in tree_part_ids or self.raw[item].get('fixedFoliage') in tree_part_ids:
                    items.append(item)
        return sorted(set(items))


class TenantLib(AbstractLib):

    def __init__(self):
        self.ext = 'tenant'
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.LOOT_PATHS)

    def get_tables(self, paths: list[str]):
        raw: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) == self.ext:
                obj = wiki.load.json(path)
                obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                raw.update({obj['name']: obj})
        print(f'- Generated {len(raw)} tenants')
        return raw

    def get_tenants_by_rent_loot_id(self, loot_id: str) -> list[list]:
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('rent'):
                if self.raw[item].get('rent').get('pool') == loot_id:
                    items.append(item)
        return sorted(set(items))


class NPCLib(AbstractLib):

    def __init__(self):
        self.ext = 'npctype'
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.LOOT_PATHS)
        self.apply_bases()
    
    def apply_bases(self):
        while self.check_bases_exist():
            for npc in self.raw:
                if 'baseType' in self.raw[npc] and self.raw[npc]['baseType'] in self.raw:
                    base = self.raw[npc].pop('baseType')
                    self.raw[npc] = dict(self.merge(self.raw[base], self.raw[npc]))
                    self.raw[npc]['type'] = npc

    def check_bases_exist(self):
        for npc in self.raw:
            if 'baseType' in self.raw[npc] and self.raw[npc]['baseType'] in self.raw:
                return True

    def merge(self, dict1: dict, dict2: dict):
        for k in set(dict1.keys()).union(dict2.keys()):
            if k in dict1 and k in dict2:
                if isinstance(dict1[k], dict) and isinstance(dict2[k], dict):
                    yield (k, dict(self.merge(dict1[k], dict2[k])))
                else:
                    yield (k, dict2[k])
            elif k in dict1:
                yield (k, dict1[k])
            else:
                yield (k, dict2[k])

    def get_tables(self, paths: list[str]):
        raw: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) == self.ext:
                obj = wiki.load.json(path)
                obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                raw.update({obj['type']: obj})
        print(f'- Generated {len(raw)} npcs')
        return raw

    def get_npcs_by_loot_id(self, loot_id: str) -> list[list]:
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('dropPools'):
                if self.raw[item].get('dropPools')[0].get('default') == loot_id:
                    items.append(item)
        return sorted(set(items))

    def get_npcs_by_shop_item_id(self, item_id: str) -> list[list]:
        npcs: list[str] = []
        for item in self.raw:
            shop = None
            if self.raw[item].get('scriptConfig'):
                if self.raw[item]['scriptConfig'].get('merchant'):
                    if self.raw[item]['scriptConfig']['merchant'].get('poolsFile'):
                        shop = wiki.load.json(self.raw[item]['scriptConfig']['merchant']['poolsFile'])
            if shop:
                if self.raw[item]['scriptConfig']['merchant'].get('categories'):
                    if self.raw[item]['scriptConfig']['merchant']['categories'].get('default'):
                        for category in self.raw[item]['scriptConfig']['merchant']['categories']['default']:
                            for leveled in shop[category]:
                                for entry in leveled[1]:
                                    if type(entry['item']) == str and entry['item'] == item_id:
                                        npcs.append(item)
                                    elif type(entry['item']) == dict and entry['item']['name'] == item_id:
                                        npcs.append(item)
        return sorted(set(npcs))


class MonsterLib(AbstractLib):

    def __init__(self):
        self.ext = 'monstertype'
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.LOOT_PATHS)

    def get_tables(self, paths: list[str]):
        raw: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) == self.ext:
                obj = wiki.load.json(path)
                obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                raw.update({obj['type']: obj})
        print(f'- Generated {len(raw)} monsters')
        return raw

    def get_by_loot_id(self, loot_id: str, loot_type: str) -> list[list]:
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('dropPools'):
                if self.raw[item].get('dropPools')[0].get(loot_type) == loot_id:
                    items.append(item)
        return sorted(items)


class TreeLib:

    def __init__(self):
        self.exts = [
            'modularstem', 'modularfoliage',
        ]
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.ITEM_PATHS)

    def get_tables(self, paths: list[str]):
        raw: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) in self.exts:
                obj = wiki.load.json(path)
                if obj.get('name'):
                    obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                    raw.update({obj['name']: obj})
        print(f'- Generated {len(raw)} tree parts')
        return raw

    def get_by_item_id(self, item_id: str) -> list[list]:
        items: list[str] = []
        for item in self.raw:
            drops = self.raw[item].get('dropConfig', {}).get('drops', [])
            for option in drops:
                for drop in option:
                    if drop['item'] == item_id:
                        items.append(item)
        return sorted(set(items))





class Item:

    def __init__(self, item: dict|list|str):
        try:
            if type(item) == dict:  # Always the case with recipes, but not always with loot
                self._parse(str(item['item']), int(item.get('count', 1)), dict(item.get('parameters', {})))
            elif type(item) == list:
                self._parse(str(item[0]), int(item[1] if len(item) > 1 else 1), dict(item[2] if len(item) > 2 else {}))
            else:
                self._parse(str(item), 1, {})
            self.raw = item
        except Exception as e:
            print(f'Can\'t parse item descriptor: {item}')
            raise e

    def _parse(self, uid: str, n: int, params: dict):
        self.uid = uid
        self.n = n
        self.params = params


class LootEntry(Item):

    def __init__(self, loot_entry: dict, weight_default=0.0):
        self.is_pool = bool(loot_entry.get('pool'))
        self.weight = str(loot_entry.get('weight', weight_default))
        super().__init__(loot_entry.get('item') or loot_entry.get('pool'))
        self.raw = loot_entry


class Loot:

    def __init__(self, loot: list):
        try:
            self.level = int(loot[0])
            self.values = dict(loot[1])
            self.pool_raw: tuple[dict] = tuple(self.values.get('pool', []))
            self.fill_raw: tuple[dict] = tuple(self.values.get('fill', []))
            self.pool = tuple(LootEntry(pool) for pool in self.pool_raw)
            self.fill = tuple(LootEntry(fill, 'always present') for fill in self.fill_raw)
            self.all = self.pool + self.fill
            self.rounds: tuple[tuple[float, int]] = tuple(self.values.get('poolRounds', []))
            self.raw = loot
        except Exception as e:
            print(f'Can\'t parse loot table: {loot}')
            raise e


class LootTable:

    def __init__(self, loot_list: list):
        try:
            self.entries_raw = tuple(loot for loot in loot_list if type(loot) == list)
            self.entries = tuple(Loot(loot) for loot in self.entries_raw)
            self.raw = loot_list
        except Exception as e:
            print(f'Can\'t parse loot list: {loot_list}')
            raise e


class LootLib(AbstractLib):

    def __init__(self):
        try:
            self.ext = 'treasurepools'
            self.tables_raw: dict[str, list[tuple[int, dict]]] = self.get_tables(wiki.load.filepaths_in_dirs(wiki.load.dirs(wiki.load.LOOT_PATHS)))
            self.tables = {str(key): LootTable(self.tables_raw[key]) for key in self.tables_raw}
            self.tables = {key: self.tables[key] for key in self.tables if self.tables[key].entries}
            print(f'- Generated {len(self.tables)} loot tables ({len(self.tables_raw)} entries total found, including chests)')
        except Exception as e:
            print(f'Can\'t parse loot library: {self.tables}')
            raise e

    # Sources

    def find_loot_that_drops_obj(self, obj_uid: str, top_level = False) -> list[str]:
        result = []
        for table in self.tables:
            result.extend(self.find_loot_that_drops_obj_inner(obj_uid, table, top_level))
        return sorted(set(result))

    def find_loot_that_drops_obj_inner(self, obj_uid: str, table: str, top_level = False) -> list[str]:
        result = []
        if table in self.tables:
            for loot in self.tables[table].entries:
                source_uid = None
                for f in loot.all:
                    if obj_uid == f.uid:
                        source_uid = table
                        break
                    elif not top_level and f.is_pool:
                        if self.find_loot_that_drops_obj_inner(obj_uid, f.uid):
                            source_uid = table
                            break
                if source_uid:
                    result.append(source_uid)
                    break
        return result

    # Alternative

    def find_pool_uids_of_obj(self, loot_uids: list[str]):
        result = []
        for loot_uid in loot_uids:
            if loot_uid in self.tables:
                for loot in self.tables[loot_uid].entries:
                    for f in loot.all:
                        if f.is_pool and f.uid in self.tables:
                            result.extend(self.find_pool_uids_of_obj([f.uid]))
        return list(set(result + loot_uids))

    def get_tree_loot_raw(self, obj: dict) -> list[list]:
        return dict(obj.get('dropConfig', {})).get('drops', [])

    def get_tree_loot(self, obj: dict):
        return tuple(tuple(Item(item) for item in option) for option in self.get_tree_loot_raw(obj))

    def get_object_loot_raw(self, obj: dict) -> list[list]:
        return obj.get('breakDropOptions', []) + obj.get('smashDropOptions', [])

    def get_object_loot(self, obj: dict):
        return tuple(tuple(Item(item) for item in option) for option in self.get_object_loot_raw(obj))

    def find_obj_loot_of_obj(self, obj: dict):
        result: dict[str, LootTable] = {}
        for i, option in enumerate(self.get_object_loot(obj)):
            result.update({f'drop option {i + 1}': LootTable([[0, {'pool': [{'weight':1.0,'item':[item.uid, item.n]} for item in option]}]])})
        return result

    def find_obj_loot_of_obj_raw(self, obj: dict):
        result = self.find_obj_loot_of_obj(obj)
        return {k: result[k].raw for k in result}

    # Loot

    def find_loot_of_obj(self, loot_uids: dict[str, str]):
        result: dict[str, LootTable] = {}
        for name in loot_uids:
            for table_uid in self.tables:
                if loot_uids[name] == table_uid:
                    result[name] = self.tables[table_uid]
        return result

    def find_first_option(self, uid: str, items: list[Item]):
        for item in items:
            if uid == item.uid:
                return item.uid
