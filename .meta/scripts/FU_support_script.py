"""
This script automatically creates support for the Frakin' Universe mod.
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#frackin-races
"""

import RT_support_script


PATH = f'/species/{RT_support_script.RACE}.raceeffect'
PATH_WINDOW = '/interface/scripted/statWindow/statWindow.config.patch'
PATH_SPECIES = f'/species/{RT_support_script.RACE}.species'
AFFECTED_FILES = [PATH, PATH_WINDOW, PATH_SPECIES]
MOD = 'Frakin Universe/Frakin Races'
HINT = RT_support_script.base.HINT.format(mod=MOD, name=RT_support_script.base.get_file(__file__))
EXCLUDED = [
    'foodDelta',
]
TEMPLATE = '''{hint}
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

def run():
	RT_support_script.create_patch(EXCLUDED, TEMPLATE, HINT, RT_support_script.RACE, PATH, '    ')
	with open(RT_support_script.base.ROOT + PATH_WINDOW, 'w') as f:
		f.write(f'''{HINT}
[
	{{
		"op": "add",
		"path": "/races/-",
		"value": "{RT_support_script.RACE}"
	}}
]
''')
	TEXT = '''

If you have ^orange;Frakin' Universe^reset;/^orange;Frakin' Races^reset;/^orange;Race Traits^reset; installed:
    ^yellow;Attributes^reset;
^cyan;Max Health^reset;: ^red;-20%^reset;
^cyan;Max Energy^reset;: ^green;+10%^reset;
^cyan;Energy Regen^reset;: ^green;+5%^reset;
    ^yellow;Resistances^reset;
^cyan;Fire Resistance^reset;: ^red;-10%^reset;
^cyan;Electric Resistance^reset;: ^green;+20%^reset;
^cyan;Poison Resistance^reset;: ^green;+5%^reset;
^cyan;Ice Resistance^reset;: ^green;+5%^reset;
^cyan;Cosmic Resistance^reset;: ^green;+10%^reset; ^gray;(FU/FR only)^reset;
^cyan;Radioactive Resistance^reset;: ^red;-25%^reset; ^gray;(FU/FR only)^reset;
^cyan;Shadow Resistance^reset;: ^red;-15%^reset; ^gray;(FU/FR only)^reset;
    ^yellow;Immunities^reset;
^#7733aa;Electrified^reset;
    ^yellow;Extra Stats^reset;
^cyan;Hunger Slowness ^gray;(Race Traits)^reset;/^cyan;Max Food ^gray;(FU/FR)^reset;: ^green;+10%^reset;
^cyan;Jump Height^reset;: ^green;+5%^reset;
^cyan;Charisma^reset;: ^green;+15%^reset; ^gray;(FU/FR only)^reset;
^cyan;Mental Protection^reset;: ^green;+15%^reset; ^gray;(FU/FR only)^reset;

^orange;Diet^reset;: ^cyan;Herbivore^reset; ^gray;(FU/FR only)^reset;
^orange;Environment^reset;: None ^gray;(FU/FR only)^reset;
^orange;Weapons^reset;: None ^gray;(FU/FR only)^reset;'''
	desc = str(''.join(RT_support_script.CONFIG.get('lore')) + TEXT).replace('\n\n', '\\n\\n').replace('\n', '  \\n')
	hint = '    ' + RT_support_script.base.HINT.format(mod='species traits mods', name=RT_support_script.base.get_file(__file__)) + '\n'
	has_hint = False
	has_desc = False
	lore_line = 0
	lines = []
	with open(RT_support_script.base.ROOT + PATH_SPECIES, 'r') as f:
		lines = f.readlines()
		for i in range(len(lines)):
			if '"subTitle"' in lines[i]:
				lore_line = i
				if '//' in lines[i+1]:
					has_hint = True
				if '"description"' in lines[i+2] or '"description"' in lines[i+1]:
					has_desc = True
				break
		if lore_line > 0:
			if has_hint:
				lines[lore_line + 1] = hint
			else:
				lines.insert(lore_line + 1, hint)
			if has_desc:
				lines[lore_line + 2] = f'    "description" : "{desc}"\n'
			else:
				lines.insert(lore_line + 2, f'    "description" : "{desc}"\n')
	with open(RT_support_script.base.ROOT + PATH_SPECIES, 'w') as f:
		f.writelines(lines)
