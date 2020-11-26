import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
    AudioPlayer(playerId: 'forth')
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
    for (var i = 0; i < 4; i++) {
      audioplayers[i].setUrl(urls[i]);

      //-----------------------------------
    }
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar-AE");

    flutterTts.setStartHandler(() {
      setState(() {
        //print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        //print("Complete");
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
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/sample.mp3?alt=media&token=37199f5a-4235-46c5-839b-98215ba3d19d',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/test.mp3?alt=media&token=a7c98dfe-f1f4-4c3c-a8b1-c10d765d4d6b',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/sample.mp3?alt=media&token=37199f5a-4235-46c5-839b-98215ba3d19d',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/test.mp3?alt=media&token=a7c98dfe-f1f4-4c3c-a8b1-c10d765d4d6b'
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

  num mapNumRange(num n, num inMin, num inMax, num outMin, num outMax) {
    return ((n - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
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
              _speak('$index');
            },
          ),
          itemCount: 4,
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
