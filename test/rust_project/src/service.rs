use crate::models::{Message, User};

pub struct ChatService {
    messages: Vec<Message>,
}

impl ChatService {
    pub fn new() -> Self {
        ChatService { messages: vec![] }
    }

    pub fn send(&mut self, from: User, body: &str) {
        let msg = Message::new(from, body);
        self.messages.push(msg);
    }

    pub fn history(&self) -> Vec<String> {
        self.messages.iter().map(|m| m.preview()).collect()
    }
}
