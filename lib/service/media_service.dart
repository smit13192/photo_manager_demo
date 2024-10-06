import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_demo/screen/media_picker.dart';
import 'package:photo_manager_demo/service/permission_service.dart';

class MediaService {
  static Future<List<File>?> pickImage(
    BuildContext context, [
    int maxCount = 1,
  ]) async {
    bool isGranted = await PermissionService.requestGalleryPermission(context);
    if (!isGranted) return null;
    if (!context.mounted) return null;
    List<File>? files = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MediaPicker(
            maxCount: maxCount,
            requestType: RequestType.image,
          );
        },
      ),
    );
    return files;
  }

  static Future<List<AssetPathEntity>> loadAlbums(
    RequestType requestType,
  ) async {
    List<AssetPathEntity> albumList = [];
    albumList = await PhotoManager.getAssetPathList(type: requestType);
    return albumList;
  }

  static Future<List<AssetEntity>> loadAssets(
    AssetPathEntity selectedAlbum,
  ) async {
    List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(
      start: 0,
      end: await selectedAlbum.assetCountAsync,
    );
    return assetList;
  }
}
