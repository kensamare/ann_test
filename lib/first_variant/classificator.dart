import 'dart:typed_data';

import 'package:ann/first_variant/iris_loader.dart';
import 'package:eneural_net/eneural_net.dart';

class IrisClassifier {
  ANN<double, Float32x4, SignalFloat32x4, Scale<double>>? ann;

  IrisClassifier() {
    // Type of scale to use to compute the ANN:
    var scale = ScaleDouble.ZERO_TO_ONE;

    // Load iris data
    var irisData = IrisDataset.load();

    // Shuffle the data
    IrisDataset.shuffle(irisData);

    var samples = irisData.map((data) {
      var input = data.sublist(0, 4).map((e) => double.parse(e)).toList();

      // Placeholder for output, will be set based on iris class
      var output = [0.0, 0.0, 0.0];

      // Set output values based on iris class
      var irisClass = data[4];
      switch (irisClass) {
        case 'Iris-setosa':
          output[0] = 1.0;
          break;
        case 'Iris-versicolor':
          output[1] = 1.0;
          break;
        case 'Iris-virginica':
          output[2] = 1.0;
          break;
      }

      return SampleFloat32x4.fromNormalized(input, output, scale);
    }).toList();

    var samplesSet = SamplesSet(samples, subject: 'iris');

    // The activation function to use in the ANN:
    var activationFunction = ActivationFunctionSigmoid();

    // The ANN using layers that can compute with Float32x4 (SIMD compatible type).

    ann = ANN<double, Float32x4, SignalFloat32x4, Scale<double>>(
      scale,
      // Input layer: 4 neurons with linear activation function:
      LayerFloat32x4(4, true, ActivationFunctionLinear()),
      // 1 Hidden layer: 5 neurons with sigmoid activation function:
      [HiddenLayerConfig(5, true, activationFunction)],
      // Output layer: 3 neurons with sigmoid activation function:
      LayerFloat32x4(3, false, activationFunction),
    );

    // Training algorithm:
    var backpropagation = Backpropagation<double, Float32x4, SignalFloat32x4,
        Scale<double>, SampleFloat32x4>(ann!, samplesSet);

    // Train the ANN using Backpropagation until global error 0.01,
    // with max epochs per training session of 50000 and
    // a max retry of 10 when a training session can't reach
    // the target global error:
    var achievedTargetError = backpropagation.trainUntilGlobalError(
      targetGlobalError: 0.01,
      maxEpochs: 5000,
      maxRetries: 10,
    );

    var globalError = ann!.computeSamplesGlobalError(samples);

    print('\nglobalError: $globalError');
    print('achievedTargetError: $achievedTargetError\n');
  }

  (List<double>, String) classify(List<double> input) {
    // Normalize inputs in the same scale used during training:
    SignalFloat32x4 normalizedInputs = SignalFloat32x4.from([
      ann!.scale.normalize(input[0]),
      ann!.scale.normalize(input[1]),
      ann!.scale.normalize(input[2]),
      ann!.scale.normalize(input[3]),
    ]);

    // Activate the sample input:
    ann!.activate(normalizedInputs);

    // The current output of the ANN (after activation):
    var output = ann!.output;

    // Find the index with the maximum value in the output
    var maxIndex =
        output.toList().indexOf(output.reduce((a, b) => a > b ? a : b));

    // Map the index to the corresponding iris class
    switch (maxIndex) {
      case 0:
        return (output, 'Iris-setosa');
      case 1:
        return (output, 'Iris-versicolor');
      case 2:
        return (output, 'Iris-virginica');
      default:
        return (output, 'Unknown');
    }
  }
}
