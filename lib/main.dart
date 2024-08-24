import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Bouldering Log',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class Climb {
  String name;
  String grade;
  String notes;
  String photoPath;

  Climb(
      {required this.name,
      required this.grade,
      required this.notes,
      this.photoPath = ''});
}

class MyAppState extends ChangeNotifier {
  String gradingType = 'Font';
  List<Climb> climbs = [];
  Map<String, List<String>> gradingScales = {
    'Font': ['5a', '5b', '5c', '6a', '6b', '6c', '7a', '7b', '7c'],
    'V-Scale': ['V0', 'V1', 'V2', 'V3', 'V4', 'V5', 'V6', 'V7', 'V8']
  };

  MyAppState() {
    loadGradingType();
    loadClimbs();
  }

  Future<void> loadGradingType() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      gradingType = prefs.getString('gradingType')?.toLowerCase() ?? 'font';
      notifyListeners();
    } catch (e) {
      print("Error loading grading type: $e");
    }
  }

  Future<void> loadClimbs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? climbsData = prefs.getStringList('climbs');
      if (climbsData != null) {
        climbs = climbsData.map((climbString) {
          List<String> climbParts = climbString.split('|');
          return Climb(
            name: climbParts[0],
            grade: climbParts[1],
            notes: climbParts[2],
            photoPath: climbParts.length > 3 ? climbParts[3] : '',
          );
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error loading climbs: $e");
    }
  }

  Future<void> saveClimbs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> climbsData = climbs.map((climb) {
        return '${climb.name}|${climb.grade}|${climb.notes}|${climb.photoPath}';
      }).toList();
      await prefs.setStringList('climbs', climbsData);
    } catch (e) {
      print("Error saving climbs: $e");
    }
  }

  List<String> getCurrentGradingScale() {
    return gradingScales[gradingType.capitalize()] ?? [];
  }

  void addClimb(String name, String grade, String notes) {
    climbs.add(Climb(name: name, grade: grade, notes: notes));
    notifyListeners();
    saveClimbs();
  }

  void deleteClimb(Climb climb) {
    climbs.remove(climb);
    saveClimbs();
    notifyListeners();
  }

  void updateClimb(Climb oldClimb, Climb newClimb) {
    int index = climbs.indexOf(oldClimb);
    if (index != -1) {
      climbs[index] = newClimb;
      saveClimbs();
      notifyListeners();
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bouldering Log'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MyAppState>(
        builder: (context, myAppState, child) {
          return ListView.builder(
            itemCount: myAppState.climbs.length,
            itemBuilder: (context, index) {
              Climb climb = myAppState.climbs[index];
              return ListTile(
                title: Text(climb.name),
                subtitle: Text(climb.grade),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClimbDetailsPage(climb: climb),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddClimbPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddClimbPage extends StatefulWidget {
  @override
  _AddClimbPageState createState() => _AddClimbPageState();
}

class _AddClimbPageState extends State<AddClimbPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _photoPath = '';
  String? selectedGrade;

  @override
  Widget build(BuildContext context) {
    final myAppState = Provider.of<MyAppState>(context);
    final gradingScale = myAppState.getCurrentGradingScale();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Climb'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            DropdownButton<String>(
              value: selectedGrade,
              hint: Text('Select Grade'),
              items: gradingScale.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGrade = newValue;
                });
              },
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
            ),
            SizedBox(height: 20),
            _photoPath.isNotEmpty
                ? Image.file(File(_photoPath))
                : Text("No image selected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _photoPath = image.path;
                  });
                }
              },
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    selectedGrade != null &&
                    _notesController.text.isNotEmpty) {
                  Climb newClimb = Climb(
                    name: _nameController.text,
                    grade: selectedGrade!,
                    notes: _notesController.text,
                    photoPath: _photoPath,
                  );
                  myAppState.addClimb(
                      newClimb.name, newClimb.grade, newClimb.notes);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill out all fields')),
                  );
                }
              },
              child: Text('Add Climb'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClimbDetailsPage extends StatefulWidget {
  final Climb climb;

  ClimbDetailsPage({required this.climb});

  @override
  _ClimbDetailsPageState createState() => _ClimbDetailsPageState();
}

class _ClimbDetailsPageState extends State<ClimbDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _gradeController;
  late TextEditingController _notesController;
  String _photoPath = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.climb.name);
    _gradeController = TextEditingController(text: widget.climb.grade);
    _notesController = TextEditingController(text: widget.climb.notes);
    _photoPath = widget.climb.photoPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Climb'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Provider.of<MyAppState>(context, listen: false)
                  .deleteClimb(widget.climb);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _gradeController,
              decoration: InputDecoration(labelText: 'Grade'),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
            ),
            SizedBox(height: 20),
            _photoPath.isNotEmpty
                ? Image.file(File(_photoPath))
                : Text("No image selected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _photoPath = image.path;
                  });
                }
              },
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Climb updatedClimb = Climb(
                  name: _nameController.text,
                  grade: _gradeController.text,
                  notes: _notesController.text,
                  photoPath: _photoPath,
                );
                Provider.of<MyAppState>(context, listen: false)
                    .updateClimb(widget.climb, updatedClimb);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
