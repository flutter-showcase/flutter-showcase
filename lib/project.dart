import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

class ProjectParseException implements Exception {
  ProjectParseException({ @required this.message });

  final String message;
}

class Project {
  const Project({
    this.name,
    this.description, 
    this.author, 
    this.url, 
    this.type, 
    this.relativeMainPath, 
    this.tags, 
    this.id, 
    this.create, 
    this.className});
  
  final String name;
  final String description;
  final String author;
  final String url;
  final String type;
  final String relativeMainPath;
  final String id;
  final List<String> tags;
  final Function create;
  final String className;

  static Future<Project> fromPubspec(File file) async {
    final mainFile = new File(file.parent.path + '/main.dart');
    if (!(await mainFile.exists())) {
      throw new ProjectParseException(message: "No 'main.dart' found in '${file.parent.path}'.");
    }

    final appClass = await determineAppClass(mainFile);
    if (appClass == null) {
      throw new ProjectParseException(message: "No 'runApp(...)' line was found in '${mainFile.path}'.");
    }

    final relativePath = file.parent.path.substring(file.parent.path.indexOf('user_content/') + 13);

    final showcase = loadYaml(await file.readAsString())['flutter_showcase'];
    return new Project(
      name: showcase['name'] ?? '',
      description: showcase['description'] ?? '',
      author: showcase['author'] ?? '',
      url: showcase['project-url'] ?? '',
      type: showcase['type'] ?? '',
      relativeMainPath: relativePath + '/main.dart',
      tags: (showcase['tags'] ?? []).map((t) => t.trim()).where((t) => t.isNotEmpty),
      id: relativePath.replaceAll('/', '_'),
      className: appClass
    );
  }

  static Future<String> determineAppClass(File file) async {
    final contents = await file.readAsLines();
    final expression = new RegExp(r'.*runApp\(new (.*)\(\)\);');

    final runLine = contents.firstWhere((l) => expression.hasMatch(l), orElse: () => null);
    
    return runLine == null ? null : expression.firstMatch(runLine).group(1);    
  }

  String toRawDart() {
    final rawTags = "[${tags.map((t) => '\"$t\"').join(', ')}]";

    return """
    new Project(
      name: \"$name\",
      description: \"$description\",
      author: \"$author\",
      url: \"$url\",
      type: \"$type\",
      relativeMainPath: \"$relativeMainPath\",
      tags: $rawTags,
      id: \"$id\",
      create: (navkey) => $id.$className(navkey: navkey),
      className: \"$className\",
    )""";
  }
}