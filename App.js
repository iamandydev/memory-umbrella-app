import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Importar tus screens
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
          headerShown: false, // ocultamos el header nativo para usar el de tus pantallas personalizadas
          animation: 'slide_from_right',
        }}
      >
        <Stack.Screen
          name="Home"
          component={HomeScreen}
        />
        <Stack.Screen
          name="Scan"
          component={ScanScreen}
        />
        <Stack.Screen
          name="DeviceControl"
          component={DeviceControlScreen}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
