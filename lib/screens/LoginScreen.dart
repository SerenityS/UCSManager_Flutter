import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:requests/requests.dart';

import 'package:ucs_manager/utilties/constatns.dart';
import 'package:ucs_manager/screens/MainScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pref = GetStorage();

  bool _isAutoLogin = false;
  bool _isRemember = false;

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _pwController = new TextEditingController();
  var _pwFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  _loadPref() async {
    if (_pref.read('isRemember') == 'true') {
      setState(
        () {
          _emailController.text = _pref.read('email');
          _pwController.text = _pref.read('pw');
          _isRemember = true;
        },
      );
      if (_pref.read('isAutoLogin') == 'true') {
        setState(
          () {
            _isAutoLogin = true;
          },
        );
        await getLogin();
      }
    }
  }

  _savePref() async {
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
        children: <Widget>[
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
    String id = _emailController.text;
    String pw = _pwController.text;

    if (id != '' && pw != '') {
      String loginUrl = 'http://www.piugame.com/bbs/piu.login_check.php';

      var response = await Requests.post(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
          'Accept-Encoding': "gzip, deflate",
          'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
          'Connection': 'keep-alive',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Host': 'www.piugame.com',
          'Origin': 'http://www.piugame.com',
          'Referer': 'http://www.piugame.com/piu.xx/',
          'Upgrade-Insecure-Requests': '1',
        },
        body: <String, String>{
          'mb_id': id,
          'mb_password': pw,
        },
      );

      if (response.statusCode == 302) {
        _savePref();
        Get.offAll(
          () => MainScreen(),
        );
      } else {
        if (!Get.isSnackbarOpen) {
          Get.snackbar('Login Failure!', 'Please Check your Email & Password.');
        }
      }
    } else {
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Login Failure!', 'Please Fill your Email & Password.');
      }
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
