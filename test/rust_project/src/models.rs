pub struct User {
    pub id: u32,
    pub name: String,
    pub email: String,
}

impl User {
    pub fn new(id: u32, name: &str, email: &str) -> Self {
        User {
            id,
            name: name.to_string(),
            email: email.to_string(),
        }
    }

    pub fn display_name(&self) -> &str {
        &self.name
    }
}

pub struct Message {
    pub from: User,
    pub body: String,
}

impl Message {
    pub fn new(from: User, body: &str) -> Self {
        Message {
            from,
            body: body.to_string(),
        }
    }

    pub fn preview(&self) -> String {
        format!(
            "[{}]: {}",
            self.from.display_name(),
            &self.body[..self.body.len().min(50)]
        )
    }
}
