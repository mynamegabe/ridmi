import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class DeviceInteractionScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceInteractionScreen({super.key, required this.device});

  @override
  State<DeviceInteractionScreen> createState() => _DeviceInteractionScreenState();
}

class Message{

  String? text;

  int? sender;

  Message(this.text,this.sender);

}

class _DeviceInteractionScreenState extends State<DeviceInteractionScreen> {
  List<BluetoothService>? _services;
  bool _isLoading = true;
  BluetoothCharacteristic? _lastChar;
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      setState(() {
        _services = services;
        _isLoading = false;
        BluetoothService lastService = services.last;
        _lastChar = lastService.characteristics.last;
      });
    } catch (e) {
      print("Error discovering services: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_lastChar != null) {

      setState(() {
        messages.add(Message(message,1));
      });

      await _lastChar!.setNotifyValue(true);
      await _lastChar!.write(Uint8List.fromList(utf8.encode(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name.isNotEmpty ? widget.device.name : 'Unknown Device')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services != null
          ? ListView.builder(
        itemCount: _services!.length,
        itemBuilder: (context, index) {
          final service = _services![index];
          // List<Message> messages = [];
          StreamSubscription<List<int>>? streamSub;

          streamSub = _lastChar?.onValueReceived.listen((value) async {
            if (value.isNotEmpty) {
              String s = String.fromCharCodes(value);
              setState(() {
                messages.add(Message(s,0));
              });
            }
          });

          return ExpansionTile(
            title: Text('Service: ${service.uuid}'),
            children: service.characteristics.map((characteristic) {
              return ListTile(
                title: Text('Characteristic: ${characteristic.uuid}'),
                subtitle: Text('Properties: ${characteristic.properties}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (characteristic.properties.read)
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          var value = await characteristic.read();
                          print("Read value: $value");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Value: $value')),
                          );
                        },
                      ),
                    if (characteristic.properties.write)
                      IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: () async {
                          await characteristic.write([0x01, 0x02]); // Example data
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data written successfully')),
                          );
                        },
                      ),
                    if (characteristic.properties.notify)
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () async {
                          await characteristic.setNotifyValue(true);
                          characteristic.value.listen((value) {
                            print("Notification: $value");
                          });
                        },
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      )
          : const Center(child: Text('No services found')),
    );
  }
}
