import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:touna/firebase_options.dart';
import 'package:touna/page/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

enum AppState { done, loading, error }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: home());
  }

  home() {
    // if (Platform.isAndroid) {
    //   return const HomeMobilePage(title: 'Jadwal Sidang KN Touna');
    // }
    return const HomePage(title: 'Jadwal Sidang KN Touna');
  }
}
