import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '\n@Yash Vyas\n',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Text(
              'YVCounter app is created while learning flutter to solve a common scenario to count malas or japs which is done by hindu religion pepole to remember god.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
