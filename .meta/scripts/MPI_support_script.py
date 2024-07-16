"""
Run this script to update the cockpit patch file to include
biome and planet info for the More Planet Info addon.
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#more-planet-info
"""

import os
import pyjson5
import base


PATH_INPUT = '/.meta/cockpit.config.patch'
PATH = '/interface/cockpit/cockpit.config.patch'
AFFECTED_FILES = [PATH, PATH_INPUT]
MOD = 'More Planet Info'
HINT = base.HINT.format(mod=MOD, name=base.get_file(__file__))

def is_effect(name: str) -> bool:
    return (base.get_ext(name) == 'statuseffect')

def is_weather(name: str) -> bool:
    return (base.get_ext(name) == 'weather')

def is_biome(name: str) -> bool:
    return (base.get_ext(name) == 'biome')

def run():
    # Initial fill
    json_patches: list[list[dict]] = [
        pyjson5.load(open(base.ROOT + PATH_INPUT)),
        '\n  ' + HINT,
        [ { "op": "test", "path": "/displayEnvironmentStatusEffects" }, ],
        [ { "op": "test", "path": "/weatherThreatValues" }, ],
        [ { "op": "test", "path": "/namesList" }, ]
    ]

    # Effects
    paths = base.get_files_flat(is_effect)
    objs = {path: base.get_obj(path) for path in paths}
    for path in objs:
        icon = objs[path].get('icon', 'icon.png')
        objs[path]['icon'] = ((os.path.dirname(path) + '/' + icon) if icon[0] != '/' else icon).replace(base.ROOT, '').replace('\\', '/')
    patches = [ ( objs[path].get('name'), f"{objs[path].get('label')}", objs[path].get('icon'), ) for path in objs ]
    json_patches[-3].extend([{'op': 'add', 'path': f'/displayEnvironmentStatusEffects/{patch[0]}', 'value': {'displayName': patch[1], 'icon': patch[2]}} for patch in patches])

    # Weather
    paths = base.get_files_flat(is_weather)
    objs = {path: base.get_obj(path) for path in paths}
    patches = [ ( objs[path].get('name'), f"{objs[path].get('threat', 0.1)}", ) for path in objs ]
    json_patches[-2].extend([{'op': 'add', 'path': f'/weatherThreatValues/{patch[0]}', 'value': patch[1]} for patch in patches])

    # Biomes
    paths = base.get_files_flat(is_biome)
    objs = {path: base.get_obj(path) for path in paths}
    patches = [ ( objs[path].get('name'), f"{objs[path].get('friendlyName')}", ) for path in objs ]
    json_patches[-1].extend([{'op': 'add', 'path': f'/namesList/{patch[0]}', 'value': {'word': patch[0], 'friendlyWord': patch[1]}} for patch in patches])

    lines = [('\n  [\n    ' + ',\n    '.join([pyjson5.dumps(json_patch) for json_patch in json_batch]) + '\n  ]' + (',' if json_batch != json_patches[-1] else '')) if type(json_batch) == list else json_batch for json_batch in json_patches]

    json_patch_lines = '[' + ''.join(lines) + '\n]\n'
    # print(json_patch_lines)
    with open(base.ROOT + PATH, 'w') as patch_file:
        patch_file.writelines(json_patch_lines)
