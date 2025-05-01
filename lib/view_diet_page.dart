import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDietPage extends StatefulWidget {
  @override
  _ViewDietPageState createState() => _ViewDietPageState();
}

class _ViewDietPageState extends State<ViewDietPage> {
  Map<String, dynamic>? _dietData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDietData();
  }

  Future<void> _fetchDietData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('diets').doc(uid).get();
    if (doc.exists) {
      setState(() {
        _dietData = doc.data();
        _isLoading = false;
      });
    } else {
      setState(() {
        _dietData = null;
        _isLoading = false;
      });
    }
  }

  Widget _buildMealCard(String title, String? meal) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(meal ?? 'Not available'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Diet Plan')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _dietData == null
              ? Center(child: Text('No diets saved'))
              : ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(
                      'Based on your preferences:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    _buildMealCard('Breakfast', _dietData?['breakfast']),
                    _buildMealCard('Lunch', _dietData?['lunch']),
                    _buildMealCard('Dinner', _dietData?['dinner']),
                    _buildMealCard('Snack', _dietData?['snack']),
                  ],
                ),
    );
  }
}
