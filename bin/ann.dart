import 'package:ann/dataset_transform/dataset_transformer.dart';
import 'package:ann/first_variant/classificator.dart';
import 'package:ann/first_variant/test_ann.dart';
import 'package:ann/ml_algo/classificator.dart';
import 'package:ann/ml_algo/ml_algo.dart';
import 'package:ann/ml_algo/regress.dart';

void main(List<String> arguments) async {
  // var irisClassifier = IrisClassifier();
  // var prediction = irisClassifier.classify([6.0, 2.8, 4.5, 1.5]);
  // print('Predicted class: $prediction');

  Classificator().train();

  // DataTransformer.transform();
  // Regress().train();
}
