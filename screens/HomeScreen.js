// src/screens/HomeScreen.js
import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Alert,
  FlatList,
  PermissionsAndroid,
  Platform,
  Linking,
} from 'react-native';
import RNBluetoothClassic from 'react-native-bluetooth-classic';

export default function HomeScreen({ navigation }) {
  const [devices, setDevices] = useState([]);
  const [scanning, setScanning] = useState(false);
  const [message, setMessage] = useState('');

  // -------------------------------------
  // 🔹 Solicitar permisos Bluetooth y ubicación (Android)
  // -------------------------------------
  const requestPermissions = async () => {
    if (Platform.OS === 'android') {
      try {
        const permissions = [
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        ];

        // Android 12+ requiere permisos adicionales
        if (Platform.Version >= 31) {
          permissions.push(
            PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
            PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT
          );
        }

        const granted = await PermissionsAndroid.requestMultiple(permissions);
        const allGranted = Object.values(granted).every(
          (v) => v === PermissionsAndroid.RESULTS.GRANTED
        );

        if (!allGranted) {
          Alert.alert(
            'Permisos requeridos',
            'Por favor concede permisos de Bluetooth y ubicación.',
            [{ text: 'Abrir configuración', onPress: () => Linking.openSettings() }]
          );
          return false;
        }
        return true;
      } catch (err) {
        console.error('❌ Error solicitando permisos:', err);
        return false;
      }
    }
    return true;
  };

  // -------------------------------------
  // 🔹 Escanear dispositivos emparejados
  // -------------------------------------
  const handleScanPress = async () => {
    setDevices([]);
    setMessage('');
    setScanning(true);

    const hasPerms = await requestPermissions();
    if (!hasPerms) {
      setScanning(false);
      return;
    }

    try {
      const enabled = await RNBluetoothClassic.isBluetoothEnabled();
      if (!enabled) {
        Alert.alert('Bluetooth apagado', 'Por favor activa el Bluetooth.');
        setScanning(false);
        return;
      }

      console.log('✅ Bluetooth habilitado');
      setMessage('🔍 Buscando dispositivos emparejados...');

      const bondedDevices = await RNBluetoothClassic.getBondedDevices();
      console.log('📡 Dispositivos emparejados:', bondedDevices);

      if (!bondedDevices || bondedDevices.length === 0) {
        setMessage('No se encontraron dispositivos emparejados.');
      } else {
        setDevices(bondedDevices);
        setMessage(`🔗 ${bondedDevices.length} dispositivo(s) encontrado(s).`);
      }
    } catch (err) {
      console.error('❌ Error durante el escaneo:', err);
      setMessage('Error escaneando dispositivos.');
    }

    setScanning(false);
  };

  // -------------------------------------
  // 🔹 Conectar a un dispositivo
  // -------------------------------------
  const handleConnect = async (device) => {
    try {
      console.log('🔌 Intentando conectar con:', device.name || device.address);
      const connected = await RNBluetoothClassic.connectToDevice(device.address);
      if (connected) {
        Alert.alert('Conectado', `Conectado a ${device.name || device.address}`);
        navigation.navigate('Device', { device });
      } else {
        Alert.alert('Error', `No se pudo conectar a ${device.name || device.address}`);
      }
    } catch (err) {
      console.error('❌ Error de conexión:', err);
      Alert.alert('Error', 'No se pudo conectar al dispositivo.');
    }
  };

  // -------------------------------------
  // 🔹 Render de lista de dispositivos
  // -------------------------------------
  const renderItem = ({ item }) => (
    <View style={styles.deviceContainer}>
      <Text style={styles.deviceText}>
        {item.name || 'Sin nombre'} ({item.address})
      </Text>
      <TouchableOpacity
        style={styles.connectButton}
        onPress={() => handleConnect(item)}
      >
        <Text style={styles.connectText}>Conectar</Text>
      </TouchableOpacity>
    </View>
  );

  // -------------------------------------
  // 🔹 Interfaz principal
  // -------------------------------------
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        {/* Logo */}
        <View style={styles.logoContainer}>
          <Image
            source={{
              uri: 'https://images.unsplash.com/photo-1701500096456-28186c4a306d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
            }}
            style={styles.logo}
          />
        </View>

        {/* Título */}
        <View style={styles.titleContainer}>
          <Text style={styles.title}>Control ESP32</Text>
          <Text style={styles.subtitle}>Controla tus dispositivos vía Bluetooth</Text>
        </View>

        {/* Botón Escanear */}
        <TouchableOpacity
          style={[styles.button, scanning && { backgroundColor: '#94a3b8' }]}
          onPress={handleScanPress}
          disabled={scanning}
        >
          <Text style={styles.buttonText}>
            {scanning ? 'Buscando...' : 'Escanear Dispositivos'}
          </Text>
        </TouchableOpacity>

        {/* Resultados */}
        <View style={styles.resultsBox}>
          {devices.length > 0 ? (
            <FlatList
              data={devices}
              keyExtractor={(item) => item.address}
              renderItem={renderItem}
            />
          ) : (
            <Text style={styles.messageText}>{message}</Text>
          )}
        </View>
      </View>
    </View>
  );
}

// -------------------------------------
// 🔹 Estilos
// -------------------------------------
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f6ff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    alignItems: 'center',
    width: '90%',
    maxWidth: 400,
  },
  logoContainer: {
    width: 180,
    height: 180,
    borderRadius: 100,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowOffset: { width: 0, height: 6 },
    shadowRadius: 8,
    elevation: 5,
    marginBottom: 30,
  },
  logo: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  titleContainer: {
    alignItems: 'center',
    marginBottom: 30,
  },
  title: {
    fontSize: 26,
    color: '#2563eb',
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 16,
    color: '#4b5563',
    marginTop: 5,
    textAlign: 'center',
  },
  button: {
    backgroundColor: '#2563eb',
    paddingVertical: 18,
    paddingHorizontal: 40,
    borderRadius: 14,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowOffset: { width: 0, height: 6 },
    shadowRadius: 8,
    elevation: 4,
    width: '80%',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  resultsBox: {
    marginTop: 25,
    width: '100%',
    backgroundColor: '#e2e8f0',
    borderRadius: 10,
    padding: 10,
    maxHeight: 300,
  },
  messageText: {
    textAlign: 'center',
    color: '#475569',
    marginTop: 10,
  },
  deviceContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomColor: '#cbd5e1',
    borderBottomWidth: 1,
    paddingVertical: 8,
  },
  deviceText: {
    flex: 1,
    color: '#334155',
    fontSize: 14,
  },
  connectButton: {
    backgroundColor: '#2563eb',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 6,
  },
  connectText: {
    color: '#fff',
    fontWeight: 'bold',
  },
});
