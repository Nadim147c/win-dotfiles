import json
import yaml


class Packages:
    def __init__(self, packages: "dict[str, list[str]]", **kwargs) -> None:
        self.winget = packages["winget"]
        self.chocolatey = packages["chocolatey"]
        self.python = packages["python"]


class Link:
    def __init__(self, source: str, destination: str, **kwargs):
        self.source = source
        self.destination = destination


class Config:
    def __init__(self):
        with open("./config.yml", "r") as f:
            config = yaml.safe_load(f.read())
        self.packages = Packages(**config)
        self.links = [Link(**link) for link in config["links"]]

    def __repr__(self) -> str:
        return json.dumps(self.__dict__, indent=4)
