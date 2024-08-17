import 'package:ecobinproj/page/map_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  late CameraController controller;
  bool _isCameraInitialized = false;
  bool _isInterpreterInitialized = false; // 모델이 로드되었는지 확인하는 변수
  String _classificationResult = ''; // 이미지 분류 결과를 저장할 변수
  File? _image; // 촬영한 이미지 파일

  late Interpreter _interpreter; // TFLite 인터프리터

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadModel(); // 모델 로드
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _interpreter.close(); // TFLite 리소스 해제
    super.dispose();
  }

  void _disposeCamera() {
    if (_isCameraInitialized) {
      controller.dispose();
      _isCameraInitialized = false;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isNotEmpty) {
        controller = CameraController(
          _cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await controller.initialize();

        if (!mounted) {
          return;
        }

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

  Future<void> _loadModel() async {
    try {
      // 모델 로드
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      setState(() {
        _isInterpreterInitialized = true; // 모델이 로드되었음을 표시
      });
      print("모델 로드 완료");
    } catch (e) {
      print("모델 로드 오류: $e");
    }
  }

  Future<void> _classifyImage(File image) async {
    if (!_isInterpreterInitialized) {
      print('모델이 아직 로드되지 않았습니다.');
      return;
    }

    try {
      // 이미지 로드 및 전처리
      var inputImage = img.decodeImage(image.readAsBytesSync())!;

      // 모델이 기대하는 입력 크기로 이미지 크기 조정
      var inputShape = _interpreter.getInputTensor(0).shape;
      var inputSize = inputShape[1]; // 보통은 [1, height, width, channels] 형식

      var resizedImage = img.copyResize(inputImage, width: inputSize, height: inputSize);

      // 이미지 데이터를 모델 입력 형식에 맞게 변환
      var input = _imageToByteList(resizedImage, inputSize, 127.5, 127.5);

      // 모델의 출력 크기 확인
      var outputShape = _interpreter.getOutputTensor(0).shape;
      var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);

      // 모델 실행
      _interpreter.run([input], output);

      // 결과 처리 (출력의 형태에 따라 수정 필요)
      double prediction = output[0][0];
      String result = prediction > 0.5 ? "재활용쓰레기" : "일반쓰레기";

      _showResultDialog(prediction, result);
    } catch (e) {
      print('이미지 분류 오류: $e');
    }
  }

  List<List<List<double>>> _imageToByteList(img.Image image, int inputSize, double mean, double std) {
    var buffer = List.generate(
      inputSize,
      (_) => List.generate(inputSize, (_) => List.filled(3, 0.0)),
    );

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[i][j][0] = (img.getRed(pixel) - mean) / std;
        buffer[i][j][1] = (img.getGreen(pixel) - mean) / std;
        buffer[i][j][2] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return buffer;
  }

  Future<void> _takePicture() async {
    if (!controller.value.isInitialized || controller.value.isTakingPicture) {
      print('카메라가 초기화되지 않았거나 이미 사진을 찍고 있는 중입니다.');
      return;
    }

    try {
      print('사진 촬영 시작');
      final XFile file = await controller.takePicture();

      final File imageFile = File(file.path);

      if (await imageFile.length() == 0) {
        throw Exception("Captured image is empty");
      }

      setState(() {
        _image = imageFile;
      });

      await _classifyImage(imageFile);
    } catch (e) {
      print('사진 촬영 오류: $e');
    }
  }

  void _showResultDialog(double prediction, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('분류 결과'),
          content: Text('결과: $result\n확률: ${prediction.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              child: Text('재촬영하기'),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
                _takePicture(); // 다시 촬영
              },
            ),
            TextButton(
              child: Text('지도로 가기'),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(result: result),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isCameraInitialized) {
        _initializeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Detector'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(controller),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
                onTap: _takePicture,
                child: const Icon(
                  Icons.camera_enhance,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _image == null ? const Text('No image captured.') : Image.file(_image!),
                  const SizedBox(height: 16),
                  Text(
                    _classificationResult,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
