import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveStreamScreen extends StatefulWidget {
  @override
  _LiveStreamScreenState createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late WebSocketChannel channel;
  late VideoPlayerController controller;
  late String videoFilePath;

  @override
  void initState() {
    super.initState();

    channel = IOWebSocketChannel.connect('ws://192.168.1.5:5000/stream',);
    controller = VideoPlayerController.network('');
    controller.initialize().then((_) {
      setState(() {});
      controller.play();
    });

    getTemporaryDirectory().then((dir) {
      videoFilePath = '${dir.path}/live_stream_temp.mp4';
      channel.stream.listen((message) {
        writeVideoFramesToFile(Uint8List.fromList(message.codeUnits));
      });
    });
  }

  Future<void> writeVideoFramesToFile(Uint8List videoData) async {
    final tempFile = File(videoFilePath);
    await tempFile.writeAsBytes(videoData);
    setState(() {
      controller.pause();
      controller.dispose();
      controller = VideoPlayerController.file(tempFile);
      controller.initialize().then((_) {
        setState(() {});
        controller.play();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Stream'),
      ),
      body: Container(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}