import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider with ChangeNotifier {
  final List<BluetoothDevice> _devices = []; // List to store discovered devices
  BluetoothDevice? _connectedDevice; // Currently connected device

  List<BluetoothDevice> get devices => List.unmodifiable(_devices);

  void startScanning() {
    _devices.clear();
    notifyListeners();

    // Start scanning
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen for scan results
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!_devices.any((device) => device.id == result.device.id)) {
          _devices.add(result.device);
          notifyListeners();
        }
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect(); // Disconnect existing device
    }

    try {
      await device.connect(); // Connect to the new device
      _connectedDevice = device;
      notifyListeners();
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  bool isConnected(BluetoothDevice device) {
    return _connectedDevice?.id == device.id; // Check connection status
  }

  Future<void> disconnectFromDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect(); // Disconnect current device
      _connectedDevice = null;
      notifyListeners();
    }
  }
}
