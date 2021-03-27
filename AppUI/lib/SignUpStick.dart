import 'package:flutter/material.dart';
import 'Size_Config.dart';
import 'homeR.dart';
import 'package:flutter/services.dart';
import 'TextToSpeech.dart';
import 'dart:async';

bool debugShowCheckedModeBanner = true;

class SignUpStick extends StatelessWidget {
  TextEditingController sticknameController = new TextEditingController();
  TextEditingController stickPasswordController = new TextEditingController();
  TextEditingController stickConfirmPasswordController =
      new TextEditingController();

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
        routes: {'/home': (context) => Home()},
        title: 'SignupStick_Trial',
        home: Builder(
            builder: (context) => Scaffold(
               // resizeToAvoidBottomPadding: false,
                backgroundColor: Color(0xFF00B1D2),
                appBar: new AppBar(
                  title: new Text('Set Stick Details'),
                  backgroundColor: Color(0xFF1C3BC8),
                ),
                body: GestureDetector(
                    behavior: HitTestBehavior.opaque,
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
                                if (!sticknameController.text.isEmpty)
                                  tts.promptInput(sticknameController.text);
                              },
                              child: Column(children: <Widget>[
                                new Text(
                                  "Give a name for your stick",
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      color: const Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Roboto"),
                                ),
                                new TextField(
                                  controller: sticknameController,
                                  style: new TextStyle(
                                      fontSize: 25.0,
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Roboto"),
                                  onTap: () {
                                    if (sticknameController.text.isEmpty)
                                      tts.promptInput(
                                          "Enter The name of your stick");
                                  },
                                  onChanged: (value) {
                                    tts.inputPlayback(value);
                                  },
                                ),
                              ])),
                          GestureDetector(
                            onDoubleTap: () {
                              if (!stickPasswordController.text.isEmpty)
                                tts.promptInput(stickPasswordController.text);
                            },
                            child: Column(children: <Widget>[
                              new Text(
                                "Give a Password for your stick",
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Roboto"),
                              ),
                              new TextField(
                                obscureText: true,
                                controller: stickPasswordController,
                                style: new TextStyle(
                                    fontSize: 25.0,
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Roboto"),
                                onTap: () {
                                  if (stickPasswordController.text.isEmpty)
                                    tts.promptInput(
                                        "Enter a password for your stick");
                                },
                                onChanged: (value) {
                                  tts.inputPlayback(value);
                                },
                              ),
                            ]),
                          ),
                          GestureDetector(
                            onDoubleTap: () {
                              if (!stickConfirmPasswordController.text.isEmpty)
                                tts.promptInput(
                                    stickConfirmPasswordController.text);
                            },
                            child: Column(children: <Widget>[
                              new Text(
                                "Confirm Password that you just entered",
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Roboto"),
                              ),
                              new TextField(
                                obscureText: true,
                                controller: stickConfirmPasswordController,
                                style: new TextStyle(
                                    fontSize: 25.0,
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Roboto"),
                                onTap: () {
                                  if (stickConfirmPasswordController
                                      .text.isEmpty)
                                    tts.promptInput(
                                        "Enter the password for your stick again");
                                },
                                onChanged: (value) {
                                  tts.inputPlayback(value);
                                },
                              ),
                            ]),
                          ),
                          new Padding(
                            child: new SizedBox(
                              width: 210.0,
                              height: 50.0,
                              child: new RaisedButton(
                                key: null,
                                onPressed: () {
                                  tts.tellPress("SIGN UP");
                                  _startTimer();
                                  if (goOrNot(0)) {
                                    Navigator.pushNamed(context, '/home');
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
                            ),
                            padding: const EdgeInsets.fromLTRB(
                                50.0, 50.0, 50.0, 25.0),
                          )
                        ]))))));
  }
}
