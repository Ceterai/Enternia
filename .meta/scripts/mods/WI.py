"""
This script automatically creates support for the Wardrobe Interface mod.
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#wardrobe-interface
"""

import json
import base


PATH = '/wardrobe/my_enternia.json'
AFFECTED_FILES = [PATH]
MOD = 'Wardrobe Interface'
HINT = base.HINT.format(mod=MOD, name=base.get_file(__file__))

def is_obj_file(name: str) -> bool:
    return (base.get_ext(name) in ('head', 'chest', 'legs', 'back'))

def run():
    paths = base.get_files_flat(is_obj_file)
    objs = {path: base.get_obj(path) for path in paths if 'deprecated' not in path and 'WIP' not in path}
    result = {
        'head': [],
        'chest': [],
        'legs': [],
        'back': [],
    }
    for obj in objs:
        if 'mimic' not in objs[obj]['itemName']:
            params = {
                "path": base.get_folder(obj) + '/',
                "fileName": base.get_file(obj),
                "name": objs[obj]['itemName'],
                "icon": objs[obj]['inventoryIcon'],
            }
            for param in ("shortdescription", "maleFrames", "femaleFrames", "mask"):
                if param in objs[obj]:
                    params[param] = objs[obj][param]
            if 'colorOptions' in objs[obj]:
                params['colorOptions'] = []
                for option in objs[obj]['colorOptions']:
                    colors = {}
                    for color in option:
                        colors['#' + color.replace('#', '')] = option[color]
                    params['colorOptions'].append(colors)
            result[base.get_ext(obj)].append(params)
    with open(base.ROOT + PATH, 'w') as patch_file:
        json.dump(result, patch_file, indent=2)
        patch_file.write('\n')
    return AFFECTED_FILES
