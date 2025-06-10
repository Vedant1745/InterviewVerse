import 'package:flutter/material.dart';
import 'add_experience_screen.dart';
import 'login_screen.dart';
import '../models/experience.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Experience> experiences = [];
  bool loading = true;
  String? error;
  String? userName;
  String? userEmail;
  String? userId;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchExperiences();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name');
      userEmail = prefs.getString('user_email');
      userId = prefs.getString('user_id');
    });
  }

  Future<void> fetchExperiences() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await ApiService.getExperiences();
      setState(() {
        experiences = data.map((e) => Experience.fromJson(e)).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  List<Experience> get filteredExperiences {
    if (searchQuery.isEmpty) return experiences;
    return experiences.where((exp) {
      return exp.companyName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          exp.role.toLowerCase().contains(searchQuery.toLowerCase()) ||
          exp.studentName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          exp.branch.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear all stored data
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExperience(String id) async {
    try {
      await ApiService.deleteExperience(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Experience deleted successfully')),
      );
      fetchExperiences(); // Refresh the list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Experience'),
        content: Text(
            'Are you sure you want to delete this interview experience? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExperience(id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool canDeleteExperience(Experience exp) {
    return userId != null && exp.postedBy != null && exp.postedBy == userId;
  }

  void _showExperienceDetails(Experience exp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp.companyName, style: TextStyle(fontSize: 24)),
                      Text(exp.role,
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (canDeleteExperience(exp))
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(exp.id);
                    },
                    tooltip: 'Delete Experience',
                  ),
              ],
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailSection(
                  title: 'Student Details',
                  content: '${exp.studentName}\n${exp.branch} (${exp.year})',
                ),
                SizedBox(height: 16),
                _DetailSection(
                  title: 'Interview Experience',
                  content: exp.experience,
                ),
                SizedBox(height: 16),
                _DetailSection(
                  title: 'Interview Rounds',
                  content: exp.rounds.map((r) => '• $r').join('\n'),
                ),
                if (exp.tips != null && exp.tips!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  _DetailSection(
                    title: 'Tips',
                    content: exp.tips!,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview Vault'),
        actions: [
          if (userName != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Welcome, $userName',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          IconButton(
            onPressed: _showLogoutDialog,
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by company, role, or student...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchExperiences,
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error loading experiences',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 8),
                              Text(
                                error!,
                                style: TextStyle(color: Colors.red),
                              ),
                              TextButton(
                                onPressed: fetchExperiences,
                                child: Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : filteredExperiences.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty
                                    ? 'No experiences shared yet'
                                    : 'No matching experiences found',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredExperiences.length,
                              padding: EdgeInsets.all(8),
                              itemBuilder: (ctx, i) {
                                final exp = filteredExperiences[i];
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exp.companyName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (canDeleteExperience(exp))
                                          IconButton(
                                            icon: Icon(Icons.delete_outline,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _showDeleteConfirmation(exp.id),
                                            tooltip: 'Delete Experience',
                                          ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text(
                                          exp.role,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${exp.studentName} • ${exp.branch} (${exp.year})',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showExperienceDetails(exp),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExperienceScreen()),
          );
          if (result == true) {
            fetchExperiences();
          }
        },
        icon: Icon(Icons.add),
        label: Text('Share Experience'),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;

  const _DetailSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
