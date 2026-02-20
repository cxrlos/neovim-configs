import { readFileSync } from "fs";

interface User {
  name: string;
  age: number;
  email?: string;
}

function createUser(name: string, age: number, email?: string): User {
  return { name, age, email };
}

const processUsers = (users: User[]): void => {
  for (const u of users) {
    console.log(`${u.name} (${u.age})`);
    if (u.email) {
      console.log(`  email: ${u.email}`);
    }
  }
};

const users: User[] = [
  createUser("Alice", 30, "alice@example.com"),
  createUser("Bob", 25),
  createUser("Charlie", 35, "charlie@example.com"),
];

processUsers(users);
