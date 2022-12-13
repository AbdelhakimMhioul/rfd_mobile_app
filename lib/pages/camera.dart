import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);
  static const routeName = '/camera';

  @override
  // ignore: library_private_types_in_public_api
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
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
    try {
      MultipartRequest request = MultipartRequest(
        'POST',
        Uri.parse(apiServer),
      );
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['type'] = 'photo';
      request.files.add(await MultipartFile.fromPath('file', image.path));
      await request.send();
      setState(() => loading = false);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // print(e);
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
      try {
        MultipartRequest request = MultipartRequest(
          'POST',
          Uri.parse(apiServer),
        );
        request.headers['Content-Type'] = 'multipart/form-data';
        request.fields['type'] = 'photo';
        request.files.add(
          await MultipartFile.fromPath('file', result.files.first.path ?? ""),
        );
        await request.send();
        setState(() => loading = false);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        // print(e);
      }
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
