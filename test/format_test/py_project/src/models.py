from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class Item:
    name: str
    price: float
    tags: List[str] = field(default_factory=list)


@dataclass
class Cart:
    items: List[Item] = field(default_factory=list)
    owner: Optional[str] = None

    def add(self, item: Item) -> None:
        self.items.append(item)

    def total(self) -> float:
        return sum(i.price for i in self.items)

    def summary(self) -> str:
        lines = [f"{i.name}: ${i.price:.2f}" for i in self.items]
        lines.append(f"Total: ${self.total():.2f}")
        return "\n".join(lines)
