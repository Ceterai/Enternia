import shutil
import subprocess
import webbrowser
import mods
import generate_tenant_guide
import meta
import extract_version
import base


PREDEPLOY = False
DEPLOY = False

def print_affected(files):
    '''Prints affected files for your convenience.'''
    print('  Affected files:\n' + '\n'.join(['  - ' + path for path in files]))

# Step 0

print('Step 0. Check if git, gh, and other processes work fine.')
command = ['git', 'commit', '--all', '--branch', '--dry-run']
result = subprocess.run(command, encoding='utf-8', capture_output=True)
if 'Changes to be committed:' not in str(result.stdout):
    raise RuntimeError()
command = ['.\\..\\..\\win32\\asset_packer.exe']
result = subprocess.run(command, encoding='utf-8', capture_output=True)
if 'asset_packer.exe: Packs asset folder into a starbound .pak file' not in str(result.stdout):
    raise RuntimeError()
command = ['gh']
result = subprocess.run(command, encoding='utf-8', capture_output=True)
if 'Work seamlessly with GitHub from the command line.' not in str(result.stdout):
    raise RuntimeError()

# Step 1

print('Step 1. Extract latest version and changelog.')
VERSION, TITLE,  = extract_version.run()

if VERSION and TITLE:

    # Step 2

    print('Step 2. Run all mod support scripts.')
    print_affected(mods.run())

    # Step 3

    print('Step 3. Update the Tenant Guide.')
    print_affected(generate_tenant_guide.run())

    # Step 4

    print('Step 4. Update the "_metadata" file.')
    print_affected(meta.run(VERSION))

    if PREDEPLOY:

        TMP = base.os.path.join(base.MODS, 'tmp')
        ARCHIVE = base.os.path.join(base.MODS, f'My Enternia {VERSION}')
        ARCHIVE_ZIP = f'{ARCHIVE}.zip'
        ARCHIVE_PAK = f'{ARCHIVE}.pak'

        # Step 5

        print('Step 5. Create a "mods/tmp" folder with release files.')
        ignore = [name for name in base.os.listdir(base.ROOT) if name[0] == '.'] + ['README.md']
        if base.os.path.exists(TMP):
            shutil.rmtree(TMP)
        shutil.copytree(base.ROOT, TMP, ignore=shutil.ignore_patterns(*ignore))

        # Step 6

        print('Step 6. Create a .zip archive.')
        # command = ["winrar", "a", "-afzip", "-r", f"mods/My Enternia {VERSION}", "mods/tmp/*"]
        # result = subprocess.run(command, cwd=base.STARBOUND, stdout=subprocess.PIPE, universal_newlines=True, encoding='utf-8', shell=True)
        shutil.make_archive(ARCHIVE, 'zip', TMP, '.', verbose=True)

        # Step 7

        print('Step 7. Create a .pak archive.')
        command = ['.\\..\\..\\win32\\asset_packer.exe', TMP, ARCHIVE_PAK]
        result = subprocess.run(command, encoding='utf-8', shell=True)
        result = subprocess.run(command, encoding='utf-8', shell=True)

        if DEPLOY:

            # Step 8

            print('Step 8. Upload to GitHub')
            # Documentation: https://git-scm.com/docs/git-commit
            commit_msg = base.os.path.join(base.RELEASE, 'commit.txt')
            release_msg = base.os.path.join(base.RELEASE, 'notes.md')

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
            command = ['gh', 'release', 'create', VERSION, '--title', f'My Enternia {VERSION}: {TITLE}', '--notes-file', release_msg, ARCHIVE_ZIP, ARCHIVE_PAK]
            print('- Running command:', ' '.join(command))
            result = subprocess.run(command, encoding='utf-8', shell=True)

            # Step 9

            print('Step 9. Upload to Steam and Starbound Forums. Opening the browser...')
            webbrowser.open(f'{base.REPO}/releases/', new=0, autoraise=True)
            webbrowser.open('https://steamcommunity.com/sharedfiles/filedetails/changelog/2006558650', new=0, autoraise=True)
            webbrowser.open('https://community.playstarbound.com/resources/my-enternia.6252/add-version', new=0, autoraise=True)

            # Step 11

            print('Step 11. Cleanup')
            if base.os.path.exists(ARCHIVE_ZIP):
                print('- Deleting file:', ARCHIVE_ZIP)
                base.os.remove(ARCHIVE_ZIP)
            if base.os.path.exists(ARCHIVE_PAK):
                print('- Deleting file:', ARCHIVE_PAK)
                base.os.remove(ARCHIVE_PAK)
