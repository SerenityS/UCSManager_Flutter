import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:requests/requests.dart';

import 'package:ucs_manager/utilities/PIUApi.dart';

class SearchUCSScreen extends StatefulWidget {
  @override
  _SearchUCSScreen createState() => _SearchUCSScreen();
}

class _SearchUCSScreen extends State<SearchUCSScreen> {
  final TextEditingController _songTitleController = TextEditingController();
  final TextEditingController _stepArtistController = TextEditingController();
  final TextEditingController _stepLvController = TextEditingController();

  @override
  void dispose() {
    _songTitleController.dispose();
    _stepArtistController.dispose();
    _stepLvController.dispose();
    super.dispose();
  }

  void addFavoriteAlert(context, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADD Favorite'),
          content: Text('Are You Sure Want To ADD Favorite?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                bool result = await PIUApi().addFavoriteUCS([
                  ucsNoList[index],
                  songTitleList[index],
                  stepArtistList[index],
                  stepLvList[index],
                  '',
                ]);
                Get.back();
                if (result == true) {
                  Get.snackbar('UCS Manager',
                      'Successfully Add Favorite! / UCS No : ${ucsNoList[index]}.');
                } else {
                  Get.snackbar('UCS Manager',
                      'Already in Favorite! / UCS No : ${ucsNoList[index]}.');
                }
              },
              child: Text('YES'),
            ),
          ],
        );
      },
    );
  }

  void addUCSAlert(context, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ADD UCS'),
          content: Text('Are You Sure Want To ADD UCS?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('NO'),
            ),
            TextButton(
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
              child: Text('YES'),
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
  void searchUCS(songTitle, stepArtist, stepLv) async {
    songTitleList.clear();
    stepArtistList.clear();
    stepLvList.clear();
    ucsNoList.clear();

    var ucs;
    if (songTitle.contains('UCS') || songTitle.contains('ucs')) {
      ucs = await Requests.get(
        'http://ucs.qwertycvb.site:5000/getpack',
        queryParameters: {
          'pack': songTitle,
        },
      );
    } else {
      ucs = await Requests.get(
        'http://ucs.qwertycvb.site:5000/getucs',
        queryParameters: {
          'songTitle': songTitle,
          'stepMaker': stepArtist,
          'songLv': stepLv
        },
      );
    }

    var ucsList = ucs.json();
    for (var ucsData in ucsList) {
      songTitleList.insert(0, ucsData[1]);
      stepArtistList.insert(0, ucsData[4]);
      stepLvList.insert(0, ucsData[3]);
      ucsNoList.insert(0, ucsData[0].toString());
    }

    setState(
      () {
        searchButtonText = 'Search';
        searchButtonEnabled = true;
      },
    );
  }

  var searchButtonText = 'Search';
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
                        hintText: 'Song Title',
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
                        hintText: 'Step Artist',
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
                        hintText: 'Step Level',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14.0),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
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
                        searchUCS(_songTitleController.text,
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
                  child: Text(searchButtonText),
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
                          onLongPress: () {
                            addFavoriteAlert(context, index);
                          },
                          child: Column(
                            children: [
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
