import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  late String pathToImageFolder;
  List<File> imageFiles = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Downloader'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          imageFiles.isEmpty == true
              ? const Center(child: Text('No images found'))
              : Expanded(
                  child: ListView.builder(
                    itemCount: imageFiles.length,
                    itemBuilder: (context, index) {
                      final file = imageFiles.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.file(file, fit: BoxFit.fitWidth),
                      );
                    },
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(label: Text('Enter image link')),
                )),
                ElevatedButton(
                    onPressed: () async {
                      _saveImage(_controller.text);
                      _controller.clear();
                    },
                    child: const Text('Save'))
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    pathToImageFolder = p.join(appDocDir.path, "images");
    final imagesDir =
        await Directory(pathToImageFolder).create(recursive: true);
    imageFiles = await imagesDir
        .list()
        .where((event) =>
            event is File &&
            (event.path.endsWith(".jpg") || event.path.endsWith(".png")))
        .map((file) => File(file.path))
        .toList();
    setState(() {});
  }

  Future<void> _saveImage(String url) async {
    final imageName = url.substring(url.lastIndexOf("/") + 1);
    final response = await get(Uri.parse(url));
    final file = File(p.join(pathToImageFolder, imageName));
    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      imageFiles.add(file);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
