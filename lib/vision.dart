import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralInfo extends StatefulWidget {
  @override
  _GeneralInfoState createState() => _GeneralInfoState();
}

class _GeneralInfoState extends State<GeneralInfo> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen2 = (prefs.getBool('seen2') ?? false);

    if (_seen2) {
      prefs.remove('seen2');
      //is there away to block any interactions until the audio finishes
      // intro to home audio
    } else {
      await prefs.setBool('seen2', true);
      _speak(
          'مرحبًا بك في صفحة، رؤيا، في هذه الصفحة ستجد عدة نصوصٍ من كتبٍ مختلفة، لتستمع اليها. اليك كيف تستعملها.  النصوص متوفرة في شاشتك مثل البطاقات، للتنقل من نصٍّ الى اخر، قم بِالسَّحْبِ اُفُقِيَّا مرَّةً على حِدَا و سنقرأ لك الفئة الموافقة. لاِختيار فئة، يكفي اَنْ تَنْقُرَ على الشاشة مرَّةً واحدةً و ستبدأ قراءة النص. يمكنك التَّسريع اِلى الاَمام عبر السَّحْبِ اِلى الاَسفل اَو العودةِ اِلى الوراءِ عَبر السَّحْبِ اِلى الاَعلى. لاِيقاف القِرائة يَكفي اَن تَنقر مَرة ثانيةً عَلى الشاشة. وَ طَبعاً كَكُلِّ مَرة اَذا نَسِيت اَي شيئ هُزَّ الهَاتف و سَنُذَكِّرُكَ');

      //home audio(simple hello)
    }
  }

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
  bool check = false;
  FlutterTts flutterTts;
  @override
  void initState() {
    super.initState();
    initTts();
    initAudioPlayers();
  }

  initAudioPlayers() async {
    for (var i = 0; i < 3; i++) {
      await audioplayers[i].setUrl(urls[i]);

      //-----------------------------------
    }
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

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(word);
  }

  List<String> urls = [
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/text1.aac?alt=media&token=3abca029-ed0a-4bcf-b257-a966d98d7022',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/text2.aac?alt=media&token=5700b9f6-fced-4eb0-a3f2-081c5f14201b',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/text3.aac?alt=media&token=c511fc0b-965e-491c-b283-50ffd880e9f7',
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
//play
      audioPlayer.setVolume(10);
      var res = await audioplayers[index].play(urls[index], isLocal: true);
      if (res == 1) {
        setState(() {
          playing = true;
        });
      } else {
        _speak('جاري تحميل الاوديو');
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
  }


  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }
void afterFirstLayout(BuildContext context) => checkFirstSeen();
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
              _speak('واحد');
            },
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                child: GestureDetector(
                  onVerticalDragStart: (DragStartDetails details) {
                    initial = details.globalPosition.dy;
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
                      color: Colors.amber),
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
