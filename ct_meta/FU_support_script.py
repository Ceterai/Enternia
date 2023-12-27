"""
This script automatically creates support for the Racial Traits mod.
"""

import RT_support_script


PATH = f'/species/{RT_support_script.RACE}.raceeffect'
MOD = 'Frakin Universe/Frakin Races'
EXCLUDED = [
    'foodDelta',
]
TEMPLATE = '''// Mod Support for {mod} (see mod description)
{{
	"stats": [
{stats}
	],
	"diet" : "{diet}",
  "controlModifiers": {{
{controls}
  }}
}}
'''

RT_support_script.create_patch(EXCLUDED, TEMPLATE, MOD, RT_support_script.RACE, PATH, '    ')
with open(RT_support_script.ROOT + '/interface/scripted/statWindow/statWindow.config.patch', 'w') as f:
    f.write(f'''// Mod Support for Frakin Universe/Frakin Races (see mod description)
[
	{{
		"op": "add",
		"path": "/races/-",
		"value": "{RT_support_script.RACE}"
	}}
]
''')
