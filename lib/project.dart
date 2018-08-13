import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

class Project {
  const Project({this.name, this.description, this.author, this.url, this.type, this.relativeMainPath, this.tags, this.id, this.create, this.className});
  
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
    final doc = loadYaml(file.readAsStringSync());

    final showcase = doc['flutter_showcase'];

    final relativePath = file.parent.path.substring(file.parent.path.indexOf('user_content/') + 13);

    final mainFile = new File(file.parent.path + '/main.dart');
    final contents = await mainFile.readAsLines();
    final appClass = new RegExp(r".*runApp\((.*)\)\);").firstMatch(contents.firstWhere((l) => l.contains(r'.*runApp\(.*\)\);')));

    //runApp(new MyApp())

    return new Project(
      name: showcase['name'] ?? '',
      description: showcase['description'] ?? '',
      author: showcase['author'] ?? '',
      url: showcase['project-url'] ?? '',
      type: showcase['type'] ?? '',
      relativeMainPath: relativePath + '/main.dart',
      tags: (showcase['tags'] ?? []).where((t) => t.isNotEmpty).map((t) => t.trim()),
      id: relativePath.replaceAll('/', '_')
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
      relativeMainPath: \"$relativeMainPath\",
      tags: $rawTags,
      id: \"$id\",
      create: (navkey) => $id.$className(navkey: navkey),
      className: \"$className\",
    )
    """;
  }
}