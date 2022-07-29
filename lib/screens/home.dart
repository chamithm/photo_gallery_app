import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testing_app/controllers/app_controller.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:testing_app/screens/show_image.dart';

import 'upload_images.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();
  final appController = Get.put(AppController());
  MultiSelectController multiSelectController = new MultiSelectController();
  bool visibleDeleteButton = false;

  Future<void> imageSelect(BuildContext context) async {
    List<XFile> imagesFileList = [];
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if(selectedImages.isNotEmpty){
      imagesFileList.addAll(selectedImages);
      Navigator.push(context, MaterialPageRoute(builder: (context) => OpenImages(imagesFileList)));
    }
  }
  void delete(){
    var alert = AlertDialog(
      content: Container(
        height: 80.0,
        child: Column(
          children: [
            Container(
              height: 34,
              width: 300,
              color: Colors.blue[800],
              child: Center(
                child: Text("Delete",style: TextStyle(color: Colors.white,fontSize: 18),)
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Text("Are you sure want to Delete?",style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            var list = multiSelectController.selectedIndexes;
            AppController.deleteSelectedImages(list);
            multiSelectController.deselectAll();
            setState(() {
              visibleDeleteButton = false;
            });
            Navigator.pop(context);
            print(list);
          },
          child: Text("Delete",style: TextStyle(color: Colors.red,fontSize: 16),),
        ),
        FlatButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 16),),
        ),
      ],
    );
    showDialog(context: context,builder:(_) => alert);
  }

  Future<bool> _onBackPress(){
    bool isBack;
    if(multiSelectController.isSelecting){
      setState(() {
        multiSelectController.deselectAll();
        visibleDeleteButton = false;
        isBack = false;
      });
    }
    else{
      setState(() {
        isBack = true;        
      });
    }
    return Future<bool>.value(isBack);
  }

  @override
  void initState() {
    multiSelectController.disableEditingWhenNoneSelected = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPress,
        child: Scaffold(
          backgroundColor: Colors.blue[600],
          key: _scaffoldKey,
          drawer: Container(
            width: 200.0,
            color: Colors.red,
            child: Drawer(
              child: ListView(
                children: [
                  Container(
                    height: 100.0,
                    color: Colors.blue[50],
                    child: Center(
                      child: InkWell(
                        onTap: (){
                          print("something");
                        },
                        child: Text(
                          "Photo Gallery",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Theme",
                    ),
                    leading: Icon(Icons.brightness_4),
                  ),
                  ListTile(
                    title: Text('Exit'),
                    leading: Icon(Icons.transit_enterexit, color: Colors.blue,),
                    onTap: (){
                      SystemNavigator.pop();
                    },
                ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.zero,
                  child: Container(
                    height: 100.0,
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.menu),
                                onPressed: (){
                                  _scaffoldKey.currentState.openDrawer();
                                },
                              ),
                            ),
                            Container(
                              child: Text(
                                "Photo Gallery",
                                style: TextStyle(color: Colors.white,fontSize: 17.0,fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              child: IconButton(
                                icon: Icon(Icons.language),
                                color: Colors.white,
                                onPressed: (){
                                  print("something");
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(25.0),topLeft: Radius.circular(25.0),),
                    color: Colors.white
                  ),
                  child: GetX<AppController>(
                    builder: (controller) {
                      return AppController.fetchImages.isNotEmpty ? AppController.isDownloading.isFalse ? GridView.builder(
                        itemCount: AppController.fetchImages.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 24.0,right: 24.0,top: 16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                        ),
                        itemBuilder: (BuildContext context,int index){
                          Map image = AppController.fetchImages[index];
                          return MultiSelectItem(
                            isSelecting: multiSelectController.isSelecting,
                            onSelected: () {
                              setState(() {
                                multiSelectController.toggle(index);
                                visibleDeleteButton = true;
                              });
                            },
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage(image['url'])));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top:16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  child: Container(
                                    decoration: multiSelectController.isSelected(index) ? 
                                      new BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),border: Border.all(color: Colors.blueAccent,width: 4.0,)) :
                                      new BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Image.network(image['url'],fit: BoxFit.cover,),
                                  ),
                                ),
                              ),
                            )
                          );
                        }
                      ) : Center(child: CircularProgressIndicator()) : Center(child: Text("No Images",style: TextStyle(fontSize: 16.0),));
                    }
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            width: 40.0,
            height: 40.0,
            child: FloatingActionButton(
              backgroundColor: Colors.blue[600],
              onPressed: (){
                imageSelect(context);
              },
              tooltip: 'Increment',
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          bottomNavigationBar: Visibility(
            visible: multiSelectController.isSelecting,
            child: InkWell(
              onTap: (){
                delete();
              },
              child: Container(
                width: double.infinity,
                height: 50.0,
                color: Colors.blueGrey[600],
                child: Icon(
                  Icons.delete,
                  size: 30.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}