import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ucs_manager/screens/FavoriteUCSScreen.dart';
import 'package:ucs_manager/screens/LoginScreen.dart';
import 'package:ucs_manager/screens/SearchUCSScreen.dart';
import 'package:ucs_manager/utilities/PIUApi.dart';

import 'UCSListScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreen createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> with TickerProviderStateMixin {
  final _pref = GetStorage();

  bool isDarkMode = false;

  final TextEditingController _textFieldController = TextEditingController();

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

  void printSnackBar(msg) {
    Get.snackbar('UCS Manager', msg, colorText: Colors.white);
  }

  void logoutAlert(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are You Sure Want to Logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                await _pref.write('isRemember', 'false');
                await Get.offAll(
                  () => LoginScreen(),
                );
              },
              child: Text('YES'),
            ),
          ],
        );
      },
    );
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
            decoration: InputDecoration(hintText: 'UCS No'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                var ucsNoList = _textFieldController.text.split(',');
                if (ucsNoList[0] != '') {
                  var ucsAddSuccess = '';
                  var ucsAddFailure = '';
                  for (var ucsNo in ucsNoList) {
                    var result = await PIUApi().addUCS(ucsNo);
                    if (result.contains('Registration is complete.')) {
                      ucsAddSuccess += '$ucsNo, ';
                    } else if (result.contains('SOURCE ERROR')) {
                      ucsAddFailure += '$ucsNo, ';
                    }
                  }
                  Get.back();
                  if (ucsAddSuccess != '') {
                    setState(
                      () {
                        UCSListScreen();
                      },
                    );
                    printSnackBar(
                        'Successfully Add UCS! / UCS No : ${ucsAddSuccess.substring(0, ucsAddSuccess.length - 2)}.');
                  } else {
                    printSnackBar(
                        'Add UCS Failed! / UCS No : ${ucsAddFailure.substring(0, ucsAddFailure.length - 2)}.');
                  }
                } else {
                  Get.back();
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void buildUCSAlert(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Build UCS Pack'),
          content: Text('Are You Sure Want To Build UCS PACK?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                var result = await PIUApi().buildUCS();
                Get.back();
                if (result.contains('Registration is complete.')) {
                  printSnackBar('Successfully Build UCS Pack.');
                } else {
                  printSnackBar(result);
                }
              },
              child: Text('YES'),
            ),
          ],
        );
      },
    );
  }

  void removeAllUCSAlert(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove All UCS'),
          content: Text('Are You Sure Want To Remove All UCS?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                var result = await PIUApi().removeAllUCS();
                Get.back();
                if (result != false) {
                  setState(
                    () {
                      UCSListScreen();
                    },
                  );
                  printSnackBar('Successfully Remove All UCS.');
                } else {
                  printSnackBar('You don\'t have Any UCS to Remove.');
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
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('NO'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('EXIT'),
                ),
              ],
            );
          },
        );
        return value == true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'UCS Manager',
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/icon/logout.png',
                color: Colors.white,
                scale: 1.3,
              ),
              tooltip: 'Logout',
              onPressed: () => {
                logoutAlert(context),
              },
            )
          ],
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
          tooltip: 'Menu',
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
                Get.to(
                  () => SearchUCSScreen(),
                );
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.favorite),
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              label: 'Favorite UCS',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                Get.to(
                  () => FavoriteUCSScreen(),
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
