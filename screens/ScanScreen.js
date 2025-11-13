<<<<<<< HEAD
import React, { useState, useEffect } from 'react';
=======
// src/screens/ScanScreen.js
import React, { useState, useEffect } from "react";
>>>>>>> 3851e77 (first commit version 0.0.18)
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
  StyleSheet,
<<<<<<< HEAD
  Animated,
} from 'react-native';
import Icon from 'react-native-vector-icons/Feather';
import RNBluetoothClassic from 'react-native-bluetooth-classic';
import { SafeAreaView } from 'react-native-safe-area-context';

const ScanScreen = ({ navigation }) => {
  const [scanning, setScanning] = useState(true);
  const [devices, setDevices] = useState([]);
  const [errorMessage, setErrorMessage] = useState('');
  const fadeAnim = new Animated.Value(0);

  // 🔹 Mostrar banner de error con animación
  const showError = (message) => {
    setErrorMessage(message);
    Animated.sequence([
      Animated.timing(fadeAnim, { toValue: 1, duration: 300, useNativeDriver: true }),
      Animated.delay(2500),
      Animated.timing(fadeAnim, { toValue: 0, duration: 500, useNativeDriver: true }),
    ]).start(() => setErrorMessage(''));
  };

  // 🔹 Escaneo de dispositivos al montar la pantalla
  useEffect(() => {
    const scanDevices = async () => {
      try {
        setScanning(true);
        setDevices([]);

        // Verifica si el Bluetooth está activo
        const enabled = await RNBluetoothClassic.isBluetoothEnabled();
        if (!enabled) {
          showError('El Bluetooth está apagado.');
          setScanning(false);
          return;
        }

        // Escanear dispositivos emparejados
        const bonded = await RNBluetoothClassic.getBondedDevices();
        if (bonded.length === 0) {
          showError('No se encontraron dispositivos emparejados.');
        } else {
          setDevices(bonded);
        }
      } catch (error) {
        console.error('❌ Error al escanear dispositivos:', error);
        showError('Error al escanear dispositivos Bluetooth.');
      } finally {
        setScanning(false);
      }
    };

    scanDevices();
  }, []);

  // 🔹 Calcular barras de señal (RSSI)
  const getSignalBars = (rssi) => {
    if (rssi > -50) return 4;
    if (rssi > -60) return 3;
    if (rssi > -70) return 2;
    return 1;
  };

  // 🔹 Conectar al dispositivo seleccionado
  const handleDeviceSelect = async (device) => {
    try {
      setScanning(true);
      const connected = await RNBluetoothClassic.connectToDevice(device.address);

      if (connected) {
        navigation.navigate('DeviceControl', { device });
      } else {
        showError(`No se pudo conectar a ${device.name}`);
      }
    } catch (error) {
      console.error('❌ Error al conectar:', error);
      showError('Error al conectar con el dispositivo.');
    } finally {
      setScanning(false);
    }
  };

  // 🔹 Volver a la pantalla anterior
  const handleBack = () => navigation.goBack();

=======
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";

export default function ScanScreen({ navigation }) {
  const [scanning, setScanning] = useState(true);
  const [devices, setDevices] = useState([]);

  useEffect(() => {
    setDevices([]);
    setScanning(true);

    const mockDevices = [
      { id: "1", name: "ESP32-LED-Control", signalStrength: -45 },
      { id: "2", name: "ESP32-Device-01", signalStrength: -62 },
      { id: "3", name: "ESP32-Smart-Home", signalStrength: -58 },
      { id: "4", name: "ESP32-Sensor", signalStrength: -71 },
      { id: "5", name: "ESP32-Gateway", signalStrength: -80 },
    ];

    let count = 0;
    const interval = setInterval(() => {
      if (count < mockDevices.length) {
        setDevices((prev) => [...prev, mockDevices[count]]);
        count++;
      } else {
        setScanning(false);
        clearInterval(interval);
      }
    }, 800);

    return () => clearInterval(interval);
  }, []);

  const getSignalBars = (strength) => {
    if (strength > -50) return 4;
    if (strength > -60) return 3;
    if (strength > -70) return 2;
    return 1;
  };

  const handleDeviceSelect = (device) => {
    navigation.navigate("Device", { device });
  };

>>>>>>> 3851e77 (first commit version 0.0.18)
  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
<<<<<<< HEAD
        <TouchableOpacity onPress={handleBack} style={styles.backButton}>
          <Icon name="chevron-left" size={24} color="#fff" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Dispositivos Disponibles</Text>
      </View>

      {/* Indicador de escaneo */}
      {scanning && (
        <View style={styles.scanIndicator}>
          <ActivityIndicator size="small" color="#2563EB" />
          <Text style={styles.scanText}>Buscando dispositivos...</Text>
        </View>
      )}

      {/* Lista de dispositivos */}
      <ScrollView contentContainerStyle={styles.deviceList}>
        {devices.length > 0 ? (
          devices.map((device) => (
            <TouchableOpacity
              key={device.address}
=======
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Ionicons name="chevron-back" size={26} color="white" />
        </TouchableOpacity>
        <Text style={styles.headerText}>Dispositivos Disponibles</Text>
      </View>

      {/* Scanning Indicator */}
      {scanning && (
        <View style={styles.scanningContainer}>
          <ActivityIndicator size="small" color="#2563eb" />
          <Text style={styles.scanningText}>Buscando dispositivos...</Text>
        </View>
      )}

      {/* Device List */}
      <ScrollView contentContainerStyle={styles.listContainer}>
        {devices.length > 0 ? (
          devices.map((device) => (
            <TouchableOpacity
              key={device.id}
>>>>>>> 3851e77 (first commit version 0.0.18)
              style={styles.deviceCard}
              onPress={() => handleDeviceSelect(device)}
            >
              {/* Icono Bluetooth */}
              <View style={styles.iconContainer}>
<<<<<<< HEAD
                <Icon name="bluetooth" size={28} color="#2563EB" />
              </View>

              {/* Info */}
              <View style={styles.deviceInfo}>
                <Text style={styles.deviceName}>{device.name || 'Sin nombre'}</Text>
                <Text style={styles.deviceId}>MAC: {device.address}</Text>
              </View>

              {/* Señal */}
              <View style={styles.signalBars}>
=======
                <Ionicons name="bluetooth" size={28} color="#2563eb" />
              </View>

              {/* Info del dispositivo */}
              <View style={styles.deviceInfo}>
                <Text style={styles.deviceName}>{device.name}</Text>
                <Text style={styles.deviceId}>ID: {device.id}</Text>
              </View>

              {/* Intensidad de señal */}
              <View style={styles.signalContainer}>
>>>>>>> 3851e77 (first commit version 0.0.18)
                {[1, 2, 3, 4].map((bar) => (
                  <View
                    key={bar}
                    style={[
                      styles.signalBar,
                      {
                        height: bar * 6,
                        backgroundColor:
<<<<<<< HEAD
                          bar <= getSignalBars(device.rssi || -60)
                            ? '#2563EB'
                            : '#D1D5DB',
=======
                          bar <= getSignalBars(device.signalStrength)
                            ? "#2563eb"
                            : "#d1d5db",
>>>>>>> 3851e77 (first commit version 0.0.18)
                      },
                    ]}
                  />
                ))}
              </View>
            </TouchableOpacity>
          ))
        ) : (
          !scanning && (
<<<<<<< HEAD
            <View style={styles.emptyState}>
              <Text style={styles.emptyText}>No se encontraron dispositivos</Text>
            </View>
          )
        )}
      </ScrollView>

      {/* 🔻 Banner de error */}
      {errorMessage !== '' && (
        <Animated.View style={[styles.errorBanner, { opacity: fadeAnim }]}>
          <Text style={styles.errorText}>{errorMessage}</Text>
        </Animated.View>
      )}
    </View>
  );
};

export default ScanScreen;

// ----------------------
// 🔹 Estilos
// ----------------------
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F0F7FF',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2563EB',
    paddingVertical: 16,
    paddingHorizontal: 12,
=======
            <Text style={styles.noDevicesText}>
              No se encontraron dispositivos
            </Text>
          )
        )}
      </ScrollView>
    </View>
  );
}

// 🎨 Estilos
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f0f5ff",
  },
  header: {
    backgroundColor: "#2563eb",
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 12,
    paddingVertical: 14,
>>>>>>> 3851e77 (first commit version 0.0.18)
    elevation: 4,
  },
  backButton: {
    marginRight: 8,
<<<<<<< HEAD
  },
  headerTitle: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  scanIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E0ECFF',
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#C7DBFF',
  },
  scanText: {
    marginLeft: 8,
    color: '#2563EB',
    fontSize: 14,
  },
  deviceList: {
    padding: 16,
  },
  deviceCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    elevation: 2,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#E0ECFF',
    alignItems: 'center',
    justifyContent: 'center',
=======
    padding: 6,
  },
  headerText: {
    color: "white",
    fontSize: 18,
    fontWeight: "600",
  },
  scanningContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#eff6ff",
    borderBottomWidth: 1,
    borderBottomColor: "#dbeafe",
    padding: 10,
    gap: 10,
  },
  scanningText: {
    color: "#2563eb",
    fontSize: 14,
  },
  listContainer: {
    padding: 16,
  },
  deviceCard: {
    backgroundColor: "white",
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    flexDirection: "row",
    alignItems: "center",
    elevation: 2,
  },
  iconContainer: {
    backgroundColor: "#dbeafe",
    borderRadius: 30,
    width: 48,
    height: 48,
    alignItems: "center",
    justifyContent: "center",
>>>>>>> 3851e77 (first commit version 0.0.18)
    marginRight: 12,
  },
  deviceInfo: {
    flex: 1,
  },
  deviceName: {
<<<<<<< HEAD
    fontSize: 16,
    color: '#111827',
    fontWeight: '500',
  },
  deviceId: {
    fontSize: 13,
    color: '#6B7280',
  },
  signalBars: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    height: 24,
  },
  signalBar: {
    width: 4,
    borderRadius: 2,
    marginHorizontal: 1,
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyText: {
    color: '#6B7280',
    fontSize: 15,
  },
  errorBanner: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: '#DC2626',
    paddingVertical: 10,
    alignItems: 'center',
  },
  errorText: {
    color: '#fff',
    fontWeight: '500',
  },
=======
    color: "#111827",
    fontSize: 16,
    fontWeight: "500",
  },
  deviceId: {
    color: "#6b7280",
    fontSize: 12,
  },
  signalContainer: {
    flexDirection: "row",
    alignItems: "flex-end",
    height: 24,
  },
  signalBar: {
    width: 3,
    borderRadius: 2,
    marginHorizontal: 1,
  },
  noDevicesText: {
    textAlign: "center",
    color: "#6b7280",
    marginTop: 48,
    fontSize: 15,
  },
>>>>>>> 3851e77 (first commit version 0.0.18)
});
