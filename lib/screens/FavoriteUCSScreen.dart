import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ucs_manager/utilties/PIUApi.dart';

class FavoriteUCSScreen extends StatefulWidget {
  const FavoriteUCSScreen({Key key}) : super(key: key);

  @override
  _FavoriteUCSScreenState createState() => _FavoriteUCSScreenState();
}

class _FavoriteUCSScreenState extends State<FavoriteUCSScreen> {
  final _pref = GetStorage();

  List favoriteUcsList;

  TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future _getFavoriteData() async {
    favoriteUcsList = await _pref.read('favoriteUcsList');
    return favoriteUcsList;
  }

  Future favoriteMenuDialog(context, index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Favorite UCS Menu"),
          children: [
            SimpleDialogOption(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Text("ADD UCS to UCS Slot"),
              ),
              onPressed: () async {
                var result = await PIUApi().addUCS(favoriteUcsList[index][0]);
                Get.back();
                if (result.contains('Registration is complete.')) {
                  Get.snackbar('UCS Manager',
                      'Successfully Add UCS! / UCS No : ${favoriteUcsList[index][0]}.');
                } else {
                  Get.snackbar('UCS Manager',
                      'Add UCS Failed! / UCS No : ${favoriteUcsList[index][0]}.');
                }
              },
            ),
            SimpleDialogOption(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Text("Modify Memo"),
              ),
              onPressed: () async {
                addUCSAlert(context, index);
              },
            ),
            SimpleDialogOption(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Text("Remove UCS from Favorite"),
              ),
              onPressed: () {
                removeFavoriteAlert(context, index);
              },
            )
          ],
        );
      },
    );
  }

  Future addUCSAlert(context, index) async {
    _textFieldController.clear();
    _textFieldController.text = favoriteUcsList[index][4];
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify Memo'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Memo"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                await PIUApi()
                    .modifyFavoriteMemo(index, _textFieldController.text);
                setState(() {});
                Get.back();
                Get.back();
                Get.snackbar('UCS Manager', 'Successfully Modify Memo.');
              },
            ),
          ],
        );
      },
    );
  }

  Future removeFavoriteAlert(context, index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Favorite UCS'),
          content: Text("Are You Sure Want To Remove Favorite?"),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                await PIUApi().removeFavoriteUCS(index);
                setState(() {});
                Get.back();
                Get.back();
                Get.snackbar('UCS Manager', 'Successfully Remove Favorite.');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite UCS'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Center(
          child: FutureBuilder(
            future: _getFavoriteData(),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return Column(children: [
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.center,
                      child: Text(
                        "No Favorite UCS.",
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Column(
                        children: [
                          Text(
                            "Made by qwertycvb with Pump It Up Gallery.",
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                ]);
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            favoriteMenuDialog(context, index);
                          },
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 8.0),
                              Text(
                                favoriteUcsList[index][0],
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "${favoriteUcsList[index][1]} ${favoriteUcsList[index][3]}",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                favoriteUcsList[index][2],
                                style: TextStyle(fontSize: 20),
                              ),
                              if (favoriteUcsList[index][4] != '')
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                  child: Text(
                                    favoriteUcsList[index][4],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              SizedBox(height: 8.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
