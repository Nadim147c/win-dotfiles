from rich.progress import Progress
import json
import requests
import colorama
import ctypes
import subprocess
import shutil
import sys
import yaml
import os

colorama.init()
WHITE = colorama.Fore.WHITE
GREEN = colorama.Fore.GREEN
RED = colorama.Fore.RED
CYAN = colorama.Fore.CYAN
YELLOW = colorama.Fore.YELLOW

DOTFILE_REPO = "https://github.com/Nadim147c/win-dotfiles"

is_admin = ctypes.windll.shell32.IsUserAnAdmin() != 0
is_debug = "--debug" in sys.argv


def colorize(text: str, color: str):
    return f"{color}{text}{colorama.Fore.WHITE}"


def pc(text: str, color: str):
    print(colorize(text, color))


def download_file(url: str, destination: str):
    response = requests.get(url, stream=True)
    if os.path.exists(destination):
        print(f"${url}\n   already exists in {destination}")
        return

    if response.status_code == 200:
        total_size = int(response.headers.get("content-length", 0))
        current_size = 0

        with Progress() as progress:
            task = progress.add_task("[cyan]Downloading: ", total=total_size)

            with open(f"temp/{destination}", "wb") as file:
                for chunk in response.iter_content(chunk_size=1024):
                    file.write(chunk)
                    current_size += len(chunk)
                    progress.update(task, completed=current_size)

    else:
        print(f"Failed to download file. Status code: {response.status_code}")


if is_admin:
    pc("User has admin permission.", GREEN)
else:
    pc("Missing admin permission. Please run this script as administrator.", RED)
    if not is_debug:
        sys.exit(1)


def is_command_exists(cmd: "list[str]") -> bool:
    pipe = subprocess.PIPE
    exists = subprocess.run(cmd, text=True, stdout=pipe, stderr=pipe)
    return True if exists.stdout else False


# Installing package managers
pc("Installing package managers", CYAN)

# Checking and installing winget
winget_exists = is_command_exists(["winget"])

if winget_exists:
    pc("winget already exists", GREEN)
else:
    pc("Installing winget...", CYAN)

    release_uri = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    pc(f"Fetching {release_uri}", WHITE)

    response = requests.get(release_uri)

    if response.status_code == 200:
        results = response.json()

        url = ""

        for asset in results["assets"]:
            if asset["name"].endswith(".msixbundle"):
                url = asset["browser_download_url"]
                break

        if not url:
            pc("Failed to find download uri for winget", RED)
            sys.exit(1)

        print(f"Donwloading {url}")

        download_file(url, "winget.msixbundle")

        pc("Finishing winget installation", CYAN)

        powershell = r"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
        subprocess.call(
            f"{powershell} Add-AppxPackage temp/winget.msixbundle", shell=True
        )

    else:
        pc(f"Failed fetching status code {response.status_code}", RED)
        sys.exit(1)


def winget_install(packages: "list[str]", use_winget_source_only: bool = True):
    yes = "--accept-package-agreements"
    cmd = ["winget", "install", yes]

    if use_winget_source_only:
        cmd.extend(["-s", "winget"])

    cmd.extend(packages)
    subprocess.run(cmd)


chocolatey_exists = is_command_exists(["choco"])

if chocolatey_exists:
    pc("chocolatey already exists", GREEN)
else:
    pc("Installing chocolatey...", CYAN)
    winget_install(["chocolatey"])

pip_exists = is_command_exists(["pip", "-v"])

if pip_exists:
    pc("Python and pip already exists", GREEN)
else:
    pc("Installing python3", CYAN)
    winget_install(["python3"])


def choco_install(packages: "list[str]"):
    cmd = ["choco", "install", "-y"]
    cmd.extend(packages)
    subprocess.run(cmd)


def pip_install(packages: "list[str]"):
    cmd = ["pip", "install"]
    cmd.extend(packages)
    subprocess.run(cmd)


# Installing packages
class Packages:
    def __init__(self, packages: "dict[str, list[str]]") -> None:
        self.winget = packages["winget"]
        self.chocolatey = packages["chocolatey"]
        self.python = packages["python"]


class Link:
    def __init__(self, source: str, destination: str):
        self.source = source
        self.destination = destination


class Config:
    def __init__(self):
        with open("./installer/config.yml", "r") as f:
            config = yaml.safe_load(f.read())
        self.packages = Packages(**config)
        self.links = [Link(**link) for link in config["links"]]

    def __repr__(self) -> str:
        return json.dumps(self.__dict__, indent=4)


pc("Installing git from winget", CYAN)

winget_install(["Git.Git"])
os.makedirs("~/.config/")

pc("Cloning dot files", CYAN)
subprocess.run(["git", "clone", DOTFILE_REPO, "~/.config/win-dotfiles"])

os.chdir("~/.config/win-dotfiles")

config = Config()

# Installing chocolatey packages
pc("Installing chocolatey packages: ", CYAN)
choco_packages = [package for package in config.packages.chocolatey]
pc(" ".join(choco_packages), GREEN)
choco_install(choco_packages)

# Installing python packages
pc("Installing python packages: ", CYAN)
pip_packages = [package for package in config.packages.python]
pc(" ".join(pip_packages), GREEN)
pip_install(pip_packages)

# Installing winget packages
pc("Installing winget packages: ", CYAN)
winget_packages = [package for package in config.packages.winget]
pc(" ".join(winget_packages), GREEN)
winget_install(winget_packages, False)

os.mkdir("backup")


def create_symlink(source: str, destination: str):
    if os.path.exists(destination):
        file_name = source.split("/")[-1]
        shutil.copy(destination, f"backup/{file_name}")
        os.remove(destination)

    os.symlink(source, destination)


for link in config.links:
    create_symlink(link.source, link.destination)
