import 'package:flutter/material.dart';
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
        title: 'Rock Climbing Log',
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
  String description;
  String photoPath;

  Climb({required this.name, required this.grade, required this.description, this.photoPath = ''});
}

class MyAppState extends ChangeNotifier {
  List<Climb> climbs = [];

  void addClimb(Climb climb) {
    climbs.add(climb);
    notifyListeners();
  }

  Future<void> pickAndUploadImage(Climb climb) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      climb.photoPath = pickedFile.path;
      notifyListeners();
    }
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rock Climbing Log'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddClimbDialog(context),
          ),
        ],
      ),
      body: Consumer<MyAppState>(
        builder: (context, state, child) {
          return ListView.builder(
            itemCount: state.climbs.length,
            itemBuilder: (context, index) {
              final climb = state.climbs[index];
              return ListTile(
                title: Text(climb.name),
                subtitle: Text('${climb.grade} - ${climb.description}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClimbDetailsPage(climb: climb)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddClimbDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController gradeController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Climb'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: gradeController,
                decoration: InputDecoration(labelText: 'Grade'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    Provider.of<MyAppState>(context, listen: false).addClimb(
                      Climb(
                        name: nameController.text,
                        grade: gradeController.text,
                        description: descriptionController.text,
                        photoPath: image.path,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Upload Image'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                final climb = Climb(
                  name: nameController.text,
                  grade: gradeController.text,
                  description: descriptionController.text,
                  // photoPath will be added when the image is picked
                );
                Provider.of<MyAppState>(context, listen: false).addClimb(climb);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ClimbDetailsPage extends StatelessWidget {
  final Climb climb;

  ClimbDetailsPage({required this.climb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Climb Details'),
      ),
      body: Column(
        children: [
          Text('Name: ${climb.name}'),
          Text('Grade: ${climb.grade}'),
          Text('Description: ${climb.description}'),
          climb.photoPath.isNotEmpty
              ? Image.file(File(climb.photoPath))
              : Text("No image selected"),
        ],
      ),
    );
  }
}
