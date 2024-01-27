import 'dart:convert';
import 'dart:io';
import 'dart:math';

class IrisDataset {
  static List<List<dynamic>> load() {
    // Путь к файлу с данными Iris (пример)
    var filePath = 'iris.сsv.txt';

    try {
      // Чтение данных из файла
      var fileContent = File(filePath).readAsStringSync();

      // Преобразование CSV-строк в список списков
      var lines = LineSplitter.split(fileContent)
          .map((line) => line.split(','))
          .toList();

      lines.removeLast();

      return lines;
    } catch (e) {
      print('Error loading Iris data: $e');
      return [];
    }
  }

  static void shuffle(List<List<dynamic>> data) {
    var random = Random();
    for (var i = data.length - 1; i > 0; i--) {
      var j = random.nextInt(i + 1);
      var temp = data[i];
      data[i] = data[j];
      data[j] = temp;
    }
  }
}