import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:torch_light/torch_light.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool checkTourch = true;
  stt.SpeechToText? _speech;
  bool isListening = false;
  String showText = 'Press the button to talk';
  bool isFlashon = false;

  final service = FlutterBackgroundService();
  //bg

  String result = "Say something!";
  String confirmation = "";
  String confirmationReply = "";
  String voiceReply = "";
  bool isbg = false;
  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();
    initializeService();
    setState(() {
      if (mounted) isListening = true;
    });

    FlutterBackground.initialize(androidConfig: androidConfig);
    super.initState();
  }

  Future<void> initializeService() async {
    service.startService();
  }

  final String accessKey = "..."; // your Picovoice AccessKey

  final androidConfig = const FlutterBackgroundAndroidConfig(
    notificationTitle: "TourchLight",
    notificationText: "App running in the background",
    notificationImportance: AndroidNotificationImportance.Max,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff072ff7).withOpacity(0.5),
      body: SafeArea(
        child: FutureBuilder(
          future: _isTorchAvailable(context),
          builder: (context, AsyncSnapshot snapshot) {
            return Center(
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height - 300,
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isFlashon = !isFlashon;
                            isFlashon
                                ? _enableTorch(context)
                                : _disableTorch(context);
                          });
                        },
                        child: Image.asset(
                          !isFlashon ? 'assets/t1.png' : 'assets/t.png',
                          height: MediaQuery.of(context).size.height - 300,
                          width: MediaQuery.of(context).size.width,
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              minimumSize: Size(
                                MediaQuery.of(context).size.width / 2.5,
                                30,
                              ),
                              backgroundColor: Colors.green,
                              shadowColor: Colors.grey),
                          onPressed: () async {
                            FlutterBackground.enableBackgroundExecution();
                            service.on(isListen());
                          },
                          child: Text('Enable'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shadowColor: Colors.grey,
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width / 2.5, 30)),
                          onPressed: () async {
                            await FlutterBackground
                                .disableBackgroundExecution();

                            _speech!.stop();
                          },
                          child: Text("disable"),
                        ),
                      ],
                    ),
                  ),
                  Text(showText)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  isListen() async {
    bool available = await _speech!.initialize(
      options: [],
      finalTimeout: const Duration(minutes: 5),
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => isListening = true);
      await _speech!.listen(
        onResult: (val) => setState(() async {
          if (val.recognizedWords.toLowerCase() == 'light on') {
            setState(() {
              isFlashon = true;
            });
          } else if (val.recognizedWords.toLowerCase() == 'light off') {
            setState(() {
              isFlashon = false;
            });
          }
          showText = val.recognizedWords.toLowerCase();
          showText == 'light on'
              ? _enableTorch(context)
              : showText == 'light off'
                  ? _disableTorch(context)
                  : Null;

          showText = val.recognizedWords.toLowerCase();
          if (val.hasConfidenceRating && val.confidence > 0) {}
        }),
      );
    }
    if (FlutterBackground.isBackgroundExecutionEnabled) {
      isListen();
    } else {
      _speech!.stop();
    }
  }

  Future<bool> _isTorchAvailable(BuildContext context) async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> _enableTorch(BuildContext context) async {
    try {
      await TorchLight.enableTorch();
    } on Exception catch (_) {}
  }

  Future<void> _disableTorch(BuildContext context) async {
    try {
      await TorchLight.disableTorch();
    } on Exception catch (_) {}
  }

  void _listen() async {
    if (!isListening) {
      bool available = await _speech!.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => isListening = true);
        _speech!.listen(
            onResult: (val) => setState(() {
                  setState(() {
                    showText = val.recognizedWords.toLowerCase();
                    showText == 'light on'
                        ? _enableTorch(context)
                        : showText == 'light off'
                            ? _disableTorch(context)
                            : Null;
                  });
                  showText = val.recognizedWords.toLowerCase();
                }));
      }
    } else {
      setState(() => isListening = false);
      _speech!.stop();
    }
  }
}
