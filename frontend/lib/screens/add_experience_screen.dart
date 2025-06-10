import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddExperienceScreen extends StatefulWidget {
  @override
  _AddExperienceScreenState createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  List<String> rounds = ['Technical Round 1'];
  
  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final studentNameController = TextEditingController();
  final branchController = TextEditingController();
  final yearController = TextEditingController();
  final experienceController = TextEditingController();
  final tipsController = TextEditingController();
  
  void addRound() {
    setState(() {
      rounds.add('Technical Round ${rounds.length + 1}');
    });
  }

  void removeRound(int index) {
    setState(() {
      rounds.removeAt(index);
    });
  }

  Future<void> submitExperience() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await ApiService.addExperience({
        'companyName': companyController.text,
        'role': roleController.text,
        'studentName': studentNameController.text,
        'branch': branchController.text,
        'year': int.parse(yearController.text),
        'experience': experienceController.text,
        'rounds': rounds,
        'tips': tipsController.text.isEmpty ? null : tipsController.text,
      });

      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Interview Experience'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: companyController,
              decoration: InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: roleController,
              decoration: InputDecoration(
                labelText: 'Role/Position',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the role';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: studentNameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: branchController,
                    decoration: InputDecoration(
                      labelText: 'Branch',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your branch';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: yearController,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter year';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 2000 || year > 2100) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Interview Rounds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...List.generate(
              rounds.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: rounds[index],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        onChanged: (value) => rounds[index] = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter round name';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (rounds.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                        onPressed: () => removeRound(index),
                      ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: addRound,
              icon: Icon(Icons.add),
              label: Text('Add Round'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: experienceController,
              decoration: InputDecoration(
                labelText: 'Interview Experience',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please share your interview experience';
                }
                if (value.length < 50) {
                  return 'Please provide more details (minimum 50 characters)';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: tipsController,
              decoration: InputDecoration(
                labelText: 'Tips for Others (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : submitExperience,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit Experience', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
