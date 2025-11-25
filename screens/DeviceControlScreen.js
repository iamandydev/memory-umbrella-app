import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Alert,
  Animated,
  Switch,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { SafeAreaView } from 'react-native-safe-area-context';
import RNBluetoothClassic from 'react-native-bluetooth-classic';

const DeviceControlScreen = ({ route, navigation }) => {
  const { device } = route.params;

  const [lightEnabled, setLightEnabled] = useState(false);
  const [blinkEnabled, setBlinkEnabled] = useState(false);

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

  // 🔵 Función genérica para enviar comandos al ESP32
  const sendCommand = async (cmd) => {
    try {
      if (!isConnected) throw new Error("El dispositivo no está conectado");
      await RNBluetoothClassic.writeToDevice(device.id, cmd + "\n");
    } catch (error) {
      showError("Error al enviar comando: " + error.message);
    }
  };

  // 🌕 LIGHT
  const handleLightToggle = async () => {
    const newValue = !lightEnabled;
    setLightEnabled(newValue);

    if (newValue) {
      setBlinkEnabled(false); // apagar BLINK
      await sendCommand("ligth"); // así está escrito en tu ESP32
    } else {
      await sendCommand("off");
    }
  };

  // ⚡ BLINK
  const handleBlinkToggle = async () => {
    const newValue = !blinkEnabled;
    setBlinkEnabled(newValue);

    if (newValue) {
      setLightEnabled(false); // apagar LIGHT
      await sendCommand("blink");
    } else {
      await sendCommand("off");
    }
  };

  const handleViewStatus = () => {
    Alert.alert(
      'Estado del dispositivo',
      `Modo actual:\n${
        lightEnabled ? "LIGHT"
        : blinkEnabled ? "BLINK"
        : "OFF"
      }\nConexión: ${isConnected ? 'Activa' : 'Inactiva'}`
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
              <Icon name="bluetooth" size={20} color="#2563eb" />
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

        {/* 🔥 Nuevo Control de Modos */}
        <View style={styles.card}>
          <Text style={styles.sectionTitle}>Modos de Iluminación</Text>

          {/* LIGHT */}
          <View style={styles.ledRow}>
            <View
              style={[
                styles.ledIconContainer,
                { backgroundColor: lightEnabled ? "#fef9c3" : "#f3f4f6" },
              ]}
            >
              <Icon name="wb-sunny" size={24} color={lightEnabled ? "#eab308" : "#9ca3af"} />
            </View>

            <View style={{ flex: 1 }}>
              <Text style={styles.ledTitle}>Modo Luz (LIGHT)</Text>
              <Text style={styles.ledSubtitle}>
                {lightEnabled ? "Encendido" : "Apagado"}
              </Text>
            </View>

            <Switch
              value={lightEnabled}
              onValueChange={handleLightToggle}
              trackColor={{ false: "#d1d5db", true: "#2563eb" }}
              thumbColor="#fff"
            />
          </View>

          {/* BLINK */}
          <View style={[styles.ledRow, { marginTop: 14 }]}>
            <View
              style={[
                styles.ledIconContainer,
                { backgroundColor: blinkEnabled ? "#ffe4e6" : "#f3f4f6" },
              ]}
            >
              <Icon name="flash-on" size={24} color={blinkEnabled ? "#f43f5e" : "#9ca3af"} />
            </View>

            <View style={{ flex: 1 }}>
              <Text style={styles.ledTitle}>Modo Parpadeo (BLINK)</Text>
              <Text style={styles.ledSubtitle}>
                {blinkEnabled ? "Activado" : "Desactivado"}
              </Text>
            </View>

            <Switch
              value={blinkEnabled}
              onValueChange={handleBlinkToggle}
              trackColor={{ false: "#d1d5db", true: "#2563eb" }}
              thumbColor="#fff"
            />
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

/* 🎨 Estilos */
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
  headerTitle: { color: "#fff", fontSize: 18, fontWeight: "600" },

  scrollContainer: { padding: 16 },

  card: {
    backgroundColor: "#fff",
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    elevation: 2,
  },

  deviceInfoRow: { flexDirection: "row", alignItems: "center", marginBottom: 8 },
  deviceIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: "#dbeafe",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },

  deviceName: { fontSize: 16, color: "#111827", fontWeight: "bold" },
  deviceId: { fontSize: 13, color: "#6b7280" },

  statusDot: { width: 10, height: 10, borderRadius: 5 },
  statusRow: { flexDirection: "row", alignItems: "center", gap: 6 },
  statusText: { color: "#6b7280", marginLeft: 6 },

  sectionTitle: { fontSize: 16, fontWeight: "bold", color: "#111827", marginBottom: 12 },

  ledRow: { flexDirection: "row", alignItems: "center" },

  ledIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },

  ledTitle: { fontSize: 15, color: "#111827", fontWeight: "600" },
  ledSubtitle: { color: "#6b7280", fontSize: 13 },

  actionButton: {
    backgroundColor: "#f9fafb",
    borderRadius: 10,
    padding: 12,
    marginTop: 8,
  },
  actionButtonText: { fontSize: 14, color: "#2563eb" },

  disconnectButton: { backgroundColor: "#fee2e2" },
  disconnectText: { color: "#b91c1c" },

  errorBanner: {
    position: "absolute",
    bottom: 20,
    left: 20,
    right: 20,
    backgroundColor: "#ef4444",
    padding: 12,
    borderRadius: 8,
    elevation: 4,
  },
  errorText: { color: "#fff", textAlign: "center", fontWeight: "600" },
});

export default DeviceControlScreen;
