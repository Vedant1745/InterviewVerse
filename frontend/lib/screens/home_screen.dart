import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_experience_screen.dart';
import 'login_screen.dart';
import '../models/experience.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Experience> experiences = [];
  bool loading = true;

  Future<void> fetchExperiences() async {
    final prefs = await SharedPreferences.getInstance();
    final res = await http.get(
      Uri.parse('http://YOUR_IP:PORT/api/experience'),
      headers: {
        'Authorization': 'Bearer ${prefs.getString('token')}',
      },
    );

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      setState(() {
        experiences = data.map((e) => Experience.fromJson(e)).toList();
        loading = false;
      });
    } else {
      print("Error fetching experiences");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  void initState() {
    fetchExperiences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview Vault'),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: experiences.length,
              itemBuilder: (ctx, i) {
                final exp = experiences[i];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('${exp.companyName} - ${exp.role}'),
                    subtitle: Text('By ${exp.studentName} (${exp.year})'),
                    isThreeLine: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('${exp.companyName} (${exp.role})'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Experience:\n${exp.experience}\n'),
                                Text('Rounds: ${exp.rounds.join(", ")}'),
                                if (exp.tips != null)
                                  Text('\nTips:\n${exp.tips}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Close"))
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddExperienceScreen())),
      ),
    );
  }
}
