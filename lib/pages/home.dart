import 'package:flutter/material.dart';
import 'package:rfd_mobile_app/pages/camera.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  static const routeName = '/home';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rotten Fruits Detector"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: NetworkImage(image),
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 90),
              const Text(
                'Insert a picture of a fruit to detect if it is rotten or not.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Camera.routeName)
            .then((value) => setState(() => image = value)),
        tooltip: 'Take a picture',
        child: const Icon(Icons.camera_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
