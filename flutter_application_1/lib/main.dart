import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(LEDControlApp());
}

class LEDControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Control',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.lightBlueAccent,
          inactiveTrackColor: Colors.blueAccent,
          thumbColor: Colors.white,
        ),
      ),
      home: LEDControlPage(),
    );
  }
}

class LEDControlPage extends StatefulWidget {
  @override
  _LEDControlPageState createState() => _LEDControlPageState();
}

class _LEDControlPageState extends State<LEDControlPage> {
  String _selectedColor = 'OFF';
  double _brightnessValue = 0.0;

  Future<void> _setColor(String color) async {
    setState(() {
      _selectedColor = color;
    });
    await _sendDataToESP8266();
  }

  Future<void> _setBrightness(double value) async {
    setState(() {
      _brightnessValue = value;
    });
    await _sendDataToESP8266();
  }

  Future<void> _sendDataToESP8266() async {
    // IP address
    final uri = Uri.http('192.168.67.133', '/data', {'color': _selectedColor, 'brightness': _brightnessValue.toString()});
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print('Data sent successfully');
      } else {
        print('Failed to send data. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LED Control'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildColorButton('RED'),
                  SizedBox(width: 20),
                  _buildColorButton('GREEN'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildColorButton('BLUE'),
                  SizedBox(width: 20),
                  _buildColorButton('OFF'),
                ],
              ),
              SizedBox(height: 20),
              Slider(
                value: _brightnessValue,
                min: 0.0,
                max: 1.0,
                onChanged: (value) => _setBrightness(value),
              ),
              Text(
                'Brightness: ${(_brightnessValue * 100).round()}%',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(String color) {
    return ElevatedButton(
      onPressed: () => _setColor(color),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          _selectedColor == color ? _getColor(color) : Colors.grey,
        ),
      ),
      child: Text(color),
    );
  }

  Color _getColor(String color) {
    switch (color) {
      case 'RED':
        return Colors.red;
      case 'GREEN':
        return Colors.green;
      case 'BLUE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
