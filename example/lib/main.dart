import 'package:flutter/material.dart';
import 'package:store_plugin/cx_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: CXStore()

          // Center(
          //   child: GestureDetector(
          //       onTap: () {
          //         Navigator.of(context).push(CupertinoPageRoute(
          //             // settings: const RouteSettings(name: "store_main"),
          //             builder: (_) {
          //           return const CXStore();
          //         }));
          //       },
          //       child: Text('Running on: $_platformVersion\n')),
          // ),
          ),
    );
  }
}
