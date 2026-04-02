import AsyncStorage from '@react-native-async-storage/async-storage';
import { useCallback, useEffect, useRef, useState } from 'react';
import { generateAstrologerResponse, getAstrologerSystemPrompt } from '../lib/ai/astrologerService';
import { AstrologerContext, ChatMessage, ChatSession } from '../types/chat';

const CHAT_SESSION_KEY = 'zodian.astro_chat.session';

// Simple ID generator
function generateId() {
  return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
}

export const useAstrologerChat = (context: AstrologerContext) => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const sessionRef = useRef<ChatSession | null>(null);

  // Initialize or load existing chat session
  useEffect(() => {
    const initSession = async () => {
      try {
        const saved = await AsyncStorage.getItem(CHAT_SESSION_KEY);
        let session: ChatSession;

        if (saved) {
          const parsed = JSON.parse(saved);
          // Check if it's for the same user (same signs)
          if (parsed.westernSign === context.westernSign && parsed.chineseSign === context.chineseSign) {
            session = parsed;
            setMessages(parsed.messages || []);
          } else {
            // New user, create new session
            session = createNewSession(context);
            setMessages([]);
          }
        } else {
          // First time, create new session
          session = createNewSession(context);
          setMessages([]);
        }

        sessionRef.current = session;
      } catch (err) {
        console.warn('Failed to load chat session:', err);
        sessionRef.current = createNewSession(context);
        setMessages([]);
      }
    };

    initSession();
  }, [context.westernSign, context.chineseSign]);

  // Save session whenever messages change
  useEffect(() => {
    const saveSession = async () => {
      if (!sessionRef.current) return;

      sessionRef.current.messages = messages;
      sessionRef.current.updatedAt = Date.now();

      try {
        await AsyncStorage.setItem(CHAT_SESSION_KEY, JSON.stringify(sessionRef.current));
      } catch (err) {
        console.warn('Failed to save chat session:', err);
      }
    };

    if (messages.length > 0) {
      saveSession();
    }
  }, [messages]);

  const sendMessage = useCallback(
    async (content: string) => {
      if (!content.trim() || isLoading) return;

      const userMessage: ChatMessage = {
        id: generateId(),
        role: 'user',
        content: content.trim(),
        timestamp: Date.now(),
      };

      setMessages((prev) => [...prev, userMessage]);
      setIsLoading(true);
      setError(null);

      try {
        const systemPrompt = getAstrologerSystemPrompt(context);
        const conversationHistory = messages.map((msg) => ({
          role: msg.role,
          content: msg.content,
        }));

        conversationHistory.push({
          role: 'user',
          content: userMessage.content,
        });

        const responseText = await generateAstrologerResponse(
          userMessage.content,
          systemPrompt,
          conversationHistory
        );

        const assistantMessage: ChatMessage = {
          id: generateId(),
          role: 'assistant',
          content: responseText,
          timestamp: Date.now(),
        };

        setMessages((prev) => [...prev, assistantMessage]);
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : 'Failed to generate response';
        setError(errorMsg);
        console.error('Error generating astrologer response:', err);
      } finally {
        setIsLoading(false);
      }
    },
    [messages, isLoading, context]
  );

  const clearChat = useCallback(async () => {
    setMessages([]);
    sessionRef.current = createNewSession(context);
    try {
      await AsyncStorage.removeItem(CHAT_SESSION_KEY);
    } catch (err) {
      console.warn('Failed to clear chat session:', err);
    }
  }, [context]);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    messages,
    isLoading,
    error,
    sendMessage,
    clearChat,
    clearError,
  };
};

function createNewSession(context: AstrologerContext): ChatSession {
  return {
    id: generateId(),
    messages: [],
    westernSign: context.westernSign,
    chineseSign: context.chineseSign,
    createdAt: Date.now(),
    updatedAt: Date.now(),
  };
}
