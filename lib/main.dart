import 'package:flutter/material.dart';

import 'stories_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instalavista',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        MainScreen.routeName: (context) => MainScreen(),
        StoryScreen.routeName: (context) => StoryScreen(),
      },
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  static const String routeName = "routeMain";

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instalavista"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Go To Stories"),
          onPressed: () {
            Navigator.pushNamed(context, StoryScreen.routeName);
          },
        ),
      ),
    );
  }
}
