import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AlarmifyHome(),
    );
  }
}

class AlarmifyHome extends StatefulWidget {
  const AlarmifyHome({Key? key}) : super(key: key);

  @override
  _AlarmifyHomeState createState() => _AlarmifyHomeState();
}

class _AlarmifyHomeState extends State<AlarmifyHome> {
  final _alarmTimeController = TextEditingController();
  final _playlistUriController = TextEditingController();
  String _currentAlarm = 'No alarm set';

  Future<void> _setAlarm() async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1:5000/set_alarm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alarm_time': _alarmTimeController.text,
        'playlist_uri': _playlistUriController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _currentAlarm = 'Alarm set for ${_alarmTimeController.text} with playlist ${_playlistUriController.text}';
      });
    } else {
      throw Exception('Failed to set alarm');
    }
  }

  Future<void> _getAlarm() async {
    final response = await http.get(Uri.parse('http://192.168.56.1:5000/get_alarm'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _currentAlarm = 'Alarm set for ${data['alarm_time']} with playlist ${data['playlist_uri']}';
      });
    } else {
      throw Exception('Failed to get alarm');
    }
  }

  Future<void> _startTimecheck() async {
    final response = await http.post(Uri.parse('http://192.168.56.1:5000/start_timecheck'));

    if (response.statusCode == 200) {
      setState(() {
        _currentAlarm = 'Time check started';
      });
    } else {
      throw Exception('Failed to start time check');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarmify GUI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _alarmTimeController,
              decoration: const InputDecoration(labelText: 'Alarm Time (HH:MM)'),
            ),
            TextField(
              controller: _playlistUriController,
              decoration: const InputDecoration(labelText: 'Playlist URI'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setAlarm,
              child: const Text('Set Alarm'),
            ),
            ElevatedButton(
              onPressed: _getAlarm,
              child: const Text('Get Alarm'),
            ),
            ElevatedButton(
              onPressed: _startTimecheck,
              child: const Text('Start Time Check'),
            ),
            const SizedBox(height: 20),
            Text('Current Alarm: $_currentAlarm'),
          ],
        ),
      ),
    );
  }
}
