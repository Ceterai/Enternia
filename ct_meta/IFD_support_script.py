"""
It's a bit stupid that you have to specify effect's path AND name
for the Improved Food Descriptions mod, since the path is used to
literally load the effect which already has the name in it, so I
did this to create patches automatically for this mod (since it
has a lot of effects)."""

import os
import pyjson5
import re


ROOT = os.path.dirname(os.path.dirname(__file__))

def get_paths_flat(roots: list[str] = ['']) -> list[str]:
    paths = []
    for path in roots:
        paths.extend([r[0] for r in list(os.walk(os.path.join(ROOT, path)))])
    return paths

def get_obj(file_path) -> dict[str, str]:
    with open(file_path, encoding="utf-8") as fp:
        lines = ''.join(fp.readlines())
        lines = str(re.sub(r'((?<!:)\/\/.*)\n', r'\n', lines))
        lines = lines.replace('\n', ' ')
        return pyjson5.loads(lines)

def is_obj_file(name: str) -> bool:
    return (name[-13:] == '.statuseffect')

def get_files(path: str) -> list[str]:
    file_names = os.listdir(path)
    file_paths = [os.path.join(path, file_name) for file_name in file_names if is_obj_file(file_name)]
    return file_paths

def get_files_flat(paths: list[str]) -> list[str]:
    obj_list = []
    for path in paths:
        obj_list.extend(get_files(path))
    return obj_list

paths = get_files_flat(get_paths_flat())
objs = {path: get_obj(path) for path in paths}
patches = [(objs[path].get('name'), f"^green;+ {objs[path].get('label')}^reset;", path.replace(ROOT, '').replace('\\', '/')) for path in objs]
json_patches = [{'op': 'add', 'path': f'/effectNames/{patch[0]}', 'value': {'customLabels': [patch[1]], 'path': patch[2]}} for patch in patches]
json_patch_lines = '[\n  ' + ',\n  '.join([pyjson5.dumps(json_patch) for json_patch in json_patches]) + '\n]\n'
json_patch_lines = '// Mod Support for Improved Food Descriptions (see mod description)\n' + json_patch_lines
print(json_patch_lines)
with open(os.path.join(ROOT, 'IFD_statuseffects.config.patch'), 'w') as patch_file:
    patch_file.writelines(json_patch_lines)
