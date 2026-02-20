import { User, formatUser } from "./user";

interface Message {
  from: User;
  body: string;
}

export class ChatService {
  private messages: Message[] = [];

  send(from: User, body: string): void {
    this.messages.push({ from, body });
  }

  history(): string[] {
    return this.messages.map(
      (m) => `[${formatUser(m.from)}]: ${m.body.slice(0, 50)}`,
    );
  }
}
