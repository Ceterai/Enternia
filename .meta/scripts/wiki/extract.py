import math
import wiki.load
from wiki.pages.urls import RECIPE_SOURCES, RECIPE_SOURCES_ADMIN


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
    """
    CockpitLib is a library for extracting and managing cockpit configuration data, specifically focused on weather entries, from Starbound mod files.
    Attributes:
        patches (list): List of patch data loaded from the cockpit configuration.
        tables (dict): Dictionary mapping configuration paths to their values.
        weather (dict): Dictionary of weather entries extracted from the configuration.
    """

    def __init__(self):
        self.ext = 'weather'
        self.patches = wiki.load.get_patches(wiki.load.json(wiki.load.COCKPIT_CONFIG))
        self.tables = self.get_all_tables()
        
        self.weather_objects: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(wiki.load.LOOT_PATHS)):
            if wiki.load.ext(path) == self.ext:
                obj = wiki.load.json(path)
                self.weather_objects[obj['name']] = obj
                self.weather_objects[obj['name']]['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
        self.weather = self.get_weather()
        print(f'- Generated {len(self.weather)} weather entries')

    def is_weather(self, path: str):
        return path[:len('/displayWeathers/')] == '/displayWeathers/'

    def get_all_tables(self):
        tables: dict[str] = {}
        for patch in self.patches:
            tables.update({self.get_path(patch): self.get_value(patch)})
        return tables

    def get_weather(self):
        weather: dict[str, dict] = {k.replace('/displayWeathers/', ''): self.tables[k] for k in self.tables if self.is_weather(k)}
        for key in self.weather_objects:
            if self.weather_objects[key]['name'] in weather:
                weather[self.weather_objects[key]['name']].update(self.weather_objects[key])
        return weather
    
    def get_weather_by_effect_id(self, effect_id: str) -> list[str]:
        result = []
        for weather_id in self.weather:
            if effect_id in self.weather[weather_id].get('statusEffects', []):
                result.append(weather_id)
        return sorted(set(result))


class ChestLib(AbstractLib):
    """
    A utility class for extracting and organizing chest and loot table data from Starbound mod files.
    """

    def __init__(self):
        self.ext = 'treasurechests'
        self.tables: dict[str, list[dict]] = self.get_tables(wiki.load.filepaths_in_dirs(wiki.load.dirs(wiki.load.LOOT_PATHS)))
        print(f'- Generated {len(self.tables)} chests')

    def get_loot(self) -> dict[str, dict[str]]:
        return { k: { r['minimumLevel']: r['treasurePool'] for r in self.tables[k] } for k in self.tables }

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
                chests.extend(r['containers'])
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
                for c in r['containers']:
                    result[c] = result.get(c, []) + [k]
        return result

    def get_pools_per_obj(self):
        result: dict[str, dict[str, dict[str, list[str]]]] = {}
        for k in self.tables:
            for r in self.tables[k]:
                for c in r['containers']:
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
    """
    A library responsible for loading and managing radio message tables.
    Attributes:
        ext (str): The file extension associated with radio message files.
        tables (dict[str, dict]): A dictionary mapping table names to their corresponding data, loaded from specified directories.
        msgs (dict[str, str]): A dictionary mapping table names to their 'text' field extracted from the loaded tables.
    """

    def __init__(self):
        self.ext = 'radiomessages'
        self.tables: dict[str, dict] = self.get_tables(wiki.load.filepaths_in_dirs(wiki.load.dirs(wiki.load.RADIO_PATHS)))
        self.msgs = {table: self.tables[table]['text'] for table in self.tables}
        self.msgs.update({
            'pickupseed': "I see that you've discovered some seeds. I suggest planting them in some tilled soil, and watering them until they grow. The tools you need can be built at a foraging table.",
            'pickupflag': "I am able to reconfigure the ship's teleporter to teleport directly to the location marked by this flag. Place and interact with the flag to establish a name.",
            'pickupcoal': "You discovered coal! You can turn coal into torches to light your way. The chance of fatal incidents is dramatically increased in the dark. Explore the crafting menu.",
            'pickupore': "You discovered some ore. Ore can be turned into bars using a furnace, bars are useful for crafting a wide range of equipment that may increase your life expectancy.",
            'pickupcorefrag': "You discovered a core fragment! These are useful objects. I estimate that you will require at least 20 of them.",
            'pickupplantfibre': "You discovered some plant fibre. This can be woven into useful fabrics at a spinning wheel.",
            'pickupdye': "You discovered dye. With these you can colour your attire to your liking. You can apply one to any piece of armour or clothing with a right-click.",
            'pickupepp': "You obtained an Enviro Protection Pack (EPP). These specialised devices enable the user to survive in otherwise inhospitable environments. You can also enhance EPPs with augments.",
            'pickupaugment': "You obtained an augment. These modules can provide a wide range of benefits. Install them to an Enviro Protection Pack (EPP) with a right-click.",
            'pickupcollar': "You discovered a collar. When worn by a tamed monster, these collars can provide a wide range of benefits. You can add them to a filled capture pod with a right-click.",
        })
        print(f'- Generated {len(self.tables)} radio messages')

    def get_msgs(self, tables: list[str]) -> list[str]:
        msgs = [self.msgs[table] for table in tables if table in self.msgs]
        return msgs


class ItemLib:
    """
    A utility class for loading, processing, and querying Starbound item data for wiki extraction and analysis.
    Attributes:
        exts (list[str]): List of supported item file extensions/types.
        id_params (list[str]): List of keys used to identify items.
        defs (dict): Default configuration definitions loaded from JSON.
        raw (dict[str, dict]): Dictionary mapping item IDs to their raw data.
        tips (dict): Dictionary of tips and text data loaded from JSON.
    """

    def __init__(self):
        """Initializes the ItemLib instance, loading item definitions and data."""
        self.exts = [
            'consumable', 'item', 'object', 'activeitem', 'head', 'back', 'chest', 'legs',
            'thrownitem', 'augment', 'harvestingtool', 'miningtool', 'flashlight', 'tillingtool',
        ]
        self.id_params = [ 'itemName', 'objectName', ]
        self.defs = wiki.load.json('/items/buildscripts/alta/defaults.config')
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.ITEM_PATHS)
        self.tips = wiki.load.json('/items/buildscripts/ct_texts.config')

    def get_tables(self, paths: list[str]):
        """Loads and processes item data from the given file paths."""
        raw: dict[str, dict] = {}
        raw2: dict[str, dict] = {}
        fertilizers = wiki.load.json('/xrc_fertilizer.config.patch')
        fertilizers = {e[1]['path'][1:]: e[1]['value'] for e in fertilizers}
        transmutations = wiki.load.json('/EES_transmutationstudylist.config.patch')
        transmutations = [e['path'][1:].split('/') for e in transmutations]
        transmutations = {e[2]: e[0] + e[1] for e in transmutations}
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
                            if builder == 'tool' and 'price' not in obj and 'price' not in obj.get('build', {}):
                                obj['build']['price'] = 720 if obj.get('twoHanded') else 480
                        obj = self.get_defaults(obj, obj['path'], obj.get('race'))
                        if obj[id_param] in fertilizers:
                            obj['growing_tray_value'] = fertilizers[obj[id_param]]
                        if obj[id_param] in transmutations:
                            obj['transmutation'] = transmutations[obj[id_param]]
                        raw.update({obj[id_param]: obj})
                        if 'presets' in obj:
                            for preset in obj['presets']:
                                obj2 = dict(self.merge(obj, obj['presets'][preset]))
                                obj2.pop('presets')
                                if 'variants' in obj2:
                                    obj2.pop('variants')
                                raw2.update({obj2[id_param] + '-' + preset: obj2})
                                if 'upgradeParameters' in obj2:
                                    obj3 = dict(self.merge(obj2, obj2['upgradeParameters']))
                                    obj3.pop('upgradeParameters')
                                    obj3['level'] = 6
                                    raw2.update({obj3[id_param] + '-upgrade': obj3})
                        if 'upgradeParameters' in obj:
                            obj2 = dict(self.merge(obj, obj['upgradeParameters']))
                            obj2.pop('upgradeParameters')
                            obj2['level'] = 6
                            raw2.update({obj2[id_param] + '-upgrade': obj2})
            elif wiki.load.ext(path) == 'codex':
                obj = wiki.load.json(path)
                if obj.get('id') and obj.get('itemConfig'):
                    obj.update(obj.get('itemConfig'))
                    obj.pop('itemConfig')
                    obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                    obj['shortdescription'] = obj['title']
                    obj.pop('title')
                    obj = self.get_defaults(obj, obj['path'], obj.get('race'))
                    raw.update({obj['id'] + '-codex': obj})
        print(f'- Generated {len(raw)} items')
        print(f'- Generated {len(raw2)} item variations')
        raw.update(raw2)
        print(f'- Generated {len(raw)} items total')
        return raw

    def merge(self, dict1: dict, dict2: dict):
        """Recursively merges two dictionaries, with dict2 values taking precedence."""
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
        """Applies default values to an item config based on category and race."""
        config = dict(self.merge((self.defs['species'].get(race or 'default') or {}).get(category or 'default') or {}, config))
        config = dict(self.merge(self.defs['species']['default'].get(category or 'default') or {}, config))
        config = dict(self.merge(self.defs['default'], config))
        return config
    
    def get_learned_bps(self, item_id: str) -> list[str]:
        """Returns a sorted list of blueprint IDs learned when picking up the given item."""
        return sorted(self.raw[item_id].get('learnBlueprintsOnPickup', [])) if item_id in self.raw else []
    
    def get_bp_sources(self, item_id: str) -> list[str]:
        """Returns a sorted list of item IDs that teach the given blueprint on pickup."""
        sources: list[str] = []
        for iid in self.raw:
            if item_id in self.get_learned_bps(iid):
                sources.append(iid)
        return sorted(sources)
    
    def get_all_bp_sources(self) -> dict[str, list[str]]:
        """Returns a dictionary mapping blueprint IDs to lists of items that teach them."""
        sources: dict[str, list[str]] = {}
        for item_id in self.raw:
            sources.update({item_id: self.get_bp_sources(item_id)})
        return {item_id: sources[item_id] for item_id in sources if sources[item_id]}
    
    def get_all_learned_bps(self) -> dict[str, list[str]]:
        """Returns a dictionary mapping item IDs to lists of blueprints learned on pickup."""
        sources: dict[str, list[str]] = {}
        for item_id in self.raw:
            sources.update({item_id: self.get_learned_bps(item_id)})
        return {item_id: sources[item_id] for item_id in sources if sources[item_id]}

    def get_messages(self, item_id: str) -> list[str]:
        """Returns a sorted list of radio message IDs triggered by picking up the item."""
        if item_id in self.raw:
            tags = self.raw[item_id].get("itemTags", [])
            messages: list[str] = list(self.raw[item_id].get('radioMessagesOnPickup', []))
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
        """Returns a sorted list of tags associated with the item, including race, rarity, and elemental type."""
        if item_id in self.raw and self.raw[item_id].get("itemTags"):
            tags: list[str] = self.raw[item_id].get("itemTags", [])
            tags.extend([self.raw[item_id].get("race"), (self.get_rarity(item_id) or '').lower(), self.raw[item_id].get("elementalType")])
            return sorted(set([tag for tag in tags if tag]))
        return []

    def get_colony_tags(self, item_id: str) -> list[str]:
        """Returns a sorted list of colony tags associated with the item."""
        if item_id in self.raw and self.raw[item_id].get("colonyTags"):
            tags: list[str] = self.raw[item_id].get("colonyTags", [])
            tags.extend([self.raw[item_id].get("race"), (self.get_rarity(item_id) or '').lower(), self.raw[item_id].get("elementalType")])
            return sorted(set([tag for tag in tags if tag]))
        return []

    def get_level(self, item_id: str) -> int|None:
        """Returns the item's level, or 0 if not set."""
        if item_id in self.raw:
            return self.raw[item_id].get("level", 0)

    def get_rarity(self, item_id: str) -> str|None:
        """Returns the item's rarity, or infers it from level if not set."""
        if item_id in self.raw:
            return self.raw[item_id].get("rarity") or self.tips['rarityTypes'].get(str(self.get_level(item_id)))

    def get_icon(self, item_id: str) -> str|None:
        """Returns the path to the item's icon."""
        if item_id in self.raw:
            icon: str = self.raw[item_id].get("inventoryIcon", self.raw[item_id].get("icon")) or self.raw[item_id].get("animationParts", {}).get("blade")
            if icon and not icon.startswith('/'):
                icon = wiki.load.os.path.dirname(self.raw[item_id]['path']) + '/' + icon
            return icon

    def get_bonus(self, item_id: str) -> int:
        """Returns the number of bonus markers () in the item's name."""
        if item_id in self.raw:
            return self.raw[item_id].get("shortdescription", "").count("")
        return 0

    def get_upgradeable(self, item_id: str) -> bool|None:
        """Returns True if the item has upgrade parameters, else False."""
        if item_id in self.raw:
            return bool(self.raw[item_id].get("upgradeParameters"))

    def get_upgrade(self, item_id: str) -> bool|None:
        """Returns ID of this item's upgrade, if it exists."""
        if item_id in self.raw and item_id + '-upgrade' in self.raw:
            return item_id + '-upgrade'

    def get_downgrade(self, item_id: str) -> bool|None:
        """Returns ID of this upgrade's original item, if it exists."""
        if item_id.endswith('-upgrade') and item_id[:-8] in self.raw:
            return item_id[:-8]

    def get_price(self, item_id: str) -> int|None:
        """Returns the calculated price of the item, applying level and bonus modifiers."""
        if item_id in self.raw:
            price = self.raw[item_id].get("price") or self.raw[item_id].get("build", {}).get("price")
            if not self.raw[item_id].get("fixedPrice", False):
                price = price * (0.5 * self.get_level(item_id) + 0.5)
                price = price + (math.floor((price / 100) + 0.5) * 10 * self.get_bonus(item_id))
            return round(price)

    def get_power(self, item_id: str) -> float|None:
        """Returns the item's power value, calculated from price if not set."""
        if item_id in self.raw:
            return round(self.raw[item_id].get('power', (
                (self.get_price(item_id) or 1) / (self.raw[item_id].get("price") or self.raw[item_id].get("build", {}).get("price") or (self.get_price(item_id) or 1))
            )), 2)

    def get_reward_bags_by_loot_id(self, loot_id: str, levels: list[int] = None):
        """Returns a sorted list of item IDs that are reward bags for the given loot pool."""
        items: list[str] = []
        for item in self.raw:
            if not levels or (self.get_level(item) in levels):
                if self.raw[item].get("treasure", {}).get("pool"):
                    if self.raw[item].get("treasure", {}).get("pool") == loot_id:
                        items.append(item)
        return sorted(set(items))

    def get_shops_by_item_id(self, item_id: str):
        """Returns a sorted list of shop item IDs that sell the given item."""
        items: list[str] = []
        for item in self.raw:
            if type(self.raw[item].get("interactData")) == dict:
                if self.raw[item].get("interactData", {}).get("items"):
                    for entry in self.raw[item].get("interactData", {}).get("items"):
                        item_id2 = entry.get("item", '')
                        if 'parameters' in entry:
                            if 'preset' in entry['parameters']:
                                item_id2 = item_id2 + '-' + entry['parameters']['preset']
                            if 'upgraded' in entry['parameters'] and entry['parameters']['upgraded']:
                                item_id2 = item_id2 + '-upgrade'
                        if item_id2 == item_id:
                            items.append(item)
        return sorted(set(items))

    def get_breakables_by_item_id(self, item_id: str) -> list[str]:
        """Returns a sorted list of breakable item IDs that can drop the given item."""
        items: list[str] = []
        for item in self.raw:
            drops = self.raw[item].get('breakDropOptions', []) + self.raw[item].get('smashDropOptions', [])
            for option in drops:
                for drop in option:
                    item_id2 = drop[0]
                    if len(drop) == 3:
                        if 'preset' in drop[2]:
                            item_id2 = item_id2 + '-' + drop[2]['preset']
                        if 'upgraded' in drop[2] and drop[2]['upgraded']:
                            item_id2 = item_id2 + '-upgrade'
                    if item_id2 == item_id:
                            items.append(item)
        return sorted(set(items))

    def get_breakables_by_loot_id(self, loot_id: str) -> list[str]:
        """Returns a sorted list of breakable item IDs that use the given loot pool."""
        items: list[str] = []
        for item in self.raw:
            drops = [self.raw[item].get('breakDropPool'), self.raw[item].get('smashDropPool')]
            for option in drops:
                if option == loot_id:
                    items.append(item)
        return sorted(set(items))

    def get_crops_by_loot_id(self, loot_id: str) -> list[str]:
        """Returns a sorted list of crop item IDs whose final stage harvests from the given loot pool."""
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('stages'):
                if self.raw[item].get('stages')[-1].get('harvestPool') == loot_id:
                    items.append(item)
        return sorted(set(items))
    
    def get_saplings_by_tree_ids(self, tree_part_ids: list[str]) -> list[str]:
        """Returns a sorted list of sapling item IDs that use the given tree part IDs."""
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

    def get_items_by_effect_id(self, effect_id: str) -> list[str]:
        """Returns a sorted list of item IDs that have the given status effect."""
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('statusEffects'):
                if effect_id in self.raw[item]['statusEffects']:
                    items.append(item)
        for item in self.raw:
            if self.raw[item].get('effects'):
                if effect_id in [effect['effect'] for effect in self.raw[item]['effects'][0] if type(effect) is dict]:
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
                obj.update(obj['tenants'][0])
                obj.pop('tenants')
                obj.update(obj.get('wiki', {}))
                obj['species'] = [obj['species']] if type(obj['species']) is str else obj['species']
                raw.update({obj['name']: obj})
        print(f'- Generated {len(raw)} tenants')
        return raw

    def get_tenants_by_rent_loot_id(self, loot_id: str) -> list[str]:
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('rent'):
                if self.raw[item].get('rent').get('pool') == loot_id:
                    items.append(item)
        return sorted(set(items))

    def get_tenants_by_npc_id(self, npc_id: str) -> list[str]:
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('type'):
                if self.raw[item]['type'] == npc_id:
                    items.append(item)
        return sorted(set(items))


class NPCLib(AbstractLib):

    def __init__(self):
        self.ext = 'npctype'
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.LOOT_PATHS)
        visitors = wiki.load.json('/objects/outpost/2stopteleshop/2stoptele.object.patch')
        visitor_ids = set(visitor['value']['type'] for visitor in visitors or [])
        for visitor_id in visitor_ids:
            if visitor_id in self.raw:
                self.raw[visitor_id]['visits_outpost'] = True
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

    def get_npcs_by_loot_id(self, loot_id: str) -> list[str]:
        items: list[str] = []
        for item in self.raw:
            if self.raw[item].get('dropPools'):
                if self.raw[item].get('dropPools')[0].get('default') == loot_id:
                    items.append(item)
        return sorted(set(items))

    def get_npcs_by_shop_item_id(self, item_id: str) -> list[str]:
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
                                    elif type(entry['item']) == dict:
                                        item_id2 = entry['item']['name']
                                        if 'parameters' in entry['item']:
                                            if 'preset' in entry['item']['parameters']:
                                                item_id2 = item_id2 + '-' + entry['item']['parameters']['preset']
                                            if 'upgraded' in entry['item']['parameters'] and entry['item']['parameters']['upgraded']:
                                                item_id2 = item_id2 + '-upgrade'
                                        if item_id2 == item_id:
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

    def get_by_loot_id(self, loot_id: str, loot_type: str) -> list[str]:
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

    def get_by_item_id(self, item_id: str) -> list[str]:
        items: list[str] = []
        for item in self.raw:
            drops = self.raw[item].get('dropConfig', {}).get('drops', [])
            for option in drops:
                for drop in option:
                    item_id2 = drop['item']
                    if 'parameters' in drop:
                        if 'preset' in drop['parameters']:
                            item_id2 = item_id2 + '-' + drop['parameters']['preset']
                        if 'upgraded' in drop['parameters'] and drop['parameters']['upgraded']:
                            item_id2 = item_id2 + '-upgrade'
                    if item_id2 == item_id:
                        items.append(item)
        return sorted(set(items))


class EffectLib(AbstractLib):

    def __init__(self):
        self.ext = 'statuseffect'
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.LOOT_PATHS)

    def get_tables(self, paths: list[str]):
        raw: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) == self.ext:
                obj = wiki.load.json(path)
                obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                raw.update({obj['name']: obj})
        print(f'- Generated {len(raw)} effects')
        return raw

    def get_icon(self, item_id: str) -> str|None:
        """Returns the path to the effect's icon."""
        if item_id in self.raw:
            icon: str = self.raw[item_id].get("icon", '')
            if icon and not icon.startswith('/'):
                icon = wiki.load.os.path.dirname(self.raw[item_id]['path']) + '/' + icon
            return icon





class Item:
    """
    Represents an item descriptor that can be initialized from a dictionary, list, or string.
    Args:
        item (dict | list | str): The item descriptor. Can be a dictionary (with keys 'item', 'count', and optional 'parameters'),
            a list ([item, count, parameters]), or a string (item UID).
    Attributes:
        uid (str): The unique identifier of the item.
        n (int): The quantity of the item.
        params (dict): Additional parameters associated with the item.
        raw (dict | list | str): The original item descriptor as provided.
    Raises:
        Exception: If the item descriptor cannot be parsed.
    """

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

    def get_full_id(self) -> str:
        """Returns the full item ID, including preset and upgrade suffixes if applicable."""
        full_id = self.uid
        if 'preset' in self.params:
            full_id = full_id + '-' + self.params['preset']
        if 'upgraded' in self.params and self.params['upgraded']:
            full_id = full_id + '-upgrade'
        return full_id


class LootEntry(Item):
    """
    Represents a loot entry, which can be either a single item or a pool of items, with an associated weight.
    Args:
        loot_entry (dict): Dictionary containing loot entry data. Should have either an 'item' or 'pool' key.
        weight_default (float, optional): Default weight to use if 'weight' is not specified in loot_entry. Defaults to 0.0.
    Attributes:
        is_pool (bool): True if the loot entry represents a pool, False if it represents a single item.
        weight (float): The weight of the loot entry, used for probability calculations.
        raw (dict): The original loot entry dictionary.
    """

    def __init__(self, loot_entry: dict, weight_default=0.0):
        self.is_pool = bool(loot_entry.get('pool'))
        self.weight = loot_entry.get('weight', weight_default)
        super().__init__(loot_entry.get('item') or loot_entry.get('pool'))
        self.raw = loot_entry


class Loot:
    """
    Represents a loot object with associated entries and configuration.
    Args:
        loot (list): A list containing loot table data. The first element is expected to be the loot level (int),
            and the second element is a dictionary with loot configuration.
    Attributes:
        level (int): The level of the loot object.
        values (dict): The dictionary containing loot configuration values.
        pool_raw (tuple[dict]): The raw pool entries as a tuple of dictionaries.
        fill_raw (tuple[dict]): The raw fill entries as a tuple of dictionaries.
        pool (tuple[LootEntry]): The processed pool entries as LootEntry objects.
        fill (tuple[LootEntry]): The processed fill entries as LootEntry objects, always present with weight -1.0.
        all (tuple[LootEntry]): All loot entries, combining pool and fill.
        rounds (tuple[tuple[float, int]]): The pool rounds configuration, if present.
        raw (list): The original loot data passed to the constructor.
    Raises:
        Exception: If the loot table cannot be parsed.
    """

    def __init__(self, loot: list):
        try:
            self.level = int(loot[0] + 0.5)  # Min level of this loot object
            self.levels: list[int] = []  # All levels that would use this loot object
            self.values = dict(loot[1])
            self.pool_raw: tuple[dict] = tuple(self.values.get('pool', []))
            self.fill_raw: tuple[dict] = tuple(self.values.get('fill', []))
            self.pool = tuple(LootEntry(pool) for pool in self.pool_raw)
            # Use a negative weight of -1.0 for always-present fill entries
            self.fill = tuple(LootEntry(fill, -1.0) for fill in self.fill_raw)
            self.all = self.pool + self.fill
            self.rounds: tuple[tuple[float, int]] = tuple(self.values.get('poolRounds', []))
            self.raw = loot
        except Exception as e:
            print(f'Can\'t parse loot object: {loot}')
            raise e


class LootTable:
    """
    Represents a loot table consisting of multiple loot entries.
    Args:
        loot_list (list): A list containing loot entries, where each entry is expected to be a list.
    Attributes:
        entries_raw (tuple): A tuple of loot entries from loot_list that are lists.
        entries (tuple): A tuple of Loot objects created from entries_raw.
        raw (list): The original loot_list provided.
    Raises:
        Exception: If there is an error parsing the loot table, the exception is raised after printing an error message.
    """

    def __init__(self, loot_list: list):
        try:
            self.entries_raw = tuple(loot for loot in loot_list if type(loot) == list)
            self.entries = tuple(Loot(loot) for loot in self.entries_raw)
            for i in range(len(self.entries)):
                self.entries[i].levels = []
                for level in range(11):
                    if i < len(self.entries) - 1:
                        if level >= self.entries[i].level and level < self.entries[i+1].level:
                            self.entries[i].levels.append(level)
                    elif level >= self.entries[i].level:
                        self.entries[i].levels.append(level)
            self.raw = loot_list
            # [print(f'Loot table object, min level {entry.level}: {entry.levels}') for entry in self.entries]
        except Exception as e:
            print(f'Can\'t parse loot table: {loot_list}')
            raise e


class LootLib(AbstractLib):
    """
    A library for parsing and querying loot tables from Starbound mod data.
    Attributes:
        ext (str): The file extension for loot table files.
        tables_raw (dict[str, list[tuple[int, dict]]]): Raw loot table data loaded from files.
        tables (dict[str, LootTable]): Parsed loot tables, filtered to only include those with entries.
    """

    def __init__(self):
        try:
            self.ext = 'treasurepools'
            self.tables_raw: dict[str, list[tuple[int, dict]]] = self.get_tables(wiki.load.filepaths_in_dirs(wiki.load.dirs(wiki.load.LOOT_PATHS)))
            self.tables = {str(key): LootTable(self.tables_raw[key]) for key in self.tables_raw}
            self.tables = {key: self.tables[key] for key in self.tables if self.tables[key].entries}
            print(f'- Generated {len(self.tables)} loot tables ({len(self.tables_raw)} entries total found, including chests)')
        except Exception as e:
            print(f'Can\'t parse loot library.')
            raise e

    # Sources

    def find_loot_that_drops_obj(self, obj_uid: str, top_level = False, levels: list[int] = None) -> dict[str,list[int]]:
        result = {}
        for table in self.tables:
            result.update(self.find_loot_that_drops_obj_inner(obj_uid, table, top_level, levels))
        return dict(sorted(result.items()))

    def find_loot_that_drops_obj_inner(self, obj_uid: str, table: str, top_level = False, levels: list[int] = None) -> dict[str,list[int]]:
        result = {}
        if table in self.tables:
            source_uid = None
            source_levels = []
            for loot in self.tables[table].entries:
                if not levels or loot.level in levels:
                    for f in loot.all:
                        if not f.is_pool:
                            f_uid = f.uid
                            if 'preset' in f.params:
                                f_uid = f_uid + '-' + f.params['preset']
                            if 'upgraded' in f.params and f.params['upgraded']:
                                f_uid = f_uid + '-upgraded'
                            if obj_uid == f_uid:
                                source_uid = table
                                source_levels.extend(loot.levels)
                                break
                        elif not top_level and f.is_pool:
                            if self.find_loot_that_drops_obj_inner(obj_uid, f.uid, False, levels):
                                source_uid = table
                                source_levels.extend(loot.levels)
                                break
            if source_uid:
                result.update({source_uid: source_levels})
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

    def find_tree_loot_of_obj(self, obj: dict):
        result: dict[str, LootTable] = {}
        for i, option in enumerate(self.get_tree_loot(obj)):
            result.update({f'drop option {i + 1}': LootTable([[0, {'pool': [{'weight':1.0,'item':[item.uid, item.n]} for item in option]}]])})
        return result

    def find_tree_loot_of_obj_raw(self, obj: dict):
        result = self.find_tree_loot_of_obj(obj)
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


class ShopEntry(Item):
    """
    Represents a shop entry, which is basically an item with a price and rarity.
    Args:
        shop_entry (dict): Dictionary containing shop entry data. Should have either an 'item' or 'pool' key.
        weight_default (float, optional): Default weight to use if 'weight' is not specified in shop_entry. Defaults to 0.0.
    Attributes:
        is_pool (bool): True if the shop entry represents a pool, False if it represents a single item.
        weight (float): The weight of the shop entry, used for probability calculations.
        raw (dict): The original shop entry dictionary.
    """

    def __init__(self, shop_entry: dict, items: ItemLib):
        self.item_raw: dict = shop_entry.get('item', {})
        super().__init__([self.item_raw.get('name'), self.item_raw.get('count', 1), self.item_raw.get('parameters', {})])
        self.rarity = shop_entry.get('rarity', 0.0)
        self.price = shop_entry.get('price', items.get_price(self.get_full_id()) or 0)
        self.raw = shop_entry


class Shop:
    """
    Represents a shop object with associated entries and configuration.
    Args:
        category (list): A list containing shop table data. The first element is expected to be the shop level (int),
            and the second element is a dictionary with shop configuration.
    Attributes:
        level (int): The level of the shop object.
        values (dict): The dictionary containing shop configuration values.
        pool (tuple[Item]): The processed pool entries as Item objects.
        raw (list): The original shop data passed to the constructor.
    Raises:
        Exception: If the shop table cannot be parsed.
    """

    def __init__(self, category: list, items: ItemLib):
        try:
            self.level = int(category[0] + 0.5)  # Min level of this shop object
            self.levels: list[int] = []  # All levels that would use this shop object
            self.values = list(category[1])
            self.pool = tuple(
                ShopEntry(item, items)
                for item in self.values
            )
            self.raw = category
        except Exception as e:
            print(f'Can\'t parse shop object: {category}')
            raise e


class ShopTable:
    """
    Represents a shop table consisting of multiple shop entries.
    Args:
        shop_list (list): A list containing shop entries, where each entry is expected to be a list.
    Attributes:
        entries_raw (tuple): A tuple of shop entries from shop_list that are lists.
        entries (tuple): A tuple of Shop objects created from entries_raw.
        raw (list): The original shop_list provided.
    Raises:
        Exception: If there is an error parsing the shop table, the exception is raised after printing an error message.
    """

    def __init__(self, shop_list: list, items: ItemLib):
        try:
            self.entries_raw = tuple(loot for loot in shop_list if type(loot) == list)
            self.entries = tuple(Shop(loot, items) for loot in self.entries_raw)
            for i in range(len(self.entries)):
                self.entries[i].levels = []
                for level in range(11):
                    if i < len(self.entries) - 1:
                        if level >= self.entries[i].level and level < self.entries[i+1].level:
                            self.entries[i].levels.append(level)
                    elif level >= self.entries[i].level:
                        self.entries[i].levels.append(level)
            self.raw = shop_list
            # [print(f'Shop table object, min level {entry.level}: {entry.levels}') for entry in self.entries]
        except Exception as e:
            print(f'Can\'t parse shop table: {shop_list}')
            raise e


class ShopLib(AbstractLib):
    """
    A library for parsing and querying shop tables from Starbound mod data.
    Attributes:
        ext (str): The file extension for shop table files.
        tables_raw (dict[str, list[tuple[int, dict]]]): Raw shop table data loaded from files.
        tables (dict[str, LootTable]): Parsed shop tables, filtered to only include those with entries.
    """

    def __init__(self, items: ItemLib):
        try:
            self.ext = 'config'
            self.tables_raw: dict[str, list[tuple[int, dict]]] = self.get_tables(wiki.load.filepaths_in_dirs(wiki.load.dirs(['npcs'])))
            self.tables = {str(key): ShopTable(self.tables_raw[key], items) for key in self.tables_raw}
            self.tables = {key: self.tables[key] for key in self.tables if self.tables[key].entries}
            print(f'- Generated {len(self.tables)} shop tables ({len(self.tables_raw)} entries total found, including chests)')
        except Exception as e:
            print(f'Can\'t parse shop library.')
            raise e


class Recipe:

    def __init__(self, recipe: dict):
        try:
            self.raw_input = tuple(recipe['input'])
            self.raw_output = dict(recipe['output'])
            self.input = tuple(Item(entry) for entry in self.raw_input)
            self.output = Item(self.raw_output)
            self.tags = tuple(recipe.get('groups', []))
            self.dur = float(dur) if '.' in str(dur := recipe.get('duration', 0.0)) else int(dur)
            self.sources_admin = self._get_sources(RECIPE_SOURCES_ADMIN)
            self.sources = self._get_sources(RECIPE_SOURCES)
            if not (self.sources_admin + self.sources):
                self.sources = ['Other Crafting Tables']
            self.raw = recipe
            # Output shortcuts
            self.uid = self.output.uid
            self.n = self.output.n
            self.params = self.output.params
        except Exception as e:
            print(f'Can\'t parse recipe: {recipe}')
            raise e

    def _get_sources(self, source_lib: dict[str, list[str]]) -> list[str]:
        sources = []
        for source in source_lib:
            for tag in self.tags:
                if tag in source_lib[source]:
                    sources.append(source)
                    break
        return sources


class RecipeLib:

    def __init__(self):
        self.exts = [
            'recipe',
        ]
        self.raw: dict[str, list[dict]] = self.get_tables(wiki.load.ITEM_PATHS)
        self.recipes = {item_id: tuple(Recipe(recipe) for recipe in self.raw[item_id]) for item_id in self.raw}

    def get_tables(self, paths: list[str]):
        raw: dict[str, list[dict]] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) in self.exts:
                obj = wiki.load.json(path)
                obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                output = Item(obj['output'])
                item_id = output.uid
                if 'preset' in output.params:
                    item_id = item_id + '-' + output.params['preset']
                if 'upgraded' in output.params and output.params['upgraded']:
                    item_id = item_id + '-upgrade'
                if item_id in raw:
                    raw[item_id].append(obj)
                else:
                    raw[item_id] = [obj]
        print(f'- Generated {len(raw)} recipes')
        return raw
    
    def get_recipes_by_output_id(self, item_id: str) -> list[Recipe]:
        if item_id in self.recipes:
            return self.recipes[item_id]
        else:
            return []
    
    def get_groups_by_output_id(self, item_id: str) -> set[str]:
        recipes = self.get_recipes_by_output_id(item_id)
        groups = set()
        for recipe in recipes:
            groups.update(recipe.tags)
        return groups
    
    def get_recipes_by_input_id(self, item_id: str) -> list[Recipe]:
        recipes: list[Recipe] = []
        for recipe_list in self.recipes.values():
            for recipe in recipe_list:
                for entry in recipe.input:
                    if entry.get_full_id() == item_id:
                        recipes.append(recipe)
                        break
        return recipes
    
    def get_groups_by_input_id(self, item_id: str) -> set[str]:
        recipes = self.get_recipes_by_input_id(item_id)
        groups = set()
        for recipe in recipes:
            groups.update(recipe.tags)
        return groups
    
    def get_recipes(self, input_ids: list[str], output_id: str = None, groups: list[str] = None) -> list[Recipe]:
        recipes: list[Recipe] = []
        for recipe_list in self.recipes.values():
            for recipe in recipe_list:
                if output_id and recipe.output.get_full_id() != output_id:
                    continue
                if groups and not set(groups).intersection(set(recipe.tags)):
                    continue
                if input_ids:
                    found = True
                    for input_id in input_ids:
                        found_input = False
                        for entry in recipe.input:
                            if entry.get_full_id() == input_id:
                                found_input = True
                                break
                        if not found_input:
                            found = False
                            break
                    if not found:
                        continue
                recipes.append(recipe)
        return recipes

    def find_recipes_of_obj(self, uid: str) -> list[Recipe]:
        result: list[Recipe] = []
        if uid not in self.recipes:
            return result
        for recipe in self.recipes[uid]:
            if recipe.sources:
                result.append(recipe)
        return result

    def find_admin_recipes_of_obj(self, uid: str) -> list[Recipe]:
        result: list[Recipe] = []
        if uid not in self.recipes:
            return result
        for recipe in self.recipes[uid]:
            if recipe.sources_admin:
                result.append(recipe)
        return result


class BiomeLib(AbstractLib):

    def __init__(self):
        self.ext = 'biome'
        self.raw: dict[str, dict[str]] = self.get_tables(wiki.load.BIOME_PATHS)

    def get_tables(self, paths: list[str]):
        raw: dict[str, dict] = {}
        for path in wiki.load.filepaths_in_dirs(wiki.load.dirs(paths)):
            if wiki.load.ext(path) == self.ext:
                obj = wiki.load.json(path)
                obj['path'] = path.replace(wiki.load.ROOT, '').replace('\\', '/')
                raw.update({obj['name']: obj})
        print(f'- Generated {len(raw)} biomes')
        return raw
