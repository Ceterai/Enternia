import base
import json


PATH = '/_metadata'
SOURCE = base.os.path.join(base.META, 'description.txt')

def run(version: str = None):
    # Updates metadata with description from `description.txt`
    with open(SOURCE, 'r') as f:
        mod_info = base.get_obj(base.ROOT + PATH)
        mod_desc = ''.join(f.readlines())
        mod_info['description'] = mod_desc
        if version:
            mod_info['version'] = version
        json.dump(mod_info, open(base.ROOT + PATH, 'w'), indent=2)
    return [PATH]
