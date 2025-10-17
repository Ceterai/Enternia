import argparse
import shutil
import subprocess
import webbrowser
import mods
import generate_tenant_guide
import meta
import extract_version
import base
from wiki import gen


def _print_affected(files):
    '''Prints affected files for your convenience.'''
    print('  Affected files:\n' + '\n'.join(['  - ' + path for path in files]))

def check_bash_commands():
    """Check if git, gh, and other processes work fine."""
    print('Step 0. Check if git, gh, and other processes work fine.')
    command = ['git', '--version']
    result = subprocess.run(command, encoding='utf-8', capture_output=True, shell=True, errors='replace')
    if 'git version' not in str(result.stdout):
        raise RuntimeError('Git check failed')
    path_game_root = base.os.path.dirname(base.os.path.dirname(base.ROOT))
    path_asset_packer = base.os.path.join(path_game_root, 'win32', 'asset_packer.exe')
    command = [path_asset_packer, '--help']
    print('- Running command:', ' '.join(command))
    result = subprocess.run(command, encoding='utf-8', capture_output=True, shell=True, errors='replace')
    output = str(result.stdout) + str(result.stderr)
    if 'asset_packer.exe: Packs asset folder into a starbound .pak file' not in output:
        raise RuntimeError('Asset packer check failed: ' + output)
    command = ['gh']
    result = subprocess.run(command, encoding='utf-8', capture_output=True, shell=True, errors='replace')
    output = str(result.stdout) + str(result.stderr)
    if 'Work seamlessly with GitHub from the command line.' not in output:
        raise RuntimeError('GitHub CLI check failed')

def process_changes():
    """Extract latest version and changelog."""
    print('Step 1. Extract latest version and changelog to make sure a new version exists.')
    VERSION, TITLE = extract_version.run()
    if not VERSION or not TITLE:
        raise RuntimeError()
    return VERSION, TITLE

def update_mod_support():
    """Step 2.1. Run all mod support scripts."""
    print('Step 2.1. Run all mod support scripts.')
    _print_affected(mods.run())

def update_tenant_guide():
    """Step 2.2. Update the Tenant Guide."""
    print('Step 2.2. Update the Tenant Guide.')
    _print_affected(generate_tenant_guide.run())

def update_database():
    """Step 2.3. Update the `data/alta_database.json` file."""
    print('Step 2.3. Update the `data/alta_database.json` file.')
    _print_affected(gen.run()[1])

def update_metadata(version):
    """Step 2.4. Update the "_metadata" file."""
    print('Step 2.4. Update the "_metadata" file.')
    _print_affected(meta.run(version))

def predeploy_checks(version):
    update_mod_support()
    update_tenant_guide()
    update_database()
    update_metadata(version)

def predeploy_process(version):
    TMP = base.os.path.join(base.MODS, 'tmp')
    ARCHIVE = base.os.path.join(base.MODS, f'My Enternia {version}')
    ARCHIVE_ZIP = f'{ARCHIVE}.zip'
    ARCHIVE_PAK = f'{ARCHIVE}.pak'

    print('Step 3.1. Create a "mods/tmp" folder with release files.')
    ignore = [name for name in base.os.listdir(base.ROOT) if name[0] == '.'] + ['README.md']
    if base.os.path.exists(TMP):
        shutil.rmtree(TMP)
    shutil.copytree(base.ROOT, TMP, ignore=shutil.ignore_patterns(*ignore))

    print('Step 3.2. Create a .zip archive.')
    shutil.make_archive(ARCHIVE, 'zip', TMP, '.', verbose=True)

    print('Step 3.3. Create a .pak archive.')
    path_game_root = base.os.path.dirname(base.os.path.dirname(base.ROOT))
    path_asset_packer = base.os.path.join(path_game_root, 'win32', 'asset_packer.exe')
    command = [path_asset_packer, TMP, ARCHIVE_PAK]
    result = subprocess.run(command, encoding='utf-8', shell=True)
    result = subprocess.run(command, encoding='utf-8', shell=True)

    return ARCHIVE_ZIP, ARCHIVE_PAK

def deploy(version, title, archive_zip, archive_pak):
    print('Step 4.1. Upload to GitHub')
    # Documentation: https://git-scm.com/docs/git-commit
    commit_msg = base.os.path.join(base.RELEASE, 'commit.txt')
    release_msg = base.os.path.join(base.RELEASE, 'notes.md')

    # Create a new commit and push it to GitHub
    command = ['git', 'add', '.']
    print('- Running command:', ' '.join(command))
    result = subprocess.run(command, encoding='utf-8', shell=True)
    command = ['git', 'commit', '--all', '--branch', '--file=' + commit_msg]
    print('- Running command:', ' '.join(command))
    result = subprocess.run(command, encoding='utf-8', shell=True)
    command = ['git', 'push']
    print('- Running command:', ' '.join(command))
    result = subprocess.run(command, encoding='utf-8', shell=True)

    # Installation: https://github.com/cli/cli?tab=readme-ov-file#windows
    # Documentation: https://cli.github.com/manual/gh_release_create
    command = ['gh', 'release', 'create', version, '--title', f'My Enternia {version}: {title}', '--notes-file', release_msg, archive_zip, archive_pak]
    print('- Running command:', ' '.join(command))
    result = subprocess.run(command, encoding='utf-8', shell=True)

    print('Step 4.2. Upload to Steam and Starbound Forums. Opening the browser...')
    webbrowser.open(f'{base.REPO}/releases/', new=0, autoraise=True)
    webbrowser.open('https://steamcommunity.com/sharedfiles/filedetails/changelog/2006558650', new=0, autoraise=True)
    webbrowser.open('https://community.playstarbound.com/resources/my-enternia.6252/add-version', new=0, autoraise=True)
    webbrowser.open('https://www.nexusmods.com/starbound/mods/1057?tab=files', new=0, autoraise=True)

def cleanup(archive_zip, archive_pak):
    print('Step 11. Cleanup')
    if base.os.path.exists(archive_zip):
        print('- Deleting file:', archive_zip)
        base.os.remove(archive_zip)
    if base.os.path.exists(archive_pak):
        print('- Deleting file:', archive_pak)
        base.os.remove(archive_pak)

def main():
    """
    Main entry point for the deployment script.
    This function parses command-line arguments and executes the appropriate action
    for deploying the My Enternia mod for Starbound.
    Available actions:
        - check: Verify that required bash commands are available
        - mod-support: Run mod support scripts as described here: /.meta/wiki/manual/Modding-Mod-Support.md
        - tenants: Update tenant list
        - db: Update the Alta Universal Information & Knowledge Accumulation (Alta UIKA) database: /data/alta_database.json
        - meta: Update /.metadata file (requires --version) with new version
        - prepare: Run pre-deployment checks, mod support scripts, tenant script, database and metadata updates
        - predeploy: Create deployment archives (requires --version)
        - deploy: Deploy the mod to distribution platforms (requires --version, --title, --zip, --pak)
        - cleanup: Remove temporary deployment files (requires --zip, --pak)
    Args:
        Command-line arguments parsed by argparse:
            action (str): The action to perform (see choices above)
            --version (str, optional): Version string for the release
            --title (str, optional): Title for the release
            --zip (str, optional): Path to the .zip archive
            --pak (str, optional): Path to the .pak archive
    Returns:
        None
    Examples:
        python deploy.py check
        python deploy.py meta --version "1.2.3"
        python deploy.py deploy --version "1.2.3" --title "New Release" --zip "path/to/file.zip" --pak "path/to/file.pak"
    """
    parser = argparse.ArgumentParser(description='Deploy script for My Enternia mod')
    parser.add_argument('action', choices=['check', 'mod-support', 'tenants', 'db', 'meta', 'prepare', 'predeploy', 'deploy', 'cleanup'],
                        help='Action to perform', default='check')
    parser.add_argument('--version', help='Version string')
    parser.add_argument('--title', help='Release title')
    parser.add_argument('--zip', help='Path to .zip archive')
    parser.add_argument('--pak', help='Path to .pak archive')
    
    args = parser.parse_args()
    
    if args.action == 'check':
        check_bash_commands()
    
    elif args.action == 'mod-support':
        update_mod_support()
    
    elif args.action == 'tenants':
        update_tenant_guide()
    
    elif args.action == 'db':
        update_database()
    
    elif args.action == 'meta':
        if not args.version:
            print("Error: --version is required for 'meta' action")
            return
        update_metadata(args.version)
    
    elif args.action == 'prepare':
        check_bash_commands()
        version, title = process_changes()
        predeploy_checks(version)
        print(f'\nNext step:\npython .meta/scripts/deploy.py predeploy --version "{version}" --title "{title}"')
    
    elif args.action == 'predeploy':
        if not args.version:
            print("Error: --version is required for 'predeploy' action")
            return
        archive_zip, archive_pak = predeploy_process(args.version)
        print(f'\nNext steps:')
        print(f'python .meta/scripts/deploy.py deploy --version "{args.version}" --title "{args.title}" --zip "{archive_zip}" --pak "{archive_pak}"')
        print(f'python .meta/scripts/deploy.py cleanup --zip "{archive_zip}" --pak "{archive_pak}"')
    
    elif args.action == 'deploy':
        if not all([args.version, args.title, args.zip, args.pak]):
            print("Error: --version, --title, --zip, and --pak are required for 'deploy' action")
            return
        deploy(args.version, args.title, args.zip, args.pak)
    
    elif args.action == 'cleanup':
        if not all([args.zip, args.pak]):
            print("Error: --zip and --pak are required for 'cleanup' action")
            return
        cleanup(args.zip, args.pak)

if __name__ == '__main__':
    main()
