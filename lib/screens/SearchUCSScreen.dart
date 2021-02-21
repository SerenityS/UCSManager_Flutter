import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

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
  void initState() {
    super.initState();
  }

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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text("YES"),
                onPressed: () async {
                  await PIUApi().addUCS(ucsNoList[index]);
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  alertMessage(context, title, content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
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
  searchUCSList(songTitle, stepArtist, stepLv) async {
    songTitleList.clear();
    stepArtistList.clear();
    stepLvList.clear();
    ucsNoList.clear();
    searchUCS(url) async {
      var ucs = await Requests.get(url);
      dom.Document document = parser.parse(ucs.content());
      var totalPage = document.getElementsByClassName('share_board_info_text');
      totalPage = totalPage[0].getElementsByTagName('span');
      var totalPageStr = totalPage[0].text;
      totalPageStr.replaceAllMapped(RegExp(r'\s+(\d+)\s+'), (match) {
        totalPageStr = '${match.group(1)}';
        return '${match.group(1)}';
      });
      var totalPageInt = int.parse(totalPageStr);

      totalPageInt = (totalPageInt + 14) ~/ 15;
      if (totalPageInt == 0) {
        searchButtonText = "Search";
        searchButtonEnabled = true;
        setState(() {});
        return ucsNoList.length;
      }

      for (var i = 1; i < totalPageInt + 1; i++) {
        var ucspage = await Requests.get(url + i.toString());
        dom.Document document = parser.parse(ucspage.content());
        var ucslist = document.getElementsByTagName('tr');

        for (var j = 1; j < ucslist.length; j++) {
          var songTitleParsed =
              ucslist[j].getElementsByClassName('share_song_title')[0].text;
          var stepArtistParsed = ucslist[j]
              .getElementsByClassName('share_stepmaker')[0]
              .text
              .replaceAll(' ', '');
          var stepLvParsed = ucslist[j]
              .getElementsByClassName('share_level')[0]
              .getElementsByTagName('span')[0]
              .attributes['class'];
          var ucsNoParsed = ucslist[j]
              .getElementsByClassName('btnaddslot_ucs btnAddtoUCSSLOT')[0]
              .attributes['data-ucs_id'];

          if (stepLvParsed.contains('single')) {
            stepLvParsed = ('S${stepLvParsed.substring(22)}');
          } else if (stepLvParsed.contains('sinper')) {
            stepLvParsed = ('SP${stepLvParsed.substring(22)}');
          } else if (stepLvParsed.contains('double')) {
            stepLvParsed = ('D${stepLvParsed.substring(22)}');
          } else if (stepLvParsed.contains('douper')) {
            stepLvParsed = ('DP${stepLvParsed.substring(22)}');
          } else {
            stepLvParsed = ('CO-OPx${stepLvParsed.substring(21)}');
          }

          if (stepArtistParsed
              .toLowerCase()
              .contains(_stepArtistController.text.toLowerCase())) {
            if (stepLvParsed
                .toLowerCase()
                .contains(_stepLvController.text.toLowerCase())) {
              var idx = songTitleList.length;
              songTitleList.insert(idx, songTitleParsed);
              stepArtistList.insert(idx, stepArtistParsed);
              stepLvList.insert(idx, stepLvParsed);
              ucsNoList.insert(idx, ucsNoParsed);
            }
          }
        }
        if (i == totalPageInt) {
          try {
            var nextUrl = document.getElementsByClassName('pg_page pg_end');
            var nextUrlString = nextUrl[0].attributes['href'].toString();
            nextUrlString =
                nextUrlString.substring(1, nextUrlString.length - 1);
            searchUCS('http://www.piugame.com/bbs$nextUrlString');
          } on RangeError {
            searchButtonText = "Search";
            searchButtonEnabled = true;
            setState(() {});
            return ucsNoList.length;
          }
        }
      }
    }

    if (songTitle.length > 2) {
      searchUCS(
          "http://www.piugame.com/bbs/board.php?bo_table=ucs&sfl=ucs_song_no&stx=$songTitle&page=");
    }
    else {
      searchUCS(
          "http://www.piugame.com/bbs/board.php?bo_table=ucs&sfl=wr_name&stx=$stepArtist&page=");
    }
  }

  var searchButtonText = "Search";
  bool searchButtonEnabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF398AE5),
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
                    if (_songTitleController.text.length > 2 ||
                        _stepArtistController.text != '') {
                        if (searchButtonEnabled) {
                          searchButtonEnabled = false;
                          searchButtonText = 'Searching...';
                          setState(() {});
                          await searchUCSList(_songTitleController.text,
                              _stepArtistController.text, _stepLvController.text);
                        } else {
                          alertMessage(context, 'Error!',
                              'Your search process is already in progress.\nPlease Wait.');
                        }
                      } else {
                        alertMessage(context, 'Error!',
                            'You must Enter\nSong Title more than 3 letters\nOR Full Step Artist Name.');
                    }
                  }
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
