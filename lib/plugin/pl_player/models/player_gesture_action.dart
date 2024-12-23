enum PlayerGestureAction {
  none,
  toggleFullScreen,
  pipInside,
  pipOutside,
  backToHome,
}

extension PlayerGestureActionDesc on PlayerGestureAction {
  String get description => ['无', '进入/退出全屏', '应用内小窗', '应用外小窗', '返回主页'][index];
}

extension PlayerGestureActionCode on PlayerGestureAction {
  int get code => index;

  static PlayerGestureAction? fromCode(int code) {
    if (code >= 0 && code < PlayerGestureAction.values.length) {
      return PlayerGestureAction.values[code];
    }
    return null;
  }
}
