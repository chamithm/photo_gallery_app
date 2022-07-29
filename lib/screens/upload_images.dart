import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../controllers/app_controller.dart';

class OpenImages extends StatelessWidget {
  List<XFile> imagesFileList = [];
  OpenImages(this.imagesFileList);
  final appController = Get.put(AppController());


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Selected Images"),
          backgroundColor: Colors.blue[600],
        ),
        body: Container(
          color: Colors.white,
          child: GridView.builder(
            itemCount: imagesFileList.length,
            padding: EdgeInsets.only(left: 24.0,right: 24.0,top: 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (BuildContext context,int index){
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  child: Image.file(File(imagesFileList[index].path),fit: BoxFit.cover,)
                ),
              );
            }
          ),
        ),
        floatingActionButton: Container(
          width: 120.0,
          height: 40.0,
          child: Material(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.blue[600],
            child: MaterialButton(
              onPressed: (){
                AppController.uploadImagesToFirestore(imagesFileList);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12.0,),
                  Text(
                    "Upload",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}