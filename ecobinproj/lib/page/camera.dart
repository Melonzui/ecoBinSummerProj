import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPage();
}

class _CameraPage extends State<CameraPage> {
  List<CameraDescription> _cameras = [];
  late CameraController controller;
  bool _isCameraInitialized = false; // 카메라 초기화 상태를 추적하기 위한 변수

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // 사용할 수 있는 카메라 목록을 가져옵니다.
      _cameras = await availableCameras();

      if (_cameras.isNotEmpty) {
        controller = CameraController(
          _cameras[0], // 첫 번째 카메라 사용
          ResolutionPreset.max,
          enableAudio: false,
        );

        // 컨트롤러 초기화
        await controller.initialize();

        if (!mounted) {
          return;
        }

        // 초기화가 완료되었을 때 상태를 업데이트합니다.
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        print('사용 가능한 카메라가 없습니다.');
      }
    } catch (e) {
      print('카메라 초기화 오류: $e');
    }
  }

  // 사진을 찍는 함수
  Future<void> _takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }

    try {
      // 사진 촬영
      final XFile file = await controller.takePicture();

      // 사진을 저장할 경로 : 기본경로(storage/emulated/0/)
      Directory directory = Directory('storage/emulated/0/DCIM/MyImages');

      // 지정한 경로에 디렉토리를 생성하는 코드
      // .create : 디렉토리 생성    recursive : true - 존재하지 않는 디렉토리일 경우 자동 생성
      await Directory(directory.path).create(recursive: true);

      // 지정한 경로에 사진 저장
      await File(file.path).copy('${directory.path}/${file.name}');
    } catch (e) {
      print('사진 촬영 오류: $e');
    }
  }

  @override
  void dispose() {
    // 카메라 컨트롤러 해제
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 카메라가 초기화되지 않았을 때 로딩 표시
    if (!_isCameraInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    // 카메라 인터페이스와 위젯을 겹쳐 구성할 예정이므로 Stack 위젯 사용
    return Stack(
      children: [
        // 화면 전체를 차지하도록 Positioned.fill 위젯 사용
        Positioned.fill(
          // 카메라 촬영 화면이 보일 CameraPreview
          child: CameraPreview(controller),
        ),
        // 하단 중앙에 위치도록 Align 위젯 설정
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            // 버튼 클릭 이벤트 정의를 위한 GestureDetector
            child: GestureDetector(
              onTap: () {
                // 사진 찍기 함수 호출
                _takePicture();
              },
              // 버튼으로 표시될 Icon
              child: const Icon(
                Icons.camera_enhance,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
