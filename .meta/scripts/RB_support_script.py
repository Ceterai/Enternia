"""
This script automatically creates support for the Recipe Browser mod.
Read more about automated support for this mod here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#recipe-browser
License note: this script is a modified, simplified version of the original script written by Recipe Browser author.
"""

import pyjson5
import json
import base


PATH = '/data/FullDatabase.database.patch'
AFFECTED_FILES = [PATH]
MOD = 'Recipe Browser'
HINT = base.HINT.format(mod=MOD, name=base.get_file(__file__))

def find_objects(path):
    files = [
        base.os.path.join(root, name)
        for root, dirs, files in base.os.walk(path)
        for name in files
        if name.endswith(".object") or name.endswith(".recipe") or name.endswith("_recipes.config")
    ]
    return files

def build_database(files, tempdir, exclude = []):
    recipes_for_material = {}
    extra_recipes = {}
    extra_recipes_station = {}
    object_for_categories = {}
    object_upgrades = {}
    object_upgrade_check = []
    all_craftable_objects = set()
    
    station_in_class = {}
    station_in_class["extractionlab"] = []
    station_in_class["extractionlabmadness"] = []
    station_in_class["xenostation"] = []
    extra_recipes_station["extractionlab"] = ["extractionlab"]
    extra_recipes_station["extractionlabmadness"] = ["extractionlabmadness"]
    extra_recipes_station["xenostation"] = ["xenostation"]
    
    for abspath in files:
        
        skipping = False
        
        path = abspath.replace('\\','/')
        for n in exclude:
            if n in abspath or n in path:
                skipping = True
        
        if not skipping:
            # Load json as python dict
            try:
                with open(path, "r") as k:
                    f_lines = k.readlines()
            except:
                f_lines = []
                with open(path, "r") as fp:
                    for i in range(0, 3000): 
                        try :
                            line = fp[i]                        
                            f_lines.append(line)
                        except:
                            pass
            f = open(path, "r")
            try:
                l = pyjson5.load(f)
            except:
                temp_path = base.os.path.join(tempdir, 'temp.dat')
                delete = open(temp_path, 'w+')
                delete.close()
                g = open(temp_path, 'a+')
                
                # Catching comments
                for line in f_lines:
                    line = line.partition('//')[0] 
                    line = line.rstrip()
                    if not line.strip() == '':
                        print(line, file = g)
                g.close()
                g = open(temp_path, 'r')
                try:
                    l = pyjson5.load(g)
                except:
                    skipping = True
                finally:
                    g.close

            """ 
            Rules to parse the assets to extract the relevant information,
            based on assumed minimal necessary contents of known recipe/item data formats used in vanilla and popular mods
            """

            # Frackin Universe style extraction and similarly defined crafting
            # Parse used station, required materials and resulting item(s)
            if not skipping and abspath.endswith("centrifuge_recipes.config"):
                for k,v in l.items():
                    if k == "recipeTypes":
                        for cls, itemMaps in v.items():
                            for itemMap in itemMaps:
                                if itemMap in extra_recipes_station:
                                    extra_recipes_station[itemMap].append(cls)
                                else:
                                    extra_recipes_station[itemMap] = []
                                    extra_recipes_station[itemMap].append(cls)
                    else:
                        extra_recipes[k] = {}
                        for material,products in v.items():
                            all_craftable_objects.update(products)
                            for product in products:
                                if product in extra_recipes[k].keys():
                                    extra_recipes[k][product].append(({"item": material, "count": 1},))
                                else:
                                    extra_recipes[k][product] = list()
                                    extra_recipes[k][product].append(({"item": material, "count": 1},))
                            if material in recipes_for_material.keys():
                                recipes_for_material[material].update(products.keys())
                            else:
                                recipes_for_material[material] = set()
                                recipes_for_material[material].update(products.keys())
            elif not skipping and abspath.endswith("_recipes.config"):
                station = str.split(str.split(abspath, "\\")[-1], "_recipes")[0]
                extra_recipes[station] = {}
                for recipe in l:
                    if isinstance(recipe,str):
                        break
                    products = recipe['outputs'].keys()
                    materials = recipe['inputs'].keys()
                    all_craftable_objects.update(products)
                    for material in materials:
                        if material in recipes_for_material.keys():
                            recipes_for_material[material].update(products)
                        else:
                            recipes_for_material[material] = set()
                            recipes_for_material[material].update(products)
                    for product in products:
                        materialsAndCount = []
                        for material,count in recipe['inputs'].items():
                            if isinstance(count,list):
                                materialsAndCount.append({"item": material, "count": count[0]})
                            else:
                                materialsAndCount.append({"item": material, "count": count})
                        if product in extra_recipes[station].keys():
                            extra_recipes[station][product].append(materialsAndCount)
                        else:
                            extra_recipes[station][product] = list()
                            extra_recipes[station][product].append(materialsAndCount)
                
            # Vanilla recipes
            if not skipping and abspath.endswith(".recipe") and len(l) > 0:
                try:
                    product = l['output']['item']
                    materials = l['input']
                except:
                    try:
                        product = l['output']['name']
                        materials = l['input']
                    except:
                        product = l['output']
                        materials = l['input']
                
                if isinstance(product,list):
                    product = product[0]
                all_craftable_objects.add(product)
                    
                for descript in materials:
                    itemid = ""
                    if isinstance(descript,str):
                        itemid = descript
                    elif isinstance(descript,list):
                        itemid = descript[0]
                    else:
                        if 'item' in descript:
                            itemid = descript['item']
                        elif 'name' in descript:
                            itemid = descript['name']
                        else:
                            print(f"skipping unrecognized material {descript} in file \n {abspath}")
                            continue
                        
                    if itemid in recipes_for_material.keys():
                        recipes_for_material[itemid].add(product)
                    else:
                        recipes_for_material[itemid] = set()
                        recipes_for_material[itemid].add(product)
                
            # Parse objects for properties allowing use as a crafting station and associate them with types of crafting
            # Also find required materials for upgrading objects and create recipes from them    
            elif not skipping and abspath.endswith(".object"):
                    object_name = l["objectName"]

                # Special cases for modded items
                    # Centrifuge style objects
                    if "centrifugeType" in l:
                        stationType = l["centrifugeType"]
                        if stationType in station_in_class:
                            station_in_class[stationType].append(object_name)
                        else:
                            station_in_class[stationType] = []
                            station_in_class[stationType].append(object_name)
                    # Special cases for modded items using scripts
                    if "scripts" in l:
                        for script in l["scripts"]:
                            if script.endswith("extractionlab_common.lua"):
                                station_in_class["extractionlab"].append(object_name)
                            elif script.endswith("extractionlab_madness.lua"):
                                station_in_class["extractionlabmadness"].append(object_name)
                            elif script.endswith("xenostation_common.lua"):
                                station_in_class["xenostation"].append(object_name)
                    
                    materials = []
                # Vanilla style crafting station without upgrades 
                    if "interactData" in l.keys() and "upgradeStages" not in l.keys():
                        if "filter" in l["interactData"]:
                            for group in l["interactData"]["filter"]:
                                if group not in ['all', 'disabled']:  
                                    if group in object_for_categories.keys():
                                        object_for_categories[group].add(object_name)
                                    else:
                                        object_for_categories[group] = set()
                                        object_for_categories[group].add(object_name)
                # Upgradeable crafting stations                
                    elif "upgradeStages" in l.keys():
                        stage_number = 0
                        # max_stage = l["maxUpgradeStage"]
                        for stage in l["upgradeStages"]:
                            # Create item data with correct parameters for upgraded object, using custom name for upgraded versions
                            # (current format is object_nameN, with N being the stage or tier of upgrade and object_name being the id of the base version (N=1))
                            stage_number += 1
                            
                            item_parameters = {}
                            for key, value in stage["itemSpawnParameters"].items():

                                item_parameters[key] = value
                            # Parameter determining the version of the object when created
                            item_parameters["startingUpgradeStage"] = stage_number
                            
                            belongs_to = {"name" : object_name,  "parameters" : item_parameters}
                            
                            if materials != []:
                                belongs_to["upgradeRecipe"] = materials
                            
                            if stage_number == 1:
                                upgrade_name = object_name
                            else:
                                upgrade_name = object_name + str(stage_number)
                            
                            if upgrade_name in object_upgrades.keys():
                                if stage_number == 1:
                                    print("ERROR, duplicate name")
                                    print(f"object name {upgrade_name} is already used as upgrade name for object {object_upgrades[upgrade_name]['name']}")
                                else:
                                    print("ERROR, multiple parents for upgrade:")
                                    print(f"failed to register upgrade name {upgrade_name} for object {object_name}")
                                    print(f"already registered upgrade name {upgrade_name} for object {object_upgrades[upgrade_name]['name']}")
                            else:
                                object_upgrades[upgrade_name] = belongs_to
                            
                            if stage_number == 1:
                                
                                if "interactData" in stage.keys():
                                    # Handle each stage like a separate crafting station, new recipes are unlocked by adding new crafting categories to "filter"
                                    if "filter" in stage["interactData"].keys():
                                        for group in stage["interactData"]["filter"]:
                                            if group not in ['all', 'disabled']: 
                                                if group in object_for_categories.keys():
                                                    object_for_categories[group].add(upgrade_name)
                                                else:
                                                    object_for_categories[group] = set()
                                                    object_for_categories[group].add(upgrade_name)
                                    # Upgrading an object is also a recipe, but not as readily accessible from in-game
                                    # use stage N and required materials as input, stage N+1 as output
                                    # and treat it like a vanilla recipe,
                                    # then save the inputs as a parameter of the created item data for the next stage (at the start of the next loop)
                                    if "upgradeMaterials" in stage["interactData"].keys():
                                        materials = stage["interactData"]["upgradeMaterials"][:]
                                        materials.append({"item" : upgrade_name, "count" : 1})
                                        all_craftable_objects.add(object_name + str(stage_number+1))
                                        for descript in materials :
                                            if descript['item'] in recipes_for_material.keys():
                                                recipes_for_material[descript['item']].add(object_name + str(stage_number+1))
                                            else:
                                                recipes_for_material[descript['item']] = set()
                                                recipes_for_material[descript['item']].add(object_name + str(stage_number+1))
                                # If an object uses addons, treat them like a separate station
                                if "addonConfig" in stage.keys():
                                    if "usesAddons" in stage["addonConfig"].keys():
                                        for add_on in stage["addonConfig"]["usesAddons"]:
                                            if "addonData" in add_on.keys():
                                                add_on_name = str(add_on['name']).lower()
                                                if "interactData" in add_on["addonData"].keys():
                                                    if "filter" in add_on["addonData"]["interactData"]:
                                                        for group in add_on["addonData"]["interactData"]["filter"]:
                                                            if group not in ['all', 'disabled']: 
                                                                if group in object_for_categories.keys():
                                                                    object_for_categories[group].add(add_on_name)
                                                                else:
                                                                    object_for_categories[group] = set()
                                                                    object_for_categories[group].add(add_on_name)
                                
                            else:
                                # Same as first iteration, but use custom id instead of base object name
                                upgrade_name = object_name + str(stage_number)
                                # Save custom id so the mod can reference it
                                object_upgrade_check.append(upgrade_name)

                                if "interactData" in stage.keys():
                                    if "filter" in stage["interactData"].keys():
                                        for group in stage["interactData"]["filter"]:
                                            if group not in ['all', 'disabled']: 
                                                if group in object_for_categories.keys():
                                                    object_for_categories[group].add(upgrade_name)
                                                else:
                                                    object_for_categories[group] = set()
                                                    object_for_categories[group].add(upgrade_name)
                                    if "upgradeMaterials" in stage["interactData"].keys():
                                        materials = stage["interactData"]["upgradeMaterials"][:]
                                        materials.append({"item" : upgrade_name, "count" : 1})
                                        all_craftable_objects.add(object_name + str(stage_number+1))
                                        for descript in materials :
                                            if descript['item'] in recipes_for_material.keys():
                                                recipes_for_material[descript['item']].add(object_name + str(stage_number+1))
                                            else:
                                                recipes_for_material[descript['item']] = set()
                                                recipes_for_material[descript['item']].add(object_name + str(stage_number+1))
                                        materials.pop()

                                if "addonConfig" in stage.keys():
                                    if "usesAddons" in stage["addonConfig"].keys():
                                        for add_on in stage["addonConfig"]["usesAddons"]:
                                            if "addonData" in add_on.keys():
                                                add_on_name = str(add_on['name']).lower()
                                                if "interactData" in add_on["addonData"].keys():
                                                    if "filter" in add_on["addonData"]["interactData"]:
                                                        for group in add_on["addonData"]["interactData"]["filter"]:
                                                            if group not in ['all', 'disabled']: 
                                                                if group in object_for_categories.keys():
                                                                    object_for_categories[group].add(add_on_name)
                                                                else:
                                                                    object_for_categories[group] = set()
                                                                    object_for_categories[group].add(add_on_name)

            f.close()
        else:
            pass
    # Preparation to convert outputs to database format
    for k,v in recipes_for_material.items():
        recipes_for_material[k]=list(v)
    for k,v in object_for_categories.items():
        object_for_categories[k]=list(v)
    for k,v in extra_recipes_station.items():
        all_stations = []
        for i in v:
            if i in station_in_class:
                all_stations.extend(station_in_class[i])
        extra_recipes_station[k] = all_stations

    return [recipes_for_material, object_for_categories, object_upgrades, object_upgrade_check, list(all_craftable_objects), extra_recipes, extra_recipes_station]


def add_indent(jsn: str, indent: str):
    l = jsn.split('\n')
    return '\n'.join([(indent if i > 0 else '') + l[i] for i in range(len(l))])


def run(exclude = []):
    """
    Database Format (json dict) (also format for 'value' field in .patch file):
    - `craftingStationDatabase` : 'object_upgrades' in build_database function, dictionary mapping ids of craftingstations to their item data in json format
      (necessary because Starbound does not have item ids for upgraded versions of objects (they are the same item in different states), so we define them manually to be able to refer to a specific version)
    - `craftingGroupsDatabase` : 'object_for_categories', dictionary mapping crafting categories to ids of stations of that type (i.e. where items of those categories can be crafted) 
    - `stationUpgradeCheck` : 'object_upgrade_check', list of custom ids assigned to station upgrades
    - `recipeDatabase` : 'recipes_for_material', dictionary mapping ids of materials to ids of items including them in their recipe
      (the inverse -the recipe for any given item- is supported in starbounds modding api already, except for upgrades to stations and non-standard ways of crafting, like the refinery or Fracking Universes Extractors)
    - `allCraftableObjects` : 'all_craftable_objects', list of all craftable objects
    - `extra_recipes` : 'extra_recipes', dictionary mapping non-standard ways of crafting to products obtained by them and the required materials
    - `extra_recipes_station` : 'extra_recipes_station', like "craftingGroupsDatabase", but mapping types of modded/non-standard crafting to stations supporting them
    """
    recipe_data_files = find_objects(base.ROOT)

    result = build_database(recipe_data_files, base.os.path.join(base.ROOT, r'temp'), exclude)

    output: str = (
        '{\n' +
        '      "craftingStationDatabase" : ' +
        add_indent(json.dumps(result[2], indent=2), '      ') +
        ',\n' +
        '      "craftingGroupsDatabase" : ' +
        add_indent(json.dumps(result[1], indent=2), '      ') +
        ',\n' +
        '      "stationUpgradeCheck" : ' +
        add_indent(json.dumps(result[3], indent=2), '      ') +
        ',\n' +
        '      "recipeDatabase" : ' +
        add_indent(json.dumps(result[0], indent=2), '      ') +
        ',\n' +
        '      "allCraftableObjects" : ' +
        add_indent(json.dumps(result[4], indent=2), '      ') +
        ',\n' +
        '      "extra_recipes" : ' +
        add_indent(json.dumps(result[5], indent=2), '      ') +
        ',\n' +
        '      "extra_recipes_station" : ' +
        add_indent(json.dumps(result[6], indent=2), '      ') +
        '\n    }'
    )
    output_patch = '[  ' + HINT + '\n  {\n    "op": "add",\n    "path": "/-",\n    "value": ' + output + '\n  }\n]\n'
    with open(base.ROOT + PATH, 'w+') as f:
        f.write(output_patch)
