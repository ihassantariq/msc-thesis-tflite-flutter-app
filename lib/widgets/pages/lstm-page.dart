import 'package:ecg_arythmias_detection/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models-helper.dart';
import '../nav-drawer.dart';

class LSTMPage extends StatefulWidget {
  const LSTMPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LSTMPageState createState() => _LSTMPageState();
}

class _LSTMPageState extends State<LSTMPage> {
  String _detected_arythmia_type_1 = '';
  String _detected_arythmia_type_2 = '';
  String _detected_arythmia_type_3 = '';
  InferenceHelper _inferenceHelper = InferenceHelper();
  Model_Results _model_results = Model_Results();
  Data_Results _csv_data = new Data_Results();
  String _current_label = '';
  int index = 0;
  bool _is_correct_prediction = true;

  _LSTMPageState() {}
  Future<void> fetch_data() async {
    _csv_data = await _inferenceHelper.read_csv_files();
    SetStates();
  }
  void incriment_to_get_next_prediction() {
    SetStates();
  }
  Future<void> SetStates() async {
    _model_results =
    await _inferenceHelper.infernce_to_LSTM_Model(_csv_data.features[index]);
    setState(() {
      _detected_arythmia_type_1 =
          _csv_data.map_indexes_to_labels[_model_results.indexes[0]] +
              " ${(_model_results.probablities[0] * 100).toStringAsFixed(2)}%";
      _detected_arythmia_type_2 =
          _csv_data.map_indexes_to_labels[_model_results.indexes[1]] +
              " ${(_model_results.probablities[1] * 100).toStringAsFixed(2)}%";
      _detected_arythmia_type_3 =
          _csv_data.map_indexes_to_labels[_model_results.indexes[2]] +
              " ${(_model_results.probablities[2] * 100).toStringAsFixed(2)}%";
      _current_label = _csv_data.labels[index];

      if(_csv_data.map_indexes_to_labels[_model_results.indexes[0]] == _current_label)
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
    super.initState();
    fetch_data();
  }

  @override
  void dipose() {
    super.dispose();
  }
}
