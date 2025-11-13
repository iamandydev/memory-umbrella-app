import React from 'react';
<<<<<<< HEAD
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Importar tus screens
=======
import { enableScreens } from 'react-native-screens';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Habilita la optimización de pantallas nativas
enableScreens();

>>>>>>> 3851e77 (first commit version 0.0.18)
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
<<<<<<< HEAD
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
=======
          headerShown: false, // ocultar header nativo
          animation: 'fade', // animación más fluida al cambiar pantallas
          gestureEnabled: true, // habilita gestos de retroceso
        }}
      >
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Scan" component={ScanScreen} />
        <Stack.Screen name="Device" component={DeviceControlScreen} />
>>>>>>> 3851e77 (first commit version 0.0.18)
      </Stack.Navigator>
    </NavigationContainer>
  );
}
