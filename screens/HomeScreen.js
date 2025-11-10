import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  Alert,
  FlatList,
  TouchableOpacity,
  PermissionsAndroid,
  Platform,
  StyleSheet,
  Linking,
} from 'react-native';
import RNBluetoothClassic from 'react-native-bluetooth-classic';

const HomeScreen = ({ navigation }) => {
  const [devices, setDevices] = useState([]);
  const [scanning, setScanning] = useState(false);
  const [message, setMessage] = useState('');

  // -----------------------------
  // 🔹 Solicitud de permisos
  // -----------------------------
  const requestPermissions = async () => {
    if (Platform.OS === 'android') {
      try {
        const granted = await PermissionsAndroid.requestMultiple([
          PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
          PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        ]);

        const allGranted = Object.values(granted).every(
          (v) => v === PermissionsAndroid.RESULTS.GRANTED,
        );

        if (!allGranted) {
          Alert.alert(
            'Permisos requeridos',
            'Por favor concede permisos de Bluetooth y Ubicación.',
            [{ text: 'Abrir configuración', onPress: () => Linking.openSettings() }],
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

  // -----------------------------
  // 🔹 Escanear dispositivos emparejados
  // -----------------------------
  const handleScanPress = async () => {
    setDevices([]);
    setMessage('');
    setScanning(true);

    const hasPerms = await requestPermissions();
    if (!hasPerms) return;

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

      if (bondedDevices.length === 0) {
        setMessage('No se encontraron dispositivos emparejados.');
      } else {
        setDevices(bondedDevices);
        setMessage(`🔗 ${bondedDevices.length} dispositivo(s) emparejado(s) encontrado(s).`);
      }
    } catch (err) {
      console.error('❌ Error durante el escaneo:', err);
      setMessage('Error escaneando dispositivos.');
    }

    setScanning(false);
  };

  // -----------------------------
  // 🔹 Intentar conexión a un dispositivo
  // -----------------------------
  const handleConnect = async (device) => {
    try {
      console.log('🔌 Intentando conectar con:', device.name);
      const connected = await RNBluetoothClassic.connectToDevice(device.address);
      if (connected) {
        Alert.alert('Conectado', `Conectado a ${device.name}`);
        navigation.navigate('Device', { device });
      } else {
        Alert.alert('Error', `No se pudo conectar a ${device.name}`);
      }
    } catch (err) {
      console.error('❌ Error de conexión:', err);
      Alert.alert('Error', 'No se pudo conectar al dispositivo.');
    }
  };

  // -----------------------------
  // 🔹 Renderizado de dispositivos
  // -----------------------------
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

  // -----------------------------
  // 🔹 Renderizado general
  // -----------------------------
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Bluetooth Clásico</Text>

      <TouchableOpacity
        style={[styles.scanButton, scanning && { backgroundColor: '#aaa' }]}
        onPress={handleScanPress}
        disabled={scanning}
      >
        <Text style={styles.scanButtonText}>
          {scanning ? 'Buscando...' : 'Buscar dispositivos'}
        </Text>
      </TouchableOpacity>

      <View style={styles.resultBox}>
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
  );
};

// -----------------------------
// 🔹 Estilos
// -----------------------------
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff', padding: 20, paddingTop: 50 },
  title: { fontSize: 24, fontWeight: 'bold', textAlign: 'center', marginBottom: 20 },
  scanButton: {
    backgroundColor: '#28a745',
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 10,
    alignSelf: 'center',
  },
  scanButtonText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
  resultBox: {
    marginTop: 30,
    backgroundColor: '#f2f2f2',
    borderRadius: 10,
    padding: 10,
    flex: 1,
  },
  deviceContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomColor: '#ddd',
    borderBottomWidth: 1,
    paddingVertical: 8,
  },
  deviceText: { flex: 1, color: '#333' },
  connectButton: {
    backgroundColor: '#007bff',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 6,
  },
  connectText: { color: '#fff', fontWeight: 'bold' },
  messageText: { textAlign: 'center', color: '#666', marginTop: 20 },
});

export default HomeScreen;
