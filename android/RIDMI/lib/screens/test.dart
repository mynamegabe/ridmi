import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import 'device_interaction.dart';

class TestHome extends StatefulWidget {
  @override
  _TestHomeState createState() => _TestHomeState();
}

class _TestHomeState extends State<TestHome> {
  bool showAllDevices = false;
  String searchQuery = '';
  bool sortAlphabetically = false;

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    // Filter and optionally sort devices
    List devicesToShow = bluetoothProvider.devices.where((device) {
      final matchesSearchQuery =
      device.id.toString().toLowerCase().contains(searchQuery.toLowerCase());
      final isKnownDevice = device.name.isNotEmpty;

      return matchesSearchQuery && (showAllDevices || isKnownDevice);
    }).toList();

    // Sort devices alphabetically if the sort flag is enabled
    if (sortAlphabetically) {
      devicesToShow.sort((a, b) => a.id.toString().compareTo(b.id.toString()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
            tooltip: 'Go to Main Menu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Scan and toggle device visibility buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => bluetoothProvider.startScanning(),
                  child: const Text('Scan for Devices'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAllDevices = !showAllDevices;
                    });
                  },
                  child: Text(showAllDevices ? 'Hide Unknown Devices' : 'Show All Devices'),
                ),
              ),
            ],
          ),

          // Search and Sort functionality
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by MAC Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        sortAlphabetically = false; // Reset sort when typing
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      sortAlphabetically = true; // Trigger sorting
                    });
                  },
                  child: const Text('Sort'),
                ),
              ],
            ),
          ),

          // Device list display
          Expanded(
            child: ListView.builder(
              itemCount: devicesToShow.length,
              itemBuilder: (context, index) {
                final device = devicesToShow[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                  subtitle: Text(device.id.toString()),
                  trailing: bluetoothProvider.isConnected(device)
                      ? const Icon(Icons.bluetooth_connected, color: Colors.green)
                      : const Icon(Icons.bluetooth_disabled, color: Colors.red),
                  onTap: () async {
                    await bluetoothProvider.connectToDevice(device);

                    // Navigate to the interaction page after connection
                    if (bluetoothProvider.isConnected(device)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceInteractionScreen(device: device),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to connect to the device')),
                      );
                    }
                  },
                );
              },
            ),
          ),

          // Go to main menu button (from Code 2)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/menu');
              },
              child: const Text('Go to Main Menu'),
            ),
          ),
        ],
      ),
    );
  }
}
