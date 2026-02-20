import os, sys
from typing import List, Dict, Optional


def do_something(x: int, y: int, z: Optional[str] = None) -> Dict[str, List[int]]:
    result = {"values": [x, y], "names": ["a", "b", "c"]}
    if z is not None:
        result["extra"] = [1, 2, 3, 4, 5]
    return result


class BadlyFormatted:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age

    def greet(self) -> str:
        return f"Hi, I'm {self.name} and I'm {self.age}"

    def info(self) -> Dict:
        return {"name": self.name, "age": self.age, "greeting": self.greet()}


if __name__ == "__main__":
    obj = BadlyFormatted("Test", 25)
    print(obj.greet())
    result = do_something(1, 2, "extra")
    print(result)
