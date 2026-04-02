export type ChatRole = 'user' | 'assistant';

export interface ChatMessage {
  id: string;
  role: ChatRole;
  content: string;
  timestamp: number;
  isLoading?: boolean;
}

export interface ChatSession {
  id: string;
  messages: ChatMessage[];
  westernSign: string;
  chineseSign: string;
  createdAt: number;
  updatedAt: number;
}

export interface AstrologerContext {
  westernSign: string;
  chineseSign: string;
  birthdate: Date;
  name?: string;
}
