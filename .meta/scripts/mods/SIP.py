"""
This script automatically creates support for the Spawnable Item Pack mod.
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#spawnable-item-pack
"""

import pyjson5
import json
import base


PATH = '/sipMods/my_enternia.json'
AFFECTED_FILES = [PATH]
MOD = 'Spawnable Item Pack'
HINT = base.HINT.format(mod=MOD, name=base.get_file(__file__))

def is_obj_file(name: str) -> bool:
    return (base.get_ext(name) in ('codex', 'item', 'activeitem', 'augment', 'consumable', 'object', 'thrownitem', 'head', 'chest', 'legs', 'back'))

def run():
    paths = base.get_files_flat(is_obj_file)
    objs = {path: base.get_obj(path) for path in paths if 'deprecated' not in path and 'WIP' not in path}
    result = [ ]
    with open(base.ROOT + '/items/buildscripts/ct_texts.config') as f:
        tips = pyjson5.load(f)
    for obj in objs:
        item_id: str = objs[obj].get('itemName', objs[obj].get('objectName', str(objs[obj].get('id')) + '-codex'))
        if 'mimic' not in item_id and 'deprecated' not in obj:
            if 'itemConfig' in objs[obj]:
                objs[obj].update(objs[obj]['itemConfig'])
            params = {
                "path": base.get_folder(obj) + '/',
                "fileName": base.get_file(obj),
                "name": item_id,
                "shortdescription": objs[obj].get('shortdescription', objs[obj].get('title', '')),
                "category": objs[obj].get('category', 'codex'),
                "icon": objs[obj].get('inventoryIcon', objs[obj].get('icon')),
                "rarity": (objs[obj].get('rarity') or tips['rarityTypes'][str(objs[obj].get('level', 0))]).lower(),
            }
            if item_id.endswith('-codex'):
                params['race'] = 'alta'
            if 'race' in objs[obj]:
                params['race'] = objs[obj]['race']
            if params['category'] == 'uniqueWeapon':
                params['category'] = 'ranged'
            result.append(params)
    with open(base.ROOT + PATH, 'w', encoding="utf-8") as patch_file:
        json.dump(result, patch_file, indent=4, ensure_ascii=False)
        patch_file.write('\n')
    return AFFECTED_FILES
