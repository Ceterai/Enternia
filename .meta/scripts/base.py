import os
import pyjson5
import re


ROOT = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
HINT = '// Mod Support for {mod} (see mod description) - generated usings these scripts: https://github.com/Ceterai/Enternia/tree/main/.meta/scripts'

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

def get_files(path: str, filter_f) -> list[str]:
    file_names = os.listdir(path)
    file_paths = [os.path.join(path, file_name) for file_name in file_names if filter_f(file_name)]
    return file_paths

def get_files_flat(filter_f, paths: list[str] = None) -> list[str]:
    obj_list = []
    for path in paths or get_paths_flat():
        obj_list.extend(get_files(path, filter_f))
    return obj_list
