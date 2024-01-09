"""Run this script to update all mod support related files."""

import RT_support_script as RT, FU_support_script as FU, IFD_support_script as IFD, MPI_support_script as MPI, json

METADATA_PATH = '/_metadata'

with open(RT.base.ROOT + '/.meta/description.md', 'r') as f:
    mod_info = RT.base.get_obj(RT.base.ROOT + METADATA_PATH)
    mod_desc = ''.join(f.readlines())
    mod_info['description'] = mod_desc
    json.dump(mod_info, open(RT.base.ROOT + METADATA_PATH, 'w'), indent=2)

RT.run()
FU.run()
IFD.run()
MPI.run()
print('Affected files:\n' + '\n'.join(['- ' + path for path in (
    RT.AFFECTED_FILES +
    FU.AFFECTED_FILES +
    IFD.AFFECTED_FILES +
    MPI.AFFECTED_FILES +
    [METADATA_PATH]
)]))
