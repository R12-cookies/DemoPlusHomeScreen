import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GISplash extends StatefulWidget {
  @override
  _GISplashState createState() => _GISplashState();
}

class _GISplashState extends State<GISplash> with AfterLayoutMixin<GISplash> {
  FlutterTts flutterTts;
  bool check = false;
  TtsState ttsState = TtsState.stopped;

  initState() {
    super.initState();
    initTts();
  }

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;
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

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(word);
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen2 = (prefs.getBool('seen2') ?? false);

    if (_seen2) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new GeneralInfo()));

      //is there away to block any interactions until the audio finishes
      // intro to home audio
    } else {
      await prefs.setBool('seen2', true);
      _speak(
          'مرحبًا بك في صفحة، المعلومات العامة. في هذه الصفحة سَتَجِدُ عدة مواضيع من فِئَاتٍ مختلفة، لِتَسْتَمِعَ اِليْها. إلَيْكَ كيف تستعملها.  المواضيع متوفرة في شَاشَتِكَ مِثل البطاقات. لِلْتَنَقُّلِ مِنْ مَوضُوعٍ اِلى اَخَرْ، قُمْ بِالسَّحْبِ أُفُقِيًّا مرَّةً على حدا و سنقرأ لك الفئة الموافِقة. لإختيار فئة، يكفي ان تَنْقُرَ على الشاشة مرَّةً واحدة و ستبدأ قراءة المقال. يمكنك التسريع الى الامام عبر السَّحْبِ اِلى الاََسْفَلْ اَو العودة الى الوراء عبر السَّحْبِ اِلى الاَعلى. لِايقاف القِرَائَةِ يَكفي اَن تَنْقُرَ مَرَّةً ثَانِيَةً عَلى الشاشة. و طبعاً كَكُلِّ مَرَّةٍ اِذَا نسيت اَيَّ شيئٍ هُزَّ الهاتف و سنذكرك');

      Timer(Duration(seconds: 48), () {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new GeneralInfo()));
      });
      //home audio(simple hello)
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    );
  }
}

class GeneralInfo extends StatefulWidget {
  @override
  _GeneralInfoState createState() => _GeneralInfoState();
}

class _GeneralInfoState extends State<GeneralInfo> {
  CarouselController _scrollController = CarouselController();
  Duration duration = new Duration();
  Duration positionA = new Duration();
  double initial = 0.0;
  double added = 0.0;

  List<AudioPlayer> audioplayers = [
    AudioPlayer(playerId: 'firstplayer'),
    AudioPlayer(playerId: 'secondplayer'),
    AudioPlayer(playerId: 'third'),
  ];

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;
  bool playing = false;
  int position;
  bool check = true;
  FlutterTts flutterTts;
  @override
  void initState() {
    super.initState();
    initTts();
    initAudioPlayers();
  }

  initAudioPlayers() async {
    if (check) {
      _speak('جاري تحميل المقالات');
    }

    for (var i = 0; i < 3; i++) {
      await audioplayers[i].setUrl(urls[i]);

      //-----------------------------------
    }
    var ready = await audioplayers[0].getDuration();

    if (ready == 1) {
      if (check) {
        _speak('تم تحميل المقالات');
      }
    }
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar-AE");
    flutterTts.setSpeechRate(0.93);

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

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak(word);
  }

  List<String> urls = [
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/universe.m4a?alt=media&token=f464860f-8abd-4957-976c-8bc2a28af56e',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/Whale.m4a?alt=media&token=9baaf125-f2fd-4339-aa3a-a2233b4c6f11',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/electricity.m4a?alt=media&token=d99d78e6-56de-40ef-a0e9-1a2061ee1ef9',
  ];

  void getAudio(int index, AudioPlayer audioPlayer) async {
    if (playing) {
      //pause
      var res = await audioplayers[index].pause();
      if (res == 1) {
        setState(() {
          playing = false;
        });
      }
    } else {
      audioPlayer.setVolume(10);
      var res = await audioplayers[index].play(urls[index], isLocal: true);
      if (res == 1) {
        setState(() {
          playing = true;
        });
      }
    }
    audioplayers[index].onDurationChanged.listen((Duration dd) {
      setState(() {
        duration = dd;
      });
    });
    audioplayers[index].onAudioPositionChanged.listen((Duration dd) {
      setState(() {
        positionA = dd;
      });
    });

    audioplayers[index].onPlayerCompletion.listen((event) {
      if (check) {
        _speak('إنتهى المقال');

      }
    });
  }

  List<String> categories = [
    'الفلك',
    'الحياة البرية',
    'تقنيات',
    'التنمية الذاتية'
  ];

  Widget shakeDetector() {
    // ignore: unused_local_variable
    ShakeDetector detector = ShakeDetector.autoStart(
        shakeThresholdGravity: 2.2,
        onPhoneShake: () {
          if (check) {
            _speak(
                'قم بِالسَّحْبِ اُفٌقِيًّا لتغيير الفِئَةِ. اُنْقُرْ مرة لِبَدْإِِ القِرَائَةِ ثم مرة ثانيةً لإيقافها. إسحبْ تدريجيًّا اِلَى الأَسْفَلِ للتسريع الى الأمام و اِلى الأعلى للعودة الى الوراء');
          }
        });

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: CarouselSlider.builder(
          carouselController: _scrollController,
          options: CarouselOptions(
            pageSnapping: true,
            enlargeCenterPage: true,
            aspectRatio: 0.6,
            initialPage: 0,
            onPageChanged: (index, reason) {
              _speak(categories[index]);
              print(categories[index]);
              setState(() {
                audioplayers[index].seek(new Duration(seconds: 0));
              });
            },
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1),
                child: GestureDetector(
                  onVerticalDragStart: (DragStartDetails details) {
                    initial = details.globalPosition.dy;
                    setState(() {
                      added = positionA.inSeconds.toDouble();
                    });
                  },
                  onVerticalDragUpdate: (DragUpdateDetails details) {
                    double distance = details.globalPosition.dy - initial;
                    double addition =
                        distance / MediaQuery.of(context).size.height;
                    double sec = positionA.inSeconds.toDouble();
                    print(sec);
                    setState(() {
                      added = (added + addition)
                          .clamp(0.0, duration.inSeconds.toDouble());
                    });
                    print(details.globalPosition.dy);
                    //print(distance);
                    setState(() {
                      audioplayers[index]
                          .seek(new Duration(seconds: added.toInt()));
                    });
                  },
                  onVerticalDragEnd: (DragEndDetails details) {
                    initial = 0;
                  },
                  onTap: () {
                    getAudio(index, audioplayers[index]);
                    print(MediaQuery.of(context).size.height);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.black,
                    child: shakeDetector(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum TtsState {
  playing,
  stopped,
}
