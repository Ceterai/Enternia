"""
This script automatically creates support for the Equivalent Exchange mod.
Made in accordance to the general guide: https://steamcommunity.com/workshop/filedetails/discussion/1790667104/1642042464747956675/
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#equivalent-exchange
"""

import pyjson5
import base


PATH = '/EES_transmutationstudylist.config.patch'
AFFECTED_FILES = [PATH]
MOD = 'Equivalent Exchange'
HINT = base.HINT.format(mod=MOD, name=base.get_file(__file__))
IDS = {
    'farm': [
        'ct_aya',
        'ct_gil',
        'ct_ionic_sap',
        'ct_tsay',
        'ct_yaara_eye',
        'ct_yaara_root',
        'ct_ayaka_wood',
        'ct_aya_powder',
    ],
    'mine': [
        'ct_bionid',
        'ct_ceternia_core',
        'ct_enterite',
        'ct_phospholion',
    ],
    'hunt': [
    ],
}

def is_obj_file(name: str) -> bool:
    return (base.get_ext(name) in ('consumable', 'item'))

def run():
    paths = base.get_files_flat(is_obj_file)
    objs = {path: base.get_obj(path) for path in paths}
    levels = {objs[path].get('itemName'): objs[path].get('level', 1) for path in objs}
    json_patches = []
    for cat in IDS:
        for name in IDS[cat]:
            tier = 'T1' if levels[name] < 3 else ('T2' if levels[name] < 5 else 'T3')
            json_patches.append({'op': 'add', 'path': f'/{cat}/{tier}/{name}', 'value': True})
    json_patch_lines = '[\n  ' + ',\n  '.join([pyjson5.dumps(json_patch) for json_patch in json_patches]) + '\n]\n'
    json_patch_lines = HINT + '\n' + json_patch_lines
    # print(json_patch_lines)
    with open(base.ROOT + PATH, 'w') as patch_file:
        patch_file.writelines(json_patch_lines)
    return AFFECTED_FILES
