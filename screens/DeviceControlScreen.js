// src/screens/DeviceControlScreen.js
import React, { useState } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  Switch,
  Alert,
  Vibration,
  StyleSheet,
} from "react-native";
import Icon from "react-native-vector-icons/Feather";

export default function DeviceControlScreen({ route, navigation }) {
  const { device } = route.params || {}; // ✅ Recibir el dispositivo desde la navegación
  const [ledEnabled, setLedEnabled] = useState(false);
  const [isConnected, setIsConnected] = useState(true);

  const handleLedToggle = (value) => {
    setLedEnabled(value);
    Vibration.vibrate(50);
    Alert.alert(
      value ? "LED encendido" : "LED apagado",
      "Comando enviado al dispositivo ESP32"
    );
  };

  const playNotificationSound = async () => {
    try {
      Vibration.vibrate([100, 200, 100]);
    } catch (error) {
      console.log("Error al reproducir sonido:", error);
    }
  };

  const handleDisconnect = () => {
    setIsConnected(false);
    playNotificationSound();
    Alert.alert(
      "Dispositivo desconectado",
      "La conexión con el ESP32 se ha perdido"
    );
    setTimeout(() => {
      navigation.goBack(); // ✅ Regresa automáticamente a la pantalla anterior
    }, 2000);
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
          <Icon name="chevron-left" size={26} color="#fff" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Control del Dispositivo</Text>
      </View>

      {/* Contenido */}
      <View style={styles.content}>
        {/* Device Info */}
        <View style={styles.card}>
          <View style={styles.row}>
            <View style={styles.iconCircleBlue}>
              <Icon name="bluetooth" size={28} color="#2563eb" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.deviceName}>{device?.name || "ESP32"}</Text>
              <Text style={styles.deviceId}>ID: {device?.id || "0000"}</Text>
            </View>
            <View
              style={[
                styles.statusDot,
                { backgroundColor: isConnected ? "#22c55e" : "#ef4444" },
              ]}
            />
          </View>
          <View style={styles.statusRow}>
            <Icon name="power" size={16} color="#6b7280" />
            <Text style={styles.statusText}>
              {isConnected ? "Conectado" : "Desconectado"}
            </Text>
          </View>
        </View>

        {/* LED Control */}
        <View style={styles.card}>
          <View style={styles.row}>
            <View
              style={[
                styles.iconCircle,
                { backgroundColor: ledEnabled ? "#fef9c3" : "#f3f4f6" },
              ]}
            >
              <Icon
                name="sun"
                size={24}
                color={ledEnabled ? "#eab308" : "#9ca3af"}
              />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.cardTitle}>Control LED</Text>
              <Text style={styles.cardSubtitle}>
                {ledEnabled ? "LED encendido" : "LED apagado"}
              </Text>
            </View>
            <Switch
              value={ledEnabled}
              onValueChange={handleLedToggle}
              trackColor={{ false: "#d1d5db", true: "#2563eb" }}
              thumbColor="#fff"
            />
          </View>

          {/* Estado visual */}
          <View style={styles.ledStateBox}>
            <Text style={styles.ledStateLabel}>Estado:</Text>
            <View
              style={[
                styles.ledStateIndicator,
                {
                  backgroundColor: ledEnabled ? "#dcfce7" : "#e5e7eb",
                },
              ]}
            >
              <Text
                style={{
                  color: ledEnabled ? "#15803d" : "#4b5563",
                  fontWeight: "bold",
                }}
              >
                {ledEnabled ? "ON" : "OFF"}
              </Text>
            </View>
          </View>
        </View>

        {/* Acciones */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Acciones</Text>

          <TouchableOpacity
            style={styles.actionButton}
            onPress={() =>
              Alert.alert(
                "Estado del dispositivo",
                `LED: ${ledEnabled ? "Encendido" : "Apagado"}\nConexión: ${
                  isConnected ? "Activa" : "Inactiva"
                }`
              )
            }
          >
            <Icon name="info" size={18} color="#2563eb" />
            <Text style={styles.actionText}>Ver Estado del Dispositivo</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.actionButton, { marginTop: 10 }]}
            onPress={handleDisconnect}
          >
            <Icon name="x-circle" size={18} color="#dc2626" />
            <Text style={[styles.actionText, { color: "#dc2626" }]}>
              Desconectar Dispositivo
            </Text>
          </TouchableOpacity>
        </View>

        {/* Nota */}
        <View style={styles.noteBox}>
          <Text style={styles.noteText}>
            💡 <Text style={{ fontWeight: "bold" }}>Nota:</Text> Esta aplicación
            simula el control Bluetooth de un ESP32. En una implementación real,
            se deben usar librerías nativas como{" "}
            <Text style={{ fontStyle: "italic" }}>react-native-ble-plx</Text> o{" "}
            <Text style={{ fontStyle: "italic" }}>react-native-bluetooth-classic</Text>.
          </Text>
        </View>
      </View>
    </View>
  );
}

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
