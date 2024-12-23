import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/network_img_layer.dart';
import '../../models/video/reply/emote.dart';
import 'controller.dart';

import 'package:PiliPalaX/common/widgets/spring_physics.dart';

class EmotePanel extends StatefulWidget {
  final Function onChoose;
  const EmotePanel({super.key, required this.onChoose});

  @override
  State<EmotePanel> createState() => _EmotePanelState();
}

class _EmotePanelState extends State<EmotePanel>
    with AutomaticKeepAliveClientMixin {
  final EmotePanelController _emotePanelController =
      Get.put(EmotePanelController());
  late Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _emotePanelController.getEmote();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map data = snapshot.data as Map;
            if (data['status']) {
              List<Packages> emotePackage = _emotePanelController.emotePackage;

              return Column(
                children: [
                  Expanded(
                      child: TabBarView(
                    physics: const CustomTabBarViewScrollPhysics(),
                    controller: _emotePanelController.tabController,
                    children: emotePackage.map(
                      (e) {
                        int size = e.emote!.first.meta!.size!;
                        int type = e.type!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  type == 4 ? 100 : (size == 1 ? 40 : 60),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              mainAxisExtent: size == 1 ? 40 : 60,
                            ),
                            itemCount: e.emote!.length,
                            itemBuilder: (context, index) {
                              return Material(
                                color: Colors.transparent,
                                clipBehavior: Clip.hardEdge,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(4),
                                // ),
                                child: InkWell(
                                  onTap: () {
                                    widget.onChoose(e, e.emote![index]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: type == 4
                                        ? Text(
                                            e.emote![index].text!,
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                          )
                                        : NetworkImgLayer(
                                            src: e.emote![index].url!,
                                            width: size * 38,
                                            height: size * 38,
                                            semanticsLabel:
                                                e.emote![index].text!,
                                            type: 'emote',
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ).toList(),
                  )),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  TabBar(
                    controller: _emotePanelController.tabController,
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabs: _emotePanelController.emotePackage
                        .map(
                          (e) => NetworkImgLayer(
                            width: 36,
                            height: 36,
                            type: 'emote',
                            src: e.url,
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              );
            } else {
              return Center(child: Text(data['msg']));
            }
          } else {
            return const Center(child: Text('加载中...'));
          }
        });
  }
}
