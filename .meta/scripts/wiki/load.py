import os
import pyjson5
import re


ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
MODS = os.path.dirname(ROOT)
META = os.path.join(ROOT, '.meta')
WIKI = os.path.join(META, 'wiki')
RELEASE = os.path.join(META, 'release')
STARBOUND = os.path.dirname(MODS)
COCKPIT_CONFIG = '/interface/cockpit/cockpit.config.patch'  # Custom Path Example
SKIPPED_EXTS = (
    'weaponability',
    'monsterpart',
    'animation',
    'parallax',
    'frames',
    'config',
    'png',
    'lua',
    'txt',
    'raceeffect',
    'default',
)

LOOT_PATHS = [
    '',
]

RECIPE_PATHS = [
    '',
]

CHEST_PATHS = [
    '',
]

RADIO_PATHS = [
    '',
]

ITEM_PATHS = [
    '',
]

OBJECT_PATHS = [
    '',
]

CODEX_PATHS = [
    '',
]


def single_root(file_path: str, root=ROOT) -> str:
    return root + file_path.replace(root, '')


def text(file_path: str, root=ROOT) -> str:
    if file_path:
        with open(single_root(file_path, root), encoding='utf-8') as fp:
            return ''.join(fp.readlines())
    return ''

def json(file_path: str, root=ROOT) -> dict[str]:
    if raw := text(file_path, root):
        lines = re.sub(r'((?<!:)\/\/.*)\n', r'\n', raw).replace('\n', '  ')
        return pyjson5.loads(lines)
    return {}

def md(file_path: str, root=ROOT, **kwargs) -> str:
    if md := text(file_path, root):
        for arg in kwargs:
            md = md.replace('<%%' + arg + '%%>', kwargs[arg])
        return md
    return ''

def ext_is_allowed(name: str, skipped_exts=tuple()) -> bool:
    return '.' in name and ext(name) not in (SKIPPED_EXTS + skipped_exts)

def dirs(roots: list[str], source: str = ROOT) -> list[str]:
    dir_paths = []
    for path in roots:
        dir_paths.extend([r[0] for r in list(os.walk(source + '/' + path))])
    return dir_paths

def filepaths_in_dir(dir_path: str, skipped_exts=tuple()) -> list[str]:
    return [os.path.join(dir_path, fn) for fn in os.listdir(dir_path) if ext_is_allowed(fn, skipped_exts)]

def filepaths_in_dirs(dir_paths: list[str], skipped_exts=tuple()) -> list[str]:
    filepath_list = []
    for dir_path in dir_paths:
        filepath_list.extend(filepaths_in_dir(dir_path, skipped_exts))
    return filepath_list

def json_in_dir(dir_path: str, skipped_exts=tuple()) -> list[dict]:
    return [json(fp) for fp in filepaths_in_dir(dir_path, skipped_exts)]

def json_in_dirs(dir_paths: list[str], skipped_exts=tuple()) -> list[dict]:
    obj_list = []
    for dir_path in dir_paths:
        obj_list.extend(json_in_dir(dir_path, skipped_exts))
    return obj_list

def ext(path: str):
    return path.split('.')[-1]

def get_filename(path: str):
    return os.path.basename(path)

def get_name(path: str):
    return '.'.join(get_filename(path).split('.')[:-1])

def get_patches(obj):
    if len(obj) > 0 and type(obj[0]) == list:
        return obj[0]
    return obj


# Patches


def merge_patches(source: dict, dest: dict):
    for k, v in source.items():
        if isinstance(v, dict):
            node = dest.setdefault(k, {})
            merge_patches(v, node)
        elif isinstance(v, list):
            dest.setdefault(k, [])
            dest[k].extend(v)
        else:
            dest[k] = v
    return dest


def decode_patch_list(patch_list):
    obj: dict[str] = {}
    for patch in patch_list:
        op: str = patch['op']
        if op in ('add', 'replace', ):
            path: str = patch['path']
            value: str = patch['value']
            path = path[1:].split('/')
            for i in range(len(path)-1, -1, -1):
                if path[i] == '-':
                    value = [value]
                else:
                    value = {path[i]: value}
            obj = merge_patches(value, obj)
    return obj
