import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid?
  await Firebase.initializeApp(
  options: const FirebaseOptions(
      apiKey: 'AIzaSyDQV6QJTDMhBp9E8TYdTWEnYKHiLhNniyA',
    appId: '1:566081636212:android:34e9f0735eeca2cb7f8e21',
    messagingSenderId: '566081636212',
    projectId: 'image-video-task',
        storageBucket: 'image-video-task.appspot.com',
  )
   )
  :await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  late Reference _storageRef;
  bool _uploading = false;
  double _uploadProgress = 0.0;

  Future<void> _uploadImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _uploading = true;
      _uploadProgress = 0.0;
    });

    final file = File(pickedFile.path);
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size exceeds 10 MB limit.')),
      );
      setState(() {
        _uploading = false;
      });
      return;
    }

    _storageRef = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = _storageRef.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    try {
      await uploadTask.whenComplete(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully!')),
        );
        print('Image uploaded successfully!');
        setState(() {
          _uploading = false;
        });
      });
    } catch (e) {
      print('Failed to upload image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image. Please try again later.')),
      );
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<void> _uploadVideo(BuildContext context) async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _uploading = true;
      _uploadProgress = 0.0;
    });

    final file = File(pickedFile.path);
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video size exceeds 10 MB limit.')),
      );
      setState(() {
        _uploading = false;
      });
      return;
    }

    _storageRef = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}.mp4');
    final uploadTask = _storageRef.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    try {
      await uploadTask.whenComplete(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video uploaded successfully!')),
        );
        print('Video uploaded successfully!');
        setState(() {
          _uploading = false;
        });
      });
    } catch (e) {
      print('Failed to upload video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload video. Please try again later.')),
      );
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image audio upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _uploading ? null : () => _uploadImage(context),
              child: Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: _uploading ? null : () => _uploadVideo(context),
              child: Text('Upload Video'),
            ),
            SizedBox(height: 20),
            _uploading
                ? Column(
              children: [
                CircularProgressIndicator(value: _uploadProgress),
                SizedBox(height: 10),
                Text('Uploading...'),
              ],
            )
                : const SizedBox(), 
          ],
        ),
      ),
    );
  }
}
