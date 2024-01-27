import 'dart:convert';
import 'dart:io';

import 'package:ml_dataframe/ml_dataframe.dart';

class DataTransformer {
 static void transform() async {
    final dataFrame = await fromCsv(
        'Sleep_Efficiency.csv',
        columns: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);

    Series bedtimeSeries = dataFrame.series.toList()[2];
    Series wakeTimeSeries = dataFrame.series.toList()[3];

    // bedtimeSeries
    List<dynamic> newDate = [];
    for(var elm in bedtimeSeries.data){
      DateTime time = DateTime.parse(elm.toString());
      int timeInt = time.hour * 60 + time.minute;
      newDate.add(timeInt);
    }
    bedtimeSeries = Series(bedtimeSeries.name, newDate);

    newDate = [];
    for(var elm in wakeTimeSeries.data){
      DateTime time = DateTime.parse(elm.toString());
      int timeInt = time.hour * 60 + time.minute;
      newDate.add(timeInt);
    }
    wakeTimeSeries = Series(wakeTimeSeries.name, newDate);
    List<Series> newSeries = [];
    for(int i = 0; i < dataFrame.series.length; i++){
      if(i == 2){
        newSeries.add(bedtimeSeries);
      }
      else if(i == 3){
        newSeries.add(wakeTimeSeries);
      }else {
        newSeries.add(dataFrame.series.toList()[i]);
      }
    }
    DataFrame newsFrame = DataFrame.fromSeries(newSeries);
    File('dataset.json').writeAsString(jsonEncode(newsFrame.toJson()));
  }
}
