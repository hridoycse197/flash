import 'package:flutter/material.dart';
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
  String showText = 'Enable Mic And Say Light On';
  bool isFlashon = false;

  // final service = FlutterBackgroundService();
  //bg

  String result = "Say something!";
  String confirmation = "";
  String confirmationReply = "";
  String voiceReply = "";
  bool isbg = false;

  bool _enabled = false;
  bool _enabled1 = false;
  int _status = 0;
  List<DateTime> _events = [];
  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();
    // initializeService();

    setState(() {
      if (mounted) isListening = true;
    });

    //FlutterBackground.initialize(androidConfig: androidConfig);
    super.initState();
  }

  // Future<void> initializeService() async {
  //  service.startService();
  // }

  final String accessKey = "..."; // your Picovoice AccessKey

  // final androidConfig = const FlutterBackgroundAndroidConfig(
  //   notificationTitle: "TourchLight",
  //   notificationText: "App running in the background",
  //   notificationImportance: AndroidNotificationImportance.Max,
  //   notificationIcon: AndroidResource(
  //       name: 'background_icon',
  //       defType: 'drawable'), // Default is ic_launcher from folder mipmap
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF3A3A3B), Color(0xff141318)],
              begin: Alignment.topCenter,
              end: Alignment.center),
        ),
        child: SafeArea(
          child: FutureBuilder(
            future: _isTorchAvailable(context),
            builder: (context, AsyncSnapshot snapshot) {
              return Center(
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xff151519),
                                offset: Offset(-4, 7),
                                blurRadius: 5,
                                blurStyle: BlurStyle.normal,
                                spreadRadius: 4),
                          ],
                          gradient: LinearGradient(
                              colors: [Color(0xff3A3A3B), Color(0xff141318)])),
                      height: MediaQuery.of(context).size.height * 0.09,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 20,
                        itemBuilder: (context, index) => Container(
                          width: 65,
                          decoration: const BoxDecoration(
                              color: Color(0xff3A3A3B),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xff151519),
                                    offset: Offset(-.5, -.5),
                                    blurRadius: 8,
                                    blurStyle: BlurStyle.normal,
                                    spreadRadius: 10),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    !isFlashon
                        ? const CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xff19660C),
                          )
                        : const CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xff34ED16),
                          ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    !isFlashon
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _enabled1 = false;
                                isFlashon = !isFlashon;
                                isFlashon
                                    ? _enableTorch(context)
                                    : _disableTorch(context);
                              });
                            },
                            child: Container(
                                alignment: Alignment.center,
                                height:
                                    MediaQuery.of(context).size.height * 0.28,
                                width: MediaQuery.of(context).size.width * 0.7,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff393939)),
                                child: Image.asset('assets/off_button.png')),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                _enabled1 = false;
                                isFlashon = !isFlashon;
                                isFlashon
                                    ? _enableTorch(context)
                                    : _disableTorch(context);
                              });
                            },
                            child: Container(
                                alignment: Alignment.center,
                                height:
                                    MediaQuery.of(context).size.height * 0.28,
                                width: MediaQuery.of(context).size.width * 0.7,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff393939)),
                                child: Image.asset('assets/light on.png')),
                          ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    Text(
                      showText,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * .12,
                      decoration: BoxDecoration(
                        color: Color(0xff38373A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width * .7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                _enabled = true;
                                isListening = true;
                              });

                              isListen();
                            },
                            child: Text(
                              'Enable Mic',
                              style: TextStyle(
                                  color: !_enabled
                                      ? Colors.white
                                      : Color(0xff34ED16),
                                  fontSize: 15),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            width: 2,
                            height: MediaQuery.of(context).size.width * .12,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _enabled = false;
                                _enabled1 = true;
                                isListening = false;
                                showText = 'Enable Mic And Say Light On';
                              });

                              _speech!.stop();
                            },
                            child: Text(
                              'Disable Mic',
                              style: TextStyle(
                                  color: _enabled
                                      ? Color(0xffEFBA00)
                                      : !_enabled1
                                          ? Color(0xffEFBA00)
                                          : Color(0xff34ED16),
                                  fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
    if (isListening == true) {
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
