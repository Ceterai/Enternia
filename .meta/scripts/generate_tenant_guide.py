import base


WIKI_URL = 'https://raw.githubusercontent.com/wiki/Ceterai/Enternia/'
FILE_PATH = '/.meta/wiki/tenants.md'
CATEGORIES = {
    'alta' : '## Alta',
    'casual' : '### Casual',
    'official' : '#### Official',
    'service' : '#### Service',
    'tech' : '#### Tech',
    'science' : '### Scientific',
    'arco' : '#### A.R.C.O.',
    'eds' : '#### EDS',
    'hevika' : '#### Hevika Ordis',
    'ghearun' : '#### Ghearun',
    'ceterai' : '#### Ceterai Project',
    'neiteru' : '#### Neiteru-1',
    'lab' : '#### Alta Lab',
    'tserera' : '#### Tserera',
    'themed_science' : '#### Themed Researchers',
    'themed' : '### Themed',
    'travel' : '#### Travel',
    'order' : '#### Order',
    'miniknog' : '#### MKI',
    'human' : '#### Human',
    'nature' : '#### Nature',
    'colorful' : '#### Colorful',
    'tropical' : '#### Tropical',
    'holiday' : '#### Holiday',
    'retro' : '#### Track',
    'tiered' : '#### Tiered',
    'guard' : '### Guards',
    'guard_l3' : '#### Level 3',
    'guard_l4' : '#### Level 4',
    'guard_l5' : '#### Level 5',
    'guard_l6' : '#### Level 6',
    'guard_l7' : '#### Level 7 and above',
    'guard_l0' : '#### Unleveled',
    'android' : '#### Androids',
}


def is_obj_file(name: str) -> bool:
    return (base.get_ext(name) == 'tenant')


def get_image(path: str):
    return f'![ ]({WIKI_URL}{path})' if path else ''


class Tenant:
    def __init__(self, obj: dict[str]):
        self.raw = obj

    @property
    def desc(self):
        return self.raw.get('wiki', {}).get('description', '')

    @property
    def name(self):
        return self.raw.get('wiki', {}).get('title', '')

    @property
    def id(self):
        return self.raw.get('name', '')

    @property
    def npc(self):
        return self.raw.get('tenants', [{}])[0].get('type', '')

    @property
    def species(self):
        return self.raw.get('tenants', [{}])[0].get('species', '')

    @property
    def tags(self):
        tags = self.raw.get('colonyTagCriteria', {})
        return {tag: tags[tag] for tag in tags if tag not in ('light', 'door',)}

    @property
    def tags_str(self):
        return ', '.join([f'`{tag}` ({self.tags[tag]})' for tag in self.tags])

    @property
    def category(self):
        return self.raw.get('wiki', {}).get('category', '')

    @property
    def images(self) -> dict[str]:
        return self.raw.get('wiki', {}).get('images', {})

    @property
    def icon(self) -> str:
        return get_image(self.images.get('main'))

    @property
    def primary_images(self) -> str:
        return '\n'.join([get_image(img) for img in self.images.get('primary', [])])

    @property
    def secondary_images(self) -> str:
        return '\n'.join([get_image(img) for img in self.images.get('secondary', [])])

    @property
    def old_images(self) -> str:
        return ('Old variants:\n\n' + '\n'.join([get_image(img) for img in self.images.get('old', [])])) if self.images.get('old') else ''


def get_tenants():
    return [Tenant(obj) for obj in base.get_objects(is_obj_file).values()]


def get_tenants_by_cats(all_tenants: list[Tenant]):
    result = {cat : [] for cat in CATEGORIES}
    result[''] = []
    for tenant in all_tenants:
        result[tenant.category].append(tenant)
    return result


def get_table_head():
    return '''
<tr valign="middle"><th>
Sprite
</th> <th>
Description </th></tr>
'''


def get_table_expand(tenant: Tenant):
    return f'''
<details>
<summary>Examples: (Expand)</summary>

{tenant.primary_images}

{tenant.secondary_images}

{tenant.old_images}
</details>
''' if tenant.primary_images or tenant.secondary_images or tenant.old_images else ''


def get_table_row(tenant: Tenant):
    return f'''
<tr><td valign="middle" align="middle">

{tenant.icon}
</td><td>

Type: **{tenant.name}**

Tags: {tenant.tags_str}

{tenant.desc}
{get_table_expand(tenant)}
</td></tr>
'''


def get_table(tenants: list[Tenant]):
    rows = '\n'.join(get_table_row(tenant) for tenant in tenants)
    return f'''
<table> <tbody valign="top">
{get_table_head()}
{rows}
</table>
'''


def get_text():
    all_tenants = get_tenants()
    tenants = get_tenants_by_cats(all_tenants)
    body = f'This mod adds a total of {len(all_tenants)} tenants.\n\n'
    for cat in CATEGORIES:
        body = body + CATEGORIES[cat] + '\n'
        if len(tenants[cat]) > 0:
            body = body + get_table(tenants[cat])
        body = body + '\n'
    return body.replace('\n\n\n\n\n', '\n\n').replace('\n\n\n\n', '\n\n').replace('\n\n\n', '\n\n')[:-1]


def run():
    with open(base.ROOT + FILE_PATH, 'w') as guide:
        guide.write(get_text())
