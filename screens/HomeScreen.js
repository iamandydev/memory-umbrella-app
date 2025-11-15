import React from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Alert,
  Linking,
  PermissionsAndroid,
  Platform,
} from 'react-native';
import RNBluetoothClassic from 'react-native-bluetooth-classic';
import { SafeAreaView } from 'react-native-safe-area-context';

const HomeScreen = ({ navigation }) => {
  // ✅ Función principal que valida permisos y servicios
  const handleScanPress = async () => {
    try {
      // --- 1️⃣ Verificar permisos ---
      const hasPermissions = await requestBluetoothPermissions();

      if (!hasPermissions) {
        Alert.alert(
          'Permisos',
          'Por favor otorga permisos de ubicación y Bluetooth.',
          [
            {
              text: 'Ir a configuraciones',
              onPress: () => Linking.openSettings(),
            },
            { text: 'Cancelar', style: 'cancel' },
          ]
        );
        return;
      }

      // --- 2️⃣ Verificar servicios Bluetooth ---
      //const isBluetoothEnabled = await BluetoothSerial.isEnabled();
      const isBluetoothEnabled = await RNBluetoothClassic.isBluetoothEnabled();

      if (!isBluetoothEnabled) {
        Alert.alert(
          'Servicios',
          'Por favor activa los servicios de Bluetooth y Ubicación.'
        );
        return;
      }

      // --- 3️⃣ Si todo está correcto, navegar a ScanScreen ---
      navigation.navigate('Scan');

    } catch (error) {
      console.error('Error al validar permisos:', error);
      Alert.alert('Error', 'Ocurrió un error al validar los permisos.');
    }
  };

  // ✅ Función para solicitar permisos Bluetooth + Ubicación
  const requestBluetoothPermissions = async () => {
    if (Platform.OS === 'android') {
      try {
        const btScan = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN
        );
        const btConnect = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT
        );
        const location = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
        );

        return (
          btScan === PermissionsAndroid.RESULTS.GRANTED &&
          btConnect === PermissionsAndroid.RESULTS.GRANTED &&
          location === PermissionsAndroid.RESULTS.GRANTED
        );
      } catch (err) {
        console.error('Error solicitando permisos:', err);
        return false;
      }
    }
    return true; // iOS maneja permisos de otra forma
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Contenedor principal */}
      <View style={styles.innerContainer}>
        {/* Logo */}
        <View style={styles.logoContainer}>
          <Image
            /* source={{
              uri: 'https://images.unsplash.com/photo-1701500096456-28186c4a306d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxibHVldG9vdGglMjBsb2dvJTIwaWNvbnxlbnwxfHx8fDE3NjE4NzU1ODh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
            }} */
           source={require('../assets/marca/mu-icon.png')}
            style={styles.logo}
            resizeMode="cover"
          />
        </View>

        {/* Título */}
        <View style={styles.titleContainer}>
          <Text style={styles.title}>Memory Umbrella</Text>
          <Text style={styles.subtitle}>Toma el control y aprovecha al maximo tu memory umbrella one</Text>
        </View>

        {/* Botón Escanear */}
        <TouchableOpacity
          style={styles.button}
          activeOpacity={0.8}
          onPress={handleScanPress}
        >
          <Text style={styles.buttonText}>Escanear Dispositivos</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

export default HomeScreen;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0D1B2A',
    justifyContent: 'center',
    alignItems: 'center',
  },
  innerContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
    maxWidth: 360,
    paddingHorizontal: 24,
    gap: 48,
  },
  logoContainer: {
    width: 192,
    height: 192,
    overflow: 'hidden',
    elevation: 10,
    shadowColor: 'transparent',
  },
  logo: {
    width: '100%',
    height: '100%',
  },
  titleContainer: {
    alignItems: 'center',
    marginTop: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    color: '#2563eb',
  },
  subtitle: {
    fontSize: 16,
    color: '#4b5563',
    marginTop: 4,
    textAlign: 'center',
  },
  button: {
    width: '100%',
    maxWidth: 280,
    backgroundColor: '#2563eb',
    paddingVertical: 16,
    borderRadius: 16,
    shadowColor: '#2563eb',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
    marginTop: 24,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
});
