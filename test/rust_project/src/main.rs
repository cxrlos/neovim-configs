mod models;
mod service;

use models::User;
use service::ChatService;

fn main() {
    let mut chat = ChatService::new();

    let alice = User::new(1, "Alice", "alice@example.com");
    let bob = User::new(2, "Bob", "bob@example.com");

    chat.send(alice, "Hey Bob, how's it going?");
    chat.send(bob, "All good, working on the new feature.");

    for line in chat.history() {
        println!("{}", line);
    }
}
