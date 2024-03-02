"""
This script automatically creates support for the Race Traits mod.
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#race-traits
"""

import os
import pyjson5
import pathlib
import base


PATH = '/stats/effects/om_customstats/om_racetraits/om_racetraits.statuseffect.patch'
AFFECTED_FILES = [PATH]
RACE = 'alta'
MOD = 'Racial Traits'
HINT = base.HINT.format(mod=MOD, name=base.get_file(__file__))
EXCLUDED = [
	'maxFood',
	'fuCharisma',
	'mentalProtection',
	'cosmicResistance',
	'radioactiveResistance',
	'shadowResistance',
]
CONFIG = dict(pyjson5.load(open(os.path.dirname(os.path.dirname(__file__)) + '/' + RACE + '.config')))
TEMPLATE = '''{hint}
[
  {{
    "op": "add", "path": "/effectConfig/0/{species}",
    "value": {{
      "stats": [
{stats}
      ],
      "benefits": [
{benefits}
      ],
      "controlModifiers": {{
{controls}
      }}
    }}
  }}
]
'''

def create_patch(excluded_stats: list, template: str, hint: str, species: str, path: str, pref: str='        '):
    stats = ',\n'.join([pref + pyjson5.dumps(stat) for stat in CONFIG['stats'] if stat['stat'] not in excluded_stats])
    benefits = ',\n'.join([pref + pyjson5.dumps(stat) for stat in CONFIG['benefits']])
    controls = ',\n'.join([pref + '"' + stat + '":' + pyjson5.dumps(CONFIG['controlModifiers'][stat]) for stat in CONFIG['controlModifiers']])
    result = template.format(hint=hint, species=species, stats=stats, benefits=benefits, controls=controls, diet=CONFIG.get('diet'))
    # print(result)
    # Saving...
    pathlib.Path(os.path.dirname(base.ROOT + path)).mkdir(parents=True, exist_ok=True)
    with open(base.ROOT + path, 'w') as f:
        f.write(result)

def run():
    create_patch(EXCLUDED, TEMPLATE, HINT, RACE, PATH)
