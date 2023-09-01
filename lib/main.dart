import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Task {
  Task({
    required this.name,
    required this.desc,
    required this.date,
    this.isExpanded = false,
    this.finished = false,
  });
  String name;
  String desc;
  DateTime date;
  bool isExpanded;
  bool finished;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/list': (context) => HomePage(),
        '/creation': (context) => CreationPage(),
      },
      initialRoute: '/list',
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  String _title = "";

  void _navigateToFormPage(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/creation');
    if (result != null && result is Task) {
      setState(() {
        tasks.add(result);
      });
    }
  }

  void _changeTitle(String newTitle) {
    // Function to change the title
    setState(() {
      _title = newTitle;
    });
  }

  void _showTitleInputDialog(BuildContext context) {
    String newTitle = ''; // Store user input

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Entrer le nouveau titre"),
          content: TextField(
            onChanged: (value) {
              newTitle = value; // Update user input as they type
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _changeTitle(newTitle); // Change the title
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Accueil'),
          backgroundColor: const Color.fromARGB(255, 79, 203, 83),
        ),
        body: Container(
            child: Column(
          children: [
            _buildPanel(),
            FloatingActionButton(
              onPressed: () {
                _navigateToFormPage(context);
              },
              child: Icon(Icons.add),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          tasks[index].isExpanded = !isExpanded;
        });
      },
      children: tasks.map<ExpansionPanel>((Task task) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              onTap: () {
                setState(() {
                  if (!task.finished) {
                    task.finished = true;
                  } else {
                    task.finished = false;
                  }
                });
              },
              onLongPress: () {
                _showTitleInputDialog(context);
                setState(() {
                  task.name = _title;
                });
              },
              title: Text(
                "${task.name} (${task.date.day}/${task.date.month}/${task.date.year})",
                style: TextStyle(
                    decoration: task.finished
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
              ),
            );
          },
          body: ListTile(
              title: Text(task.desc),
              subtitle: const Text('Supprimer'),
              trailing: const Icon(Icons.delete),
              onTap: () {
                setState(() {
                  tasks.removeWhere((Task currentTask) => task == currentTask);
                });
              }),
          isExpanded: task.isExpanded,
        );
      }).toList(),
    );
  }
}

class CreationPage extends StatefulWidget {
  @override
  _CreationPageState createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  void _addTask(BuildContext context) {
    String name = nameController.text;
    String desc = descController.text;
    print(dateController);
    DateTime date = DateTime.parse(dateController.text);
    Task task = Task(name: name, desc: desc, date: date);

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page de création')),
      body: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nom'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Entrer le nom';
              }
              return null;
            },
          ),
          TextFormField(
            controller: descController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Entrer une description';
              }
              return null;
            },
          ),
          TextField(
              controller: dateController,
              decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today), //icon of text field
                  labelText: "Entrer la date de fin" //label text of field
                  ),
              readOnly: false,
              //set it true, so that user will not able to edit text
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(2100));

                if (pickedDate != null) {
                  print(pickedDate);
                  dateController.text = pickedDate.toString();
                }
              }),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _addTask(context),
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
