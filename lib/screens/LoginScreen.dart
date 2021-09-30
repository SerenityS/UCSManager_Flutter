import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ucs_manager/utilities/PIUApi.dart';
import 'package:ucs_manager/utilities/constatns.dart';
import 'package:ucs_manager/screens/MainScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pref = GetStorage();

  bool _isAutoLogin = false;
  bool _isRemember = false;

  bool isLogin = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final _pwFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _setWindowSize();
    }
    _loadPref();
  }

  void _setWindowSize() async {
    await DesktopWindow.setWindowSize(Size(550, 850));
    await DesktopWindow.setMinWindowSize(Size(400, 600));
    await DesktopWindow.setMaxWindowSize(Size(800, 1000));
  }

  void _loadPref() async {
    if (_pref.read('isRemember') == 'true') {
      setState(
        () {
          _emailController.text = _pref.read('email');
          _pwController.text = _pref.read('pw');
          _isRemember = true;
          if (_pref.read('isAutoLogin') == 'true') _isAutoLogin = true;
        },
      );
      if (_pref.read('isAutoLogin') == 'true') await getLogin();
    }
  }

  void _savePref() async {
    await _pref.write('email', _emailController.text);
    await _pref.write('pw', _pwController.text);
    await _pref.write('isAutoLogin', _isAutoLogin.toString());
    await _pref.write('isRemember', _isRemember.toString());
  }

  Widget _buildIDTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_pwFocusNode),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _pwController,
            onEditingComplete: getLogin,
            obscureText: true,
            focusNode: _pwFocusNode,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoLoginCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: [
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _isAutoLogin,
              checkColor: Colors.blue,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _isAutoLogin = value;
                });
              },
            ),
          ),
          Text(
            'Auto Login',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _isRemember,
              checkColor: Colors.blue,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _isRemember = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: getLogin,
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _pwFocusNode.dispose();

    super.dispose();
  }

  Future getLogin() async {
    var id = _emailController.text;
    var pw = _pwController.text;

    if (!isLogin) {
      isLogin = true;
      if (id != '' && pw != '') {
        if (await PIUApi().piuLogin(id, pw) == 302) {
          _savePref();
          await Get.offAll(
            () => MainScreen(),
          );
        } else {
          if (!Get.isSnackbarOpen) {
            Get.snackbar(
                'Login Failure!', 'Please Check your Email & Password.');
          }
        }
      } else {
        if (!Get.isSnackbarOpen) {
          Get.snackbar('Login Failure!', 'Please Fill your Email & Password.');
        }
      }
      isLogin = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 100.0,
                      ),
                      Text(
                        'Login to UCS Manager',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildIDTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildRememberMeCheckbox(),
                      SizedBox(
                        height: 15.0,
                      ),
                      _buildAutoLoginCheckbox(),
                      _buildLoginBtn(),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
