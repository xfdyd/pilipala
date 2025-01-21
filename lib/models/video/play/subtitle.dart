enum SubtitlePreference { off, on, withoutAi }

extension SubtitlePreferenceDesc on SubtitlePreference {
  static final List<String> _descList = [
    '默认不显示字幕',
    '默认显示，优先选择非自动生成(ai)字幕',
    '默认仅显示非自动生成(ai)字幕',
  ];
  get description => _descList[index];
}

extension SubtitlePreferenceCode on SubtitlePreference {
  static final List<String> _codeList = ['off', 'on', 'withoutAi'];
  get code => _codeList[index];

  static SubtitlePreference? fromCode(String code) {
    final index = _codeList.indexOf(code);
    if (index != -1) {
      return SubtitlePreference.values[index];
    }
    return null;
  }
}
