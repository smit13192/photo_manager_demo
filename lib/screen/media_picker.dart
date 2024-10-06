import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_demo/service/media_service.dart';
import 'package:photo_manager_demo/widget/button.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class MediaPicker extends StatefulWidget {
  final int maxCount;
  final RequestType requestType;
  const MediaPicker({
    super.key,
    required this.maxCount,
    required this.requestType,
  });

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    final albums = await MediaService.loadAlbums(widget.requestType);
    albumList = albums;
    selectedAlbum = albums[0];
    final images = await MediaService.loadAssets(selectedAlbum!);
    assetList = images;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Pick Image'),
      ),
      body: Column(
        children: [
          if (albumList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DropdownButton<AssetPathEntity>(
                isExpanded: true,
                dropdownColor: Colors.black,
                value: selectedAlbum,
                onChanged: (value) => _onDropDownChange(value),
                items: albumList.map<DropdownMenuItem<AssetPathEntity>>(
                    (AssetPathEntity album) {
                  return DropdownMenuItem<AssetPathEntity>(
                    value: album,
                    child: FutureBuilder<int>(
                      future: album.assetCountAsync,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else {
                          return Text(
                            '${album.name} (${snapshot.data})',
                            style: const TextStyle(color: Colors.white),
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 10),
          if (assetList.isNotEmpty)
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: assetList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  AssetEntity assetEntity = assetList[index];
                  return GridTile(
                    child: GestureDetector(
                      onTap: () {},
                      child: assetWidget(assetEntity),
                    ),
                  );
                },
              ),
            ),
          if (selectedAssetList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Button(
              text: 'DONE',
              onPressed: () => _onDoneTap(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget assetWidget(AssetEntity assetEntity) => GestureDetector(
        onTap: () => selectAsset(assetEntity: assetEntity, context: context),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(
                  selectedAssetList.contains(assetEntity) == true ? 15 : 0,
                ),
                child: Image(
                  fit: BoxFit.cover,
                  image: AssetEntityImageProvider(
                    assetEntity,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(250),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                alignment: Alignment.center,
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: selectedAssetList.contains(assetEntity) == true
                      ? Colors.blue
                      : Colors.black12,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${selectedAssetList.indexOf(assetEntity) + 1}',
                  style: TextStyle(
                    color: selectedAssetList.contains(assetEntity) == true
                        ? Colors.white
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  void _onDropDownChange(AssetPathEntity? value) async {
    selectedAlbum = value;
    assetList = await MediaService.loadAssets(selectedAlbum!);
    selectedAssetList.clear();
    setState(() {});
  }

  void selectAsset({
    required AssetEntity assetEntity,
    required BuildContext context,
  }) {
    if (selectedAssetList.contains(assetEntity)) {
      setState(() {
        selectedAssetList.remove(assetEntity);
      });
    } else if (selectedAssetList.length < widget.maxCount) {
      setState(() {
        selectedAssetList.add(assetEntity);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum number of selections reached'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onDoneTap(BuildContext context) async {
    List<File> selectedFiles = [];
    for (var element in selectedAssetList) {
      final file = await element.file;
      if (file != null) {
        selectedFiles.add(file);
      }
    }
    if (!context.mounted) return;
    Navigator.pop(context, selectedFiles);
  }
}
