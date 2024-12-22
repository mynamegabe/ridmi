import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../config.dart';
import 'dart:convert';

class BluetoothProvider with ChangeNotifier {
  final List<BluetoothDevice> _devices = []; // List to store discovered devices
  BluetoothDevice? _connectedDevice; // Currently connected device
  BluetoothCharacteristic? _readChar; // Characteristic for reading data
  final List<int> _dataBuffer = [];
  String _data = '';
  Map? _parsedData;

  List<BluetoothDevice> get devices => List.unmodifiable(_devices);
  BluetoothDevice? get connectedDevice => _connectedDevice;
  Map? get parsedData => _parsedData;
  String get data => _data;

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
      getService();
      notifyListeners();
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future<void> getService() async {
    if (_connectedDevice != null) {
      try {
        List<BluetoothService> services = await _connectedDevice!.discoverServices();
        // print all services and characteristics
        services.forEach((service) {
          print('Service: ${service.uuid}');
          service.characteristics.forEach((char) {
            print('Characteristic: ${char.uuid}');
            if ('${char.uuid}' == Config.characteristicId) {
              _readChar = char;
              print('Read characteristic found');
            }
          });
        });
        // _readChar = lastService.characteristics.last;
        // find characteristic matching Config.serviceId and characteristicId
        // _readChar = services
        //     .expand((service) => service.characteristics)
        //     .firstWhere((char) => char.uuid == Config.characteristicId);
        notifyListeners();
      } catch (e) {
        print('Error discovering services: $e');
      }
    }
  }

  Future<void> readData() async {
    _dataBuffer.clear();
    _data = '';
    // send write command 0x11
    if (_readChar != null) {
      try {
        await _readChar!.write([0x11]);
      } catch (e) {
        print('Error writing data: $e');
      }

        List<int> value = [0x01];
        List<int> lastValue = [0x01];

      do {
        value = await _readChar!.read();
        if (lastValue != value && value.isNotEmpty) {
          print('Data received a: $value');
          lastValue = value;
          _data += utf8.decode(value);
          print(_data);
          // _dataBuffer.addAll(value);
        }
        else {
          print('Same value');
        }
        // value.clear();
      } while (_data.contains('END') == false);


        // slice string from { to len-3
        _data = _data.substring(_data.indexOf('{'), _data.indexOf('END'));

        // parse json in _data
        try {
          final data = jsonDecode(_data);
          _parsedData = data;
          print('Parsed data: $data');
        } catch (e) {
          print('Error parsing data: $e');
        }
      // });
    }
    // test data
    // _parsedData = {
    //   "NM": "John Doe",
    //   "DOB": "1985-06-15",
    //   "SEX": "Male",
    //   "CON": "+1234567890",
    //   "ECON": "+0987654321",
    //   "CI": [
    //     "Diabetes",
    //     "Hypertension"
    //   ],
    //   "PH": [
    //     "Appendectomy (2010)",
    //     "Knee surgery (2015)"
    //   ],
    //   "AL": [
    //     "Penicillin",
    //     "Peanuts"
    //   ],
    //   "FMH": [
    //     "Father: Heart disease",
    //     "Mother: Cancer"
    //   ],
    //   "VR": [
    //     {
    //       "va": "COVID-19",
    //       "doa": "2021-03-15",
    //       "bo": false
    //     },
    //     {
    //       "va": "Influenza",
    //       "doa": "2023-10-05",
    //       "bo": true
    //     }
    //   ],
    //   "DOA": [
    //     "2023-12-01"
    //   ],
    //   "BR": [
    //     "2023-12-05"
    //   ],
    //   "LTR": [
    //     {
    //       "te": "Blood test",
    //       "d": "2023-11-15",
    //       "r": "Normal"
    //     },
    //     {
    //       "te": "X-ray",
    //       "d": "2023-11-10",
    //       "r": "Fracture detected"
    //     }
    //   ],
    //   "AH": [
    //     {
    //       "ad": "2023-12-01",
    //       "r": "Routine checkup"
    //     },
    //     {
    //       "ad": "2023-11-15",
    //       "r": "Follow-up after surgery"
    //     }
    //   ],
    //   "MH": [
    //     {
    //       "m": "Metformin",
    //       "d": "500mg",
    //       "f": "Twice a day"
    //     },
    //     {
    //       "m": "Amlodipine",
    //       "d": "10mg",
    //       "f": "Once a day"
    //     }
    //   ]
    // };
  }


  Future<void> writeData(String key, String data) async {
    if (_readChar != null) {
      try {
        await _readChar!.write(utf8.encode(jsonEncode({key: data})));
      } catch (e) {
        print('Error writing data: $e');
      }
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
