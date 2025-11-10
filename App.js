import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from './screens/HomeScreen';
import DeviceScreen from './screens/DeviceScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{ title: 'Buscador BLE' }}
        />
        <Stack.Screen
          name="Device"
          component={DeviceScreen}
          options={{ title: 'Dispositivo conectado' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
