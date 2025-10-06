import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Check extends StatefulWidget {
  final Map<String, dynamic> task; // get selected task

  const Check({super.key, required this.task});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  Future<void> markAsComplete(String id) async {
    final url = Uri.parse(
      "https://taskmanagement-3efe7-default-rtdb.firebaseio.com/tasks/$id.json",
    );

    await http.patch(url, body: jsonEncode({"completed": true}));
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text("Task Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Task: ${task['taskname']}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text("Description: ${task['taskdes']}"),
            SizedBox(height: 8),
            Text("Date: ${task['date']}"),
            Text("Time: ${task['time']}"),
            Image.network(
              task['image'] ?? 'https://via.placeholder.com/150',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await markAsComplete(task['id']);
                Navigator.pop(context, true);
              },
              child: Text("Mark as Complete"),
            ),
          ],
        ),
      ),
    );
  }
}
