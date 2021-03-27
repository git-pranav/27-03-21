import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'SignUpStick.dart';
import 'TextToSpeech.dart';
import 'Size_Config.dart';
import 'login.dart';
import 'dart:async';

bool debugShowCheckedModeBanner = true;

class SignUpUser extends StatelessWidget {
  TextEditingController nameController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  TextToSpeech tts = new TextToSpeech();
  final timeout = const Duration(seconds: 3);

  var go = [false, false]; //0:login,1:signup

  bool goOrNot(int touch) {
    if (go[touch]) {
      go[touch] = false;
      return true;
    } else {
      for (int i = 0; i < 2; i++) {
        if (i == touch)
          go[touch] = true;
        else
          go[i] = false;
      }
    }
    return false;
  }

  void cancelTouch() {
    for (int i = 0; i < 2; i++) go[i] = false;
  }

  void _startTimer() {
    Timer _timer;
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      cancelTouch();
      timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    tts.tellCurrentScreen("Sign up");
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => Login(),
          '/SignUpStick': (context) => SignUpStick()
        },
        title: 'SignupUser_Trial',
        home: Builder(
            builder: (context) => Scaffold(
                //  resizeToAvoidBottomPadding: false,
                backgroundColor: Color(0xFF00B1D2),
                appBar: new AppBar(
                  title: new Text('SIGN UP'),
                  backgroundColor: Color(0xFF1C3BC8),
                ),
                body: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.primaryDelta < -20) {
                        tts.tellDateTime();
                      }
                      if (details.primaryDelta > 20)
                        tts.tellCurrentScreen("Sign Up");
                    },
                    child: SingleChildScrollView(
                        child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                          GestureDetector(
                              onDoubleTap: () {
                                if (!nameController.text.isEmpty)
                                  tts.promptInput(nameController.text);
                              },
                              child: Column(children: <Widget>[
                                SizedBox(height: 200),
                                new Text(
                                  "Enter Number ",
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      color: const Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Roboto"),
                                ),
                                new TextField(
                                  controller: nameController,
                                  style: new TextStyle(
                                      fontSize: 25.0,
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Roboto"),
                                  keyboardType: TextInputType.phone,
                                  onTap: () {
                                    if (nameController.text.isEmpty)
                                      tts.promptInput("Enter your Number");
                                  },
                                  onChanged: (value) {
                                    tts.inputPlayback(value);
                                  },
                                ),
                                SizedBox(width: 210.0, height: 50.0),
                                RaisedButton(
                                  key: null,
                                  onPressed: () {
                                    tts.tellPress("SIGN UP");
                                    _startTimer();
                                    if (goOrNot(0)) {
                                      Navigator.pushNamed(
                                          context, '/SignUpStick');
                                    }
                                  },
                                  color: const Color(0xFF266EC0),
                                  child: new Text(
                                    "SIGN UP",
                                    style: new TextStyle(
                                        fontSize: 35.0,
                                        color: const Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Roboto"),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(40.0))),
                                ),
                              ])),
                        ]))))));
  }
}
