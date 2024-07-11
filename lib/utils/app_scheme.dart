import 'package:appscheme/appscheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import '../http/search.dart';
import '../models/common/search_type.dart';
import 'id_utils.dart';
import 'url_utils.dart';
import 'utils.dart';

class PiliScheme {
  static AppScheme appScheme = AppSchemeImpl.getInstance()!;
  static Future<void> init() async {
    ///
    final SchemeEntity? value = await appScheme.getInitScheme();
    if (value != null) {
      routePush(value);
    }

    /// 完整链接进入 b23.无效
    appScheme.getLatestScheme().then((SchemeEntity? value) {
      if (value != null) {
        routePush(value);
      }
    });

    /// 注册从外部打开的Scheme监听信息 #
    appScheme.registerSchemeListener().listen((SchemeEntity? event) {
      if (event != null) {
        routePush(event);
      }
    });
  }

  static SchemeEntity stringToSchemeEntity(String dataString) {
    Uri uri = Uri.parse(dataString);
    Map<String, String>? queryParams =
        uri.query.isNotEmpty ? Uri.splitQueryString(uri.query) : null;
    return SchemeEntity(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
      query: queryParams,
      source: dataString,
      dataString: dataString,
    );
  }

  /// 路由跳转
  static void routePush(SchemeEntity value) async {
    final String scheme = value.scheme!;
    final String host = value.host!;
    final String path = value.path!;

    if (scheme == 'bilibili') {
      if (host == 'root') {
        Navigator.popUntil(
            Get.context!, (Route<dynamic> route) => route.isFirst);
      } else if (host == 'space') {
        final String mid = path.split('/').last;
        Get.toNamed<dynamic>(
          '/member?mid=$mid',
          arguments: <String, dynamic>{'face': null},
        );
      } else if (host == 'video') {
        String pathQuery = path.split('/').last;
        final numericRegex = RegExp(r'^[0-9]+$');
        if (numericRegex.hasMatch(pathQuery)) {
          pathQuery = 'AV$pathQuery';
        }
        Map map = IdUtils.matchAvorBv(input: pathQuery);
        if (map.containsKey('AV')) {
          videoPush(map['AV'], null);
        } else if (map.containsKey('BV')) {
          videoPush(null, map['BV']);
        } else {
          SmartDialog.showToast('投稿匹配失败');
        }
      } else if (host == 'live') {
        final String roomId = path.split('/').last;
        Get.toNamed<dynamic>('/liveRoom?roomid=$roomId',
            arguments: <String, String?>{'liveItem': null, 'heroTag': roomId});
      } else if (host == 'bangumi') {
        if (path.startsWith('/season')) {
          final String seasonId = path.split('/').last;
          bangumiPush(int.parse(seasonId), null);
        }
      } else if (host == 'opus') {
        if (path.startsWith('/detail')) {
          var opusId = path.split('/').last;
          Get.toNamed(
            '/webview',
            parameters: {
              'url': 'https://www.bilibili.com/opus/$opusId',
              'type': 'url',
              'pageTitle': '',
            },
          );
        }
      } else if (host == 'search') {
        Get.toNamed('/searchResult', parameters: {'keyword': ''});
      } else if (host == 'article') {
        final String id = path.split('/').last.split('?').first;
        Get.toNamed(
          '/htmlRender',
          parameters: {
            'url': 'www.bilibili.com/read/cv$id',
            'title': '',
            'id': 'cv$id',
            'dynamicType': 'read'
          },
        );
      } else if (host == 'following' && path.startsWith("/detail/")) {
        var opusId = path.split('/').last;
        Get.toNamed(
          '/webview',
          parameters: {
            'url': 'https://www.bilibili.com/opus/$opusId',
            'type': 'url',
            'pageTitle': '',
          },
        );
      } else {
        print(value.dataString);
        SmartDialog.showToast('未知路径:${value.dataString}，请截图反馈给开发者');
        // Get.toNamed(
        //   '/webview',
        //   parameters: {
        //     'url': value.dataString ?? "",
        //     'type': 'url',
        //     'pageTitle': ''
        //   },
        // );
      }
    } else if (scheme == 'https') {
      fullPathPush(value);
    }
  }

  // 投稿跳转
  static Future<void> videoPush(int? aidVal, String? bvidVal) async {
    SmartDialog.showLoading<dynamic>(msg: '获取中...');
    try {
      int? aid = aidVal;
      String? bvid = bvidVal;
      if (aidVal == null) {
        aid = IdUtils.bv2av(bvidVal!);
      }
      if (bvidVal == null) {
        bvid = IdUtils.av2bv(aidVal!);
      }
      final int cid = await SearchHttp.ab2c(bvid: bvidVal, aid: aidVal);
      final String heroTag = Utils.makeHeroTag(aid);
      SmartDialog.dismiss<dynamic>().then(
        // ignore: always_specify_types
        (e) => Get.toNamed<dynamic>('/video?bvid=$bvid&cid=$cid',
            arguments: <String, String?>{
              'pic': null,
              'heroTag': heroTag,
            }),
      );
    } catch (e) {
      SmartDialog.showToast('video获取失败: $e');
    }
  }

  // 番剧跳转
  static Future<void> bangumiPush(int? seasonId, int? epId) async {
    print('seasonId: $seasonId, epId: $epId');
    SmartDialog.showLoading<dynamic>(msg: '获取中...');
    try {
      var result = await SearchHttp.bangumiInfo(seasonId: seasonId, epId: epId);
      if (result['status']) {
        var bangumiDetail = result['data'];
        final int cid = bangumiDetail.episodes!.first.cid;
        final String bvid = IdUtils.av2bv(bangumiDetail.episodes!.first.aid);
        final String heroTag = Utils.makeHeroTag(cid);
        var epId = bangumiDetail.episodes!.first.id;
        SmartDialog.dismiss().then(
          (e) => Get.toNamed(
            '/video?bvid=$bvid&cid=$cid&epId=$epId',
            arguments: <String, dynamic>{
              'pic': bangumiDetail.cover,
              'heroTag': heroTag,
              'videoType': SearchType.media_bangumi,
            },
          ),
        );
      } else {
        SmartDialog.showToast(result['msg']);
      }
    } catch (e) {
      SmartDialog.showToast('番剧获取失败：$e');
    }
  }

  static Future<void> fullPathPush(SchemeEntity value) async {
    // https://m.bilibili.com/bangumi/play/ss39708
    // https | m.bilibili.com | /bangumi/play/ss39708
    // final String scheme = value.scheme!;
    final String host = value.host!;
    final String? path = value.path;
    Map<String, String>? query = value.query;
    RegExp regExp = RegExp(r'^((www\.)|(m\.))?bilibili\.com$');
    if (regExp.hasMatch(host)) {
      print('bilibili.com');
    } else if (host.contains('live')) {
      int roomId = int.parse(path!.split('/').last);
      Get.toNamed(
        '/liveRoom?roomid=$roomId',
        arguments: {'liveItem': null, 'heroTag': roomId.toString()},
      );
      return;
    } else if (host.contains('space')) {
      var mid = path!.split('/').last;
      Get.toNamed('/member?mid=$mid', arguments: {'face': ''});
      return;
    } else if (host == 'b23.tv') {
      final String fullPath = 'https://$host$path';
      final String redirectUrl = await UrlUtils.parseRedirectUrl(fullPath);
      final String pathSegment = Uri.parse(redirectUrl).path;
      final String lastPathSegment = pathSegment.split('/').last;
      final RegExp avRegex = RegExp(r'^[aA][vV]\d+', caseSensitive: false);
      if (avRegex.hasMatch(lastPathSegment)) {
        final Map<String, dynamic> map =
            IdUtils.matchAvorBv(input: lastPathSegment);
        if (map.containsKey('AV')) {
          videoPush(map['AV']! as int, null);
        } else if (map.containsKey('BV')) {
          videoPush(null, map['BV'] as String);
        } else {
          SmartDialog.showToast('投稿匹配失败');
        }
      } else if (lastPathSegment.startsWith('ep')) {
        handleEpisodePath(lastPathSegment, redirectUrl);
      } else if (lastPathSegment.startsWith('ss')) {
        handleSeasonPath(lastPathSegment, redirectUrl);
      } else if (lastPathSegment.startsWith('BV')) {
        UrlUtils.matchUrlPush(
          lastPathSegment,
          '',
          redirectUrl,
        );
      } else {
        Get.toNamed(
          '/webview',
          parameters: {'url': redirectUrl, 'type': 'url', 'pageTitle': ''},
        );
      }
      return;
    }

    if (path != null) {
      List<String> pathPart = path.split('/');
      final String area = pathPart[1] == 'mobile' ? pathPart[2] : pathPart[1];
      switch (area) {
        case 'bangumi':
          print('番剧');
          for (var pathSegment in pathPart) {
            if (pathSegment.startsWith('ss')) {
              print(pathSegment);
              bangumiPush(matchNum(pathSegment).first, null);
              break;
            } else if (pathSegment.startsWith('ep')) {
              print(pathSegment);
              bangumiPush(null, matchNum(pathSegment).first);
              break;
            }
          }
          break;
        case 'video':
          print('投稿');
          final Map<String, dynamic> map = IdUtils.matchAvorBv(input: path);
          if (map.containsKey('AV')) {
            videoPush(map['AV']! as int, null);
          } else if (map.containsKey('BV')) {
            videoPush(null, map['BV'] as String);
          } else {
            SmartDialog.showToast('投稿匹配失败');
          }
          break;
        case 'read':
          print('专栏');
          late String id;
          if (query != null && query['id'] != null) {
            id = 'cv${matchNum(query['id']!).first}';
          } else {
            id = 'cv${matchNum(path).first}';
          }
          Get.toNamed('/htmlRender', parameters: {
            'url': value.dataString!,
            'title': '',
            'id': id,
            'dynamicType': 'read'
          });
          break;
        case 'space':
          print('个人空间');
          Get.toNamed('/member?mid=$area', arguments: {'face': ''});
          break;
        default:
          var res = IdUtils.matchAvorBv(input: area.split('?').first);
          if (res.containsKey('AV')) {
            videoPush(res['AV']! as int, null);
          } else if (res.containsKey('BV')) {
            videoPush(null, res['BV'] as String);
          } else {
            SmartDialog.showToast('未知路径或匹配错误:${value.dataString}，先采用浏览器打开');
            Get.toNamed(
              '/webview',
              parameters: {
                'url': value.dataString ?? "",
                'type': 'url',
                'pageTitle': ''
              },
            );
          }
      }
    }
  }

  static List<int> matchNum(String str) {
    final RegExp regExp = RegExp(r'\d+');
    final Iterable<Match> matches = regExp.allMatches(str);

    return matches.map((Match match) => int.parse(match.group(0)!)).toList();
  }

  static void handleEpisodePath(String lastPathSegment, String redirectUrl) {
    final String seasonId = extractIdFromPath(lastPathSegment);
    bangumiPush(null, matchNum(seasonId).first);
  }

  static void handleSeasonPath(String lastPathSegment, String redirectUrl) {
    final String seasonId = extractIdFromPath(lastPathSegment);
    bangumiPush(matchNum(seasonId).first, null);
  }

  static String extractIdFromPath(String lastPathSegment) {
    return lastPathSegment.split('/').last;
  }
}
