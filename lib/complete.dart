import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Complete extends StatefulWidget {
  const Complete({super.key});

  @override
  State<Complete> createState() => _CompleteState();
}

class _CompleteState extends State<Complete> {
  Future<List<Map<String, dynamic>>> fetchCompletedTasks() async {
    final response = await http.get(
      Uri.parse(
        "https://taskmanagement-3efe7-default-rtdb.firebaseio.com/tasks.json",
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data == null) return [];
      List<Map<String, dynamic>> completedTasks = [];
      data.forEach((key, value) {
        if (value['completed'] == true) {
          completedTasks.add({
            'id': key,
            'taskname': value['taskname'] ?? "",
            'taskdes': value['taskdes'] ?? "",
            'date': value['Date'] ?? "",
            'time': value['Time'] ?? "",
            'completed': value['completed'] ?? false,
          });
        }
      });

      return completedTasks;
    } else {
      throw Exception("Error fetching completed tasks");
    }
  }

  Future<void> deleteTask(String id) async {
    final url = Uri.parse(
      "https://taskmanagement-3efe7-default-rtdb.firebaseio.com/tasks/$id.json",
    );
    await http.delete(url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Completed Tasks")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCompletedTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final tasks = snapshot.data!;
            if (tasks.isEmpty) {
              return Center(child: Text("No completed tasks"));
            }
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(task['taskname'] ?? "No Task Name"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['taskdes'] ?? "No Description"),
                        Text(
                          "📅 ${task['date'] ?? ""}   🕒 ${task['time'] ?? ""}",
                        ),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        deleteTask(task['id']);
                      },
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("No data found"));
          }
        },
      ),
    );
  }
}
