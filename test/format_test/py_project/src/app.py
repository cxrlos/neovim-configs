from models import Item, Cart


def build_cart() -> Cart:
    cart = Cart(owner="Alice")
    cart.add(Item("Widget", 9.99, ["sale", "new"]))
    cart.add(Item("Gadget", 24.99, ["premium"]))
    cart.add(Item("Thing", 4.50))
    return cart


def main():
    cart = build_cart()
    print(cart.summary())
    print(f"\nOwner: {cart.owner}")
    print(f"Items: {len(cart.items)}")


if __name__ == "__main__":
    main()
