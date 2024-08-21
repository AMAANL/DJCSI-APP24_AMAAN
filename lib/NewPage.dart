import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'SecondPage.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  List<Color> col = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
  int number = 0;
  List<Note> i = [];
  List<Note> filteredNotes = [];
  bool isDarkTheme = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
    loadThemePreference();
    searchController.addListener(() {
      filterNotes();
    });
  }

  void filterNotes() {
    List<Note> _notes = [];
    _notes.addAll(i);
    if (searchController.text.isNotEmpty) {
      _notes.retainWhere((note) {
        String searchTerm = searchController.text.toLowerCase();
        String noteTitle = note.name.toLowerCase();
        return noteTitle.contains(searchTerm);
      });
    }
    setState(() {
      filteredNotes = _notes;
    });
  }

  Future<void> saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesList = i.map((note) => note.toJson()).toList();
    await prefs.setStringList('notes', notesList);
  }

  Future<void> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesList = prefs.getStringList('notes');
    if (notesList != null) {
      setState(() {
        i = notesList.map((note) => Note.fromJson(note)).toList();
        filterNotes();
      });
    }
  }

  Future<void> saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkTheme);
  }

  Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? true; // Default to true
    setState(() {});
  }

  void addNote() {
    String? newNoteTitle;
    String? newNoteContent;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add a New Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    newNoteTitle = value;
                  },
                  decoration: InputDecoration(hintText: "Enter Note Title"),
                ),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (newNoteTitle != null && newNoteTitle!.isNotEmpty) {
                  setState(() {
                    number++;
                    i.add(Note(
                      id: number,
                      name: newNoteTitle!,
                      content: newNoteContent ?? '',
                    ));
                    filterNotes();
                    saveNotes(); // Save notes after adding a new note
                  });
                }
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }


  void deleteNote(Note note) {
    setState(() {
      i.removeWhere((element) => element.id == note.id);
      filterNotes();
      saveNotes(); // Save the updated list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.grey,
        onPressed: addNote,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notes',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Switch(
                    value: isDarkTheme,
                    onChanged: (value) {
                      setState(() {
                        isDarkTheme = value;
                        saveThemePreference();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredNotes.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 90),
                      Image.asset(
                        'assets/images/img.png',
                        height: 150,
                      ),
                      const Text(
                        'Create your first Note!!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SecondPage(note: note),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 100,
                                  color: col[note.id % col.length],
                                  child: Center(
                                    child: Text(
                                      note.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteNote(note);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
    );
  }
}

class Note {
  int id;
  String name;
  String content;

  Note({
    required this.id,
    required this.name,
    required this.content,
  });

  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'content':content,
    });
  }

  static Note fromJson(String json) {
    final data = jsonDecode(json);
    return Note(
      id: data['id'],
      name: data['name'],
      content: data['content'],
    );
  }
}
