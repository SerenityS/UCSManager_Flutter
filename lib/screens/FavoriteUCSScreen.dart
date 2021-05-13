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

  Future _getFavoriteData() async {
    favoriteUcsList = await _pref.read('favoriteUcsList');
    return favoriteUcsList;
  }

  addUCSAlert(context, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADD UCS'),
          content: Text('Are You Sure Want To ADD UCS?'),
          actions: <Widget>[
            TextButton(
              child: Text("NO"),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text("YES"),
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
          ],
        );
      },
    );
  }

  removeFavoriteAlert(context, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Favorite'),
          content: Text("Are You Sure Want To Remove this Favorite?"),
          actions: [
            TextButton(
              child: Text("NO"),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text("YES"),
              onPressed: () async {
                await PIUApi().removeFavoriteUCS(index);
                setState(() {
                  FavoriteUCSScreen();
                });
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
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              } else {
                if (snapshot.data == 0) {
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
                              addUCSAlert(context, index);
                            },
                            onLongPress: () {
                              removeFavoriteAlert(context, index);
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
                                SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
