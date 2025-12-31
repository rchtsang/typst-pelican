import os
import platform
import shutil
import argparse
from pathlib import Path

import toml

"""
a local install script for typst packages
"""

PKG_DIR = Path(__file__).parent
PKG_META = toml.load(PKG_DIR / "typst.toml")['package']

DATA_DIR = None

match (system := platform.system()):
    case "Darwin":
        DATA_DIR = Path("~/Library/Application Support").expanduser()
    case "Linux":
        if "XDG_DATA_HOME" in os.environ:
            DATA_DIR = os.environ["XDG_DATA_HOME"]
        else:
            DATA_DR = Path("~/.local/share").expanduser()
    case "Windows":
        assert (DATA_DIR := os.getenv("APPDATA")), "%APPDATA% not set"
    case _:
        assert False, "unsupported system: {}".format(system)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="install.py", description=__doc__)
    parser.add_argument('-n', '--namespace', dest="namespace", type=str,
        default="local",
        help="override typst package namespace (default: `local`)")
    parser.add_argument('--data-dir', dest='data_dir', type=Path,
        default=DATA_DIR,
        help=f"override system data directory (default: {str(DATA_DIR)})")
    parser.add_argument('--force', dest='force', action='store_true',
        default=False,
        help="force package reinstall")
    parser.add_argument('--rm', '--remove', dest='remove',
        action='store_true',
        default=False,
        help="remove installation")

    args = parser.parse_args()
    
    pkg_loc = args.data_dir / "typst" / "packages" / args.namespace
    install_loc = pkg_loc / PKG_META['name'] / PKG_META['version']

    print("package info:")
    for field, value in PKG_META.items():
        print(f"{field}: {value}")
    print()
    print(f"package directory: {str(pkg_loc)}")
    
    if not input("continue? (y/N): ").lower().startswith('y'):
        print("aborted.")
        exit(0)

    print(f"package install location: {str(install_loc)}")
    
    if install_loc.is_dir():
        if not args.force:
            print("package already installed.")
            exit(0)

        print("removing previous installation...")
        shutil.rmtree(install_loc)

        if args.remove:
            print("removed {PKG_META['name']}")
            exit(0)
    elif args.remove:
        print("package not found.")
        exit(0)

    install_loc.mkdir(parents=True, exist_ok=True)

    ignore = shutil.ignore_patterns(
        '.git',
        '.DS_Store',
        '.gitignore',
        'install.py',
    )

    print(f"installing {PKG_META['name']}...")
    shutil.copytree(PKG_DIR, install_loc, ignore=ignore, dirs_exist_ok=True)
    print(f"installed {PKG_META['name']}")
