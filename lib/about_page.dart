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
              'YVCounter app is created while learning flutter to solve a common scenario to count malas or japas which is done by hindu religion pepole during meditation.\n\nIn Hinduism the japa mala is used to direct and count the recitation of mantras during meditation. It usually consists of 108 beads strung in a circle to represent the cyclic nature of life.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
