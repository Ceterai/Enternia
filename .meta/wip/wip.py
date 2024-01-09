HEADER = '''
If you have ^orange;Frakin' Universe^reset;/^orange;Frakin' Races^reset;/^orange;Race Traits^reset; installed:'''
ATTRS = '''    ^yellow;Attributes^reset;
^cyan;Max Health^reset;: ^red;-20%^reset;
^cyan;Max Energy^reset;: ^green;+10%^reset;
^cyan;Energy Regen^reset;: ^green;+5%^reset;'''
RESISTS = '''    ^yellow;Resistances^reset;
^cyan;Fire Resistance^reset;: ^red;-10%^reset;
^cyan;Electric Resistance^reset;: ^green;+20%^reset;
^cyan;Poison Resistance^reset;: ^green;+5%^reset;
^cyan;Ice Resistance^reset;: ^green;+5%^reset;
^cyan;Cosmic Resistance^reset;: ^green;+10%^reset; ^gray;(FU/FR only)^reset;
^cyan;Radioactive Resistance^reset;: ^red;-25%^reset; ^gray;(FU/FR only)^reset;
^cyan;Shadow Resistance^reset;: ^red;-15%^reset; ^gray;(FU/FR only)^reset;'''
IMMUNS = '''    ^yellow;Immunities^reset;
^green;Electrified^reset;'''
EXTRA = '''    ^yellow;Extra Stats^reset;
^cyan;Hunger Slowness ^gray;(Race Traits)^reset;/^cyan;Max Food ^gray;(FU/FR)^reset;: ^green;+10%^reset;
^cyan;Jump Height^reset;: ^green;+5%^reset;
^cyan;Charisma^reset;: ^green;+15%^reset; ^gray;(FU/FR only)^reset;
^cyan;Mental Protection^reset;: ^green;+15%^reset; ^gray;(FU/FR only)^reset;'''
FUS = '''
^orange;Diet^reset;: ^cyan;Herbivore^reset; ^gray;(FU/FR only)^reset;
^orange;Environment^reset;: None ^gray;(FU/FR only)^reset;
^orange;Weapons^reset;: None ^gray;(FU/FR only)^reset;
'''

lib = {
    '': 'Max Health',
    '': 'Max Energy',
    '': 'Energy Regen',

    '': 'Fire Resistance',
    '': 'Electric Resistance',
    '': 'Poison Resistance',
    '': 'Ice Resistance',
    '': 'Cosmic Resistance',
    '': 'Radioactive Resistance',
    '': 'Shadow Resistance',

    '': 'Electrified',

    '': 'Jump Height',
    '': 'Charisma',
    '': 'Mental Protection',
}

def bonus_color(val, good=True):
    sval = f'+{int(val*100)}' if val > 0 else str(int(val*100))
    return f'^green;{sval}%^reset;' if (val > 0 and good) or (val < 0 and not good) else f'^red;{sval}%^reset;'

def stat_title(stat, lib):
    return f'^cyan;{lib[stat]}^reset;: '

def stat_val(stat):
    return f'^green;{stat}^reset;' if stat != 'None' else 'None'

def limited(stat, excl_fu, excl_rt):
    if stat in excl_rt: return ' ^gray;(FU/FR only)^reset;'
    if stat in excl_fu: return ' ^gray;(Race Traits only)^reset;'

def header(name):
    return f'    ^yellow;{name}^reset;'

def header2(name):
    return f'^orange;{name}^reset;: '

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
