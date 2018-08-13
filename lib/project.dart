import 'dart:io';

import 'package:yaml/yaml.dart';

class Project {
  const Project({this.name, this.description, this.author, this.url, this.type, this.mainPath, this.tags});
  
  final String name;
  final String description;
  final String author;
  final String url;
  final String type;
  final String mainPath;
  final List<String> tags;

  factory Project.fromPubspec(File file) {
    final doc = loadYaml(file.readAsStringSync());

    final showcase = doc['flutter_showcase'];

    return new Project(
      name: showcase['name'] ?? '',
      description: showcase['description'] ?? '',
      author: showcase['author'] ?? '',
      url: showcase['project-url'] ?? '',
      type: showcase['type'] ?? '',
      mainPath: file.parent.path + 'main.dart',
      tags: (showcase['tags'] ?? []).where((t) => t.isNotEmpty).map((t) => t.trim())
    );
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
      mainPath: \"$mainPath\",
      tags: $rawTags
    )
    """;
  }
}