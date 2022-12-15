import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:yv_counter/family_tree/my_node.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key, required this.title});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();

  final String title;
}

final Graph graph = Graph()..isTree = true;
SugiyamaConfiguration builder = SugiyamaConfiguration();
List<MyNode> listMyNode = [];
int nodesCount = 1;

String text = "no_data";

class _TreeViewPageState extends State<TreeViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder(
        future: readJson(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            updateNode(snapshot.data);
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(text),
                Expanded(
                  child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(300),
                    minScale: 0.01,
                    maxScale: 5.6,
                    child: GraphView(
                      graph: graph,
                      algorithm: SugiyamaAlgorithm(builder),
                      paint: Paint()
                        ..color = Colors.green
                        ..strokeWidth = 1
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        // I can decide what widget should be shown here
                        //based on the id
                        var a = node.key!.value as int;
                        return rectangleWidget(a);
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Text(
              'Something went wrong!',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget rectangleWidget(int a) {
    TextEditingController textController = TextEditingController();
    if (listMyNode[a - 1].text != "") {
      textController.text = listMyNode[a - 1].text;
    }

    return InkWell(
      onTap: () {
        debugPrint("a$a");
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Colors.blue, spreadRadius: 1),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              // height: 80,
              width: 80,
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: textController,
                decoration: const InputDecoration(),
                onChanged: (v) async {
                  await listMyNode[a - 1].updateText(v, listMyNode);
                  final map = await readJson();
                  text = map.toString();
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.add_box_rounded),
                iconSize: 24,
                onPressed: () async {
                  nodesCount++;
                  final newNode = Node.Id(nodesCount);
                  var edge = graph.getNodeAtPosition(a - 1);
                  graph.addEdge(edge, newNode);
                  setState(() {
                    MyNode b = MyNode(nodesCount, "");
                    listMyNode.add(b);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    builder
      ..levelSeparation = (150)
      ..nodeSeparation = (100)
      ..orientation = (SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  void updateNode(Map<String, dynamic> map) {
    debugPrint("updateNode");
    text = map.toString();
    debugPrint(text);
    if (map.isEmpty) {
      final node1 = Node.Id(1);
      final node2 = Node.Id(2);
      MyNode block1 = MyNode(1, "empty1");
      nodesCount++;
      MyNode block2 = MyNode(2, "empty2");
      nodesCount++;
      listMyNode.add(block1);
      listMyNode.add(block2);
      graph.addEdge(node1, node2);
    } else {
      bool first = true;
      Node? node1;
      MyNode? block1;
      map.forEach((id, value) {
        final intId = int.parse(id);
        if (first) {
          node1 = Node.Id(intId);
          block1 = MyNode(intId, value);
          nodesCount++;
          first = false;
        } else {
          final node2 = Node.Id(intId);
          MyNode block2 = MyNode(intId, value);
          nodesCount++;
          listMyNode.add(block1!);
          listMyNode.add(block2);
          graph.addEdge(node1!, node2);
        }
      });
    }
  }
}
