// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/pages/msg_feed_top/at_me/view.dart';
import 'package:PiliPalaX/pages/msg_feed_top/reply_me/view.dart';
import 'package:PiliPalaX/pages/msg_feed_top/like_me/view.dart';
import 'package:PiliPalaX/pages/follow_search/view.dart';
import 'package:PiliPalaX/pages/setting/pages/logs.dart';

import '../pages/about/index.dart';
import '../pages/blacklist/index.dart';
import '../pages/danmaku_block/index.dart';
import '../pages/dynamics/detail/index.dart';
import '../pages/dynamics/index.dart';
import '../pages/fan/index.dart';
import '../pages/fav/index.dart';
import '../pages/fav_detail/index.dart';
import '../pages/fav_search/index.dart';
import '../pages/follow/index.dart';
import '../pages/history/index.dart';
import '../pages/history_search/index.dart';
import '../pages/home/index.dart';
import '../pages/hot/index.dart';
import '../pages/html/index.dart';
import '../pages/later/index.dart';
import '../pages/live_room/view.dart';
import '../pages/login/index.dart';
import '../pages/media/index.dart';
import '../pages/member/index.dart';
import '../pages/member_coin/index.dart';
import '../pages/member_like/index.dart';
import '../pages/member_search/index.dart';
import '../pages/member_season/view.dart';
import '../pages/member_series/view.dart';
import '../pages/msg_feed_top/sys_msg/view.dart';
import '../pages/rank/view.dart';
import '../pages/rank/zone/view.dart';
import '../pages/search/index.dart';
import '../pages/search_result/index.dart';
import '../pages/setting/extra_setting.dart';
import '../pages/setting/index.dart';
import '../pages/setting/pages/color_select.dart';
import '../pages/setting/pages/display_mode.dart';
import '../pages/setting/pages/font_size_select.dart';
import '../pages/setting/pages/gesture_select.dart';
import '../pages/setting/pages/home_tabbar_set.dart';
import '../pages/setting/pages/play_speed_set.dart';
import '../pages/setting/recommend_setting.dart';
import '../pages/setting/play_setting.dart';
import '../pages/setting/video_setting.dart';
import '../pages/setting/privacy_setting.dart';
import '../pages/setting/style_setting.dart';
import '../pages/setting/hidden_settings.dart';
import '../pages/subscription/index.dart';
import '../pages/subscription_detail/index.dart';
import '../pages/video/index.dart';
import '../pages/video/reply_reply/index.dart';
import '../pages/webview/index.dart';
import '../pages/whisper/index.dart';
import '../pages/whisper_detail/index.dart';
import '../utils/storage.dart';

Box<dynamic> setting = GStorage.setting;

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    // 首页(推荐)
    CustomGetPage(name: '/', page: () => const HomePage()),
    // 热门
    CustomGetPage(name: '/hot', page: () => const HotPage()),
    // 视频详情
    CustomGetPage(name: '/video', page: () => const VideoDetailPage()),
    // 图片预览
    // GetPage(
    //   name: '/preview',
    //   page: () => const ImagePreview(),
    //   transition: Transition.fade,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   showCupertinoParallax: false,
    // ),
    //
    CustomGetPage(name: '/webview', page: () => const WebviewPage()),
    // 设置
    CustomGetPage(name: '/setting', page: () => const SettingPage()),
    //
    CustomGetPage(name: '/media', page: () => const MediaPage()),
    //
    CustomGetPage(name: '/fav', page: () => const FavPage()),
    //
    CustomGetPage(name: '/favDetail', page: () => const FavDetailPage()),
    // 稍后再看
    CustomGetPage(name: '/later', page: () => const LaterPage()),
    // 历史记录
    CustomGetPage(name: '/history', page: () => const HistoryPage()),
    // 搜索页面
    CustomGetPage(name: '/search', page: () => const SearchPage()),
    // 搜索结果
    CustomGetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 动态
    CustomGetPage(name: '/dynamics', page: () => const DynamicsPage()),
    // 动态详情
    CustomGetPage(
        name: '/dynamicDetail', page: () => const DynamicDetailPage()),
    // 关注
    CustomGetPage(name: '/follow', page: () => const FollowPage()),
    // 粉丝
    CustomGetPage(name: '/fan', page: () => const FansPage()),
    // 直播详情
    CustomGetPage(name: '/liveRoom', page: () => const LiveRoomPage()),
    // 用户中心
    CustomGetPage(name: '/member', page: () => const MemberPage()),
    CustomGetPage(name: '/memberSearch', page: () => const MemberSearchPage()),
    // 二级回复
    CustomGetPage(
        name: '/replyReply', page: () => const VideoReplyReplyPanel()),
    // 推荐流设置
    CustomGetPage(
        name: '/recommendSetting', page: () => const RecommendSetting()),
    // 音视频设置
    CustomGetPage(name: '/videoSetting', page: () => const VideoSetting()),
    // 播放器设置
    CustomGetPage(name: '/playSetting', page: () => const PlaySetting()),
    // 外观设置
    CustomGetPage(name: '/styleSetting', page: () => const StyleSetting()),
    // 隐私设置
    CustomGetPage(name: '/privacySetting', page: () => const PrivacySetting()),
    // 其它设置
    CustomGetPage(name: '/extraSetting', page: () => const ExtraSetting()),
    //
    CustomGetPage(name: '/blackListPage', page: () => const BlackListPage()),
    CustomGetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    CustomGetPage(name: '/gestureSetting', page: () => const GestureSelectPage()),
    // 开发人员选项
    CustomGetPage(name: '/hiddenSetting', page: () => const HiddenSetting()),
    // 首页tabbar
    CustomGetPage(name: '/tabbarSetting', page: () => const TabbarSetPage()),
    CustomGetPage(
        name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    // 屏幕帧率
    CustomGetPage(
        name: '/displayModeSetting', page: () => const SetDisplayMode()),
    // 关于
    CustomGetPage(name: '/about', page: () => const AboutPage()),
    //
    CustomGetPage(name: '/htmlRender', page: () => const HtmlRenderPage()),
    // 历史记录搜索
    CustomGetPage(
        name: '/historySearch', page: () => const HistorySearchPage()),

    CustomGetPage(name: '/playSpeedSet', page: () => const PlaySpeedPage()),
    // 收藏搜索
    CustomGetPage(name: '/favSearch', page: () => const FavSearchPage()),
    // 消息页面
    CustomGetPage(name: '/whisper', page: () => const WhisperPage()),
    // 私信详情
    CustomGetPage(
        name: '/whisperDetail', page: () => const WhisperDetailPage()),
    // 回复我的
    CustomGetPage(name: '/replyMe', page: () => const ReplyMePage()),
    // @我的
    CustomGetPage(name: '/atMe', page: () => const AtMePage()),
    // 收到的赞
    CustomGetPage(name: '/likeMe', page: () => const LikeMePage()),
    // 系统消息
    CustomGetPage(name: '/sysMsg', page: () => const SysMsgPage()),
    // 登录页面
    CustomGetPage(name: '/loginPage', page: () => const LoginPage()),
    // 用户动态
    // CustomGetPage(
    //     name: '/memberDynamics', page: () => const MemberDynamicsPage()),
    // 用户投稿
    // CustomGetPage(
    //     name: '/memberArchive', page: () => const MemberArchivePage()),
    // 用户最近投币
    CustomGetPage(name: '/memberCoin', page: () => const MemberCoinPage()),
    // 用户最近喜欢
    CustomGetPage(name: '/memberLike', page: () => const MemberLikePage()),
    // 用户专栏
    // CustomGetPage(
    //     name: '/memberSeasons', page: () => const MemberSeasonsPage()),
    CustomGetPage(name: '/memberSeason', page: () => const MemberSeasonPage()),

    CustomGetPage(name: '/memberSeries', page: () => const MemberSeriesPage()),
    // 日志
    CustomGetPage(name: '/logs', page: () => const LogsPage()),
    // 搜索关注
    CustomGetPage(name: '/followSearch', page: () => const FollowSearchPage()),
    // 订阅
    CustomGetPage(name: '/subscription', page: () => const SubPage()),
    // 订阅详情
    CustomGetPage(name: '/subDetail', page: () => const SubDetailPage()),
    // 弹幕屏蔽管理
    CustomGetPage(name: '/danmakuBlock', page: () => const DanmakuBlockPage()),
  ];
}

class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.transitionDuration,
  }) : super(
          curve: Curves.linear,
          transition: Transition.native,
          showCupertinoParallax: false,
          popGesture: false,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
  bool? fullscreen = false;
}
