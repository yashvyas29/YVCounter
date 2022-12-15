import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class FamilyTreePage extends StatefulWidget {
  const FamilyTreePage({super.key});

  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();

  static const json = {
    'nodes': [
      {'id': 1, 'label': 'Heera Lal Ji Vyas'},
      {'id': 2, 'label': 'Bhim Shankar Ji'},
      {'id': 3, 'label': 'Kishore Ji\nVadam Bai'},
      {'id': 4, 'label': 'Narayan Ji\nGopi Bai'},
      {'id': 5, 'label': 'Banshi Lal Ji\nLahri Bai'},
      {'id': 6, 'label': 'Girja Shankar Ji\nSajjan Devi'},
      {'id': 7, 'label': 'Kamla Kant Ji\nBhagvati Devi'},
      {'id': 8, 'label': 'Lakshmi Kant Ji\nUnkari Devi'},
      {'id': 9, 'label': 'Mahedra Ji\nRukman Devi'},
      {'id': 10, 'label': 'Pramod Ji\nGopi Devi'},
      {'id': 11, 'label': 'Hemlata Devi\nMadan Ji Choubisa'},
      {'id': 12, 'label': 'Kusum Devi\nVasudev Ji Joshi'},
      {'id': 13, 'label': 'Nutan Devi\nKailash Ji Choubisa'},
      {'id': 14, 'label': 'Chaitanya Prakash Ji\nShakuntala Devi'},
      {'id': 15, 'label': 'Suman Devi\nPupsa Ji Choubisa'},
      {'id': 16, 'label': 'Chandra Prakash Ji\nLeela Devi, Uma Devi'},
      {'id': 17, 'label': 'Kanak Ji\nHansa Devi Joshi'},
      {'id': 18, 'label': 'Ritu Devi\nRajendra Ji Vyas'},
      {'id': 19, 'label': 'Kuldeep Ji\nSeema Devi Mandawat'},
      {'id': 20, 'label': 'Mohit Ji'},
      {'id': 21, 'label': 'Harita Devi\nGopal Ji Vyas'},
      {'id': 22, 'label': 'Darshan Ji\nRuchika Devi Choubisa'},
      {'id': 23, 'label': 'Tilak Ji\nRitu Devi Choubisa'},
      {'id': 24, 'label': 'Abha Devi\nBharat Ji Vyas'},
      {'id': 25, 'label': 'Priti Devi\nNaresh Ji Vijawat'},
      {'id': 26, 'label': 'Pulkit\nPoonam Choubisa'},
      {'id': 27, 'label': 'Apeksha Devi\nBhupendra Ji Joshi'},
      {'id': 28, 'label': 'Yash\nPooja Choubisa'},
      {'id': 29, 'label': 'Kovid'},
      {'id': 30, 'label': 'Buddhi'},
      {'id': 31, 'label': 'Girl'},
      {'id': 32, 'label': 'Kostubh (Goldi)'},
      {'id': 33, 'label': 'Himadri (Honey)'},
      {'id': 34, 'label': 'Jhanvi (Jheel)'},
      {'id': 35, 'label': 'Charvi (China)'},
      {'id': 36, 'label': 'Paridhi (Pari)'},
      {'id': 37, 'label': 'Neha'},
      {'id': 38, 'label': 'Shobhit'},
      {'id': 39, 'label': 'Ashu'},
      {'id': 40, 'label': 'Bholu'},
      {'id': 41, 'label': 'Naman'},
      {'id': 42, 'label': 'Kantha'},
      {'id': 43, 'label': 'Satakshi (Sakshu)'},
      {'id': 44, 'label': 'Dharv (Dhruv)'},
      {'id': 45, 'label': 'Darmendra Ji\nNirmala Devi'},
      {'id': 46, 'label': 'Sadhna Devi\nJiya Ji'},
      {'id': 47, 'label': 'Gopal Ji\nBhuvneshvari Devi Upadhyay'},
      {'id': 48, 'label': 'Anant Ji\nSugna Devi Mandawat'},
      {'id': 49, 'label': 'Ravi Ji\nGagan Devi Joshi'},
      {'id': 50, 'label': 'Cheshtha Devi\nLokesh Ji Vyas'},
      {'id': 51, 'label': 'Lakshit Ji\nKumud Devi'},
      {'id': 52, 'label': 'Om Ji\nGupt Rekha Devi'},
      {'id': 53, 'label': 'Munmun (Tali) Devi\nGopal Ji'},
      {'id': 54, 'label': 'Himanshu (Tingu)'},
      {'id': 55, 'label': 'Aakash (Aashu)'},
      {'id': 56, 'label': 'Chhavi Devi\nBharat Ji Choubisa'},
      {'id': 57, 'label': 'Kamini (Pinki) Devi'},
      {'id': 58, 'label': 'Prateek (Tinu)\nShreya Bhatt'},
      {'id': 59, 'label': 'Deveshwari\nPamna'},
      {'id': 60, 'label': 'Lokendra'},
      {'id': 61, 'label': 'Govind'},
      {'id': 62, 'label': 'Himani (Guddi)'},
      {'id': 63, 'label': 'Himanshu (Sonu)'},
      {'id': 64, 'label': 'Manish'},
      {'id': 65, 'label': 'Yoshit'},
      {'id': 66, 'label': 'Kirti'},
      {'id': 67, 'label': 'Harshita'},
      {'id': 68, 'label': 'Tanmay (Tannu)'},
      {'id': 69, 'label': 'Khushi'},
      {'id': 70, 'label': 'Niharika'},
      {'id': 71, 'label': 'Girl2'},
      {'id': 72, 'label': 'Mudit'},
      {'id': 73, 'label': 'Kuku'},
      {'id': 74, 'label': 'Kunal'},
      {'id': 75, 'label': 'Naman'},
      {'id': 76, 'label': 'Boy'},
      {'id': 77, 'label': 'Girl'},
      {'id': 78, 'label': 'Chiku'},
      {'id': 79, 'label': 'Babu'},

      {'id': 80, 'label': 'Boy'},
      {'id': 81, 'label': 'Kunj Bihari Ji'},
      {'id': 82, 'label': 'Avadh Bihari Ji'},
      {'id': 83, 'label': 'Dev Datt Ji'},

      {'id': 84, 'label': 'Aniruddh Ji'},
      {'id': 85, 'label': 'Rajendra Ji'},
      {'id': 86, 'label': 'Ashwin Ji'},
      {'id': 87, 'label': 'Pavan Ji'},
      {'id': 88, 'label': 'Dhananjay Ji'},
      {'id': 89, 'label': 'Pradhyumn Ji'},

      {'id': 90, 'label': 'Ruchika\nSanjay Ji Joshi'},
      {'id': 91, 'label': 'Omendra'},
      {'id': 92, 'label': 'Sudhanshu'},
      {'id': 93, 'label': 'Boy'},
      {'id': 94, 'label': 'Girl'},
      {'id': 95, 'label': 'Boy'},
      {'id': 96, 'label': 'Boy'},

      // {'id': 8, 'label': 'Moti Lal Ji Dharmawat'},
      // {'id': 9, 'label': 'Shankar Lal Ji'},
      // {'id': 10, 'label': 'Jagannath Ji\nHeera Bai'},
      // {'id': 21, 'label': 'Sajjan Devi\nGirja Lal Ji Vyas'},
      // {'id': 11, 'label': 'Bhanwar Lal Ji\nDurga Devi'},
      // {'id': 22, 'label': 'Sundar Lal Ji\nAmba Devi'},
      // {'id': 19, 'label': 'Pushpa Devi\nBheru Lal Ji Choubisa'},
      // {'id': 20, 'label': 'Heera Lal Ji\nRukman Devi'},
      // {'id': 13, 'label': 'Mithhu Lal Ji\nNirmala Devi'},
      // {'id': 14, 'label': 'Deepika Devi\nVinod Ji Choubisa'},
      // {'id': 15, 'label': 'Pooja\nYash Vyas'},
      // {'id': 16, 'label': 'Ayush'},
      // {'id': 17, 'label': 'Abhishek'},
      // {'id': 18, 'label': 'Parth'},
      // {'id': 23, 'label': 'Chandra Prakash Ji\nBhagvati Devi'},
      // {'id': 24, 'label': 'Deepak Ji\nDurga Devi'},
      // {'id': 25, 'label': 'Elakshi'},
      // {'id': 26, 'label': 'Prayag'},
      // {'id': 27, 'label': 'Rajshree'},
      // {'id': 28, 'label': 'Vaideh'},
      // {'id': 29, 'label': 'Devkanya Devi\nRadheshyam Ji Choubisa'},
      // {'id': 30, 'label': 'Lokesh Ji\nDeepmala Devi'},
      // {'id': 31, 'label': 'Bhagvati Devi\nMahesh Ji Choubisa'},
    ],
    'edges': [
      {'from': 1, 'to': 2},
      {'from': 2, 'to': 3},
      {'from': 3, 'to': 4},
      {'from': 4, 'to': 5},
      {'from': 5, 'to': 6},
      {'from': 5, 'to': 7},
      {'from': 5, 'to': 8},
      {'from': 6, 'to': 9},
      {'from': 6, 'to': 10},
      {'from': 7, 'to': 11},
      {'from': 7, 'to': 12},
      {'from': 7, 'to': 13},
      {'from': 7, 'to': 14},
      {'from': 8, 'to': 15},
      {'from': 8, 'to': 16},
      {'from': 8, 'to': 17},
      {'from': 11, 'to': 18},
      {'from': 11, 'to': 19},
      {'from': 11, 'to': 20},
      {'from': 12, 'to': 21},
      {'from': 12, 'to': 22},
      {'from': 12, 'to': 23},
      {'from': 13, 'to': 24},
      {'from': 13, 'to': 25},
      {'from': 13, 'to': 26},
      {'from': 14, 'to': 27},
      {'from': 14, 'to': 28},
      {'from': 27, 'to': 29},
      {'from': 27, 'to': 30},
      {'from': 28, 'to': 31},
      {'from': 18, 'to': 32},
      {'from': 18, 'to': 33},
      {'from': 19, 'to': 34},
      {'from': 19, 'to': 35},
      {'from': 19, 'to': 36},
      {'from': 21, 'to': 37},
      {'from': 21, 'to': 38},
      {'from': 22, 'to': 39},
      {'from': 23, 'to': 40},
      {'from': 23, 'to': 41},
      {'from': 24, 'to': 42},
      {'from': 24, 'to': 43},
      {'from': 25, 'to': 44},
      {'from': 9, 'to': 45},
      {'from': 9, 'to': 46},
      {'from': 9, 'to': 47},
      {'from': 10, 'to': 48},
      {'from': 10, 'to': 49},
      {'from': 15, 'to': 50},
      {'from': 15, 'to': 51},
      {'from': 15, 'to': 52},
      {'from': 16, 'to': 53},
      {'from': 16, 'to': 54},
      {'from': 16, 'to': 55},
      {'from': 17, 'to': 56},
      {'from': 17, 'to': 57},
      {'from': 17, 'to': 58},
      {'from': 45, 'to': 59},
      {'from': 45, 'to': 60},
      {'from': 45, 'to': 61},
      {'from': 46, 'to': 62},
      {'from': 46, 'to': 63},
      {'from': 46, 'to': 64},
      {'from': 47, 'to': 65},
      {'from': 48, 'to': 66},
      {'from': 48, 'to': 67},
      {'from': 49, 'to': 68},
      {'from': 49, 'to': 69},
      {'from': 50, 'to': 70},
      {'from': 50, 'to': 71},
      {'from': 50, 'to': 72},
      {'from': 51, 'to': 73},
      {'from': 51, 'to': 74},
      {'from': 52, 'to': 75},
      {'from': 53, 'to': 76},
      {'from': 53, 'to': 77},
      {'from': 56, 'to': 78},
      {'from': 56, 'to': 79},
      {'from': 4, 'to': 80},
      {'from': 80, 'to': 81},
      {'from': 80, 'to': 82},
      {'from': 80, 'to': 83},
      {'from': 81, 'to': 84},
      {'from': 81, 'to': 85},
      {'from': 82, 'to': 86},
      {'from': 82, 'to': 87},
      {'from': 83, 'to': 88},
      {'from': 83, 'to': 89},
      {'from': 84, 'to': 90},
      {'from': 84, 'to': 91},
      {'from': 85, 'to': 92},
      {'from': 86, 'to': 93},
      {'from': 87, 'to': 94},
      {'from': 88, 'to': 95},
      {'from': 89, 'to': 96},

      // {'from': 8, 'to': 9},
      // {'from': 9, 'to': 10},
      // {'from': 10, 'to': 21},
      // {'from': 10, 'to': 11},
      // {'from': 10, 'to': 22},
      // {'from': 11, 'to': 19},
      // {'from': 11, 'to': 20},
      // {'from': 11, 'to': 13},
      // {'from': 13, 'to': 14},
      // {'from': 13, 'to': 15},
      // {'from': 13, 'to': 16},
      // {'from': 13, 'to': 17},
      // {'from': 15, 'to': 12},
      // {'from': 14, 'to': 18},
      // {'from': 20, 'to': 23},
      // {'from': 20, 'to': 24},
      // {'from': 23, 'to': 25},
      // {'from': 23, 'to': 26},
      // {'from': 24, 'to': 27},
      // {'from': 24, 'to': 28},
      // {'from': 19, 'to': 29},
      // {'from': 19, 'to': 30},
      // {'from': 19, 'to': 31},
    ]
  };
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Vanshavli')),
        body: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.01,
                  maxScale: 5.6,
                  child: GraphView(
                    graph: graph,
                    algorithm: BuchheimWalkerAlgorithm(
                        builder, TreeEdgeRenderer(builder)),
                    paint: Paint()
                      ..color = Colors.green
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      // I can decide what widget should be shown here based on the id
                      var a = node.key!.value as int?;
                      var nodes = FamilyTreePage.json['nodes']!;
                      var nodeValue =
                          nodes.firstWhere((element) => element['id'] == a);
                      return rectangleWidget(nodeValue['label'] as String?);
                    },
                  )),
            ),
          ],
        ));
  }

  Widget rectangleWidget(String? a) {
    return InkWell(
      onTap: () {
        debugPrint('Node clicked');
      },
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
            ],
          ),
          child: Text('$a')),
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();
    var edges = FamilyTreePage.json['edges']!;
    for (var element in edges) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    }

    builder
      ..siblingSeparation = (10)
      ..levelSeparation = (15)
      ..subtreeSeparation = (15)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}
