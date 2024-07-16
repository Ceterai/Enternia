"""
Run this script to update all mod support related files.
Read more about automated mod support here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support
"""

import RT_support_script as RT
import FU_support_script as FU
import IFD_support_script as IFD
import MPI_support_script as MPI
import EES_support_script as EES
import WI_support_script as WI
import generate_tenant_guide as TG
import json

METADATA_PATH = '/_metadata'

# Updates metadata with description from `description.txt`
with open(RT.base.ROOT + '/.meta/description.txt', 'r') as f:
    mod_info = RT.base.get_obj(RT.base.ROOT + METADATA_PATH)
    mod_desc = ''.join(f.readlines())
    mod_info['description'] = mod_desc
    json.dump(mod_info, open(RT.base.ROOT + METADATA_PATH, 'w'), indent=2)

# Runs all support scripts
RT.run()
FU.run()
IFD.run()
MPI.run()
EES.run()
WI.run()

# Updates the Tenant Guide
TG.run()

# Prints affected files for your convenience
print('Affected files:\n' + '\n'.join(['- ' + path for path in (
    RT.AFFECTED_FILES +
    FU.AFFECTED_FILES +
    IFD.AFFECTED_FILES +
    MPI.AFFECTED_FILES +
    EES.AFFECTED_FILES +
    WI.AFFECTED_FILES +
    [METADATA_PATH]
)]))
