import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AppController extends GetxController{
  static RxList fetchImages = [].obs;
  static RxBool isDownloading = false.obs;
  @override
  void onInit() {
    getImagesFromFirestore();
    super.onInit();
  }
  
  static Future<void> uploadImagesToFirestore(List<XFile> images) async {
    for(XFile _image in images){
      Reference db = FirebaseStorage.instance.ref("photo_gallery/${getImageName(_image)}");
      try{
        await db.putFile(File(_image.path));
      }catch(e){
        print(e);
      }
    }
    fetchImages.clear();
    getImagesFromFirestore();
  }

  static String getImageName(XFile image){
    return image.path.split("/").last;
  }

  static Future<void> getImagesFromFirestore() async{
    Reference db = FirebaseStorage.instance.ref("photo_gallery/");
    try{
      isDownloading.value = true;
      final ListResult result = await db.listAll();
      final List<Reference> allImages = result.items;
      await Future.forEach(allImages, (Reference element) async {
        final String fileUrl = await (await element).getDownloadURL();
        fetchImages.add({
          "url":fileUrl,
          "path":element.fullPath
        });
      });
      isDownloading.value = false;
    }catch(e){
      print(e);
    }
  }

  static Future<void> deleteSelectedImages(List<int> list) async {
    list.sort((b, a) =>
      a.compareTo(b));
    list.forEach((element) {
      try{
        FirebaseStorage.instance.refFromURL(fetchImages[element]['url']).delete();
      }catch(e){
        print(e);
      }
    });
    fetchImages.clear();
    getImagesFromFirestore();
  }

}