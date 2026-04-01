import json
import os
import pyjson5
import re


def get_file(name: str):
    return os.path.split(name)[-1]

def get_folder(name: str):
    return os.path.dirname(name).replace(ROOT, '').replace('\\', '/')

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
MODS = os.path.dirname(ROOT)
META = os.path.join(ROOT, '.meta')
WIKI = os.path.join(META, 'wiki')
PAGES = os.path.join(META, 'scripts', 'wiki', 'pages')
RELEASE = os.path.join(META, 'release')
STARBOUND = os.path.dirname(MODS)
REPO = 'https://github.com/Ceterai/Enternia'
IMAGE_PATH = 'https://raw.githubusercontent.com/Ceterai/Enternia/main'
REPO_PATH = f'{REPO}/blob/main'
WIKI_PATH = 'https://ceterai.github.io/MyEnternia/Wiki'
HINT_PATH = __file__.replace(ROOT, '').replace('\\', '/').replace(get_file(__file__), '')
HINT = '// Mod Support for {mod}, generated with this script: ' + REPO_PATH + HINT_PATH + 'mods/{name}'

def get_paths_flat(roots: list[str] = ['']) -> list[str]:
    paths = []
    for path in roots:
        paths.extend([r[0] for r in list(os.walk(os.path.join(ROOT, path)))])
    return paths

def get_obj(file_path) -> dict[str]:
    with open(file_path, encoding="utf-8") as fp:
        lines = ''.join(fp.readlines())
        lines = str(re.sub(r'((?<!:)\/\/.*)\n', r'\n', lines))
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

def get_objects(filter_f) -> list[dict[str]]:
    return {path: get_obj(path) for path in get_files_flat(filter_f)}

def get_ext(name: str):
    return name.split('.')[-1] if '.' in name else ''

def write_json(path: str, obj: dict, indent: int = 4):
    if not os.path.exists(dirname := os.path.dirname(path)): os.mkdir(dirname)
    with open(path, 'w') as f:
        json.dump(obj, f, indent=indent)
        f.write('\n')

def sort_dict(d: dict) -> dict:
    return dict(sorted(d.items())) if d else {}

def prepare_dict(d: dict, skip_keys: list[str] = None) -> dict:
    return sort_dict({k: v for k, v in d.items() if k not in (skip_keys or [])}) if d else {}
