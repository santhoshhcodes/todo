import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/check.dart';
import 'package:my_app/complete.dart';
import 'package:my_app/task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final response = await http.get(
      Uri.parse(
        "https://taskmanagement-3efe7-default-rtdb.firebaseio.com/tasks.json",
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data == null) return [];
      List<Map<String, dynamic>> loadedTasks = [];
      data.forEach((key, value) {
        if (value['completed'] == false || value['completed'] == null) {
          loadedTasks.add({
            'id': key,
            'taskname': value['taskname'],
            'taskdes': value['taskdes'],
            'date': value['Date'],
            'time': value['Time'],
            'image': value['image'] ?? 'https://via.placeholder.com/150',
            'completed': value['completed'] ?? false,
          });
        }
      });

      return loadedTasks;
    } else {
      throw Exception("Error fetching tasks");
    }
  }

  late Future<List<Map<String, dynamic>>> futureTAsk;
  @override
  void initState() {
    super.initState();
    futureTAsk = fetchTasks();
  }

  void refreshData() {
    setState(() {
      futureTAsk = fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Task Box",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          PopupMenuButton<int>(
            color: Colors.white,
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Complete()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [Text("Completed"), Icon(Icons.check_circle)],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: futureTAsk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            final tasks = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                refreshData();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color.fromARGB(
                          255,
                          127,
                          250,
                          131,
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Task()),
                        );
                        // refreshData();
                      },

                      child: Text(
                        "Add New Task",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (BuildContext context, index) {
                        final task = tasks[index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(task['taskname'] ?? "No Task Name"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: Image.network(
                                    task['image'] ??
                                        'https://via.placeholder.com/150',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(task['taskdes'] ?? "No Description"),
                                Text(
                                  "📅 ${task['date'] ?? ""}   🕒 ${task['time'] ?? ""}",
                                ),
                              ],
                            ),

                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Check(task: task),
                                ),
                              );
                              if (result == true) {
                                refreshData();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Text("No tasks found");
          }
        },
      ),
    );
  }
}
