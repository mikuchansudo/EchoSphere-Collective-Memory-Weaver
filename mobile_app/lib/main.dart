import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(EchoSphereApp());
}

class EchoSphereApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoSphere',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [SubmitScreen(), ViewScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EchoSphere')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Submit'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'View'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SubmitScreen extends StatefulWidget {
  @override
  _SubmitScreenState createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _submitMemory() async {
    final memory = _controller.text;
    if (memory.trim().isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('https://your-heroku-app.herokuapp.com/memories'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': memory}),
        );
        if (response.statusCode == 201) {
          _controller.clear();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Memory submitted successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit memory')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Share your memory',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitMemory,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class ViewScreen extends StatefulWidget {
  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<Map<String, dynamic>> memories = [];

  @override
  void initState() {
    super.initState();
    _fetchMemories();
  }

  Future<void> _fetchMemories() async {
    try {
      final response = await http.get(Uri.parse('https://your-heroku-app.herokuapp.com/memories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          memories = data.map((m) => m as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      print('Error fetching memories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchMemories,
      child: ListView.builder(
        itemCount: memories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(memories[index]['text']),
            subtitle: Text(
              DateTime.parse(memories[index]['createdAt']).toLocal().toString(),
              style: TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}