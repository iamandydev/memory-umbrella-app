import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Alert,
  Animated,
} from 'react-native';
import Icon from 'react-native-vector-icons/Feather';
import RNBluetoothClassic from 'react-native-bluetooth-classic';
import { SafeAreaView } from 'react-native-safe-area-context';

const DeviceControlScreen = ({ route, navigation }) => {
  const { device } = route.params;
  const [ledEnabled, setLedEnabled] = useState(false);
  const [isConnected, setIsConnected] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const fadeAnim = new Animated.Value(0);

  // Conexión Bluetooth al montar la pantalla
  useEffect(() => {
    connectToDevice();
    return () => disconnectDevice();
  }, []);

  const showError = (msg) => {
    setErrorMsg(msg);
    Animated.sequence([
      Animated.timing(fadeAnim, { toValue: 1, duration: 300, useNativeDriver: true }),
      Animated.delay(3000),
      Animated.timing(fadeAnim, { toValue: 0, duration: 300, useNativeDriver: true }),
    ]).start(() => setErrorMsg(''));
  };

  const connectToDevice = async () => {
    try {
      const connected = await RNBluetoothClassic.connectToDevice(device.id);
      if (connected) {
        setIsConnected(true);
      } else {
        showError('No se pudo conectar al dispositivo');
      }
    } catch (error) {
      showError('Error al conectar: ' + error.message);
    }
  };

  const disconnectDevice = async () => {
    try {
      await RNBluetoothClassic.disconnectFromDevice(device.id);
      setIsConnected(false);
      navigation.navigate('Home');
    } catch (error) {
      showError('Error al desconectar: ' + error.message);
    }
  };

  const handleLedToggle = async () => {
    const newValue = !ledEnabled;
    setLedEnabled(newValue);

    try {
      if (!isConnected) throw new Error('El dispositivo no está conectado');
      const command = newValue ? '1' : '0';
      await RNBluetoothClassic.writeToDevice(device.id, command);
    } catch (error) {
      showError('Error al enviar comando: ' + error.message);
      setLedEnabled(!newValue); // revertir cambio
    }
  };

  const handleViewStatus = () => {
    Alert.alert(
      'Estado del dispositivo',
      `LED: ${ledEnabled ? 'Encendido' : 'Apagado'}\nConexión: ${
        isConnected ? 'Activa' : 'Inactiva'
      }`
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={disconnectDevice}>
          <Icon name="chevron-left" size={26} color="#fff" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Control del Dispositivo</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContainer}>
        {/* Info Dispositivo */}
        <View style={styles.card}>
          <View style={styles.deviceInfoRow}>
            <View style={styles.deviceIconContainer}>
              <Icon name="bluetooth" size={32} color="#2563eb" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.deviceName}>{device?.name || 'ESP32'}</Text>
              <Text style={styles.deviceId}>ID: {device?.id || 'N/A'}</Text>
            </View>
            <View
              style={[
                styles.statusDot,
                { backgroundColor: isConnected ? '#22c55e' : '#ef4444' },
              ]}
            />
          </View>
          <View style={styles.statusRow}>
            <Icon name="power" size={16} color="#6b7280" />
            <Text style={styles.statusText}>
              {isConnected ? 'Conectado' : 'Desconectado'}
            </Text>
          </View>
        </View>

        {/* Control LED */}
        <View style={styles.card}>
          <View style={styles.ledRow}>
            <View
              style={[
                styles.ledIconContainer,
                { backgroundColor: ledEnabled ? '#fef9c3' : '#f3f4f6' },
              ]}
            >
              <Icon
                name="sun"
                size={24}
                color={ledEnabled ? '#eab308' : '#9ca3af'}
              />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.ledTitle}>Control LED</Text>
              <Text style={styles.ledSubtitle}>
                {ledEnabled ? 'LED encendido' : 'LED apagado'}
              </Text>
            </View>

            <TouchableOpacity
              style={[
                styles.switchContainer,
                ledEnabled ? styles.switchOn : styles.switchOff,
              ]}
              onPress={handleLedToggle}
            >
              <View
                style={[
                  styles.switchThumb,
                  ledEnabled && styles.switchThumbOn,
                ]}
              />
            </TouchableOpacity>
          </View>
        </View>

        {/* Acciones */}
        <View style={styles.card}>
          <Text style={styles.sectionTitle}>Acciones</Text>
          <TouchableOpacity style={styles.actionButton} onPress={handleViewStatus}>
            <Text style={styles.actionButtonText}>Ver Estado del Dispositivo</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.actionButton, styles.disconnectButton]}
            onPress={disconnectDevice}
          >
            <Text style={[styles.actionButtonText, styles.disconnectText]}>
              Desconectar Dispositivo
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Banner de error */}
      {errorMsg ? (
        <Animated.View style={[styles.errorBanner, { opacity: fadeAnim }]}>
          <Text style={styles.errorText}>{errorMsg}</Text>
        </Animated.View>
      ) : null}
    </SafeAreaView>
  );
};
// 🎨 Estilos
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#f0f6ff" },
  header: {
    backgroundColor: "#2563eb",
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 14,
    elevation: 4,
  },
  backButton: { marginRight: 12, padding: 6 },
  headerTitle: { color: "#fff", fontSize: 18, fontWeight: "bold" },
  content: { padding: 16 },
  card: {
    backgroundColor: "#fff",
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    elevation: 2,
  },
  row: { flexDirection: "row", alignItems: "center", marginBottom: 8 },
  iconCircleBlue: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: "#dbeafe",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  iconCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  deviceName: { fontSize: 16, color: "#111827", fontWeight: "bold" },
  deviceId: { fontSize: 13, color: "#6b7280" },
  statusDot: { width: 10, height: 10, borderRadius: 5 },
  statusRow: { flexDirection: "row", alignItems: "center", gap: 6 },
  statusText: { color: "#6b7280", marginLeft: 6 },
  cardTitle: { fontSize: 16, fontWeight: "bold", color: "#111827" },
  cardSubtitle: { color: "#6b7280", fontSize: 13 },
  ledStateBox: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 12,
    justifyContent: "center",
  },
  ledStateLabel: { color: "#4b5563", fontSize: 13, marginRight: 6 },
  ledStateIndicator: {
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 16,
  },
  actionButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#f9fafb",
    borderRadius: 10,
    padding: 12,
  },
  actionText: { marginLeft: 10, fontSize: 14, color: "#2563eb" },
  noteBox: {
    backgroundColor: "#eff6ff",
    borderColor: "#bfdbfe",
    borderWidth: 1,
    borderRadius: 10,
    padding: 12,
  },
  noteText: { color: "#1e3a8a", fontSize: 13 },
});
export default DeviceControlScreen;
