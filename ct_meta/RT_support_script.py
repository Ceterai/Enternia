"""
This script automatically creates support for the Racial Traits mod.
"""

import os
import pyjson5
import pathlib


ROOT = os.path.dirname(os.path.dirname(__file__))
PATH = '/stats/effects/om_customstats/om_racetraits/om_racetraits.statuseffect.patch'
RACE = 'alta'
MOD = 'Racial Traits'
EXCLUDED = [
	'maxFood',
	'fuCharisma',
	'mentalProtection',
	'cosmicResistance',
	'radioactiveResistance',
	'shadowResistance',
]
CONFIG = dict(pyjson5.load(open(os.path.dirname(__file__) + '/' + RACE + '_config.json')))
TEMPLATE = '''// Mod Support for {mod} (see mod description)
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

def create_patch(excluded_stats: list, template: str, mod: str, species: str, path: str, pref: str='        '):
    stats = ',\n'.join([pref + pyjson5.dumps(stat) for stat in CONFIG['stats'] if stat['stat'] not in excluded_stats])
    benefits = ',\n'.join([pref + pyjson5.dumps(stat) for stat in CONFIG['benefits']])
    controls = ',\n'.join([pref + '"' + stat + '":' + pyjson5.dumps(CONFIG['controlModifiers'][stat]) for stat in CONFIG['controlModifiers']])
    result = template.format(mod=mod, species=species, stats=stats, benefits=benefits, controls=controls, diet=CONFIG.get('diet'))
    print(result)
    # Saving...
    pathlib.Path(os.path.dirname(ROOT + path)).mkdir(parents=True, exist_ok=True)
    with open(ROOT + path, 'w') as f:
        f.write(result)

create_patch(EXCLUDED, TEMPLATE, MOD, RACE, PATH)
