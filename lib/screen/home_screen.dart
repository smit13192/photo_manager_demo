import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager_demo/service/media_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> files = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Home Screen'),
      ),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          final file = files[index];
          return GridTile(
            child: GestureDetector(
              onTap: () {},
              child: Image.file(
                file,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onGalleryButtonTap(context),
        child: const Icon(Icons.photo_library),
      ),
    );
  }

  void _onGalleryButtonTap(BuildContext context) async {
    final images = await MediaService.pickImage(context, 10);
    if (images == null) return;
    files.clear();
    setState(() {
      files.addAll(images);
    });
  }
}
