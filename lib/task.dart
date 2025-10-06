import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class Task extends StatefulWidget {
  const Task({super.key});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  String? selectedDate;
  String? selectedTime;

  final _formKey = GlobalKey<FormState>();
  final taskNameController = TextEditingController();
  final taskDesController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final Image = TextEditingController();

  Future<void> addTask() async {
    final url = Uri.parse(
      "https://taskmanagement-3efe7-default-rtdb.firebaseio.com/tasks.json",
    );

    await http.post(
      url,
      body: jsonEncode({
        "taskname": taskNameController.text,
        "taskdes": taskDesController.text,
        "Date": dateController.text,
        "Time": timeController.text,
        "image": Image.text,
        "completed": false,
      }),
    );
  }

  Future<void> pickDate() async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(),
      value: [],
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );
    if (results != null && results.isNotEmpty) {
      setState(() {
        selectedDate =
            "${results[0]!.day}-${results[0]!.month}-${results[0]!.year}";
        dateController.text = selectedDate!;
      });
    }
  }

  Future<void> pickTime() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        DateTime picked = DateTime.now();
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Select Time", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              TimePickerSpinner(
                is24HourMode: false,
                spacing: 40,
                itemHeight: 60,
                isForce2Digits: true,
                normalTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
                highlightedTextStyle: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                ),
                onTimeChange: (time) {
                  picked = time;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedTime =
                        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                    timeController.text = selectedTime!;
                  });
                  Navigator.pop(context);
                },
                child: Text("Confirm"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: taskNameController,
                decoration: InputDecoration(labelText: "Task Name"),
                validator: (value) => value!.isEmpty ? "Enter task name" : null,
              ),
              TextFormField(
                controller: taskDesController,
                decoration: InputDecoration(labelText: "Task Description"),
              ),
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: pickDate,
                decoration: InputDecoration(
                  labelText: "Select Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              TextFormField(
                controller: timeController,
                readOnly: true,
                onTap: pickTime,
                decoration: InputDecoration(
                  labelText: "Select Time",
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
              TextField(
                controller: Image,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await addTask();
                    Navigator.pop(context, true);
                  }
                },
                child: Text("Save Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
