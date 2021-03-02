import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:ucs_manager/screens/SearchUCSScreen.dart';
import 'package:ucs_manager/utilties/PIUApi.dart';
import 'UCSListScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreen createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> with TickerProviderStateMixin {
  bool isDarkMode = false;

  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> addUCSAlert(BuildContext context) async {
    _textFieldController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ADD UCS'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "UCS No"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                var ucsNoList = _textFieldController.text.split(",");
                var ucsAddSuccess = '';
                for (var ucsNo in ucsNoList) {
                  var result = await PIUApi().addUCS(ucsNo);
                  setState(() {
                    UCSListScreen();
                  });
                  if (result.contains('Registration is complete.')) {
                    ucsAddSuccess += '$ucsNo, ';
                  }
                  else if (result.contains('SOURCE ERROR')) {
                    Fluttertoast.showToast(
                      msg: "UCS Number is Wrong - $ucsNo.",
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }
                }
                if (ucsAddSuccess != '') {
                  Fluttertoast.showToast(
                    msg: "Successfully Add UCS - ${ucsAddSuccess.substring(0, ucsAddSuccess.length - 2)}.",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  buildUCSAlert(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Build UCS Pack'),
          content: Text('Are You Sure Want To Build UCS PACK?'),
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
                  var result = await PIUApi().buildUCS();
                  if (result.contains('Registration is complete.'))
                  {
                    Fluttertoast.showToast(
                      msg: "Successfully Build UCS Pack.",
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }
                  else {
                    Fluttertoast.showToast(
                      msg: "You Can not Build when do not have any UCS.",
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  removeAllUCSAlert(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove All UCS'),
          content: Text('Are You Sure Want To Remove All UCS?'),
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
                  await PIUApi().removeAllUCS();
                  setState(() {
                    UCSListScreen();
                  });
                  Fluttertoast.showToast(
                    msg: "Successfully Remove All UCS.",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Exit?'),
                content: Text('Are You Sure Want to Exit?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('NO'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('EXIT'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });
        return value == true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.dark,
          backgroundColor: Color(0xFF398AE5),
          title: Text(
            'UCS Manager',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          child: UCSListScreen(),
        ),
        floatingActionButton: SpeedDial(
          marginEnd: 18,
          marginBottom: 30,
          // animatedIcon: AnimatedIcons.menu_close,
          // animatedIconTheme: IconThemeData(size: 22.0),
          icon: Icons.menu,
          activeIcon: Icons.remove,
          // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),
          /// The label of the main button.
          // label: Text("Open Speed Dial"),
          /// The active label of the main button, Defaults to label if not specified.
          // activeLabel: Text("Close Speed Dial"),
          /// Transition Builder between label and activeLabel, defaults to FadeTransition.
          // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
          /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements
          buttonSize: 60.0,
          visible: true,

          /// If true user is forced to close dial manually
          /// by tapping main button and overlay is not rendered.
          closeManually: false,

          /// If true overlay will render no matter what.
          renderOverlay: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          //onOpen: () => print('OPENING DIAL'),
          //onClose: () => print('DIAL CLOSED'),
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: (isDarkMode) ? Colors.white : Colors.black54,
          foregroundColor: (isDarkMode) ? Colors.black54 : Colors.white,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: 'Add UCS',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                addUCSAlert(context);
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.search),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              label: 'Search UCS',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchUCSScreen(),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.build),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              label: 'Build UCS Pack',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                buildUCSAlert(context);
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.delete_forever),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              label: 'Remove All UCS',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                removeAllUCSAlert(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
