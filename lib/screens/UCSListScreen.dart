import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:ucs_manager/utilties/PIUApi.dart';

class UCSListScreen extends StatefulWidget {
  @override
  _UCSListScreen createState() => _UCSListScreen();
}

class _UCSListScreen extends State<UCSListScreen> {
  SharedPreferences _prefs;

  List<String> songTitleList;
  List<String> stepArtistList;

  @override
  void initState() {
    super.initState();
  }

  getUCSList() async {
    await PIUApi().getUCSData();

    _prefs = await SharedPreferences.getInstance();

    songTitleList = _prefs.getStringList('songTitleList');
    stepArtistList = _prefs.getStringList('stepArtistList');

    return songTitleList.length;
  }

  removeUCSAlert(context, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove UCS'),
          content: Text("Are You Sure Want To Remove UCS?"),
          actions: <Widget>[
            TextButton(
              child: Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("YES"),
              onPressed: () async {
                await PIUApi().removeUCS(index);
                setState(() {
                  getUCSList();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Center(
        child: FutureBuilder(
          future: getUCSList(),
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
                        "No UCS.",
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Text(
                        "Made by qwertycvb with Pump It Up Gallery.",
                        style: TextStyle(fontSize: 15),
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
