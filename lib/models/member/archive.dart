class MemberArchiveDataModel {
  MemberArchiveDataModel({
    this.list,
    this.page,
    this.episodicButton,
  });

  ArchiveListModel? list;
  Map? page;
  EpisodicButton? episodicButton;

  MemberArchiveDataModel.fromJson(Map<String, dynamic> json) {
    list =
        json['list'] == null ? null : ArchiveListModel.fromJson(json['list']);
    page = json['page'];
    episodicButton = json['episodic_button'] == null
        ? null
        : EpisodicButton.fromJson(json['episodic_button']);
  }
}

class ArchiveListModel {
  ArchiveListModel({
    this.tlist,
    this.vlist,
  });

  Map<String, TListItemModel>? tlist;
  List<VListItemModel>? vlist;

  ArchiveListModel.fromJson(Map<String, dynamic> json) {
    tlist = json['tlist'] != null
        ? Map.from(json['tlist']).map((k, v) =>
            MapEntry<String, TListItemModel>(k, TListItemModel.fromJson(v)))
        : {};
    vlist = json['vlist']
        .map<VListItemModel>((e) => VListItemModel.fromJson(e))
        .toList();
  }
}

class TListItemModel {
  TListItemModel({
    this.tid,
    this.count,
    this.name,
  });

  int? tid;
  int? count;
  String? name;

  TListItemModel.fromJson(Map<String, dynamic> json) {
    tid = json['tid'];
    count = json['count'];
    name = json['name'];
  }
}

class VListItemModel {
  VListItemModel({
    this.comment,
    this.typeid,
    this.play,
    this.pic,
    this.subtitle,
    this.description,
    this.copyright,
    this.title,
    this.review,
    this.author,
    this.mid,
    this.created,
    this.pubdate,
    this.length,
    this.duration,
    this.videoReview,
    this.aid,
    this.bvid,
    this.cid,
    this.hideClick,
    this.isChargingSrc,
    this.rcmdReason,
    this.owner,
  });

  int? comment;
  int? typeid;
  int? play;
  String? pic;
  String? subtitle;
  String? description;
  String? copyright;
  String? title;
  int? review;
  String? author;
  int? mid;
  int? created;
  int? pubdate;
  String? length;
  String? duration;
  int? videoReview;
  int? aid;
  String? bvid;
  int? cid;
  bool? hideClick;
  bool? isChargingSrc;
  Stat? stat;
  String? rcmdReason;
  Owner? owner;

  VListItemModel.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    typeid = json['typeid'];
    play = json['play'];
    pic = json['pic'];
    subtitle = json['subtitle'];
    description = json['description'];
    copyright = json['copyright'];
    title = json['title'];
    review = json['review'];
    author = json['author'];
    mid = json['mid'];
    created = json['created'];
    pubdate = json['created'];
    length = json['length'];
    duration = json['length'];
    videoReview = json['video_review'];
    aid = json['aid'];
    bvid = json['bvid'];
    cid = null;
    hideClick = json['hide_click'];
    isChargingSrc = json['is_charging_arc'];
    stat = Stat.fromJson(json);
    rcmdReason = null;
    owner = Owner.fromJson(json);
  }
}

class Stat {
  Stat({
    this.view,
    this.danmu,
  });

  int? view;
  int? danmu;

  Stat.fromJson(Map<String, dynamic> json) {
    view = json["play"];
    danmu = json['video_review'];
  }
}

class Owner {
  Owner({
    this.mid,
    this.name,
    this.face,
  });
  int? mid;
  String? name;
  String? face;

  Owner.fromJson(Map<String, dynamic> json) {
    mid = json["mid"];
    name = json["author"];
    face = '';
  }
}

class EpisodicButton {
  EpisodicButton({
    this.text,
    this.uri,
  });

  String? text;
  String? uri;
  EpisodicButton.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    uri = json['uri'];
  }
}
