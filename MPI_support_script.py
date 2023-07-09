"""
Run this script to update the cockpit patch file to include
biome and planet info for the More Planet Info addon."""

import os
import pyjson5
import re


ROOT = os.path.dirname(__file__)

def get_paths_flat(roots: list[str] = ['']) -> list[str]:
    paths = []
    for path in roots:
        paths.extend([r[0] for r in list(os.walk(os.path.join(ROOT, path)))])
    return paths

def get_obj(file_path) -> dict[str, str]:
    with open(file_path, encoding="utf-8") as fp:
        lines = ''.join(fp.readlines())
        lines = str(re.sub(r'(\/\/.*)\n', r'\n', lines))
        lines = lines.replace('\n', ' ')
        return pyjson5.loads(lines)

def get_files(path: str, filter_f) -> list[str]:
    file_names = os.listdir(path)
    file_paths = [os.path.join(path, file_name) for file_name in file_names if filter_f(file_name)]
    return file_paths

def get_files_flat(filter_f, paths: list[str] = None) -> list[str]:
    obj_list = []
    for path in paths or get_paths_flat():
        obj_list.extend(get_files(path, filter_f))
    return obj_list

def is_effect(name: str) -> bool:
    return (name[-13:] == '.statuseffect')

def is_weather(name: str) -> bool:
    return (name[-8:] == '.weather')

def is_biome(name: str) -> bool:
    return (name[-6:] == '.biome')



# Initial fill
json_patches: list[list[dict]] = [
    pyjson5.load(open('interface/cockpit/cockpit.config.patch.init.json')),
    '\n  // Mod Support for More Planet Info (see mod description)',
    [ { "op": "test", "path": "/displayEnvironmentStatusEffects" }, ]
]

# Effects
paths = get_files_flat(is_effect)
objs = {path: get_obj(path) for path in paths}
for path in objs:
    icon = objs[path].get('icon', 'icon.png')
    objs[path]['icon'] = ((os.path.dirname(path) + '/' + icon) if icon[0] != '/' else icon).replace(ROOT, '').replace('\\', '/')
patches = [ ( objs[path].get('name'), f"{objs[path].get('label')}", objs[path].get('icon'), ) for path in objs ]
json_patches[-1].extend([{'op': 'add', 'path': f'/displayEnvironmentStatusEffects/{patch[0]}', 'value': {'displayName': patch[1], 'icon': patch[2]}} for patch in patches])

# Weather
paths = get_files_flat(is_weather)
objs = {path: get_obj(path) for path in paths}
patches = [ ( objs[path].get('name'), f"{objs[path].get('threat', 0.1)}", ) for path in objs ]
json_patches[-1].extend([{'op': 'add', 'path': f'/weatherThreatValues/{patch[0]}', 'value': patch[1]} for patch in patches])

# Biomes
paths = get_files_flat(is_biome)
objs = {path: get_obj(path) for path in paths}
patches = [ ( objs[path].get('name'), f"{objs[path].get('friendlyName')}", ) for path in objs ]
json_patches[-1].extend([{'op': 'add', 'path': f'/namesList/{patch[0]}', 'value': {'word': patch[0], 'friendlyWord': patch[1]}} for patch in patches])

lines = [('\n  [\n    ' + ',\n    '.join([pyjson5.dumps(json_patch) for json_patch in json_batch]) + '\n  ]' + (',' if json_batch != json_patches[-1] else '')) if type(json_batch) == list else json_batch for json_batch in json_patches]

json_patch_lines = '[' + ''.join(lines) + '\n]\n'
print(json_patch_lines)
with open('interface/cockpit/cockpit.config.patch', 'w') as patch_file:
    patch_file.writelines(json_patch_lines)
