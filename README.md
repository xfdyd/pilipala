<div align="center">
    <img width="200" height="200" src="https://github.com/orz12/PiliPalaX/blob/main/assets/images/logo/logo_android.png">
</div>



<div align="center">
    <h1>PiliPalaX</h1>
<div align="center">
    
![GitHub repo size](https://img.shields.io/github/repo-size/orz12/pilipala) 
![GitHub Repo stars](https://img.shields.io/github/stars/orz12/pilipala) 
![GitHub all releases](https://img.shields.io/github/downloads/orz12/pilipala/total) 
</div>
    <p>使用Flutter开发的BiliBili第三方客户端</p>
    
<img src="https://github.com/orz12/PiliPalaX/blob/main/assets/screenshots/510shots_so.png" width="32%" alt="home" />
<img src="https://github.com/orz12/PiliPalaX/blob/main/assets/screenshots/174shots_so.png" width="32%" alt="home" />
<img src="https://github.com/orz12/PiliPalaX/blob/main/assets/screenshots/850shots_so.png" width="32%" alt="home" />
<br/>
<img src="https://github.com/orz12/PiliPalaX/blob/main/assets/screenshots/main_screen.png" width="96%" alt="home" />
<br/>
</div>

## 开发环境

为临时修复高于3.22.3版本flutter中文字重的bug，使用flutter 3.24.4(stable)，然后在flutter自身的目录中执行
```bash
git cherry-pick d4124bd --strategy-option theirs
flutter --version
```
以更换Framework和Engine版本（之后flutter doctor就会显示为3.24.5-0.0.pre.1）如下：

```bash
[√] Flutter (Channel stable, 3.24.5-0.0.pre.1, on Microsoft Windows [版本 10.0.19045.5073], locale zh-CN)
    • Flutter version 3.24.5-0.0.pre.1 on channel stable at C:\others\flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision 1d5ace7b10 (4 months ago), 2024-07-24 00:10:30 -0400
    • Engine revision 1572635432
    • Dart version 3.6.0 (build 3.6.0-75.0.dev)
    • DevTools version 2.37.1
    • Pub download mirror https://pub.flutter-io.cn
    • Flutter download mirror https://storage.flutter-io.cn
[√] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.1)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2024.2)
[✓] VS Code (version 1.95.2)
[✓] Connected device (4 available)
[✓] Network resources

```
注：Framework revision XXXXXX可能会不一致，但后续时间应该是一致的
<br/>
Android相关版本：
> JDK: 21.0.4
> gradle: 8.10.2
> kotlin: 2.0.20
> minSdk: 21
> targetSdk: 34
> compileSdk: 34

下载后，如果Android编译失败并报了签名相关的问题（例如缺少jks文件等），请保证项目目录下的Android文件夹内存在key.properties，且里面的内容类似于
```text
storePassword=aaaaaaaa
keyPassword=bbbbbbbb
keyAlias=cccccccc
storeFile=C:/dd/dddddd.jks
```
这些占位符填写的内容和你生成jks证书文件时输入的相匹配。如果你没有jks，可以使用keytool等工具生成，具体过程这里不列出，可自行搜索。
<br/>


## 技术交流

Telegram: https://t.me/+162zlPtZlT9hNWVl


<br/>

## 功能

目前着重移动端(Android、iOS)和Pad端，暂时没有适配桌面端、手表端等

<br/>


- [x] 推荐视频列表(app端)
- [x] 最热视频列表
- [x] 热门直播
- [x] 番剧列表
- [x] 屏蔽黑名单内用户视频
- [x] 无痕模式（播放视为未登录）
- [x] 游客模式（推荐视为未登录）

- [x] 用户相关
  - [x] 粉丝、关注用户、拉黑用户查看
  - [x] 用户主页查看
  - [x] 关注/取关用户
  - [ ] 离线缓存
  - [x] 稍后再看
  - [x] 观看记录
  - [x] 我的收藏
  - [x] 站内私信
  
- [x] 动态相关
  - [x] 全部、投稿、番剧分类查看
  - [x] 动态评论查看
  - [x] 动态评论回复功能

- [x] 视频播放相关
  - [x] 双击快进/快退
  - [x] 双击播放/暂停
  - [x] 垂直方向调节亮度/音量
  - [x] 垂直方向上滑全屏、下滑退出全屏
  - [x] 水平方向手势快进/快退
  - [x] 全屏方向设置
  - [x] 倍速选择/长按2倍速
  - [x] 硬件加速（视机型而定）
  - [x] 画质选择（高清画质未解锁）
  - [x] 音质选择（视视频而定）
  - [x] 解码格式选择（视视频而定）
  - [x] 弹幕
  - [ ] 直播弹幕
  - [x] 字幕
  - [x] 记忆播放
  - [x] 视频比例：高度/宽度适应、填充、包含等
     
- [x] 搜索相关
  - [x] 热搜
  - [x] 搜索历史
  - [x] 默认搜索词
  - [x] 投稿、番剧、直播间、用户搜索
  - [x] 视频搜索排序、按时长筛选
    
- [x] 视频详情页相关
  - [x] 视频选集(分p)切换
  - [x] 点赞、投币、收藏/取消收藏
  - [x] 相关视频查看
  - [x] 评论用户身份标识
  - [x] 评论(排序)查看、二楼评论查看
  - [x] 主楼、二楼评论回复功能
  - [x] 评论点赞
  - [x] 评论笔记图片查看、保存

- [x] 设置相关
  - [x] 画质、音质、解码方式预设      
  - [x] 图片质量设定
  - [x] 主题模式：亮色/暗色/跟随系统
  - [x] 震动反馈(可选)
  - [x] 高帧率
  - [x] 自动全屏
  - [x] 横屏适配
- [ ] 等等

<br/>

## 下载

可以通过右侧release进行下载或拉取代码到本地进行编译

<br/>

## 声明

此项目（PiliPalaX）是个人为了兴趣而开发, 仅用于学习和测试，请于下载后24小时内删除。
所用API皆从官方网站收集, 不提供任何破解内容。
在此致敬原作者：[guozhigq/pilipala](https://github.com/guozhigq/pilipala)
本仓库做了更激进的修改，感谢原作者的开源精神。

感谢使用


<br/>

## 致谢

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- 等等

<br/>
<br/>
<br/>
