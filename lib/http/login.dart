import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import '../common/constants.dart';
import '../models/login/index.dart';
import '../utils/utils.dart';
import 'index.dart';

class LoginHttp {
  static String deviceId = genDeviceId();
  static String buvid = genBuvid();
  static String host = 'passport.bilibili.com';
  static String traceId =
      '11111111111111111111111111111111:1111111111111111:0:0';
  static String statistics = Uri.encodeComponent(
      '{"appId": 5,"platform": 3,"version": "1.46.2","abtest": ""}');
  static String userAgent =
      'Mozilla/5.0 BiliDroid/1.46.2 (bbcallen@gmail.com) os/android model/vivo mobi_app/android_hd build/1462100 channel/yingyongbao innerVer/1462100 osVer/14 network/2';
  static Future<Map<String, dynamic>> getHDcode() async {
    var params = {
      'appkey': Constants.appKey,
      // 'local_id': 'Y952A395BB157D305D8A8340FC2AAECECE17',
      'local_id': '0',
      //精确到秒的时间戳
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'platform': 'android',
      'mobi_app': 'android_hd',
    };
    String sign = Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request()
        .post(Api.getTVCode, queryParameters: {...params, 'sign': sign});
    print(res);
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future codePoll(String authCode) async {
    var params = {
      'appkey': Constants.appKey,
      'auth_code': authCode,
      'local_id': '0',
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    };
    String sign = Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request()
        .post(Api.qrcodePoll, queryParameters: {...params, 'sign': sign});
    return {
      'status': res.data['code'] == 0,
      'code': res.data['code'],
      'data': res.data['data'],
      'msg': res.data['message']
    };
  }

  static Future queryCaptcha() async {
    var res = await Request().get(Api.getCaptcha);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': CaptchaDataModel.fromJson(res.data['data']),
      };
    } else {
      return {'status': false, 'data': res.message};
    }
  }

  // 获取salt与PubKey
  static Future getWebKey() async {
    var res = await Request().get(Api.getWebKey);
    //data: {'disable_rcmd': 0, 'local_id': LoginUtils.generateBuvid()});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': {}, 'msg': res.data['message']};
    }
  }

  static Future sendSmsCode({
    required String cid,
    required String tel,
    // String? deviceTouristId,
    String? gee_challenge,
    String? gee_seccode,
    String? gee_validate,
    String? recaptcha_token,
  }) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var data = {
      'appkey': Constants.appKey,
      'build': '1462100',
      'buvid': buvid,
      'c_locale': 'zh_CN',
      'cid': cid,
      // if (deviceTouristId != null) 'device_tourist_id': deviceTouristId,
      'disable_rcmd': '0',
      if (gee_challenge != null) 'gee_challenge': gee_challenge,
      if (gee_seccode != null) 'gee_seccode': gee_seccode,
      if (gee_validate != null) 'gee_validate': gee_validate,
      'local_id': buvid,
      // https://chinggg.github.io/post/appre/
      'login_session_id':
          md5.convert(utf8.encode(buvid + timestamp.toString())).toString(),
      'mobi_app': 'android_hd',
      'platform': 'android',
      if (recaptcha_token != null) 'recaptcha_token': recaptcha_token,
      's_locale': 'zh_CN',
      'statistics': statistics,
      'tel': tel,
      'ts': (timestamp ~/ 1000).toString(),
    };
    String sign = Utils.appSign(
      data,
      Constants.appKey,
      Constants.appSec,
    );
    var headers = {
      'Host': host,
      'buvid': buvid,
      'env': 'prod',
      'app-key': 'android_hd',
      'user-agent': userAgent,
      'x-bili-trace-id': traceId,
      'x-bili-aurora-eid': '',
      'x-bili-aurora-zone': '',
      'bili-http-engine': 'cronet',
      'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
    };

    var res = await Request().post(
      Api.appSmsCode,
      data: {...data, 'sign': sign},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: headers,
      ),
    );
    print(res);
    if (res.data['code'] == 0 && res.data['data']['recaptcha_url'] == "") {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {
        'status': false,
        'code': res.data['code'],
        'msg': res.data['message'],
        'data': res.data['data']
      };
    }
  }

  // static Future getGuestId(String key) async {
  //   dynamic publicKey = RSAKeyParser().parse(key);
  //   var params = {
  //     'appkey': Constants.appKey,
  //     'build': '1462100',
  //     'buvid': buvid,
  //     'c_locale': 'zh_CN',
  //     'channel': 'yingyongbao',
  //     'deviceInfo': 'xxxxxx',
  //     'disable_rcmd': '0',
  //     'dt': Uri.encodeComponent(Encrypter(RSA(publicKey: publicKey))
  //         .encrypt(generateRandomString(16))
  //         .base64),
  //     'local_id': buvid,
  //     'mobi_app': 'android_hd',
  //     'platform': 'android',
  //     's_locale': 'zh_CN',
  //     'statistics': statistics,
  //     'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
  //   };
  //   String sign = Utils.appSign(
  //     params,
  //     Constants.appKey,
  //     Constants.appSec,
  //   );
  //   var headers = {
  //     'Host': host,
  //     'buvid': buvid,
  //     'env': 'prod',
  //     'app-key': 'android_hd',
  //     'user-agent': userAgent,
  //     'x-bili-trace-id': traceId,
  //     'x-bili-aurora-eid': '',
  //     'x-bili-aurora-zone': '',
  //     'bili-http-engine': 'cronet',
  //     'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
  //   };
  //   var res = await Request().post(Api.getGuestId,
  //       queryParameters: {...params, 'sign': sign},
  //       options: Options(
  //         contentType: Headers.formUrlEncodedContentType,
  //         headers: headers,
  //       ));
  //   print("getGuestId: $res");
  //   if (res.data['code'] == 0) {
  //     return {'status': true, 'data': res.data['data']};
  //   } else {
  //     return {'status': false, 'msg': res.data['message']};
  //   }
  // }

  static String genBuvid() {
    var mac = <String>[];
    var random = Random();

    for (var i = 0; i < 6; i++) {
      var min = 0;
      var max = 0xff;
      var num = (random.nextInt(max - min + 1) + min).toRadixString(16);
      mac.add(num);
    }

    var md5Str = md5.convert(utf8.encode(mac.join(':'))).toString();
    var md5Arr = md5Str.split('');
    return 'XY${md5Arr[2]}${md5Arr[12]}${md5Arr[22]}$md5Str';
  }

  static String genDeviceId() {
    // https://github.com/bilive/bilive_client/blob/2873de0532c54832f5464a4c57325ad9af8b8698/bilive/lib/app_client.ts#L62
    final String yyyyMMddHHmmss = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:TZ]'), '')
        .substring(0, 14);

    final Random random = Random(); // Random.secure();
    final String randomHex32 =
        List.generate(32, (index) => random.nextInt(16).toRadixString(16))
            .join();
    final String randomHex16 =
        List.generate(16, (index) => random.nextInt(16).toRadixString(16))
            .join();

    final String deviceID = randomHex32 + yyyyMMddHHmmss + randomHex16;

    final List<int> bytes = RegExp(r'\w{2}')
        .allMatches(deviceID)
        .map((match) => int.parse(match.group(0)!, radix: 16))
        .toList();
    final int checksumValue = bytes.reduce((a, b) => a + b);
    final String check = checksumValue
        .toRadixString(16)
        .substring(checksumValue.toRadixString(16).length - 2);

    return deviceID + check;
  }

  static String generateRandomString(int length) {
    const chars =
        '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final Random random = Random(); // Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // app端密码登录
  static Future loginByPwd({
    required String username,
    required String password,
    required String key,
    required String salt,
    String? gee_challenge,
    String? gee_seccode,
    String? gee_validate,
    String? recaptcha_token,
  }) async {
    dynamic publicKey = RSAKeyParser().parse(key);
    print(publicKey);
    String passwordEncrypted =
        Encrypter(RSA(publicKey: publicKey)).encrypt(salt + password).base64;

    Map<String, dynamic> data = {
      'appkey': Constants.appKey,
      'bili_local_id': deviceId,
      'build': '1462100',
      'buvid': buvid,
      'c_locale': 'zh_CN',
      'channel': 'yingyongbao',
      'device': 'phone',
      'device_id': deviceId,
      //'device_meta': '',
      'device_name': 'vivo',
      'device_platform': 'Android14vivo',
      'disable_rcmd': '0',
      'dt': Uri.encodeComponent(Encrypter(RSA(publicKey: publicKey))
          .encrypt(generateRandomString(16))
          .base64),
      'from_pv': 'main.homepage.avatar-nologin.all.click',
      'from_url': Uri.encodeComponent('bilibili://pegasus/promo'),
      if (gee_challenge != null) 'gee_challenge': gee_challenge,
      if (gee_seccode != null) 'gee_seccode': gee_seccode,
      if (gee_validate != null) 'gee_validate': gee_validate,
      'local_id': buvid, //LoginUtils.generateBuvid(),
      'mobi_app': 'android_hd',
      'password': passwordEncrypted,
      'permission': 'ALL',
      'platform': 'android',
      if (recaptcha_token != null) 'recaptcha_token': recaptcha_token,
      's_locale': 'zh_CN',
      'statistics': statistics,
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'username': username,
    };
    String sign = Utils.appSign(
      data,
      Constants.appKey,
      Constants.appSec,
    );
    data['sign'] = sign;
    data.map((key, value) {
      print('$key: $value');
      return MapEntry<String, dynamic>(key, value);
    });
    final Map<String, String> headers = {
      'Host': host,
      'buvid': buvid,
      'env': 'prod',
      'app-key': 'android_hd',
      'user-agent': userAgent,
      'x-bili-trace-id': traceId,
      'x-bili-aurora-eid': '',
      'x-bili-aurora-zone': '',
      'bili-http-engine': 'cronet',
      'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
    };
    var res = await Request().post(
      Api.loginByPwdApi,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: headers,
        //responseType: ResponseType.plain
      ),
    );
    print(res);
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {
        'status': false,
        'code': res.data['code'],
        'msg': res.data['message'],
        'data': res.data['data']
      };
    }
  }

  // app端短信验证码登录
  static Future loginBySms({
    required String captchaKey,
    required String tel,
    required String code,
    required String cid,
    required String key,
  }) async {
    dynamic publicKey = RSAKeyParser().parse(key);
    Map<String, dynamic> data = {
      'appkey': Constants.appKey,
      'bili_local_id': deviceId,
      'build': '1462100',
      'buvid': buvid,
      'c_locale': 'zh_CN',
      'captcha_key': captchaKey,
      'channel': 'yingyongbao',
      'cid': cid,
      'code': code,
      'device': 'phone',
      'device_id': deviceId,
      //'device_meta': '',
      'device_name': 'vivo',
      'device_platform': 'Android14vivo',
      // 'device_tourist_id': '',
      'disable_rcmd': '0',
      'dt': Uri.encodeComponent(Encrypter(RSA(publicKey: publicKey))
          .encrypt(generateRandomString(16))
          .base64),
      'from_pv': 'main.my-information.my-login.0.click',
      'from_url': Uri.encodeComponent('bilibili://user_center/mine'),
      'local_id': buvid,
      'mobi_app': 'android_hd',
      'platform': 'android',
      's_locale': 'zh_CN',
      'statistics': statistics,
      'tel': tel,
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    };
    String sign = Utils.appSign(
      data,
      Constants.appKey,
      Constants.appSec,
    );
    data['sign'] = sign;
    data.map((key, value) {
      print('$key: $value');
      return MapEntry<String, dynamic>(key, value);
    });
    final Map<String, String> headers = {
      'Host': host,
      'buvid': buvid,
      'env': 'prod',
      'app-key': 'android_hd',
      'user-agent': userAgent,
      'x-bili-trace-id': traceId,
      'x-bili-aurora-eid': '',
      'x-bili-aurora-zone': '',
      'bili-http-engine': 'cronet',
      'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
    };
    var res = await Request().post(
      Api.logInByAppSms,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: headers,
        //responseType: ResponseType.plain
      ),
    );
    print(res);
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {
        'status': false,
        'code': res.data['code'],
        'msg': res.data['message'],
        'data': res.data['data']
      };
    }
  }
}
