import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/test.dart';
import 'providers/bluetooth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        // ChangeNotifierProvider(create: (_) => IRAttackProvider()),
        // ChangeNotifierProvider(create: (_) => RFAttackProvider()),
        // ChangeNotifierProvider(create: (_) => RFIDProvider()),
        // ChangeNotifierProvider(create: (_) => WifiAttackProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RIDMI',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => TestHome(),
        // '/menu': (context) => MainMenu(),
        // '/ir': (context) => IRPage(),
        // '/rf': (context) => RFPage(),
        // '/rfid': (context) => RFIDPage(),
        // '/wifi': (context) => WifiPage(),
        // '/settings': (context) => SettingsPage(),
        // '/ir/attack': (context) => IRAttackPage(),
        // '/ir/record': (context) => IRRecordPage(),
        // '/ir/list': (context) => IRAttackListPage(),
        // '/rf/attack': (context) => RFAttackPage(),
        // '/rf/record': (context) => RFRecordPage(),
        // '/rf/list': (context) => RFAttackListPage(),
        // '/rfid/clone': (context) => RFIDClonePage(),
        // '/rfid/record': (context) => RFIDRecordPage(),
        // '/rfid/list': (context) => RFIDCardListPage(),
        // '/wifi/deauth': (context) => DeauthPage(),
      },
    );
  }
}
