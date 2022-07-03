import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class InferenceHelper {
  InferenceHelper() {}
  Future<Data_Results> read_csv_files() async {
    //Reading normalized dat
    Data_Results data = new Data_Results();
    var myData = await rootBundle
        .loadString("assets/data/test_data_2095_records_normalized.csv");
    List<List<dynamic>> csvTable =
        const CsvToListConverter(shouldParseNumbers: true, eol: '\n')
            .convert(myData);
    csvTable.removeAt(0);
    data.features = csvTable;

    //reading labels associated to above normalized data
    myData = await rootBundle
        .loadString("assets/data/test_data_2095_records_labels.csv");
    List<dynamic> labels =
        const CsvToListConverter(shouldParseNumbers: true, eol: '\n')
            .convert(myData);
    labels.removeAt(0);
    List<String> labels_without_indexes = List.filled(labels.length, '');
    for (int i = 0; i < labels.length; i++) {
      labels_without_indexes[i] = labels[i][0] as String;
    }
    data.labels = labels_without_indexes;

    //reading labels that are indexed during model training.
    myData = await rootBundle.loadString("assets/data/models_fed_labels.csv");

    List<dynamic> map_to_labels =
        const CsvToListConverter(eol: '\n').convert(myData);
    map_to_labels.removeAt(0);
    List<String> map_index_to_labels = List.filled(map_to_labels.length, '');

    for (int i = 0; i < map_to_labels.length; i++) {
      map_index_to_labels[i] = map_to_labels[i][0] as String;
    }
    data.map_indexes_to_labels = map_index_to_labels;
    return data;
  }

  Future<Model_Results> infernce_to_DNN_Model(List<dynamic> item) async {
    try {
      // Create interpreter from asset.
      Interpreter interpreter =
          await Interpreter.fromAsset("tflite/DNN_model_ROS.tflite");

      item = item.toList().reshape([1, 120]);
      List<dynamic> output = List.filled(1 * 27, 0).reshape([1, 27]);
      interpreter.run(item, output);
      output = output.toList().reshape([27]);
      return prepare_data(output);
      // print(output_classes);
    } catch (e) {
      print('Error loading model: ' + e.toString());
      return new Model_Results();
    }
  }

  Future<Model_Results> infernce_to_LSTM_Model(List<dynamic> item) async {
    try {
      // Create interpreter from asset.
      Interpreter interpreter =
          await Interpreter.fromAsset("tflite/LSTM_model.tflite");

      List<dynamic> output = List.filled(1 * 27, 0).reshape([1, 27]);
      var input = item.reshape([1, 1, 120]);
      interpreter.run(input, output);
      output = output.toList().reshape([27]);

      return prepare_data(output);
    } catch (e) {
      print('Error loading model: ' + e.toString());
      return new Model_Results();
    }
  }

  Model_Results prepare_data(output) {
    List<double> probabilities = output.cast<double>();
    List<double> probabilities_to_look_at = probabilities.toList();
    probabilities_to_look_at.sort();
    probabilities_to_look_at = probabilities_to_look_at.reversed.toList();

    Model_Results model_results = new Model_Results();

    List<int> top_arythmia = List.filled(3, 0);
    top_arythmia[0] = probabilities.indexOf(probabilities_to_look_at[0]);
    top_arythmia[1] = probabilities.indexOf(probabilities_to_look_at[1]);
    top_arythmia[2] = probabilities.indexOf(probabilities_to_look_at[2]);

    model_results.indexes = top_arythmia;

    List<double> top_arythmia_probablities = List.filled(3, 0);
    top_arythmia_probablities[0] = probabilities_to_look_at[0];
    top_arythmia_probablities[1] = probabilities_to_look_at[1];
    top_arythmia_probablities[2] = probabilities_to_look_at[2];

    model_results.probablities = top_arythmia_probablities;
    return model_results;
  }

  Future<Resnet_Inputs> read_inputs_resnetse(String filename) async {
    Resnet_Inputs inputs = new Resnet_Inputs();

    var input1 = await rootBundle
        .loadString("assets/data/resnet/data_" + filename + ".csv");
    List<List<dynamic>> data =
        const CsvToListConverter(shouldParseNumbers: true, eol: '\n')
            .convert(input1);
    data.removeAt(0);
    inputs.features = data;

    var input2 = await rootBundle
        .loadString("assets/data/resnet/ag_" + filename + ".csv");
    List<dynamic> ag =
        const CsvToListConverter(shouldParseNumbers: true, eol: '\n')
            .convert(input2);
    ag.removeAt(0);
    ag = ag[0];
    inputs.features = data;
    inputs.ag = ag;
    return inputs;
  }

  Future<Postprocessing_Data> fetch_postprocessing_data() async {
    Postprocessing_Data postprocessing_data = new Postprocessing_Data();

    var input1 = await rootBundle.loadString("assets/data/resnet/weights.csv");
    List<List<dynamic>> data =
        const CsvToListConverter(shouldParseNumbers: true, eol: '\n')
            .convert(input1);
    data.removeAt(0);
    postprocessing_data.dx = data[0].map((s) => s as int).toList();
    //print( postprocessing_data.dx);
    postprocessing_data.abbreviation = data[1].map((s) => s as String).toList();
    //print( postprocessing_data.abbreviation);
    postprocessing_data.arythmia_full_name =
        data[2].map((s) => s as String).toList();
    //print( postprocessing_data.arythmia_full_name);
    List<List<double>> weights =
        List<List<double>>.filled(1 * 5, List<double>.filled(24, 0));
    for (int i = 0; i < weights.length; i++) {
      weights[i] = data[3 + i].map((s) => s as double).toList();
    }
    postprocessing_data.weights = weights;
    //print(postprocessing_data.weights);
    return postprocessing_data;
  }

  Future<Resnet_Filenames_Data> fetch_filenames_data(
      Postprocessing_Data postprocessing_data) async {
    Resnet_Filenames_Data filenames_data = new Resnet_Filenames_Data();
    var filenames_csv =
        await rootBundle.loadString("assets/data/resnet/filenames.csv");

    List<List<dynamic>> data =
        const CsvToListConverter(shouldParseNumbers: false, eol: '\n')
            .convert(filenames_csv);
    data.removeAt(0);

    List<String> filenames = [];
    List<dynamic> labels_dx = [];
    List<dynamic> labels = [];
    for (int i = 0; i < data.length; i++) {
      String arythmia = data[i][0] as String;
      List<int> arythmias = arythmia.split(",").map(int.parse).toList();

      List<int> found_dx = map_to_original_dxs(arythmias, postprocessing_data);
      if (found_dx.isEmpty) {
        continue;
      }
      List<String> found_elements =
          map_to_original_labels(found_dx, postprocessing_data);
      if (found_elements.isEmpty) {
        continue;
      }
      labels_dx.add(found_dx);
      labels.add(found_elements);
      filenames.add(data[i][1] as String);
    }

    filenames_data.filenames = filenames;
    filenames_data.labels = labels.map((e) => e as List<String>).toList();
    filenames_data.labels_dx = labels_dx.map((e) => e as List<int>).toList();

    return filenames_data;
  }

  //map to orginal label
  List<String> map_to_original_labels(
      List<int> labels_dx, Postprocessing_Data postprocessing_data) {
    List<String> labels = [];
    for (int i = 0; i < labels_dx.length; i++) {
      int found_element = postprocessing_data.dx.firstWhere(
        (element) => element == labels_dx[i],
        orElse: () => -1,
      );
      if (found_element != -1) {
        int found_element_at = postprocessing_data.dx.indexOf(found_element);
        labels.add(postprocessing_data.abbreviation[found_element_at]);
      }
    }
    return labels;
  }

  //map to original dxs to see whether exist or not otherwise we will ignore it
  List<int> map_to_original_dxs(
      List<int> labels_dx, Postprocessing_Data postprocessing_data) {
    List<int> _labels_dx = [];
    for (int i = 0; i < labels_dx.length; i++) {
      int found_element = postprocessing_data.dx.firstWhere(
        (element) => element == labels_dx[i],
        orElse: () => -1,
      );
      if (found_element != -1) {
        _labels_dx.add(found_element);
      }
    }
    return _labels_dx;
  }

  Future<Model_Results> infernce_to_RESNETSE(Resnet_Inputs resnet_inputs,
      Postprocessing_Data postprocessing_data) async {
    // try {
    // Create interpreter from asset.
    List<String> models = [
      'tflite/resnetse-0.tflite',
      'tflite/resnetse-1.tflite',
      'tflite/resnetse-2.tflite',
      'tflite/resnetse-3.tflite',
      'tflite/resnetse-4.tflite'
    ];

    int num_classes = 24;
    int tar_fs = 257;
    int win_length = 4096;
    var inputs = resnet_inputs.features;
    var val_length = inputs.shape[1];
    var overlap = 256;

    int patch_number =
        ((val_length - win_length).abs() / (win_length - overlap)).ceil() + 1;
    int start = 1;
    if (patch_number > 1) {
      int patch_length = val_length - win_length;
      start = (patch_length / (patch_number - 1)).toInt();
    }

    List<dynamic> score = List.filled(24, 0);
    List<dynamic> combined_label = List.filled(24, 0);

    for (int j = 0; j < models.length; j++) {
      String model_one = models[j];
      List<double> logits_prob = [];

      for (int i = 0; i < patch_number; i++) {
        Interpreter interpreter = await Interpreter.fromAsset(model_one);
        //set inputs and outputs
        List<dynamic> output = List.filled(1 * 24, 0).reshape([1, 24]);

        if (i == 0) {
          var inputs_to_model = [
            resnet_inputs.features.reshape([1, 12, win_length]),
            resnet_inputs.ag.reshape([1, 5])
          ];
          var outputs = {0: output};

          //run the interpreter
          interpreter.runForMultipleInputs(inputs_to_model, outputs);

          // print("first if:" + outputs.toString());
          //apply sigmoid
          List<double>? output_after_reshape =
              outputs[0]?.reshape([24]).map((s) => s as double).toList();

          logits_prob = sigmoid(output_after_reshape!);
        } else if (i == patch_number - 1) {
          var features_to_input = slicing_2d_list(
              resnet_inputs.features.toList(),
              (val_length - win_length),
              val_length);
          int new_limit = val_length - (val_length - win_length);

          var inputs_to_model = [
            features_to_input.reshape([1, 12, new_limit]),
            resnet_inputs.ag.reshape([1, 5])
          ];
          var outputs = {0: output};
          //run the interpreter
          interpreter.runForMultipleInputs(inputs_to_model, outputs);
          print("second if else:" + outputs.toString());
          //apply sigmoid
          List<double>? output_after_reshape =
              outputs[0]?.reshape([24]).map((s) => s as double).toList();
          var logits_prob_tmp = sigmoid(output_after_reshape!);
          for (int k = 0; k < logits_prob_tmp.length; k++) {
            logits_prob[k] =
                (logits_prob[k] + logits_prob_tmp[k]) / patch_number;
          }
        } else {
          var features_to_input = slicing_2d_list(
              resnet_inputs.features.toList(),
              (i * start),
              i * start + win_length);

          int new_limit = (i * start + win_length) - (i * start);

          var inputs_to_model = [
            features_to_input.reshape([1, 12, new_limit]),
            resnet_inputs.ag.reshape([1, 5])
          ];
          var outputs = {0: output};
          //run the interpreter
          interpreter.runForMultipleInputs(inputs_to_model, outputs);
          //apply sigmoid
          List<double>? output_after_reshape =
              outputs[0]?.reshape([24]).map((s) => s as double).toList();
          var logits_prob_tmp = sigmoid(output_after_reshape!);

          for (int k = 0; k < logits_prob_tmp.length; k++) {
            logits_prob[k] = logits_prob[k] + logits_prob_tmp[k];
          }
        }
      }

      Resnet_Output_label outputs_from_output_label = output_label(
          logits_prob, postprocessing_data.weights.elementAt(j), 24);
      for (int i = 0;
          i < outputs_from_output_label.labels_predicted.length;
          i++) {
        combined_label[i] =
            combined_label[i] + outputs_from_output_label.labels_predicted[i];
      }
      for (int i = 0; i < outputs_from_output_label.logits.length; i++) {
        score[i] = score[i] + outputs_from_output_label.logits[i];
      }
    }

    // score = score / len(model)
    for (int i = 0; i < score.length; i++) {
      score[i] = score[i] / models.length;
    }

    //combined_label = combined_label / len(model)
    for (int i = 0; i < combined_label.length; i++) {
      combined_label[i] = combined_label[i] / models.length;
    }
    //max_index = np.argmax(combined_label, 1)
    var combined_label_temp = combined_label.toList();
    combined_label_temp.sort();
    combined_label_temp = combined_label_temp.reversed.toList();
    int max_index = combined_label.indexOf(combined_label_temp.first);
    combined_label[max_index] = 1;
    double threshold_tmp = 0.5;

    for (int i = 0; i < combined_label.length; i++) {
      combined_label[i] = combined_label[i] >= threshold_tmp ? 1 : 0;
    }
    List<int> current_label = combined_label.map((e) => e as int).toList();
    List<double> current_score = score.map((e) => e as double).toList();

    return post_processing_resnet_output(current_score,current_label, postprocessing_data);
  }

  List<List<dynamic>> slicing_2d_list(
      List<List<dynamic>> features, int start, int end) {
    for (int i = 0; i < features.length; i++) {
      features[i] = features[i].sublist(start, end).toList();
    }
    return features;
  }

  Model_Results post_processing_resnet_output(List<double> current_scores,
      List<int> current_labels, Postprocessing_Data postprocessing_data) {

    Model_Results model_results = new Model_Results();

    //getting indexes
    List<int> indexes = [];
    for (int i = 0; i < current_labels.length; i++) {
      if (current_labels[i] == 1) {
        indexes.add(i);
      }
    }
    model_results.indexes = indexes;

    //getting labels
    List<String> labels = [];
    for (int i = 0; i < indexes.length; i++) {
      labels.add(postprocessing_data.abbreviation[indexes[i]]);
    }
    model_results.predicted_labels = labels;

    //getting labels
    List<double> probablities = [];
    for (int i = 0; i < indexes.length; i++) {
      probablities.add(current_scores[indexes[i]]);
    }
    model_results.probablities = probablities;

    //in case the model didn't able to predict anything or make it one.
    if (indexes.isEmpty) {
      print("indexes are empty :(");
      List<double> top_probablities = current_scores.toList();
      top_probablities.sort();
      top_probablities = top_probablities.reversed.toList();

      List<int> top_arythmia = List.filled(3, 0);
      top_arythmia[0] = current_scores.indexOf(top_probablities[0]);
      top_arythmia[1] = current_scores.indexOf(top_probablities[1]);
      top_arythmia[2] = current_scores.indexOf(top_probablities[2]);
      model_results.indexes = top_arythmia;


      List<String> labels = List.filled(3, '');
      labels[0] = postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[0])];
      labels[1] = postprocessing_data.abbreviation[  current_scores.indexOf(top_probablities[1])];
      labels[2] =  postprocessing_data.abbreviation[  current_scores.indexOf(top_probablities[2])];
      model_results.predicted_labels = labels;


      List<double> top_arythmia_probablities = List.filled(3, 0);
      top_arythmia_probablities[0] = top_probablities[0];
      top_arythmia_probablities[1] = top_probablities[1];
      top_arythmia_probablities[2] = top_probablities[2];
      model_results.probablities = top_arythmia_probablities;

      return model_results;
    }
    else if(indexes.length==1) {

      print("indexes are 1 length :(");

      List<double> top_probablities = current_scores.toList();
      top_probablities.sort();
      top_probablities = top_probablities.reversed.toList();

      // Model_Results model_results = new Model_Results();

      List<int> top_arythmia = List.filled(3, 0);
      top_arythmia[0] = model_results.indexes[0];
      top_arythmia[1] = top_arythmia[0]!= current_scores.indexOf(top_probablities[0])?
                        current_scores.indexOf(top_probablities[0]):
                        current_scores.indexOf(top_probablities[1]);
      top_arythmia[2] = top_arythmia[1]!= current_scores.indexOf(top_probablities[1])?
      current_scores.indexOf(top_probablities[1]):
      current_scores.indexOf(top_probablities[2]);
      model_results.indexes = top_arythmia;


      List<String> labels = List.filled(3, '');
      print(model_results.predicted_labels.length);
      labels[0] = model_results.predicted_labels[0];
      labels[1] = labels[0]!= postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[0])]?
                              postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[0])]:
                              postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[1])];
      labels[2] =  labels[1]!= postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[1])]?
                               postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[1])]:
                               postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[2])];

      model_results.predicted_labels = labels;


      List<double> top_arythmia_probablities = List.filled(3, 0);
      top_arythmia_probablities[0] = model_results.probablities[0];
      top_arythmia_probablities[1] = top_arythmia_probablities[0]!=top_probablities[0]?
                                     top_probablities[0]:
                                     top_probablities[1];

      top_arythmia_probablities[2] = top_arythmia_probablities[1]!=top_probablities[1]?
                                     top_probablities[1]:
                                     top_probablities[2];
      model_results.probablities = top_arythmia_probablities;

      return model_results;

    }
    else if(indexes.length==2) {

      print("indexes are 2 length :(");

      List<double> top_probablities = current_scores.toList();
      top_probablities.sort();
      top_probablities = top_probablities.reversed.toList();

      // Model_Results model_results = new Model_Results();

      List<int> top_arythmia = List.filled(3, 0);
      top_arythmia[0] = model_results.indexes[0];
      top_arythmia[1] = model_results.indexes[1];

      //Just assign any random don't care this much
      top_arythmia[2] = current_scores.indexOf(top_probablities[2]);
      model_results.indexes = top_arythmia;

      List<String> labels = List.filled(3, '');
      labels[0] = model_results.predicted_labels[0];
      labels[1] =  model_results.predicted_labels[1];
      //assign third one
      labels[2] = postprocessing_data.abbreviation[ current_scores.indexOf(top_probablities[2])];

      model_results.predicted_labels = labels;


      List<double> top_arythmia_probablities = List.filled(3, 0);
      top_arythmia_probablities[0] = model_results.probablities[0];
      top_arythmia_probablities[1] = model_results.probablities[1];
      top_arythmia_probablities[2] = top_probablities[2];
      model_results.probablities = top_arythmia_probablities;

      return model_results;
    }

    return model_results;
  }

  //Sigmoid as done in original code
  List<double> sigmoid(List<double> x) {
    for (int i = 0; i < x.length; i++) {
      double p = exp(-1 * x[i]);
      x[i] = 1 / (1 + p);
    }
    return x;
  }

  Resnet_Output_label output_label(
      List<double> logits_prob, List<double> threshold, num_classes) {
    List<int> pred_label =
        List<int>.filled(num_classes, 0); //np.zeros(num_classes, dtype = int)

    //getting max value

    List<double> logits_prob_temp = logits_prob.toList();
    logits_prob_temp.sort();
    logits_prob_temp = logits_prob_temp.reversed.toList();
    double max_value = logits_prob_temp.elementAt(0);

    //getting the index of max value
    int y_pre_label =
        logits_prob.indexOf(max_value); //tf.math.argmax(logits_prob, axis = 1)
    // print(y_pre_label);
    pred_label[y_pre_label] = 1;

    List<double> score_tmp = logits_prob;
    List<int> y_pre = List<int>.filled(score_tmp.length, 0);

    //y_pre = (score_tmp - threshold) >= 0
    for (int i = 0; i < score_tmp.length; i++) {
      y_pre[i] = (score_tmp[i] - threshold[i] >= 0) ? 1 : 0;
    }
    //pred_label = pred_label + y_pre
    for (int i = 0; i < y_pre.length; i++) {
      pred_label[i] = pred_label[i] + y_pre[i];
    }
    //pred_label[pred_label > 1.1] = 1
    for (int i = 0; i < pred_label.length; i++) {
      if (pred_label[i] > 1.1) {
        pred_label[i] = 1;
      }
    }
    Resnet_Output_label output = new Resnet_Output_label();
    output.logits = score_tmp;
    output.labels_predicted = pred_label;
    return output;
  }
}

class Model_Results {
  List<double> probablities = List.filled(3, 0);
  List<int> indexes = List.filled(3, 0);
  List<String> predicted_labels = [];
}

class Data_Results {
  List<List<dynamic>> features = [];
  List<String> labels = [];
  List<String> map_indexes_to_labels = [];
}

class Resnet_Inputs {
  List<List<dynamic>> features = [];
  List<dynamic> ag = [];
}

class Postprocessing_Data {
  List<List<double>> weights = [];
  List<int> dx = [];
  List<String> abbreviation = [];
  List<String> arythmia_full_name = [];
}

class Resnet_Output_label {
  List<double> logits = [];
  List<int> labels_predicted = [];
}

class Resnet_Filenames_Data {
  List<String> filenames = [];
  List<List<int>> labels_dx = [];
  List<List<String>> labels = [];
}
