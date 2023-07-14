import 'package:pilipala/http/index.dart';
import 'package:pilipala/models/member/info.dart';

class MemberHttp {
  static Future memberInfo({String? params}) async {
    var res = await Request().get(Api.memberInfo + params!);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': MemberInfoModel.fromJson(res.data['data'])
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future memberStat({int? mid}) async {
    var res = await Request().get(Api.userStat, data: {mid: mid});
    if (res.data['code'] == 0) {
      print(res.data['data']);
      // return {'status': true, 'data': FansDataModel.fromJson(res.data['data'])};
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }
}
