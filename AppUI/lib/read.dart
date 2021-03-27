import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'Size_Config.dart';
import 'TextToSpeech.dart';
import 'package:camera/camera.dart';
import 'util.dart';
import 'package:flutter/services.dart';
import 'homeR.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

bool debugShowCheckedModeBanner = true;

class read extends StatefulWidget {
  io.File jsonFileFace;
  io.File jsonFileSos;
  read({this.jsonFileFace, this.jsonFileSos});
  @override
  _readState createState() => _readState(this.jsonFileFace, this.jsonFileSos);
}

class _readState extends State<read> {
  io.File jsonFileFace;
  io.File jsonFileSos;
  _readState(this.jsonFileFace, this.jsonFileSos);
  TextToSpeech tts = new TextToSpeech();
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  CameraController _camera;
  List<String> words = [];
  bool _isRecognising = false;
  final TextRecognizer _textRecognizer =
      FirebaseVision.instance.textRecognizer();
  ImagePicker _picker = new ImagePicker();

  var go = [
    false,
  ]; //0:read

  bool goOrNot(int touch) {
    if (go[touch]) {
      go[touch] = false;
      return true;
    } else {
      for (int i = 0; i < 1; i++) {
        if (i == touch)
          go[touch] = true;
        else
          go[i] = false;
      }
    }
    return false;
  }

  void cancelTouch() {
    for (int i = 0; i < 1; i++) go[i] = false;
  }

  void _startTimer() {
    Timer _timer;
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      cancelTouch();
      words = [];
      timer.cancel();
    });
  }

  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);
    final TextRecognizer _textRecognizer =
        FirebaseVision.instance.textRecognizer();

    _camera =
        CameraController(description, ResolutionPreset.low, enableAudio: false);
    await _camera.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget _showCamera() {
    if (_camera == null || _isRecognising)
      return Center(
          child: Container(
              height: 200, width: 200, child: CircularProgressIndicator()));
    else
      return CameraPreview(_camera);
  }

  void detectText(String path) async {
    FirebaseVisionImage img = new FirebaseVisionImage.fromFilePath(path);
    TextRecognizer recog = FirebaseVision.instance.textRecognizer();
    VisionText recognizedText = await recog.processImage(img);
    if (recognizedText.text.isEmpty)
      tts.tell("No Recognisable Text");
    else {
      tts.tell(recognizedText.text);
      print(recognizedText.text);
    }
    var dir = io.Directory(path);
    dir.deleteSync(recursive: true);
    setState(() {
      _isRecognising = false;
    });
  }

  Future<String> takePicture() async {
    if (!_camera.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }
    setState(() {
      _isRecognising = true;
    });
    final io.Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    String date_time = DateTime.now().day.toString() +
        DateTime.now().month.toString() +
        DateTime.now().year.toString() +
        DateTime.now().hour.toString() +
        DateTime.now().minute.toString() +
        DateTime.now().second.toString() +
        DateTime.now().millisecond.toString() +
        DateTime.now().microsecond.toString();
    await io.Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$date_time.jpg';

    if (_camera.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await _camera.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    print(filePath);
    detectText(filePath);
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) =>
              Home(jsonFileFace: jsonFileFace, jsonFileSos: jsonFileSos)
        },
        home: Builder(
            builder: (context) => Scaffold(
               // resizeToAvoidBottomPadding: false,
                backgroundColor: Color(0xFF00B1D2),
                appBar: new AppBar(
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () {
                        _camera.dispose();
                        Navigator.pushNamed(context, '/home');
                      }),
                  title: new Text('Read Text'),
                  backgroundColor: Color(0xFF1C3BC8),
                ),
                body: Column(
                  children: <Widget>[
                    Container(
                      height: SizeConfig.safeBlockVertical * 70,
                      width: SizeConfig.safeBlockHorizontal * 100,
                      child: _showCamera(),
                    ),
                    SizedBox(height: 20),
                    _isRecognising
                        ? Container()
                        : RaisedButton(
                            key: null,
                            onPressed: () {
                              tts.tellPress("READ TEXT");
                              if (goOrNot(0)) {
                                takePicture();
                              }
                            },
                            color: const Color(0xFF266EC0),
                            child: Center(
                              child: Text(
                                "READ TEXT",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontSize: 35.0,
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Roboto"),
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40.0))),
                          ),
                  ],
                ))));
  }
}
