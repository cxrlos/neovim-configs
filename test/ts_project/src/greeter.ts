export class Greeter {
  constructor(private name: string) {}

  greet(): string {
    return `Hello, ${this.name}!`;
  }
}

export function makeGreeter(name: string): Greeter {
  return new Greeter(name);
}
