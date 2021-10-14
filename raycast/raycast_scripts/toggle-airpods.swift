#!/usr/bin/swift

import IOBluetooth

// Get your device's MAC address by option (⌥) + clicking the bluetooth icon in the menu bar
let deviceAddress = "44-F0-9E-2D-66-5B"

func toggleAirPods() {
    guard let bluetoothDevice = IOBluetoothDevice(addressString: deviceAddress) else {
        print("Device not found")
        exit(1)
    }

    if !bluetoothDevice.isPaired() {
        print("Device not paired")
        exit(1)
    }

    if bluetoothDevice.isConnected() {
        print("AirPods Disconnected")
        bluetoothDevice.closeConnection()
    } else {
        print("AirPods Connected")
        bluetoothDevice.openConnection()
    }
}

toggleAirPods()
