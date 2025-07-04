import 'package:flutter/material.dart';
import 'package:yv_counter/famity_tree/pages/treeview.dart';
import 'addpage.dart';
import 'createpage.dart';
import 'editpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();

  final String title;
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                child: const Text(
                  "Start",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoadTree()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text(
                  "Create",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CreatePage()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text(
                  "Add",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddPage()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text(
                  "Update",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EditPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
