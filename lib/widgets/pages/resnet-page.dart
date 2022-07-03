import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models-helper.dart';
import '../nav-drawer.dart';

class RESNETPage extends StatefulWidget {
  const RESNETPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _RESNETPageState createState() => _RESNETPageState();
}

class _RESNETPageState extends State<RESNETPage> {
  String _detected_arythmia_type_1 = '';
  String _detected_arythmia_type_2 = '';
  String _detected_arythmia_type_3 = '';
  InferenceHelper _inferenceHelper = InferenceHelper();
  Model_Results _model_results = Model_Results();
  Postprocessing_Data _postprocessing_data = Postprocessing_Data();
  Resnet_Filenames_Data  _filename_data = Resnet_Filenames_Data();
  Resnet_Inputs _inputs = Resnet_Inputs();
  List<String> _current_label = [];
  int index = 0;
  bool _is_correct_prediction = true;

  _DNNPageState() {}

  Future<void> fetch_data_preprocessing_data() async {
    _postprocessing_data = await _inferenceHelper.fetch_postprocessing_data();
    _filename_data = await _inferenceHelper.fetch_filenames_data(_postprocessing_data);
    fetch_for_each_file();
  }

  Future<void> fetch_for_each_file() async {
    print(_filename_data.filenames[index]);
    _inputs= await _inferenceHelper.read_inputs_resnetse(_filename_data.filenames[index]);
    _model_results= await _inferenceHelper.infernce_to_RESNETSE(_inputs, _postprocessing_data);

    SetStates();
  }

  void incriment_to_get_next_prediction() {
    index++;
    if(_filename_data.filenames.length <= index) {
    index = 0;
    }
    fetch_for_each_file();
  }

  Future<void> SetStates() async {
    setState(() {
      _detected_arythmia_type_1 =
          _model_results.predicted_labels[0] +
              " ${(_model_results.probablities[0] * 100).toStringAsFixed(2)}%";
      _detected_arythmia_type_2 =
          _model_results.predicted_labels[1] +
              " ${(_model_results.probablities[1] * 100).toStringAsFixed(2)}%";
      _detected_arythmia_type_3 =
          _model_results.predicted_labels[2] +
              " ${(_model_results.probablities[2] * 100).toStringAsFixed(2)}%";
      _current_label = _filename_data.labels[index];
      if( _current_label.contains( _model_results.predicted_labels[0]))
      {
        _is_correct_prediction = true;
      }
      else
      {
        _is_correct_prediction=false;
      }
      index++;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                'Original Arythmia:',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                '$_current_label',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 15),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                'Detected Aryhmia Type 1:',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                '$_detected_arythmia_type_1',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 15),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left:5, top: 10), child:
            Icon(
              _is_correct_prediction==true?  Icons.check_circle_outline: Icons.cancel_outlined,
              color: _is_correct_prediction==true? Colors.green: Colors.red,
              size: 24.0,
              semanticLabel: '',
            ))
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                'Detected Aryhmia Type 2:',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                '$_detected_arythmia_type_2',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 15),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                'Detected Arythmia Type 3:',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                '$_detected_arythmia_type_3',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 15),
              ),
            ),
          ],
        ),
        Center( child:
        Padding(
            padding: EdgeInsets.only(left: 15, top: 15, right: 15),
            child: Center(
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {incriment_to_get_next_prediction();},
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        "Next",
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center
                    ),
                  ),
                ))),
        ),
      ]),
    );
  }

  @override
  void initState() {
    fetch_data_preprocessing_data();
    super.initState();
  }

  @override
  void dipose() {
    super.dispose();
  }
}
