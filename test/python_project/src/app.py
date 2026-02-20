from greeter import Greeter, make_greeter


def run():
    g = make_greeter("world")
    msg = g.greet()
    print(msg)

    direct = Greeter("direct")
    print(direct.greet())


if __name__ == "__main__":
    run()
