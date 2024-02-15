import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:petcong/constants/style.dart';
import 'package:petcong/pages/homepage.dart';
import 'package:petcong/services/socket_service.dart';

class MainVideoCallWidget extends StatefulWidget {
  // rtc 관련 변수들은, 한번 할당된 후 페이지가 있는 동안 바뀔 일 없음
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  List<RTCIceCandidate>? _iceCandidates;
  static late int quizIdx;

  MainVideoCallWidget({
    super.key,
    // required this._localRenderer,
    // required this._remoteRenderer,
    // required this._pc,
  });

  Future<void> init() async {
    await initPeerConnection();
  }

  List<RTCIceCandidate> getIceCandidates() {
    return _iceCandidates!;
  }

  void addCandidate(RTCIceCandidate ice) {
    _pc!.addCandidate(ice);
  }

  Future<void> closePeerConnection() async {
    await _pc!.close();
  }

  Future<void> initPeerConnection() async {
    final config = {
      'iceServers': [
        {"url": "stun:stun.l.google.com:19302"},
        {
          "url": "turn:i10a603.p.ssafy.io:3478",
          "username": "ehigh",
          "credential": "1234",
        },
      ],
    };

    final sdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': []
    };

    _pc = await createPeerConnection(config, sdpConstraints);

    // print("=======================makeCall start");
    // print("_pc is null = ${_pc == null} ===");
    // print("_localRenderer is null = ${_localRenderer == null}");
    // print("_remoteRenderer is null = ${_remoteRenderer == null}");
  }

  Future<RTCSessionDescription> createOffer() async {
    return _pc!.createOffer();
  }

  Future<RTCSessionDescription> createAnswer() async {
    return _pc!.createAnswer({});
  }

  Future<void> setLocalDescription(RTCSessionDescription description) async {
    _pc!.setLocalDescription(description);
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    _pc!.setRemoteDescription(description);
  }

  Future joinRoom() async {
    _iceCandidates = [];
    print("=======================joinRoom start");
    try {
      _pc!.onIceCandidate = (ice) {
        _iceCandidates!.add(ice);
      };

      // _remoteRenderer 세팅
      _remoteRenderer = RTCVideoRenderer();
      try {
        await _remoteRenderer!.initialize();
      } catch (exception) {
        print("exception = $exception");
      }

      _pc!.onAddStream = (stream) {
        _remoteRenderer!.srcObject = stream;
      };

      // _localRenderer 세팅
      _localRenderer = RTCVideoRenderer();
      await _localRenderer!.initialize();

      final mediaConstraints = {
        'audio': true,
        'video': {'facingMode': 'user'}
      };

      _localStream = await Helper.openCamera(mediaConstraints);

      // (화면에 띄울) _localRenderer의 데이터 소스를 내 _localStream으로 설정
      _localRenderer!.srcObject = _localStream;

      // 스트림의 트랙(카메라 정보가 들어오는 연결)을 peerConnection(정보를 전송할 connection)에 추가
      _localStream!.getTracks().forEach((track) {
        print(
            "================================on joinRoom(), track = ${track.toString()} =====");
        _pc!.addTrack(track, _localStream!);
      });

      await Future.delayed(const Duration(seconds: 1));
    } catch (exception) {
      print(exception);
    }
    // // print rtc objects (reconnect test)
    // print(
    //     "================================= _localRenderer.hashCode = ${_localRenderer.hashCode}=======================");
    // print(
    //     "================================= _remoteRenderer.hashCode = ${_remoteRenderer.hashCode}=======================");
    // print(
    //     "================================= _localStream.hashCode = ${_localStream.hashCode}=======================");
    // print(
    //     "================================= _pc.hashCode = ${_pc.hashCode}=======================");
    print("=======================joinRoom end");
  }

  @override
  _MainVideoCallWidgetState createState() => _MainVideoCallWidgetState();
}

class _MainVideoCallWidgetState extends State<MainVideoCallWidget> {
  late double videoWidth = MediaQuery.of(context).size.width;
  late double videoHeight = MediaQuery.of(context).size.height;
  // icebreakings
  List<String> quizs = ["sampleQuiz1", "sampleQuiz2", "sampleQuiz3"];

  @override
  void initState() {
    super.initState();
    MainVideoCallWidget.quizIdx = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> disconnectCall() async {
    widget._localRenderer!.srcObject!.getTracks().forEach((track) {
      track.stop();
      // widget._localRenderer!.srcObject!.removeTrack(track);
      print(
          "================================after removeTrack(), track = ${track.toString()} =====");
    });
    print("tracks.removeTrack() 완료됨");
    // remoteRendere의 Track 객체는 상대방이 끊었을 때 알아서 stop된다?
    widget._remoteRenderer!.srcObject!.getTracks().forEach((track) {
      track.stop();
      // widget._remoteRenderer!.srcObject!.removeTrack(track);
    });
    // await widget._localRenderer.srcObject!.dispose();
    // await widget._remoteRenderer.srcObject!.dispose();
    widget._localRenderer!.srcObject = null;
    widget._remoteRenderer!.srcObject = null;
    print("srcObject = null 완료됨");
    widget._pc!.close();
    print("pc.close 완료됨");
    // print(
    //     "end btn.onPressed - localRederer.hashCode = ${widget._localRenderer.hashCode}");
    // print(
    //     "end btn.onPressed - _remoteRenderer.hashCode = ${widget._remoteRenderer.hashCode}");
    widget._localRenderer = null;
    widget._remoteRenderer = null;
    print("renderer = null 완료됨");
    // disconnect end
    SocketService().setCallPressed(false); // flag false로
    SocketService().disposeSocket(SocketService.uid);
    await Future.delayed(const Duration(seconds: 2));
  }

  void onIdxbtnPressed() {
    int maxIdx = quizs.length;
    if (MainVideoCallWidget.quizIdx >= maxIdx) {
      MainVideoCallWidget.quizIdx = maxIdx;
      print("===============index changed by me / max!!");
      return;
    }
    MainVideoCallWidget.quizIdx++;
    print(
        "===============index changed by me / index = ${MainVideoCallWidget.quizIdx}==");
    SocketService.sendMessage("idx", MainVideoCallWidget.quizIdx.toString());
  }

  @override
  Widget build(BuildContext context) {
    final TransformationController controller = TransformationController();
    controller.value = Matrix4.identity()..scale(0.5);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 상대방 화면
          SizedBox.expand(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: RTCVideoView(
                widget._remoteRenderer!,
                mirror: false,
              ),
            ),
          ),
          //  내 화면
          ClipRect(
            child: InteractiveViewer(
              transformationController: controller,
              minScale: 0.3,
              maxScale: 0.5,
              constrained: true,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: SizedBox(
                width: videoWidth,
                height: videoHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RTCVideoView(
                    widget._localRenderer!,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 통화 종료 버튼
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            onPressed: () async {
              await disconnectCall(); // 다 꺼지면 이동
              Get.offAll(const HomePage());
            },
            heroTag: 'stop_call_button',
            shape: const CircleBorder(eccentricity: 0),
            backgroundColor: MyColor.petCongColor4,
            child: const Icon(Icons.call_end),
          ),
          FloatingActionButton(
            onPressed: onIdxbtnPressed,
            shape: const CircleBorder(eccentricity: 0),
            backgroundColor: Colors.blue,
            heroTag: 'next_button',
            child: const Icon(Icons.call_end),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
