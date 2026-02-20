class Greeter:
    def __init__(self, name: str):
        self.name = name

    def greet(self) -> str:
        return f"Hello, {self.name}!"


def make_greeter(name: str) -> Greeter:
    return Greeter(name)
