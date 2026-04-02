import AsyncStorage from '@react-native-async-storage/async-storage';
import { useEffect, useState } from 'react';

const BIRTHDATE_KEY = 'birthdate';

export function useStoredBirthdate(defaultDate: Date) {
  const [selectedDate, setSelectedDate] = useState<Date>(defaultDate);
  const [hasLoaded, setHasLoaded] = useState(false);
  const [hasSavedBirthdate, setHasSavedBirthdate] = useState(false);
  const [loadedFromStorage, setLoadedFromStorage] = useState(false);

  useEffect(() => {
    const loadBirthdate = async () => {
      try {
        const stored = await AsyncStorage.getItem(BIRTHDATE_KEY);

        if (stored) {
          setSelectedDate(new Date(stored));
          setHasSavedBirthdate(true);
          setLoadedFromStorage(true);
        }
      } catch (e) {
        console.log('Error loading birthdate', e);
      } finally {
        setHasLoaded(true);
      }
    };

    loadBirthdate();
  }, []);

  const saveBirthdate = async (date: Date) => {
    await AsyncStorage.setItem(BIRTHDATE_KEY, date.toISOString());
    setSelectedDate(date);
    setHasSavedBirthdate(true);
    setLoadedFromStorage(true);
  };

  const clearBirthdate = async () => {
    await AsyncStorage.removeItem(BIRTHDATE_KEY);
    setSelectedDate(defaultDate);
    setHasSavedBirthdate(false);
    setLoadedFromStorage(false);
  };

  return {
    selectedDate,
    setSelectedDate,
    saveBirthdate,
    clearBirthdate,
    hasLoaded,
    hasSavedBirthdate,
    loadedFromStorage,
  };
}