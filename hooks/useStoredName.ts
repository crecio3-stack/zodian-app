import AsyncStorage from '@react-native-async-storage/async-storage';
import { useEffect, useState } from 'react';

const NAME_KEY = 'display_name';

export function useStoredName() {
  const [name, setName] = useState('');
  const [hasLoaded, setHasLoaded] = useState(false);
  const [hasSavedName, setHasSavedName] = useState(false);

  useEffect(() => {
    const loadName = async () => {
      try {
        const stored = await AsyncStorage.getItem(NAME_KEY);
        if (stored && stored.trim()) {
          setName(stored.trim());
          setHasSavedName(true);
        }
      } catch (e) {
        console.log('Error loading name', e);
      } finally {
        setHasLoaded(true);
      }
    };

    loadName();
  }, []);

  const saveName = async (nextName: string) => {
    const cleaned = nextName.trim();
    await AsyncStorage.setItem(NAME_KEY, cleaned);
    setName(cleaned);
    setHasSavedName(Boolean(cleaned));
  };

  const clearName = async () => {
    await AsyncStorage.removeItem(NAME_KEY);
    setName('');
    setHasSavedName(false);
  };

  return {
    name,
    setName,
    saveName,
    clearName,
    hasLoaded,
    hasSavedName,
  };
}
