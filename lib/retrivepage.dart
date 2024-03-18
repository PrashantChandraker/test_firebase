import 'package:flutter/material.dart';

class Retrivepage extends StatefulWidget {
  final String imageUrl;

  const Retrivepage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<Retrivepage> createState() => _RetrivepageState();
}

class _RetrivepageState extends State<Retrivepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retrieved Image'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Image.network(widget.imageUrl), // Display the retrieved image
        ],
      ),
    );
  }
}
