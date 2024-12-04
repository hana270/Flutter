import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterrr/Views/app_main_screen.dart';
import 'package:provider/provider.dart';

import 'LoginScreen.dart';
import 'Provider/favorite_provider.dart';
import 'Provider/quantity.dart'; // Import QuantityProvider
import 'RegisterScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => FavoriteProvider()), // FavoriteProvider
        ChangeNotifierProvider(
            create: (context) => QuantityProvider()), // QuantityProvider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute:
            FirebaseAuth.instance.currentUser == null ? '/login' : '/main',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const AppMainScreen(),
        },
      ),
    );
  }
}
