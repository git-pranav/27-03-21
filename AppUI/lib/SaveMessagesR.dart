import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'homeR.dart';
import 'TextToSpeech.dart';
import 'dart:async';
import 'Size_Config.dart';
import 'dart:io' as io;
import 'package:speech_to_text/speech_to_text.dart';

bool debugShowCheckedModeBanner = true;

class SaveMessages extends StatefulWidget {
  io.File jsonFileFace;
  io.File jsonFileSos;
  SaveMessages({this.jsonFileFace, this.jsonFileSos});
  @override
  _SaveMessagesState createState() =>
      _SaveMessagesState(this.jsonFileFace, this.jsonFileSos);
}

class _SaveMessagesState extends State<SaveMessages> {
  io.File jsonFileFace;
  io.File jsonFileSos;
  _SaveMessagesState(this.jsonFileFace, this.jsonFileSos);
  TextToSpeech tts = new TextToSpeech();
  final SpeechToText speech = SpeechToText();
  final timeout = const Duration(seconds: 3);
  String sosMssg, userMssg;

  var go = [
    false,
    false,
    false,
    false,
  ]; //0:recosos,1:recisos,2:recofall,3:recifall

  bool goOrNot(int touch) {
    if (go[touch]) {
      go[touch] = false;
      return true;
    } else {
      for (int i = 0; i < 4; i++) {
        if (i == touch)
          go[touch] = true;
        else
          go[i] = false;
      }
    }
    return false;
  }

  void cancelTouch() {
    for (int i = 0; i < 4; i++) go[i] = false;
  }

  void _startTimer() {
    Timer _timer;
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      cancelTouch();
      timer.cancel();
    });
  }

  Future initVoiceInput() async {
    try {
      bool hasSpeech = await speech.initialize();
      if (hasSpeech) print("initialised");
    } catch (e) {
      print("Error while Initialising speech to text:" + e.toString());
    }
  }

  void RecordSosMssg() {
    tts.tell("Set S O S Message after the beep");
    Future.delayed(Duration(seconds: 4), () async {
      await initVoiceInput();
      speech.listen(
          onResult: (SpeechRecognitionResult result) async {
            tts.tell("You entered Your Message as " +
                result.recognizedWords +
                ".Say yes to confirm after the beep");
            speech.cancel();
            speech.initialize();
            Future.delayed(Duration(seconds: 7), () {
              speech.listen(
                  onResult: (SpeechRecognitionResult result1) {
                    if (result1.recognizedWords.compareTo("yes") == 0) {
                      sosMssg = result.recognizedWords;
                      speech.cancel();
                      tts.tell("S O S Message confirmed");
                      userMssg = result.recognizedWords;
                      speech.cancel();
                      Map<String, dynamic> data =
                          json.decode(jsonFileSos.readAsStringSync());
                      data["sosMssg"] = sosMssg;
                      jsonFileSos.writeAsStringSync(json.encode(data));
                    } else {
                      speech.cancel();
                      tts.tell("Failed to confirm S O S Message");
                    }
                  },
                  listenFor: Duration(seconds: 10),
                  pauseFor: Duration(seconds: 5),
                  partialResults: false,
                  listenMode: ListenMode.confirmation);
            });
          },
          listenFor: Duration(seconds: 10),
          pauseFor: Duration(seconds: 5),
          partialResults: false,
          listenMode: ListenMode.dictation);
    });
  }

  void RecordUserFallMssg() {
    tts.tell("Set User fall Message after the beep");
    Future.delayed(Duration(seconds: 4), () async {
      await initVoiceInput();
      speech.listen(
          onResult: (SpeechRecognitionResult result) async {
            tts.tell("You entered Your Message as " +
                result.recognizedWords +
                ".Say yes to confirm after the beep");
            speech.cancel();
            speech.initialize();
            Future.delayed(Duration(seconds: 7), () {
              speech.listen(
                  onResult: (SpeechRecognitionResult result1) {
                    if (result1.recognizedWords.compareTo("yes") == 0) {
                      userMssg = result.recognizedWords;
                      speech.cancel();
                      tts.tell("S O S Message confirmed");
                      Map<String, dynamic> data =
                          json.decode(jsonFileSos.readAsStringSync());
                      data["userFallMssg"] = userMssg;
                      jsonFileSos.writeAsStringSync(json.encode(data));
                    } else {
                      speech.cancel();
                      tts.tell("Failed to confim S O S Message");
                    }
                  },
                  listenFor: Duration(seconds: 10),
                  pauseFor: Duration(seconds: 5),
                  partialResults: false,
                  listenMode: ListenMode.confirmation);
            });
          },
          listenFor: Duration(seconds: 10),
          pauseFor: Duration(seconds: 5),
          partialResults: false,
          listenMode: ListenMode.dictation);
    });
  }

  @override
  void dispose() {
    try {
      speech.stop();
      speech.cancel();
    } catch (err) {
      print(err);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    tts.tellCurrentScreen("Save Message");
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) =>
              Home(jsonFileFace: jsonFileFace, jsonFileSos: jsonFileSos)
        },
        title: 'SaveMessages_trial',
        home: Builder(
            builder: (context) => Scaffold(
               // resizeToAvoidBottomPadding: false,
                backgroundColor: Color(0xFF00B1D2),
                appBar: new AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                      print("avail" + speech.isAvailable.toString());
                      print("list" + speech.isListening.toString());
                      speech.cancel();
                      speech.stop();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => Home(
                                  jsonFileFace: jsonFileFace,
                                  jsonFileSos: jsonFileSos)),
                          (route) => false);
                    },
                  ),
                  title: new Text('Save Message'),
                  backgroundColor: Color(0xFF1C3BC8),
                ),
                body: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      if (details.primaryDelta < -20) {
                        tts.tellDateTime();
                      }
                      if (details.primaryDelta > 20)
                        tts.tellCurrentScreen("Save Messages");
                    },
                    child: Column(children: <Widget>[
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: SizeConfig.safeBlockHorizontal * 100,
                      ),
                      Container(
                        height: SizeConfig.safeBlockVertical * 18 - 12.58,
                        width: SizeConfig.safeBlockHorizontal * 100,
                        child: RaisedButton(
                          key: null,
                          onPressed: () {
                            tts.tellPress("RECORD S O S MESSAGE");
                            _startTimer();
                            if (goOrNot(0)) {
                              RecordSosMssg();
                            }
                          },
                          color: const Color(0xFF266EC0),
                          child: new Text(
                            "RECORD SOS MESSAGE",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 29.0,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Roboto"),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0))),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: SizeConfig.safeBlockHorizontal * 100,
                      ),
                      Container(
                        height: SizeConfig.safeBlockVertical * 18 - 12.58,
                        width: SizeConfig.safeBlockHorizontal * 100,
                        child: RaisedButton(
                          key: null,
                          onPressed: () {
                            tts.tellPress("RECITE S O S MESSAGE");
                            _startTimer();
                            if (goOrNot(1)) {
                              Map<String, dynamic> data =
                                  json.decode(jsonFileSos.readAsStringSync());
                              if (data["sosMssg"].isEmpty)
                                tts.tell("You have not set the S O S message");
                              else
                                tts.tell("The S O S Message set is " +
                                    data["sosMssg"]);
                            }
                          },
                          color: const Color(0xFF266EC0),
                          child: new Text(
                            "RECITE SOS MESSAGE",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 29.0,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Roboto"),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0))),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: SizeConfig.safeBlockHorizontal * 100,
                      ),
                      Container(
                        height: SizeConfig.safeBlockVertical * 18 - 12.58,
                        width: SizeConfig.safeBlockHorizontal * 100,
                        child: RaisedButton(
                          key: null,
                          // onPressed: () {
                          //   tts.tellPress("RECORD USER FALL MESSAGE");
                          //   _startTimer();
                          //   if (goOrNot(2)) {
                          //     RecordUserFallMssg();
                          //   }
                          // },
                          color: const Color(0xFF266EC0),
                          child: new Text(
                            "RECORD USER - FALL MESSAGE",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 29.0,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Roboto"),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0))),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: SizeConfig.safeBlockHorizontal * 100,
                      ),
                      Container(
                          height: SizeConfig.safeBlockVertical * 18 - 12.58,
                          width: SizeConfig.safeBlockHorizontal * 100,
                          child: RaisedButton(
                            key: null,
                            // onPressed: () {
                            //   tts.tellPress("RECITE USER FALL MESSAGE");
                            //   _startTimer();
                            //   if (goOrNot(3)) {
                            //     Map<String, dynamic> data =
                            //         json.decode(jsonFileSos.readAsStringSync());
                            //     if (data["userFallMssg"].isEmpty)
                            //       tts.tell(
                            //           "You have not set the user Fall message");
                            //     else
                            //       tts.tell("The Userfall Message set is " +
                            //           data["userFallMssg"]);
                            //   }
                            // },
                            color: const Color(0xFF266EC0),
                            child: new Text(
                              "RECITE USER - FALL MESSAGE",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: 29.0,
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Roboto"),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40.0))),
                          )),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: SizeConfig.safeBlockHorizontal * 100,
                      ),
                    ])))));
  }
}
