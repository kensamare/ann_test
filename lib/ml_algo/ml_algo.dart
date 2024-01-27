import 'dart:convert';
import 'dart:io';

import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_preprocessing/ml_preprocessing.dart';

class MlTest {
  void testPreProcess() async {
    String json = await File('dataset.json').readAsString();
    final dataFrame = DataFrame.fromJson(jsonDecode(json));
    print(dataFrame);

    final pipeline = Pipeline(dataFrame, [
      toIntegerLabels(
        columnNames: ['Gender'],
      ),
      toOneHotLabels(columnNames: ['Bedtime'], headerPrefix: "bedTime_"),
      toOneHotLabels(columnNames: ['Wakeup time'], headerPrefix: "wakeUp_"),
      toIntegerLabels(
        columnNames: ['Smoking status'],
      ),
    ]);

    print(pipeline.process(dataFrame).toMatrix());
  }

  Future<void> test() async {
    // final dataFrame = await fromCsv('/Users/andrejkurakov/DartProjects/dartvsnodejs/ann/bin/Sleep_Efficiency.csv', columns: [1,2,3,4,5,6,7,8,9,10,11,12,13,14]);
    String json = await File('dataset.json').readAsString();
    final dataFrame = DataFrame.fromJson(jsonDecode(json));
    final pipeline = Pipeline(dataFrame, [
      toIntegerLabels(
        columnNames: ['Gender', 'Smoking status'],
      ),
    ]);

    DataFrame samples = pipeline.process(dataFrame);

    print(samples);

    File('samples').writeAsStringSync(jsonEncode(samples.toJson()));

    final targetName = "Sleep efficiency";

    final shuffledSamples = samples.shuffle();

    final splits = splitData(shuffledSamples, [0.8]);
    final trainData = splits[0];
    final testData = splits[1];

    final model = KnnRegressor(trainData, targetName, 4, kernel: KernelType.cosine);

    final error = model.assess(testData, MetricType.mape);

    String fileName = 'model_${DateTime.now().millisecondsSinceEpoch}.json';

    await model.saveAsJson(fileName);

    print(error);

    testPredict(fileName);
  }

  void testPredict(String fileName) async {
    String data =
        '''"ID","Age","Gender","Bedtime","Wakeup time","Sleep duration","Sleep efficiency","REM sleep percentage","Deep sleep percentage","Light sleep percentage","Awakenings","Caffeine consumption","Alcohol consumption","Smoking status","Exercise frequency"
"1","65","0","60","420","6","0.88","18","70","12","0","0","0","1","3"''';
    DataFrame frame = DataFrame.fromRawCsv(data, columns: [1,2,3,4,5,7,8,9,10,11,12,13,14]);
    print(frame);
    final file = File(fileName);
    final encodedModel = await file.readAsString();
    final model = KnnRegressor.fromJson(encodedModel);
    final prediction = model.predict(frame);
    print(prediction);
  }
}
