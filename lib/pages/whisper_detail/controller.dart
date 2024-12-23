import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/msg.dart';
import 'package:PiliPalaX/models/msg/session.dart';
import '../../utils/feed_back.dart';
import '../../utils/storage.dart';

class WhisperDetailController extends GetxController {
  late int talkerId;
  late String name;
  late String face;
  late String mid;
  RxList<MessageItem> messageList = <MessageItem>[].obs;
  //表情转换图片规则
  List<dynamic>? eInfos;
  final TextEditingController replyContentController = TextEditingController();
  Box userInfoCache = GStorage.userInfo;

  @override
  void onInit() {
    super.onInit();
    talkerId = int.parse(Get.parameters['talkerId']!);
    name = Get.parameters['name']!;
    face = Get.parameters['face']!;
    mid = Get.parameters['mid']!;
  }

  Future querySessionMsg() async {
    var res = await MsgHttp.sessionMsg(talkerId: talkerId);
    if (res['status']) {
      messageList.value = res['data'].messages;
      if (messageList.isNotEmpty) {
        if (messageList.length == 1 &&
            messageList.last.msgType == 18 &&
            messageList.last.msgSource == 18) {
          // print(messageList.last);
          // print(messageList.last.content);
          //{content: [{"text":"对方主动回复或关注你前，最多发送1条消息","color_day":"#9499A0","color_nig":"#9499A0"}]}
        } else {
          ackSessionMsg();
        }
        if (res['data'].eInfos != null) {
          eInfos = res['data'].eInfos;
        }
      }
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // 消息标记已读
  Future ackSessionMsg() async {
    if (messageList.isEmpty) {
      return;
    }
    var res = await MsgHttp.ackSessionMsg(
      talkerId: talkerId,
      ackSeqno: messageList.last.msgSeqno,
    );
    if (!res['status']) {
      SmartDialog.showToast(res['msg']);
    }
  }

  Future sendMsg() async {
    feedBack();
    String message = replyContentController.text;
    final userInfo = userInfoCache.get('userInfoCache');
    if (userInfo == null) {
      SmartDialog.showToast('请先登录');
      return;
    }
    if (message == '') {
      SmartDialog.showToast('请输入内容');
      return;
    }
    if (mid == '') {
      SmartDialog.showToast('这里不能发');
      return;
    }
    var result = await MsgHttp.sendMsg(
      senderUid: userInfo.mid,
      receiverId: int.parse(mid),
      content: '{"content":"$message"}',
      msgType: 1,
    );
    if (result['status']) {
      print(result['data']);
      querySessionMsg();
      replyContentController.text = "";
      SmartDialog.showToast('发送成功');
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }
}
