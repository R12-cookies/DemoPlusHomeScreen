import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

enum TtsState {
  playing,
  stopped,
}

class HomeState extends State<Home> with AfterLayoutMixin<Home> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen1 = (prefs.getBool('seen1') ?? false);

    if (_seen1) {
      
      //is there away to block any interactions until the audio finishes
      // intro to home audio
    } else {
      await prefs.setBool('seen1', true);
      _speak(
          ' مرحبا بك في الصفحة الرئيسية. من هنا يمكنك الدخول لباقي صفحات التطبيقْ, عن طريق الحركات التي تعلمناها سابقا. اِسحَب عمودياً لدخول صفحة الثقافة العامةْ. وأُفُقِيًا لدخول صفحة الترفيه. أخيرا، قم بالنقر مُطوَّلاً لدخول صفحة الرسائل. يمكنك دائما العودة الى الصفحة الرئيسية بالنقر مرتين اَينما كنت. وللحصول على معلومات عن الجو والوقت وغيرها، اٌنقُر مرة في الصفحة الرئيسية. لا تَقْلَقْ في حال ما نَسيتَ كل هذه المَعلوماتْ، قم بهز الهَاتِفَ و سَنُذَكِّرُكَ بِهَا');

      //home audio(simple hello)
    }
  }

  Weather w;
  WeatherFactory wf = new WeatherFactory("0159a72be3ed85ab99edbdc94dda553e",
      language: Language.ARABIC);
  final Battery _battery = Battery();
  int _batteryLevel;
  FlutterTts flutterTts;
  String time;
  bool check = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;
  @override
  initState() {
    super.initState();
    initPW();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar-AE");

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
        check = true;
      });
    });
  }

  initPW() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Weather weather = await wf.currentWeatherByLocation(
        position.latitude, position.longitude);
    setState(() {
      w = weather;
    });
  }

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak(word);
  }

  Widget shakeDetector() {
    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      if (check) {
        _speak(
            'اِسحَب عمودياً لدخول صفحة الثقافة العامةْ. وأُفُقِيًا لدخول صفحة الترفيه.  قم بالنقر مُطوَّلاً لدخول صفحة الرسائل. و اٌنقُر مرة للحصول على معلومات عن الجو والوقت وغيرها');
      }
    });

    return Container(
      
    );
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()  {
        DateTime dateTime = DateTime.now();

        if (check) {
          if (w != null) {
            _speak("الساعة الاَن هي" +
                dateTime.toString().substring(11, 16) +
                "." +
                "مستوى البطارية" +
                "$_batteryLevel" +
                "%" +
                "." +
                "الجو" +
                w.weatherDescription +
                "." +
                "و درجة الحرارة " +
                w.temperature.toString());
            _battery.batteryLevel.then((level) {
              this.setState(() {
                _batteryLevel = level;
              });
            });
          } else {
            _speak("تَأَكَّدْ اَنَّكَ مُتَّصِلٌ بالانترنت. " +
                "الساعة الاَن هي" +
                dateTime.toString().substring(11, 16) +
                "." +
                "مستوى البطارية" +
                "$_batteryLevel" +
                "%" +
                ".");
          }
          initPW();
        }
      },
      onDoubleTap: () {
        if (check) {
          _speak('الصفحة الرئيسية');
        }
      },
      onLongPress: () {
        if (check) {
          _speak('الرسائل');
        }
      },
      onHorizontalDragStart: (DragStartDetails details) {},
      onHorizontalDragEnd: (DragEndDetails details) {
        if (check) {
          _speak('تَرفيه');
        }
      },
      onVerticalDragStart: (DragStartDetails details) {},
      onVerticalDragEnd: (DragEndDetails details) {
        if (check) {
          _speak('معلومات عامة');
        }
      },
      child: Container(
        
        child: Align(
          alignment: Alignment.center,
          child: shakeDetector(),
        ),
      ),
    );
  }
}
