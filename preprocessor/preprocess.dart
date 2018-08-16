import 'dart:async';
import 'dart:io';
import 'package:app/project.dart';
import 'package:path/path.dart' as p;

void logError(String msg) {
  print('\u{1B}[31m$msg\u{1B}[0m');
}

void main() async {
  final projects = await getUserProjects();

  final errors = validateProjects(projects);
  if (errors.isNotEmpty) {
    logError("Errors found:");
    errors.forEach((e) => logError(e));
    return;
  }

  generateMain(projects);

  print('Done preprocessing.');
}

Future<List<Project>> getUserProjects() async {
  var projectsDir = new Directory('lib/user_content');

  final files = await projectsDir.list(recursive: true).toList();

  return (await Future.wait(files
    .where((f) => f is File && p.basename(f.path) == 'pubspec.yaml')
    .map((f) => Project.fromPubspec(f))))
    ..sort((p1, p2) => p1.name.compareTo(p2.name));
}

List<String> validateProjects(List<Project> projects) {
  return projects.fold<List<String>>([], (arr, p) {
    if (p.relativeMainPath == null) {
      return arr..add("'${p.name}' - '${p.author}': No 'main.dart' found.");
    }
    
    if (p.className == null) {
      return arr..add("'${p.name}' - '${p.author}': No 'runApp(...)' line was found.");
    }

    return arr;
  });
}

void generateMain(List<Project> projects) async {
  final mainFile = new File(p.join('lib', 'main.dart'));

  final imports = projects.map((p) {
    return "import 'package:app/user_content/${p.relativeMainPath}' as ${p.id};";
  }).join('\r\n');

  final fileContents = """
import 'package:app/project.dart';
import 'package:flutter/material.dart';
$imports

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FlutterShowcaseHome(title: 'Flutter Showcase'),
    );
  }
}

class FlutterShowcaseHome extends StatefulWidget {
  FlutterShowcaseHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => new _FlutterShowcaseHomeState();
}

class _FlutterShowcaseHomeState extends State<FlutterShowcaseHome> {
  List<String> _filters = [];

  String _searchText = '';

  static final List<Project> _allProjects = [
    ${projects.map((p) => p.toRawDart()).join(',\r\n')}
  ];

  final _FlutterShowcaseSearchDelegate _delegate = new _FlutterShowcaseSearchDelegate(_allProjects);

  void _launchProject(Project project) {
    Navigator.of(context).push(MaterialPageRoute(builder: (c) {
      GlobalKey<NavigatorState> appkey = GlobalKey<NavigatorState>();
      return WillPopScope(
        child: project.create(appkey),
        onWillPop: () async {
          if (appkey.currentState.canPop()) {
            appkey.currentState.pop();
            return false;
          }

          return true;
        },
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final projects = _allProjects
    .where((p) {
      final filters = _filters.map((f) => f.toLowerCase());
      final tags = [p.type.toLowerCase(), p.name.toLowerCase()]..addAll(p.tags.map((t) => t.toLowerCase()));
      return (_filters.isEmpty || tags.any((t) => filters.contains(t))) &&
        (_searchText.isEmpty || tags.any((t) => t.contains(_searchText.toLowerCase())));
    })
    .map((p) => new _ProjectCard(
      project: p,
      onPressed: () => _launchProject(p),
    ));

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          new IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final Project selected = await showSearch<Project>(
                context: context,
                delegate: _delegate,
              );

              if (selected != null) {
                _launchProject(selected);
              }
            },
          ),
        ],
      ),
      body: new ListView(
        children: [
          const SizedBox(height: 6.0,),
          new Text("Showcase", style: Theme.of(context).textTheme.headline, textAlign: TextAlign.center),
          const Divider(),
        ]
        ..addAll([${createFilterChips(projects)}])
        ..addAll(projects)
      )
    );
  }
}

class _ProjectTile extends StatelessWidget {
  _ProjectTile({Key key, @required this.project, this.onPressed}) : super(key: key);

  final Project project;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(project.name),
      subtitle: new Text(project.description),
      trailing: new Text(project.author),
      onTap: onPressed
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({Key key, @required this.project, this.onPressed}) : super(key: key);

  final Project project;
  final Function onPressed;

  Widget createChip({String text}) {
    return new Padding(
      padding: const EdgeInsets.all(4.0),
      child: new Chip(
        label: new Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagWidgets = [createChip(text: project.type)]
    ..addAll(project.tags.map((t) => createChip(text: t)));

    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new _ProjectTile(
            project: project,
            onPressed: onPressed
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: new Wrap(
              children: tagWidgets
            )
          )
        ]
      )
    );
  }
}

class _FlutterShowcaseSearchDelegate extends SearchDelegate<Project> {
  _FlutterShowcaseSearchDelegate(List<Project> data):
    this._data = data;

  final List<Project> _data;

  @override
  Widget buildLeading(BuildContext context) {
    return new IconButton(
      tooltip: 'Back',
      icon: new AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _data.where((p) {
      final tags = [p.type.toLowerCase(), p.name.toLowerCase()]..addAll(p.tags.map((t) => t.toLowerCase()));
      return query.isEmpty || tags.any((t) => t.contains(query.toLowerCase()));
    });

    if (results.isEmpty) {
      return new Center(
        child: new Text(
          'No projects were found.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return new ListView(
      children: results.map((p) {
        return new _ProjectTile(
          project: p,
          onPressed: () => close(context, p)
        );
      }).toList()
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isEmpty) {
      return <Widget>[];
    }

    return <Widget>[
      new IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }
}
""";

  mainFile.writeAsStringSync(fileContents);
}

String createFilterChips(List<Project> projects) {
  final chips = ["Animation", "Other"].map((type) {
    return """
    new Padding(
      padding: const EdgeInsets.all(4.0),
      child: new FilterChip(
        label: const Text(\"$type\"),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _filters.add(\"$type\");
            } else {
              _filters.remove(\"$type\");
            }
          });
        },
        selected: _filters.contains(\"$type\")
      ),
    )
    """;
  });

  return """
  new Padding(
    padding: const EdgeInsets.all(6.0),
    child: new Wrap(
      children: [
        ${chips.join(', \r\n')}
      ]
    )
  )
  """;
}
