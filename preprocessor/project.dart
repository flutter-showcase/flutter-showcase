import 'dart:io';

import 'package:yaml/yaml.dart';

class Project {
  const Project({this.name, this.description, this.author, this.url, this.type});
  
  final String name;
  final String description;
  final String author;
  final String url;
  final String type;

  factory Project.fromPubspec(File file) {
    final doc = loadYaml(file.readAsStringSync());

    final showcase = doc['flutter_showcase'];
    return new Project(
      name: showcase['name'] ?? '',
      description: showcase['description'] ?? '',
      author: showcase['author'] ?? '',
      url: showcase['project-url'] ?? '',
      type: showcase['type'] ?? ''
    );
  }
}