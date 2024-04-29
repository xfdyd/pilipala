// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/init.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/pages/home/index.dart';
import 'package:PiliPalaX/pages/media/index.dart';
import 'package:PiliPalaX/utils/cookie.dart';
import 'package:PiliPalaX/utils/event_bus.dart';
import 'package:PiliPalaX/utils/id_utils.dart';
import 'package:PiliPalaX/utils/login.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewController extends GetxController {
  String url = '';
  RxString type = ''.obs;
  String pageTitle = '';
  final WebViewController controller = WebViewController();
  RxInt loadProgress = 0.obs;
  RxBool loadShow = true.obs;
  EventBus eventBus = EventBus();

  @override
  void onInit() {
    super.onInit();
    url = Get.parameters['url']!;
    type.value = Get.parameters['type']!;
    pageTitle = Get.parameters['pageTitle']!;

    if (type.value == 'login') {
      controller.clearCache();
      controller.clearLocalStorage();
      WebViewCookieManager().clearCookies();
    }
    webviewInit();
  }

  webviewInit({String uaType = 'mob'}) {
    controller
      ..setUserAgent(Request().headerUa(type: uaType))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          // 页面加载
          onProgress: (int progress) {
            // Update loading bar.
            loadProgress.value = progress;
          },
          onPageStarted: (String url) {
            final parseUrl = Uri.parse(url);
            if (parseUrl.pathSegments.isEmpty) return;
            final String str = parseUrl.pathSegments[0];
            final Map matchRes = IdUtils.matchAvorBv(input: str);
            final List matchKeys = matchRes.keys.toList();
            if (matchKeys.isNotEmpty) {
              if (matchKeys.first == 'BV') {
                Get.offAndToNamed(
                  '/searchResult',
                  parameters: {'keyword': matchRes['BV']},
                );
              }
            }
          },
          onPageFinished: (String url) {
            if (type.value == 'liveRoom') {
              print("adding");
              //注入js
              controller.runJavaScriptReturningResult('''
                document.styleSheets[0].insertRule('div.open-app-btn.bili-btn-warp {display:none;}', 0);
                document.styleSheets[0].insertRule('#app__display-area > div.control-panel {display:none;}', 0);
                ''').then((value) => print(value));
            } else if (type.value == 'whisper') {
              controller.runJavaScriptReturningResult('''
                document.querySelector('#internationalHeader').remove();
                document.querySelector('#message-navbar').remove();
              ''').then((value) => print(value));
            }
          },
          // 加载完成
          onUrlChange: (UrlChange urlChange) async {
            loadShow.value = false;
            String url = urlChange.url ?? '';
            if (type.value == 'login' &&
                (url.startsWith(
                        'https://passport.bilibili.com/web/sso/exchange_cookie') ||
                    url.startsWith('https://m.bilibili.com/'))) {
              confirmLogin(url);
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('bilibili://')) {
              if (request.url.startsWith('bilibili://video/')) {
                String str = Uri.parse(request.url).pathSegments[0];
                Get.offAndToNamed(
                  '/searchResult',
                  parameters: {'keyword': str},
                );
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  confirmLogin(url) async {
    var content = '';
    if (url != null) {
      content = '${content + url}; \n';
    }
    try {
      await CookieTool.onSet();
      final result = await UserHttp.userInfo();
      if (result['status'] && result['data'].isLogin) {
        SmartDialog.showToast('登录成功，当前采用「'
            '${GStrorage.setting.get(SettingBoxKey.defaultRcmdType, defaultValue: 'web')}'
            '端」推荐');
        try {
          Box userInfoCache = GStrorage.userInfo;
          await userInfoCache.put('userInfoCache', result['data']);

          final HomeController homeCtr = Get.find<HomeController>();
          homeCtr.updateLoginStatus(true);
          homeCtr.userFace.value = result['data'].face;
          final MediaController mediaCtr = Get.find<MediaController>();
          mediaCtr.mid = result['data'].mid;
          await LoginUtils.refreshLoginStatus(true);
        } catch (err) {
          SmartDialog.show(builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('登录遇到问题'),
              content: Text(err.toString()),
              actions: [
                TextButton(
                  onPressed: () => controller.reload(),
                  child: const Text('确认'),
                )
              ],
            );
          });
        }
        Get.back();
      } else {
        // 获取用户信息失败
        SmartDialog.showToast(result['msg']);
        Clipboard.setData(ClipboardData(text: result['msg']));
      }
    } catch (e) {
      SmartDialog.showNotify(msg: e.toString(), notifyType: NotifyType.warning);
      content = content + e.toString();
      Clipboard.setData(ClipboardData(text: content));
    }
  }
}
