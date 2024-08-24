
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedGradingType;

  @override
  void initState() {
    super.initState();
    _loadGradingType();
  }

  Future<void> _loadGradingType() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedGradingType = prefs.getString('gradingType') ?? 'Font';
      });
    } catch (e) {
      print("Error loading grading type: $e");
    }
  }

  Future<void> _setGradingType(String? gradingType) async {
    if (gradingType == null) return;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedGradingType = gradingType;
        prefs.setString('gradingType', gradingType);
      });
    } catch (e) {
      print("Error saving grading type: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grading Type',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: _selectedGradingType,
                  items: <String>['Font', 'V-scale'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    _setGradingType(newValue);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
