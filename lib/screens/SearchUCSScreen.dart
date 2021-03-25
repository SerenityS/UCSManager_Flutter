import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:requests/requests.dart';

import 'package:ucs_manager/utilties/PIUApi.dart';

class SearchUCSScreen extends StatefulWidget {
  @override
  _SearchUCSScreen createState() => _SearchUCSScreen();
}

class _SearchUCSScreen extends State<SearchUCSScreen> {
  TextEditingController _songTitleController = new TextEditingController();
  TextEditingController _stepArtistController = new TextEditingController();
  TextEditingController _stepLvController = new TextEditingController();

  @override
  void dispose() {
    _songTitleController.dispose();
    _stepArtistController.dispose();
    _stepLvController.dispose();
    super.dispose();
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
                var result = await PIUApi().addUCS(ucsNoList[index]);
                Get.back();
                if (result.contains('Registration is complete.')) {
                  Get.snackbar('UCS Manager',
                      'Successfully Add UCS! / UCS No : ${ucsNoList[index]}.');
                } else {
                  Get.snackbar('UCS Manager',
                      'Add UCS Failed! / UCS No : ${ucsNoList[index]}.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  var songTitleList = [];
  var stepArtistList = [];
  var stepLvList = [];
  var ucsNoList = [];
  searchUCS(songTitle, stepArtist, stepLv) async {
    songTitleList.clear();
    stepArtistList.clear();
    stepLvList.clear();
    ucsNoList.clear();
    var ucs = await Requests.get(
      'http://13.209.41.47:5000/getucs',
      queryParameters: {
        'songTitle': songTitle,
        'stepMaker': stepArtist,
        'songLv': stepLv
      },
    );
    var ucsList = ucs.json();
    for (var ucsData in ucsList) {
      songTitleList.insert(0, ucsData[1]);
      stepArtistList.insert(0, ucsData[4]);
      stepLvList.insert(0, ucsData[3]);
      ucsNoList.insert(0, ucsData[0].toString());
    }

    setState(
      () {
        searchButtonText = "Search";
        searchButtonEnabled = true;
      },
    );
  }

  var searchButtonText = "Search";
  bool searchButtonEnabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search UCS'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 5.0),
                Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _songTitleController,
                      decoration: InputDecoration(
                        hintText: "Song Title",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14.0),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _stepArtistController,
                      decoration: InputDecoration(
                        hintText: "Step Artist",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14.0),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _stepLvController,
                      decoration: InputDecoration(
                        hintText: "Step Level",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14.0),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Text(searchButtonText),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (_songTitleController.text != '' ||
                        _stepArtistController.text != '') {
                      if (searchButtonEnabled) {
                        setState(
                          () {
                            searchButtonEnabled = false;
                            searchButtonText = 'Searching...';
                          },
                        );
                        await searchUCS(_songTitleController.text,
                            _stepArtistController.text, _stepLvController.text);
                      } else {
                        if (!Get.isSnackbarOpen) {
                          Get.snackbar('Warning!',
                              'Your Searching Process is Already in Progress.\nPlease Wait.');
                        }
                      }
                    } else {
                      if (!Get.isSnackbarOpen) {
                        Get.snackbar('Warning!',
                            'You Must Enter Song Title Or Step Artist Name.');
                      }
                    }
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: songTitleList.length,
                    itemBuilder: (context, index) {
                      return Card(
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
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 5.0),
                              Text(
                                ucsNoList[index],
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '${songTitleList[index]} ${stepLvList[index]}',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '${stepArtistList[index]}',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(height: 5.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
