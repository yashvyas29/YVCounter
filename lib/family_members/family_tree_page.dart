import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:yv_counter/common/image_file_handler.dart';
import 'package:yv_counter/common/json_file_handler.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';
import 'package:yv_counter/family_members/family_member_page.dart';
import 'package:yv_counter/l10n/app_localizations.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class FamilyTreePage extends StatefulWidget {
  final String title;

  final _jsonFileHandler = const JsonFileHandler();

  const FamilyTreePage({super.key, required this.title});
  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();

  String getFileName() {
    return _jsonFileHandler.getFamilyFileName(title);
  }

  Future<Map<String, dynamic>> readJsonData() async {
    final fileName = getFileName();
    final data = await _jsonFileHandler.readJson(fileName);
    if (data.isEmpty) {
      return await _jsonFileHandler.readJsonFromBundle(fileName);
    } else {
      return data;
    }
  }

  Future<void> writeJsonData(Map<String, dynamic> map) async {
    await _jsonFileHandler.writeJsonData(getFileName(), map);
  }
}

class _CallbackBuchheimWalkerAlgorithm extends BuchheimWalkerAlgorithm {
  bool _wasCalculated = false;
  void Function() onFirstCalculated;

  _CallbackBuchheimWalkerAlgorithm(
    super.configuration,
    super.renderer, {
    required this.onFirstCalculated,
  });

  @override
  Size run(Graph? graph, double shiftX, double shiftY) {
    final size = super.run(graph, shiftX, shiftY);
    if (!_wasCalculated) {
      onFirstCalculated();
      _wasCalculated = true;
    }
    return size;
  }
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  static const spacing = 30.0;
  static const boxSide = 320.0;
  static const boxCornerRadius = 4.0;

  static const borderWidth = 2.0;
  static const imageSide = 100.0;
  Map<String, dynamic> _data = {};
  final Map<int, dynamic> _images = {};
  late ImageFileHandler imageFileHandler;

  final _graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration();
  late final _CallbackBuchheimWalkerAlgorithm _algorithm;
  // late final Algorithm _algorithm = BuchheimWalkerAlgorithm(_builder, null);
  // final GraphViewController _controller = GraphViewController();
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _viewerKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Jump to root node pressed.");
              _jumpToRootNode();
            },
            icon: const Icon(Icons.restore),
          ),
          /*
          IconButton(
            onPressed: () {
              debugPrint("Reset to family pressed.");
              _reset();
            },
            icon: const Icon(Icons.restore),
          ),
          */
        ],
      ),
      body: _futureBuilder(),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    debugPrint("initState");
    super.initState();

    imageFileHandler = ImageFileHandler(prefix: widget.getFileName());

    _builder
      ..siblingSeparation = (spacing.toInt())
      ..levelSeparation = (spacing.toInt())
      ..subtreeSeparation = (spacing.toInt())
      ..useCurvedConnections = false;

    _algorithm = _CallbackBuchheimWalkerAlgorithm(
      _builder,
      TreeEdgeRenderer(_builder),
      onFirstCalculated: () => _jumpToRootNode(),
    );
  }

  Widget _borderedWidget(Widget widget, double radius) {
    final theme = Theme.of(context);
    final borderColor = theme.textTheme.bodyLarge?.color ?? theme.primaryColor;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: widget,
    );
  }

  Widget _clipRectWidget(Widget widget, double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: widget,
    );
  }

  Widget _futureBuilder() {
    return _data.isEmpty
        ? FutureBuilder(
            future: widget.readJsonData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              debugPrint(snapshot.connectionState.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final data = snapshot.data!;
                if (data.isEmpty) {
                  _data = {FamilyJsonKey.nodes: [], FamilyJsonKey.edges: []};
                } else {
                  _data = data;
                }
                return _interactiveViewer();
              } else {
                return Center(
                  child: Text(AppLocalizations.of(context).commonError),
                );
              }
            },
          )
        : _interactiveViewer();
  }

  int _getNewNodeId() {
    return _data[FamilyJsonKey.nodes].fold(0, (previousValue, element) {
          final currentValue = element[FamilyJsonKey.id] ?? 0;
          return previousValue > currentValue ? previousValue : currentValue;
        }) +
        1;
  }

  Map<String, dynamic> _getNewNodeMap(int id, {bool isRoot = false}) {
    final newNodeValue = {"id": id, "label": ""};
    newNodeValue[FamilyJsonKey.readOnly] = false;
    if (isRoot) {
      newNodeValue['isRoot'] = isRoot;
    }
    // debugPrint(newNodeValue.toString());
    return newNodeValue;
  }

  Widget _graphView() {
    final edges = _data[FamilyJsonKey.edges];
    _updateNode(edges);

    /*
    return GraphView.builder(
      graph: _graph,
      algorithm: _algorithm,
      paint: Paint()
        ..color = Colors.green
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
      builder: (Node node) {
        return _rectangleWidget(node);
      },
      controller: _controller,
      // animated: true,
      initialNode: ValueKey(_rootNodeId()),
      // autoZoomToFit: true,
      // centerGraph: true,
    );
    */

    return GraphView(
      key: _contentKey,
      graph: _graph,
      algorithm: _algorithm,
      paint: Paint()
        ..color = Colors.green
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
      builder: (Node node) {
        return _rectangleWidget(node);
      },
      // animated: true,
      centerGraph: true,
    );
  }

  Widget _imageWidget(File image) {
    return _borderedWidget(
      _clipRectWidget(
        ZoomOverlay(
          child: Image.file(
            image,
            width: imageSide,
            height: imageSide,
            fit: BoxFit.contain,
          ),
        ),
        boxCornerRadius,
      ),
      boxCornerRadius,
    );
  }

  Widget _interactiveViewer() {
    final contextSize = MediaQuery.sizeOf(context);
    final horizontalInsets = contextSize.width - boxSide - spacing;
    final topToExclude = !kIsWeb && Platform.isAndroid
        ? MediaQuery.viewPaddingOf(context).top + kToolbarHeight
        : 0;
    final verticalInsets =
        contextSize.height - boxSide + 2 * spacing + topToExclude;

    return InteractiveViewer(
      key: _viewerKey,
      constrained: false,
      boundaryMargin: EdgeInsets.symmetric(
        horizontal: horizontalInsets,
        vertical: verticalInsets,
      ),
      minScale: 0.05,
      maxScale: 1,
      transformationController: _transformationController,
      child: _graphView(),
    );
  }

  void _jumpToNode(ValueKey nodeKey) {
    debugPrint("Jump to node id: ${nodeKey.value}.");
    // _controller.animateToNode(nodeKey);
    try {
      final startNode = _graph.nodes.firstWhere(
        (node) => node.key!.value == nodeKey.value,
      );
      final position = Offset(
        -(startNode.x -
            MediaQuery.sizeOf(context).width / 2 +
            startNode.width / 2),
        -(startNode.y - spacing),
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _transformationController.value = Matrix4.identity()
          ..translateByVector3(Vector3(position.dx, position.dy, 0));
      });
    } catch (error) {
      debugPrint("Node not found.\n$error");
      // zoomToFit();
    }
  }

  void _jumpToRootNode() {
    final rootKey = ValueKey(_rootNodeId());
    // _controller.animateToNode(rootKey);
    _jumpToNode(rootKey);
  }

  Widget _rectangleWidget(Node node) {
    // debugPrint("rectangleWidget: ${node.toString()}");
    final nodes = _data[FamilyJsonKey.nodes];
    final id = node.key!.value;
    final nodeIndex = nodes.indexWhere((node) => node[FamilyJsonKey.id] == id);
    // debugPrint("id: $id, nodeIndex: $nodeIndex");
    final nodeValue = nodes[nodeIndex];
    // debugPrint(nodeValue.toString());
    final value = nodeValue[FamilyJsonKey.label].toString();
    final readOnly = nodeValue[FamilyJsonKey.readOnly] ?? true;
    final isValueEmptyOrBig =
        value.isEmpty ||
        !readOnly ||
        value.length > 100 ||
        value.split('\n').length > 4;
    final isRoot = nodeValue[FamilyJsonKey.isRoot] ?? false;
    final isRootChild = nodeValue[FamilyJsonKey.isRootChild] ?? false;
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge;
    final hintText = isRoot
        ? localizations.enterParentsName
        : localizations.enterChildAndSpouseName;
    final borderColor = textStyle?.color ?? theme.primaryColor;
    final inputBorder = readOnly
        ? InputBorder.none
        : OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          );
    InputDecoration inputDecoration = InputDecoration(
      enabledBorder: inputBorder,
      border: inputBorder,
      hintText: hintText,
    );
    TextEditingController textController = TextEditingController();
    textController.text = value;
    final image = _images[id];

    final predecessors = _graph.predecessorsOf(node);
    final List<Node> parentSuccessors;
    final successors = _graph.successorsOf(node);

    final Node? parentNode;
    final Node? firstChildNode;
    final ValueKey? prevNodeKey;
    final ValueKey? nextNodeKey;

    if (predecessors.isNotEmpty) {
      parentNode = predecessors.last;
    } else {
      parentNode = null;
    }

    if (successors.isNotEmpty) {
      firstChildNode = successors.first;
    } else {
      firstChildNode = null;
    }

    if (parentNode != null) {
      parentSuccessors = _graph.successorsOf(parentNode);
      if (parentSuccessors.length > 1) {
        // Multiple siblings
        final parentSuccessorIndex = parentSuccessors.indexOf(node);
        if (parentSuccessorIndex != -1 &&
            parentSuccessorIndex < parentSuccessors.length - 1) {
          // Next sibling
          nextNodeKey = parentSuccessors[parentSuccessorIndex + 1].key;
        } else if (successors.isNotEmpty) {
          // Removing next arrow when no next sibling, so first child down arrow can be shown
          nextNodeKey = null;
        } else {
          // No next sibling or child in case of multiple siblings
          nextNodeKey = null;
        }
        if (parentSuccessorIndex > 0) {
          // Previous sibling
          prevNodeKey = parentSuccessors[parentSuccessorIndex - 1].key;
        } else {
          // Removing previous arrow for first child from the multiple ones when parent exist
          prevNodeKey = null;
        }
      } else {
        // Rmoving previous and next arrow for siblings, alone child when parent exist
        prevNodeKey = null;
        nextNodeKey = null;
        /*
        if (parentSuccessors.length == 1 && successors.isNotEmpty) {
          // No siblings but have children
          // Showing down arrow in this case
          nextNodeKey = successors.first.key;
        } else {
          // Removing next arrow when there are no children or siblings when parent exist
          nextNodeKey = null;
        }
        */
      }
    } else {
      // No parent
      parentSuccessors = [];
      prevNodeKey = null;
      nextNodeKey = null;
      /*
      if (successors.isNotEmpty) {
        // No parent but have children
        // Showing down arrow in this case
        nextNodeKey = successors.first.key;
      } else {
        // No parent and children
        nextNodeKey = null;
      }
      */
    }

    return InkWell(
      onTap: () {
        // debugPrint('Node $value clicked at ${node.toString()}.');
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => FamilyMemberPage(
                  id: id,
                  name: value,
                  familyFileName: widget.getFileName(),
                ),
              ),
            )
            .then((val) {
              // debugPrint("Returned from FamilyMemberPage.\n$val");
              setState(() {
                // Update other data in future when user can edit it.
                _images.remove(id);
              });
            });
      },
      child: Container(
        width: boxSide,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(boxCornerRadius),
          boxShadow: [BoxShadow(color: Colors.red[300]!, spreadRadius: 1)],
        ),
        child: Row(
          crossAxisAlignment: isValueEmptyOrBig
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    image != null
                        ? _imageWidget(image)
                        : FutureBuilder(
                            future: imageFileHandler.loadThumbnail(id),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    final image = snapshot.data!;
                                    _images[id] = image;
                                    return _imageWidget(image);
                                  } else {
                                    return _borderedWidget(
                                      Icon(Icons.person, size: imageSide),
                                      boxCornerRadius,
                                    );
                                  }
                                },
                          ),
                    SizedBox(width: 8),
                    readOnly
                        ? SizedBox(
                            width: boxSide - imageSide - 88,
                            child: Text(value, style: textStyle),
                          )
                        : SizedBox(
                            width: boxSide - imageSide - 88,
                            height: imageSide + 4,
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: textController,
                              decoration: inputDecoration,
                              style: textStyle,
                              readOnly: readOnly,
                              autofocus: !readOnly,
                            ),
                          ),
                    SizedBox(width: 4),
                  ],
                ),
                Row(
                  children: [
                    if (prevNodeKey != null)
                      IconButton(
                        onPressed: () {
                          debugPrint(
                            "Previous node key $prevNodeKey for $value pressed.",
                          );
                          _jumpToNode(prevNodeKey!);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    if (parentNode != null)
                      IconButton(
                        onPressed: () {
                          debugPrint(
                            "Parent node key ${parentNode!.key} for $value pressed.",
                          );
                          _jumpToNode(parentNode.key!);
                        },
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    if (successors.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          debugPrint(
                            "Parent node key ${firstChildNode!.key} for $value pressed.",
                          );
                          _jumpToNode(firstChildNode.key!);
                        },
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    if (nextNodeKey != null)
                      IconButton(
                        onPressed: () {
                          debugPrint(
                            "Next node key $nextNodeKey for $value pressed.",
                          );
                          _jumpToNode(nextNodeKey!);
                        },
                        icon: const Icon(Icons.arrow_forward),
                      ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                if (!isRoot && ((!isRootChild && nodes.length > 2) || readOnly))
                  IconButton(
                    onPressed: () {
                      debugPrint("Delete for $value pressed.");
                      showDeleteConfirmationDialog(
                        context,
                        AppLocalizations.of(
                          context,
                        ).deleteConfirmation(name: value),
                        () async {
                          setState(() {
                            _removeNodeFromData(node);
                          });
                          await widget.writeJsonData(_data);
                          if (_data[FamilyJsonKey.edges].length <= 1) {
                            _reset();
                          }
                          if (!mounted) return;
                          Navigator.pop(context);
                          showSnackBar(
                            context,
                            "$value ${localizations.deleted}",
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete),
                  )
                else if (isRoot && readOnly)
                  IconButton(
                    onPressed: () async {
                      debugPrint("Add on top for $value pressed.");
                      final nodes = _data[FamilyJsonKey.nodes];
                      final newId = _getNewNodeId();
                      final currentRoot = nodes.firstWhere(
                        (node) => node[FamilyJsonKey.isRoot] == true,
                      );
                      currentRoot.remove(FamilyJsonKey.isRoot);
                      try {
                        final currentRootChild = nodes.firstWhere(
                          (node) => node[FamilyJsonKey.isRootChild] == true,
                        );
                        currentRootChild.remove(FamilyJsonKey.isRootChild);
                      } catch (error) {
                        debugPrint("No root child found.\n$error");
                      }
                      currentRoot[FamilyJsonKey.isRootChild] = true;
                      final newNode = _getNewNodeMap(newId, isRoot: true);
                      final newEdge = {
                        FamilyJsonKey.from: newId,
                        FamilyJsonKey.to: id,
                      };
                      setState(() {
                        _data[FamilyJsonKey.nodes].add(newNode);
                        _data[FamilyJsonKey.edges].add(newEdge);
                      });
                      await widget.writeJsonData(_data);
                    },
                    icon: const Icon(Icons.add_box),
                  ),
                readOnly
                    ? IconButton(
                        onPressed: () {
                          debugPrint("Edit for $value pressed.");
                          try {
                            final currentEditableNode = nodes.firstWhere(
                              (node) =>
                                  node[FamilyJsonKey.readOnly] == false &&
                                  !node[FamilyJsonKey.label].isEmpty,
                            );
                            currentEditableNode[FamilyJsonKey.readOnly] = true;
                          } catch (error) {
                            debugPrint("No editable node found.\n$error");
                          }
                          setState(() {
                            nodeValue[FamilyJsonKey.readOnly] = false;
                          });
                          // await widget.writeJsonData(_data);
                        },
                        icon: const Icon(Icons.edit),
                      )
                    : IconButton(
                        onPressed: () async {
                          debugPrint("Done for $value pressed.");
                          final text = textController.text;
                          if (text.isNotEmpty) {
                            setState(() {
                              nodeValue[FamilyJsonKey.label] =
                                  textController.text;
                              nodeValue[FamilyJsonKey.readOnly] = true;
                            });
                            await widget.writeJsonData(_data);
                            if (!mounted) return;
                            final message = value.isEmpty
                                ? "$text ${localizations.added}"
                                : "$value ${localizations.updated}";
                            showSnackBar(context, message);
                          } else {
                            debugPrint(hintText);
                          }
                        },
                        icon: const Icon(Icons.done_outline),
                      ),
                if (readOnly)
                  IconButton(
                    onPressed: () async {
                      debugPrint("Add for $value pressed.");
                      final newId = _getNewNodeId();
                      final newNode = _getNewNodeMap(newId);
                      final newEdge = {
                        FamilyJsonKey.from: id,
                        FamilyJsonKey.to: newId,
                      };
                      setState(() {
                        _data[FamilyJsonKey.nodes].add(newNode);
                        _data[FamilyJsonKey.edges].add(newEdge);
                      });
                      await widget.writeJsonData(_data);
                    },
                    icon: const Icon(Icons.add_circle),
                  )
                else if (value.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      debugPrint("Cancel for $value pressed.");
                      setState(() {
                        nodeValue[FamilyJsonKey.readOnly] = true;
                      });
                      // await widget.writeJsonData(_data);
                    },
                    icon: const Icon(Icons.cancel),
                  ),
                /*
                  if (successors.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      debugPrint("Expand Collapse for $value pressed.");
                      _controller.toggleNodeExpanded(_graph, node, animate: true);
                    },
                    icon: Icon(_controller.isNodeCollapsed(node) ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                  ),
                  */
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _removeNodeFromData(Node node) {
    final id = node.key?.value;
    _data[FamilyJsonKey.nodes].removeWhere(
      (element) => element[FamilyJsonKey.id] == id,
    );
    _data[FamilyJsonKey.edges].removeWhere(
      (edge) => edge[FamilyJsonKey.from] == id || edge[FamilyJsonKey.to] == id,
    );
    if (_graph.isTree) {
      _graph
          .successorsOf(node)
          .forEach((nodeElement) => _removeNodeFromData(nodeElement));
    }
    _graph.removeNode(node);
  }

  void _reset() {
    // _controller.zoomToFit();
    _zoomToFit();
    /*
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    }
    */
    /*
    widget._jsonFileHandler.deleteLocalFile(widget.getFileName());
    _graph = Graph()..isTree = true;
    setState(() {
      _data.clear();
    });
    */
  }

  int _rootNodeId() {
    try {
      final rootNode = _data[FamilyJsonKey.nodes].firstWhere(
        (node) => node['isRoot'] == true,
      );
      return rootNode[FamilyJsonKey.id];
    } catch (error) {
      debugPrint('No manual root found.\n$error');
      return 1;
    }
  }

  void _updateNode(List edges) {
    debugPrint("updateNode");
    debugPrint("Edges count: ${edges.length.toString()}");
    // debugPrint("Edges value: ${edges.toString()}");

    if (edges.isEmpty) {
      final nodes = _data[FamilyJsonKey.nodes];
      /*
      debugPrint("Nodes count: ${nodes.length.toString()}");
      debugPrint("Nodes value: ${nodes.toString()}");
      */
      final int firstId;
      final int secondId;
      final bool firstReadOnly;
      final bool secondReadOnly;
      if (nodes.length >= 2) {
        firstId = nodes.first[FamilyJsonKey.id];
        secondId = nodes.last[FamilyJsonKey.id];
        firstReadOnly = true;
        secondReadOnly = true;
      } else if (nodes.length == 1) {
        firstId = nodes.first[FamilyJsonKey.id];
        secondId = firstId + 1;
        firstReadOnly = true;
        secondReadOnly = false;
      } else {
        firstId = 1;
        secondId = 2;
        firstReadOnly = false;
        secondReadOnly = false;
      }
      final fromNode = Node.Id(firstId);
      final toNode = Node.Id(secondId);
      if (!firstReadOnly) {
        _data[FamilyJsonKey.nodes].add({
          "id": firstId,
          "label": "",
          "readOnly": firstReadOnly,
          "isRoot": true,
        });
      }
      if (!secondReadOnly) {
        _data[FamilyJsonKey.nodes].add({
          "id": secondId,
          "label": "",
          "readOnly": secondReadOnly,
          "isRootChild": true,
        });
      }
      _data[FamilyJsonKey.edges].add({"from": firstId, "to": secondId});
      _graph.addEdge(fromNode, toNode);
    } else {
      for (final element in edges) {
        var fromNodeId = element[FamilyJsonKey.from];
        var toNodeId = element[FamilyJsonKey.to];
        _graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
      }

      /*
      var rowCount = await DBProvider.db.getRowCount(widget.title);
      // debugPrint(rowCount.toString());
      if (rowCount > 1) {
        await DBProvider.db.cleanTable(widget.title);
        // debugPrint("Cleaned ${widget.title} Table");
        final nodes = _data[FamilyJsonKey.nodes];

        for (final element in edges) {
          var fromNodeId = element[FamilyJsonKey.from];
          var toNodeId = element[FamilyJsonKey.to];

          final nodeIndex =
              nodes.indexWhere((node) => node[FamilyJsonKey.id] == fromNodeId);
          final nodeValue = nodes[nodeIndex];
          final value = nodeValue[FamilyJsonKey.label].toString();
          if (!await DBProvider.db
              .checkIfValueExists(widget.title, 'name', value)) {
            await DBProvider.db
                .insertMember(TreeMember(value, fromNodeId), widget.title);
            // debugPrint("From Inserted $value:$fromNodeId");
          }

          final nodeIndex1 = nodes.indexWhere((node) => node[FamilyJsonKey.id] == toNodeId);
          final nodeValue1 = nodes[nodeIndex1];
          final value1 = nodeValue1[FamilyJsonKey.label].toString();
          if (!await DBProvider.db
              .checkIfValueExists(widget.title, 'name', value1)) {
            await DBProvider.db.insertMember(
                TreeMember(value1, fromNodeId, toNodeId), widget.title);
            // debugPrint("To Inserted $value:$fromNodeId");
          } else {
            await DBProvider.db.updateMember(
                widget.title, TreeMember(value1, fromNodeId, toNodeId));
            // debugPrint("To Updated $value1:$fromNodeId");
          }
        }
      }
      */
    }
  }

  void _zoomToFit() {
    /*
    // Ensure the widgets are rendered and their render objects are accessible
    final RenderBox? viewerBox =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? contentBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;

    if (viewerBox == null || contentBox == null) {
      debugPrint("Render box not found.");
      return;
    }

    final Size viewerSize = viewerBox.size;
    final Size contentSize = contentBox.size;

    if (viewerSize.isEmpty || contentSize.isEmpty) {
      debugPrint("Render box size not found.");
      return;
    }

    // 1. Calculate the scale factor to fit the content within the viewer bounds
    // We calculate scale based on both width and height and take the minimum
    // to ensure the entire content is visible without cropping.
    final double scaleX = viewerSize.width / contentSize.width;
    final double scaleY = viewerSize.height / contentSize.height;
    final double fitScale = math.min(scaleX, scaleY);

    // Optional: Add a small padding or maximum scale constraint if desired
    // final double finalScale = math.min(fitScale * 0.95, 2.0);
    final double finalScale = fitScale * 0.95; // 5% padding around the edges

    // 2. Calculate the translation needed to center the content
    final double translateX =
        (viewerSize.width - contentSize.width * finalScale) / 2;
    final double translateY =
        (viewerSize.height - contentSize.height * finalScale) / 2;

    // 3. Construct the final transformation matrix
    final Matrix4 matrix = Matrix4.identity();
    // Apply scale (S) and then translation (T)
    matrix.setEntry(0, 0, finalScale); // Scale X
    matrix.setEntry(1, 1, finalScale); // Scale Y
    matrix.setEntry(0, 3, translateX); // Translate X
    matrix.setEntry(1, 3, translateY); // Translate Y

    // Apply the new matrix to the controller
    _transformationController.value = matrix;
    */
  }
}
