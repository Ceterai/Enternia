import base
import re


CHANGELOG = base.os.path.join(base.META, 'changelog.md')
RELEASE_LOG = base.os.path.join(base.RELEASE, 'notes.md')
COMMIT_LOG = base.os.path.join(base.RELEASE, 'commit.txt')
MESSAGE_LOG = base.os.path.join(base.RELEASE, 'info.txt')

TITLE_REGEX = r'## Update [0-9].[0-9]+ - ([^\n]+)'
VERSION_REGEX = r'### ([0-9]\.[0-9]\.[0-9][a-z]?)'
SUBTITLE_REGEX = r'\*\*([A-Za-z0-9\s]+)\:\*\*'

MESSAGE = """- GitHub direct download links:
{repo}/releases/download/{version}/My.Enternia.{version}.zip
{repo}/releases/download/{version}/My.Enternia.{version}.pak

- GitHub release info:
My Enternia {version}: {title}

- Steam changelog message:
View the changelog for this version here: [url={repo}/blob/main/.meta/changelog.md#{v}]Update {version} Changelog[/url]
Link: https://steamcommunity.com/sharedfiles/filedetails/changelog/2006558650

- Starbound Forums changelog message:
My Enternia {version} Patch
View the changelog for this version here: [URL='{repo}/blob/main/.meta/changelog.md#{v}']Update {version} Changelog[/URL]
Link: https://community.playstarbound.com/resources/my-enternia.6252/add-version
"""


def run():
    title = None
    version = None
    changelog: list[str] = []
    with open(CHANGELOG, encoding='utf-8') as f:
        for line in f.readlines():
            result = re.match(TITLE_REGEX, line)
            if result:
                title = result.group(1)
            result = re.match(VERSION_REGEX, line)
            if result:
                if version:
                    break
                version = result.group(1)
            elif version:
                changelog.append(line)
    if title:
        print(f'  Found latest title: {title}')
    if version:
        print(f'  Found latest version: {version}')
        with open(RELEASE_LOG, 'w') as f:
            for line in changelog[1:-1]:
                result = re.match(SUBTITLE_REGEX, str(line))
                if result:
                    line = f'### {result.group(1)}\n'
                f.write(re.sub(r'\!\[ \]\(\/', '![ ](' + base.IMAGE_PATH + '/', line))
        print(f'  Release log saved to: {RELEASE_LOG}')
        with open(COMMIT_LOG, 'w') as f:
            f.write(f'Update {version}\n\n')
            for line in changelog[1:-1]:
                l = re.sub(r'\!\[ \]\([^\)]+\)', '', line.replace('**', '').replace('   \n', '\n'))
                if l not in ('       \n', '      \n', '     \n', '     \n', '    \n', '   \n', '  \n', ' \n'):
                    f.write(l)
        print(f'  Commit message saved to: {COMMIT_LOG}')
        with open(MESSAGE_LOG, 'w') as f:
            ARCHIVE = base.os.path.join(base.MODS, f'My Enternia {version}')
            f.write(MESSAGE.format(repo=base.REPO, version=version, v=version.replace('.', ''), title=title, notes=RELEASE_LOG, asset=ARCHIVE))
        print(f'  Release templates saved to: {MESSAGE_LOG}')
        return version, title
