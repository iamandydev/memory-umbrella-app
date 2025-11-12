import React from 'react';
import { enableScreens } from 'react-native-screens';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Habilita la optimización de pantallas nativas
enableScreens();

import HomeScreen from './screens/HomeScreen';
import ScanScreen from './screens/ScanScreen';
import DeviceControlScreen from './screens/DeviceControlScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerShown: false, // ocultar header nativo
          animation: 'fade', // animación más fluida al cambiar pantallas
          gestureEnabled: true, // habilita gestos de retroceso
        }}
      >
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Scan" component={ScanScreen} />
        <Stack.Screen name="Device" component={DeviceControlScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
