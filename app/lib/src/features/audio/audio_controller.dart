import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bossa/src/features/files/load_controller.dart';
import 'package:flutter/foundation.dart';

enum AudioStyle {modern, classic}

class AudioNotifier extends ChangeNotifier{
  LoadNotifier loadNotifier;
  final AudioPlayer _advancedPlayer = AudioPlayer();
  List _indexes = [];
  List _oldIndexes = [];
  final Random _random = Random(69);

  AudioStyle _audioStyle = AudioStyle.modern;  
  AudioStyle get audioStyle => _audioStyle;

  List<List<dynamic>> _songs = [[]];
  List<List<dynamic>> get songs => _songs;

  int _index = 0;
  int get index => _index;

  Duration _duration = const Duration();
  Duration get duration => _duration;

  Duration _position = const Duration();
  Duration get position => _position;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isRandom = false;
  bool get isRandom => _isRandom;

  bool _isRepeat = false;
  bool get isRepeat => _isRepeat;

  double _sliderValue = 0;
  double get sliderValue => _sliderValue;

  AudioNotifier({required this.loadNotifier}) {
    load();
    _advancedPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });
    _advancedPlayer.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });
    _advancedPlayer.onPlayerComplete.listen((event) {
      if ((_duration.inSeconds >= _position.inSeconds) && _position.inSeconds > 0) {
        onEnd();
      }
    });
  }

  void changeStyle(AudioStyle style){
    _audioStyle = style;
    notifyListeners();
  }

  void load() async {
    _songs = await loadNotifier.loadSongs();
    if(_songs != []){
      onStart();
    }
    notifyListeners();
  }

  void changeIndex(int newIndex){
    _index = newIndex;
    notifyListeners();
  }

  void start({bool? play}) {
    if (play != null){ _isPlaying = play;}
    if (isPlaying) {
      _advancedPlayer.pause();
    } else {
      _advancedPlayer.play(DeviceFileSource(songs[index][3]));
    }
    _isPlaying = !isPlaying;
    notifyListeners();
  }

  void random() {
    _isRandom = !isRandom;
    _advancedPlayer.setPlaybackRate(1);
    notifyListeners();
  }

  void repeat() {
    _isRepeat = !isRepeat;
    _advancedPlayer.setReleaseMode((_isRepeat ? ReleaseMode.loop : ReleaseMode.release));
    notifyListeners();
  }

  void previous(){
    if (_oldIndexes.isEmpty){return;}
    _index = _oldIndexes[_oldIndexes.length - 1];

    _oldIndexes.remove(index);
    if(_isRandom){_indexes.add(index);}

    _advancedPlayer.setSourceDeviceFile(songs[_index][3]);
    _advancedPlayer.stop();
    _position = const Duration();

    start(play: false);      
    Future.delayed(const Duration(milliseconds: 50), () => start(play: false));  
    notifyListeners();
  }

  void next(){
    onEnd();
  }

  void slider(double value){
    if (!isPlaying) { start(); }
    changeToSecond(value.toInt());
    _sliderValue = value;
  }
  
  void stop(){
    changeToSecond(0);    
    _position = const Duration();
    _isPlaying = false;
    _advancedPlayer.stop();
    notifyListeners();
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    _advancedPlayer.seek(newDuration);
  }
  
  void onStart(){
    _oldIndexes = [];
    _indexes = [];
    for (int i = 0; i < songs.length; i++) {
      _indexes.add(i);
    }
  }

  void onEnd(){
    if (!isRepeat) {      
      _oldIndexes.add(index);    

      if (isRandom) {
        if (_indexes.length > 1) {
          _indexes.remove(index);
          int number = _random.nextInt(_indexes.length);
          _index = _indexes[number];
        } else {
          onStart();
          _isRandom = false;
          return;
        }
      } else {
        _index = (index + 1 > songs.length - 1)
            ? songs.length - 1
            : index + 1;
      }
      _advancedPlayer.setSourceDeviceFile(songs[index][3]);
      _position = const Duration();
      start(play: false);      
      Future.delayed(const Duration(milliseconds: 50), () => start(play: false));  
    }    
  }
}