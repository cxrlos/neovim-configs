import { createUser, formatUser } from "./user";
import { ChatService } from "./chat";

function main(): void {
  const alice = createUser(1, "Alice", "alice@example.com");
  const bob = createUser(2, "Bob", "bob@example.com");

  const chat = new ChatService();
  chat.send(alice, "Hey Bob, how's it going?");
  chat.send(bob, "All good, working on the new feature.");

  for (const line of chat.history()) {
    console.log(line);
  }

  console.log(formatUser(alice));
}

main();
