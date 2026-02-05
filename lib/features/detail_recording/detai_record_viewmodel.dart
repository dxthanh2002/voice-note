import 'dart:async';
import 'dart:io';

import 'package:aimateflutter/services/database.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../services/data/recordings.dart';
import '../../services/recording.dart';
import '../../utils/console.dart';

class DetailRecordViewModel extends ChangeNotifier {
  final String? id;

  // Reactive state using ValueNotifier
  final ValueNotifier<Recording?> _meetingInfo = ValueNotifier(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier(0);
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _duration = ValueNotifier(Duration.zero);

  // Non-reactive state
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _tabs = ['Transcript', 'Summary']; // TODO: Add 'Chat AI'
  Timer? _debounceTimer;

  // Getters
  Recording? get meetingInfo => _meetingInfo.value;
  bool get isLoading => _isLoading.value;
  int get selectedTabIndex => _selectedTabIndex.value;
  bool get isPlaying => _isPlaying.value;
  Duration get position => _position.value;
  Duration get duration => _duration.value;
  List<String> get tabs => _tabs;
  AudioPlayer get audioPlayer => _audioPlayer;

  DetailRecordViewModel({this.id}) {
    // Setup ValueNotifier listeners
    _meetingInfo.addListener(notifyListeners);
    _isLoading.addListener(notifyListeners);
    _selectedTabIndex.addListener(notifyListeners);
    _isPlaying.addListener(notifyListeners);
    _position.addListener(notifyListeners);
    _duration.addListener(notifyListeners);

    // Setup audio player listeners
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying.value = state.playing;
    });

    _audioPlayer.positionStream.listen((pos) {
      _position.value = pos;
    });

    _audioPlayer.durationStream.listen((dur) {
      _duration.value = dur ?? Duration.zero;
    });
  }

  Future<void> loadMeetingInfo() async {
    try {
      Console.log("Loading meeting detail for ID: ${id ?? 'null'}");

      if (id != null) {
        final recording = await DatabaseService().getRecording(id!);
        _meetingInfo.value = recording;

        if (recording?.filePath != null) {
          await _initAudioPlayer(recording!.filePath);
          // await _initAudioPlayer(response.audio!.playUrl);
        } else {
          Console.warning('No audio PATH available for this meeting');
        }
      }

      _isLoading.value = false;
    } catch (e) {
      debugPrint('Failed to load meeting: $e');
      _isLoading.value = false;
    }
  }

  Future<void> _initAudioPlayer(String filePath) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (await file.exists()) {
        await _audioPlayer.setFilePath(filePath);
        Console.log('Audio player initialized with local file: $filePath');
      }
    } catch (e) {
      Console.error('Error initializing audio player from path: $e');
    }
  }

  void selectTab(int index) {
    _selectedTabIndex.value = index;
  }

  void togglePlayPause() {
    if (_isPlaying.value) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void seekAudio(double progress) {
    final total = _duration.value.inMilliseconds > 0
        ? _duration.value
        : Duration(seconds: meetingInfo?.duration ?? 0);
    final newPosition = Duration(
      milliseconds: (progress * total.inMilliseconds).round(),
    );
    _audioPlayer.seek(newPosition);
  }

  void rewindAudio() {
    final newPosition = _position.value - const Duration(seconds: 10);
    _audioPlayer.seek(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
  }

  void forwardAudio() {
    final total = _duration.value.inMilliseconds > 0
        ? _duration.value
        : Duration(seconds: meetingInfo?.duration ?? 0);
    final newPosition = _position.value + const Duration(seconds: 10);
    _audioPlayer.seek(newPosition > total ? total : newPosition);
  }

  Future<void> deleteRecording(BuildContext context) async {
    if (meetingInfo == null) return;

    await RecordingService.deleteRecording(
      context,
      meetingInfo!.meetingId,
      refresh: false,
    );
  }

  Future<void> renameRecording(BuildContext context) async {
    if (meetingInfo == null) return;

    await RecordingService.renameRecording(
      context,
      meetingInfo!.meetingId,
      meetingInfo!.title,
      refresh: false,
    );

    await loadMeetingInfo();
  }

  void onNavigateBack(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300));
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    // Cancel timers
    _debounceTimer?.cancel();

    // Dispose ValueNotifiers
    _meetingInfo.dispose();
    _isLoading.dispose();
    _selectedTabIndex.dispose();
    _isPlaying.dispose();
    _position.dispose();
    _duration.dispose();

    // Dispose audio player
    _audioPlayer.dispose();

    super.dispose();
  }
}
