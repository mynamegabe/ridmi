import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart'; // Bluetooth Provider
import '../providers/user_provider.dart'; // User Provider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final userData = Provider.of<UserProvider>(context).userData;

    // Determine Bluetooth connection status
    bool isConnected = bluetoothProvider.connectedDevice != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Full-Screen Background with Offset
          Positioned(
            top: 500,
            left: 0,
            right: 0,
            bottom: 0, // Fill until the bottom
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/globe_1.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Foreground Content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/ridmi_logo.png', // Replace with your asset path
                              width: 120,
                            ),
                          ],
                        ),
                      ),

                      // Header text Hi, name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, ${userData?['first_name']} ${userData?['last_name'][0]}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  'How can we help today?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // horizontal line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          height: 1,
                          color: Colors.black12,
                        ),
                      ),

                      // header Recent Records
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Records',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recent Records table with patients' name and date of visit
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                          },
                          children: const [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Patient Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Date of Visit',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'John Doe',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      '12th July 2021',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Jane Doe',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      '15th July 2021',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 180),
                      // text that shows whether app is bluetooth paired to device
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bluetooth Status',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5), // Adds space between the title and subtext
                            Text(
                              isConnected
                                  ? 'Device connected to reader'
                                  : 'Device not connected to reader',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20), // Adds space between subtext and button
                            // show diff button if connected
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/connect');
                                },
                                child: const Text('Connect'),
                              ),
                            if (isConnected)
                              ElevatedButton(
                                onPressed: () async {
                                  // Ensure readData is completed before proceeding
                                  await bluetoothProvider.readData();
                                  _showMedicalInfoDialog(
                                    context,
                                    bluetoothProvider.parsedData != null
                                        ? Map<String, dynamic>.from(bluetoothProvider.parsedData!) // Cast the Map to the correct type
                                        : {},
                                  );
                                },
                                child: const Text('Read'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        unselectedIconTheme: IconThemeData(color: Theme.of(context).disabledColor),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).disabledColor,
        // backgroundColor: Colors.blueAccent, // Background color of the BottomNavigationBar
        // selectedItemColor: Theme.of(context).primaryColor, // Color of selected items
        // unselectedItemColor: Colors.black54, // Color of unselected items
        // selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54), // Custom font style for selected label
        // unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black54), // Custom font style for unselected label
        elevation: 10, // Shadow effect for the BottomNavigationBar
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // icon: Icon(Icons.home),
            // icon from assets/image
            icon: ImageIcon(AssetImage('assets/images/logo_icon.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            // icon: Icon(Icons.article),
            icon: ImageIcon(AssetImage('assets/images/records_icon.png')),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            // icon: Icon(Icons.chat),
            icon: ImageIcon(AssetImage('assets/images/consults_icon.png')),
            label: 'Consults',
          ),
          BottomNavigationBarItem(
            // icon: Icon(Icons.person),
            icon: ImageIcon(AssetImage('assets/images/profile_icon.png')),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Show dialog with medical information
  void _showMedicalInfoDialog(BuildContext context, Map<String, dynamic> data) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Builder(
            builder: (context) {
              final size = MediaQuery.of(context).size;
              return Container(
                height: size.height - 20,  // Fullscreen minus 20 units
                width: size.width,         // Fullscreen width
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medical Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      _buildInfoSection(context, 'Name', data['NM'] ?? 'N/A', bluetoothProvider),
                      _buildInfoSection(context, 'DOB', data['DOB'] ?? 'N/A', bluetoothProvider),
                      _buildInfoSection(context, 'Gender', data['SEX'] ?? 'N/A', bluetoothProvider),
                      _buildInfoSection(context, 'Contact Info', data['CON'] ?? 'N/A', bluetoothProvider),
                      _buildInfoSection(context, 'Emergency Contact', data['ECON'] ?? 'N/A', bluetoothProvider),
                      _buildListSection(context, 'Chronic Illnesses', data['CI'], bluetoothProvider),
                      _buildListSection(context, 'Past Hospitalizations', data['PH'], bluetoothProvider),
                      _buildListSection(context, 'Allergies', data['AL'], bluetoothProvider),
                      _buildListSection(context, 'Family Medical History', data['FMH'], bluetoothProvider),
                      _buildNestedMapSection(context, 'Vaccination Records', data['VR'], bluetoothProvider),
                      _buildNestedMapSection(context, 'Lab Test Records', data['LTR'], bluetoothProvider),
                      _buildNestedMapSection(context, 'Appointment History', data['AH'], bluetoothProvider),
                      _buildNestedMapSection(context, 'Medication History', data['MH'], bluetoothProvider),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildInfoSection(BuildContext context, String title, String info, BluetoothProvider bluetoothProvider) {
    // Create a TextEditingController to control the text field
    TextEditingController controller = TextEditingController(text: info);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          // Editable text field for the info
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            ),
          ),
          const SizedBox(height: 8),
          // Button to save the data
          ElevatedButton(
            onPressed: () {
              // Update the value in the data map when button is pressed
              String updatedInfo = controller.text.trim();

              // Call the bluetoothProvider.writeData() to write updated data
              bluetoothProvider.writeData(title, updatedInfo);

              // Optionally, show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title updated successfully!')),
              );
            },
            child: Text('Save $title'),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title, List<dynamic>? list, BluetoothProvider bluetoothProvider) {
    if (list == null || list.isEmpty) {
      return _buildInfoSection(context, title, 'N/A', bluetoothProvider);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          ...list.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                '• $item',  // Bullet point style for list items
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNestedMapSection(BuildContext context, String title, List<dynamic>? list, BluetoothProvider bluetoothProvider) {
    if (list == null || list.isEmpty) {
      return _buildInfoSection(context, title, 'N/A', bluetoothProvider);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          ...list.map((item) {
            // Handling different types of nested structures
            if (title == 'Vaccination Records') {
              return _buildVaccinationRecord(item);
            } else if (title == 'Lab Test Records') {
              return _buildLabTestRecord(item);
            } else if (title == 'Appointment History') {
              return _buildAppointmentHistory(item);
            } else if (title == 'Medication History') {
              return _buildMedicationHistory(item);
            } else {
              return const SizedBox.shrink(); // Fallback for unhandled titles
            }
          }),
        ],
      ),
    );
  }

  Widget _buildVaccinationRecord(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '- Vaccine Name: ${item['va'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Date: ${item['doa'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Booster: ${item['bo'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildLabTestRecord(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '- Test Name: ${item['te'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Result: ${item['r'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Date: ${item['d'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildAppointmentHistory(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '- Appointment Date: ${item['ad'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Doctor: ${item['doctor'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Reason: ${item['r'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildMedicationHistory(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '- Medication Name: ${item['m'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Dosage: ${item['d'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Frequency: ${item['f'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  Start Date: ${item['start_date'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            '  End Date: ${item['end_date'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Divider(),
        ],
      ),
    );
  }


  // Helper method to build the info row in the dialog
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
