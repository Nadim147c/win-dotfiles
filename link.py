from config import Config
import shutil
import os


os.makedirs("./backup", exist_ok=True)


def create_symlink(source: str, destination: str):
    source = os.path.abspath(source)
    destination = os.path.expanduser(destination)

    if os.path.exists(destination):
        file_name = source.split("/")[-1]
        shutil.copy(destination, f"backup/{file_name}")
        os.unlink(destination)

    os.symlink(source, destination)


config = Config()

for link in config.links:
    create_symlink(link.source, link.destination)
