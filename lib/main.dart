import 'package:flutter/material.dart';
import 'package:rfd_mobile_app/pages/camera.dart';
import 'package:rfd_mobile_app/pages/home.dart';
import 'package:rfd_mobile_app/pages/splash.dart';

main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Rotten Fruits Detection",
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: Splash.routeName,
      routes: {
        Splash.routeName: (context) => const SafeArea(child: Splash()),
        Home.routeName: (context) => const SafeArea(child: Home()),
        Camera.routeName: (context) => const SafeArea(child: Camera()),
      },
    );
  }
}
