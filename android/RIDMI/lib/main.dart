import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/user_provider.dart';
import 'screens/connect_screen.dart';
import 'screens/start_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
      theme: ThemeData(
        fontFamily: 'Figtree',
        primaryColor: Color(0xFF13BFB5), // Set primary color
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF13BFB5), // Primary color for widgets
          secondary: Color(0xFF13BFB5), // Secondary color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF13BFB5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Color(0xFF13BFB5)),
            foregroundColor: Color(0xFF13BFB5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(),
        '/connect': (context) => ConnectHome(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
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
