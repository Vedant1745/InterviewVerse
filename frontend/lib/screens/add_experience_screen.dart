import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddExperienceScreen extends StatefulWidget {
  @override
  _AddExperienceScreenState createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final nameController = TextEditingController();
  final branchController = TextEditingController();
  final yearController = TextEditingController();
  final experienceController = TextEditingController();
  final roundsController = TextEditingController();
  final tipsController = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();

    final body = {
      "companyName": companyController.text,
      "role": roleController.text,
      "studentName": nameController.text,
      "branch": branchController.text,
      "year": int.parse(yearController.text),
      "experience": experienceController.text,
      "rounds": roundsController.text.split(','),
      "tips": tipsController.text,
    };

    final res = await http.post(
      Uri.parse('http://YOUR_IP:PORT/api/experience'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${prefs.getString('token')}',
      },
      body: json.encode(body),
    );

    setState(() => loading = false);
    if (res.statusCode == 201) {
      Navigator.pop(context);
    } else {
      final msg = json.decode(res.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Experience')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: companyController,
                decoration: InputDecoration(labelText: 'Company')),
            TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role')),
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Your Name')),
            TextField(
                controller: branchController,
                decoration: InputDecoration(labelText: 'Branch')),
            TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number),
            TextField(
                controller: experienceController,
                decoration: InputDecoration(labelText: 'Experience'),
                maxLines: 5),
            TextField(
                controller: roundsController,
                decoration:
                    InputDecoration(labelText: 'Rounds (comma separated)')),
            TextField(
                controller: tipsController,
                decoration: InputDecoration(labelText: 'Tips (optional)'),
                maxLines: 2),
            SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: submit, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
