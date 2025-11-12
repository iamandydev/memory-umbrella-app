// src/screens/ScanScreen.js
import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
  StyleSheet,
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

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
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
              style={styles.deviceCard}
              onPress={() => handleDeviceSelect(device)}
            >
              {/* Icono Bluetooth */}
              <View style={styles.iconContainer}>
                <Ionicons name="bluetooth" size={28} color="#2563eb" />
              </View>

              {/* Info del dispositivo */}
              <View style={styles.deviceInfo}>
                <Text style={styles.deviceName}>{device.name}</Text>
                <Text style={styles.deviceId}>ID: {device.id}</Text>
              </View>

              {/* Intensidad de señal */}
              <View style={styles.signalContainer}>
                {[1, 2, 3, 4].map((bar) => (
                  <View
                    key={bar}
                    style={[
                      styles.signalBar,
                      {
                        height: bar * 6,
                        backgroundColor:
                          bar <= getSignalBars(device.signalStrength)
                            ? "#2563eb"
                            : "#d1d5db",
                      },
                    ]}
                  />
                ))}
              </View>
            </TouchableOpacity>
          ))
        ) : (
          !scanning && (
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
    elevation: 4,
  },
  backButton: {
    marginRight: 8,
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
    marginRight: 12,
  },
  deviceInfo: {
    flex: 1,
  },
  deviceName: {
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
});
