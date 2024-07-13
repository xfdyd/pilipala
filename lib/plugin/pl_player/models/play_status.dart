import 'package:get/get.dart';

enum PlayerStatus { completed, playing, paused, none }

class PlPlayerStatus {
  Rx<PlayerStatus> status = Rx(PlayerStatus.none);

  bool get none {
    return status.value == PlayerStatus.none;
  }

  bool get playing {
    return status.value == PlayerStatus.playing;
  }

  bool get paused {
    return status.value == PlayerStatus.paused;
  }

  bool get completed {
    return status.value == PlayerStatus.completed;
  }
}
