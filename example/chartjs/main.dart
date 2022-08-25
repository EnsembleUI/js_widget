import 'package:flutter/material.dart';
import 'package:js_widget/js_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExampleChart());
  }
}

class ExampleChart extends StatefulWidget {
  const ExampleChart({Key? key}) : super(key: key);

  @override
  _ExampleChartState createState() => _ExampleChartState();
}

class _ExampleChartState extends State<ExampleChart> {
  final String _chartData = '''
  const labels = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
  ];

  const data = {
    labels: labels,
    datasets: [{
      label: 'My First dataset',
      backgroundColor: 'rgb(255, 99, 132)',
      borderColor: 'rgb(255, 99, 132)',
      data: [0, 10, 5, 2, 20, 30, 45],
    }]
  };

  const config = {
    type: 'line',
    data: data,
    options: {}
  };
  
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ChartJs Example App'),
      ),
      body: JsWidget(
        createHtmlTag: ({htmlId='chartJs'}) => ''' <div style="height:100%;width:100%;" id="${htmlId}Div"><canvas id="${htmlId}"></canvas></div>''',
        scriptToInstantiate: ({htmlId='chartJs'}) => '''const myChart = new Chart(
              document.getElementById('$htmlId'),
              config
            );''',
        loader: const SizedBox(
          child: LinearProgressIndicator(),
          width: 200,
        ),
        size: const Size(400, 400),
        data: _chartData,
        scripts: const [
          "https://cdn.jsdelivr.net/npm/chart.js",
        ],
      ),
    );
  }
}