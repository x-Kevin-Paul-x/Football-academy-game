import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youth Academy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Football Youth Academy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title ;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(child: Text(
              'Youth Academy',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
                color: Colors.black,
              ),
            )),
            const Padding(padding: EdgeInsets.all(5)),

            ElevatedButton(
            onPressed: () {
              // Navigate to the next screen
            }, 
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),child: const Text("New Game")),


            const Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(onPressed: () {
              (BuildContext context) => [
                const PopupMenuItem(value: "Load Game",child: Text("Load Game"),)];
            },style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ), child: const Text("Load Game")),


            const Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(onPressed: () {
              // Navigate to the next screen
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ), child: const Text("Quit Game")),
          ],
        ),
        
      ),
    );
  }
}
