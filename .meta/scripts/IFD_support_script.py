"""
It's a bit stupid that you have to specify effect's path AND name
for the Improved Food Descriptions mod, since the path is used to
literally load the effect which already has the name in it, so I
did this to create patches automatically for this mod (since it
has a lot of effects).
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#improved-food-descriptions
"""

import pyjson5
import base


PATH = '/IFD_statuseffects.config.patch'
AFFECTED_FILES = [PATH]
MOD = 'Improved Food Descriptions'
HINT = base.HINT.format(mod=MOD, name=base.get_file(__file__))

def is_obj_file(name: str) -> bool:
    return (name[-13:] == '.statuseffect')

def run():
    paths = base.get_files_flat(is_obj_file)
    objs = {path: base.get_obj(path) for path in paths}
    patches = [(objs[path].get('name'), f"^green;+ {objs[path].get('label')}^reset;", path.replace(base.ROOT, '').replace('\\', '/')) for path in objs]
    json_patches = [{'op': 'add', 'path': f'/effectNames/{patch[0]}', 'value': {'customLabels': [patch[1]], 'path': patch[2]}} for patch in patches]
    json_patch_lines = '[\n  ' + ',\n  '.join([pyjson5.dumps(json_patch) for json_patch in json_patches]) + '\n]\n'
    json_patch_lines = HINT + '\n' + json_patch_lines
    # print(json_patch_lines)
    with open(base.ROOT + PATH, 'w') as patch_file:
        patch_file.writelines(json_patch_lines)
