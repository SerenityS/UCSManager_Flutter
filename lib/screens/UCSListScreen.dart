import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import 'package:ucs_manager/utilities/PIUApi.dart';

class UCSListScreen extends StatefulWidget {
  @override
  _UCSListScreen createState() => _UCSListScreen();
}

class _UCSListScreen extends State<UCSListScreen> {
  final _pref = GetStorage();

  List<String> songTitleList;
  List<String> stepArtistList;

  Future<int> _getUCSList() async {
    await PIUApi().getMyUCS();

    songTitleList = _pref.read('songTitleList');
    stepArtistList = _pref.read('stepArtistList');

    return songTitleList.length;
  }

  void removeUCSAlert(context, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove UCS'),
          content: Text('Are You Sure Want To Remove UCS?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                var result = await PIUApi().removeUCS(index);
                setState(
                  () {
                    _getUCSList();
                  },
                );
                Get.back();
                if (result.contains('The file was deleted.')) {
                  Get.snackbar('UCS Manager', 'Successfully Remove UCS.', colorText: Colors.white);
                } else {
                  Get.snackbar('UCS Manager', 'Can\'t Remove UCS.', colorText: Colors.white);
                }
              },
              child: Text('YES'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Center(
        child: FutureBuilder(
          future: _getUCSList(),
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
                        'No UCS.',
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
                            'Made by qwertycvb with Pump It Up Gallery.',
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
                  itemCount: snapshot.data,
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
                            removeUCSAlert(context, index);
                          },
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 8.0),
                              Text(
                                (index + 1).toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                songTitleList[index],
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                stepArtistList[index],
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
    );
  }
}
