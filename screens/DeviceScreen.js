import React from 'react';
import { View, Text, Switch, StyleSheet } from 'react-native';

export default function DeviceScreen({ route }) {
  const { device } = route.params;

  return (
    <View style={styles.container}>
      <Text style={styles.deviceName}>{device.name || 'Dispositivo sin nombre'}</Text>

      <View style={styles.switchContainer}>
        <Text style={styles.switchLabel}>Interruptor</Text>
        <Switch
          value={false}
          onValueChange={() => {}}
          trackColor={{ false: '#ccc', true: '#28a745' }}
          thumbColor="#fff"
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'space-between',
    padding: 40,
    backgroundColor: '#fff',
  },
  deviceName: {
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    marginTop: 40,
  },
  switchContainer: {
    alignItems: 'center',
    marginBottom: 80,
  },
  switchLabel: {
    fontSize: 18,
    marginBottom: 10,
  },
});
