import 'dart:io';

import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_preprocessing/ml_preprocessing.dart';

class Classificator {
  Future<DataFrame> preProcess() async {
    final dataFrame = await fromCsv(
      'iris.сsv.txt',
      headerExists: false,
      columnDelimiter: ',',
    );
    final encoder = Encoder.oneHot(dataFrame, columnIndices: [4]);
    return encoder.process(dataFrame);
  }

  void train() async {
    DataFrame samples = await preProcess();
    samples = samples.shuffle();
    final splits = splitData(samples, [0.7]);
    final validationData = splits[0];
    final testData = splits[1];

    final model = SoftmaxRegressor(
      validationData,
      ["Iris-setosa", "Iris-versicolor", "Iris-virginica"],
      collectLearningData: true,
      iterationsLimit: 50000,
    );

    final finalScore = model.assess(testData, MetricType.accuracy);
    print('Accuracy: ${finalScore.toStringAsFixed(2)}');

    await model.saveAsJson('class.json');

    predict('class.json');
  }

  void predict(String fileName) async {
    String data = '''6.0,2.8,4.5,1.5''';
    DataFrame frame = DataFrame.fromRawCsv(data, headerExists: false);
    print(frame);
    final file = File(fileName);
    final encodedModel = await file.readAsString();
    final model = SoftmaxRegressor.fromJson(encodedModel);
    final prediction = model.predict(frame);
    print(prediction);
  }
}
