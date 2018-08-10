// Create a list of projects from user_projects
// Parse and create Project object from it
// Generate app main file

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'project.dart';

void main() async {
  final projects = await getUserProjects();

  generateMain(projects);

  print('Done preprocessing.');
}

Future<List<Project>> getUserProjects() async {
  var projectsDir = new Directory('user_content');

  final files = await projectsDir.list(recursive: true).toList();

  return files
    .where((f) => f is File && basename(f.path) == 'pubspec.yaml')
    .map((f) => new Project.fromPubspec(f))
    .toList()
    ..sort((p1, p2) => p1.name.compareTo(p2.name));
}

void generateMain(List<Project> projects) async {
  final mainFile = new File('lib/main.dart');

  final projectItems = [
    createListHeader('Animations', 'Icons.movie'),
    'const Divider()'
  ]
  ..addAll(projects.where((p) => p.type == 'animation').map((p) => projectToListTile(p)))
  ..addAll([
    createListHeader('Other', 'Icons.code'),
    'const Divider()'
  ])
  ..addAll(projects.where((p) => p.type != 'animation').map((p) => projectToListTile(p)));

  final fileContents = """
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  
  void launchProject() {

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new ListView(
        children: [
          ${projectItems.join(',\r\n\t\t\t\t\t')}
        ]
      )
    );
  }
}
""";

  mainFile.writeAsStringSync(fileContents);
}

String createListHeader(String name, String icon) {
  return "new ListTile(leading: const Icon($icon), title: const Text('$name'))";
}

String projectToListTile(Project project) {
  return "new ListTile(title: const Text(\"${project.name}\"), subtitle: const Text(\"${project.description}\"), trailing: const Text(\"${project.author}\"), onTap: () => launchProject())";
}