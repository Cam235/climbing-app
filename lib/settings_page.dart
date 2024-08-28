import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Import your main application state

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
      if (mounted) {
        setState(() {
          _selectedGradingType = prefs.getString('gradingType') ?? 'Font';
        });
      }
    } catch (e) {
      print("Error loading grading type: $e");
    }
  }

  Future<void> _setGradingType(String? gradingType) async {
    if (gradingType == null) return;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _selectedGradingType = gradingType;
          prefs.setString('gradingType', gradingType);
        });
        // Update the main application state
        Provider.of<MyAppState>(context, listen: false).setGradingType(gradingType);
      }
    } catch (e) {
      print("Error saving grading type: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gradingTypes = ['Font', 'V-scale'];

    // Ensure the selected grading type is valid
    if (_selectedGradingType == null || !gradingTypes.contains(_selectedGradingType)) {
      _selectedGradingType = gradingTypes.first;
    }

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
                  items: gradingTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGradingType = newValue;
                    });
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