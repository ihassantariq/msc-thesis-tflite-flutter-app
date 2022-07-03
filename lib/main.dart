import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ecg_arythmias_detection/widgets/nav-drawer.dart';
import 'package:ecg_arythmias_detection/widgets/pages/dnn-ros-page.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';

import 'models-helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '12-lead ECG Arythmia Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DNNPage(title: "DNN Model",),
    );
  }
}

