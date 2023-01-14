import 'package:camera/camera.dart';
import 'package:dio/dio.dart' as myDio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);
  static const routeName = '/camera';

  @override
  // ignore: library_private_types_in_public_api
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller = CameraController(
    const CameraDescription(
      name: 'Camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    ),
    ResolutionPreset.max,
  );
  bool selfie = false;
  bool loading = false;
  String apiServer = 'https://rotten-fruits-detector.onrender.com/predict';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // PRIVATE FUNCTIONS
  void _initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    controller =
        CameraController(cameras[selfie ? 1 : 0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // print('User denied camera access.');
            break;
          default:
            // print('Handle other errors.');
            break;
        }
      }
    });
  }

  Future<void> _uploadPhoto() async {
    setState(() => loading = true);
    final image = await controller.takePicture();

    final dio = myDio.Dio();
    final response = await dio.post(
      apiServer,
      data: myDio.FormData.fromMap({
        "image": await myDio.MultipartFile.fromFile(image.path),
      }),
      options: myDio.Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
      final responseData = response.data;
      if (!mounted) return;
      Navigator.pop(context, {'message': responseData['class_name']});
    } else {
      throw Exception('Failed to load data');
    }

    setState(() => loading = false);
  }

  Future<void> _pickFromGallery() async {
    List<String> allowedExtensions = [];
    allowedExtensions = ['jpg', 'png', 'gif'];
    setState(() => loading = true);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      final dio = myDio.Dio();
      final response = await dio.post(
        apiServer,
        data: myDio.FormData.fromMap({
          "image": await myDio.MultipartFile.fromFile(
            result.files.first.path!.toString(),
          ),
        }),
        options: myDio.Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (!mounted) return;
        Navigator.pop(context, {'message': responseData['class_name']});
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      // User canceled the picker
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      body: Center(
        child: !controller.value.isInitialized
            ? Container()
            : loading
                ? const CircularProgressIndicator()
                : CameraPreview(controller),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _uploadPhoto(),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _pickFromGallery(),
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              selfie = !selfie;
              _initializeCamera();
            },
            child: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
    );
  }
}
