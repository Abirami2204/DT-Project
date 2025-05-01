import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class CreateDietScreen extends StatefulWidget {
  @override
  _CreateDietScreenState createState() => _CreateDietScreenState();
}

class _CreateDietScreenState extends State<CreateDietScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedDiet;
  String? _activityLevel;

  final List<String> _goals = ['Weight Loss', 'Muscle Gain', 'Maintenance'];
  final List<String> _diets = ['Vegetarian', 'Non-Vegetarian', 'Vegan'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active'
  ];

  Future<void> _generateDiet() async {
    final url = Uri.parse("http://127.0.0.1:5000/get_diet");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "age": int.tryParse(_ageController.text),
        "gender": _selectedGender,
        "height": double.tryParse(_heightController.text),
        "weight": double.tryParse(_weightController.text),
        "activity_level": _activityLevel,
        "fitness_goal": _selectedGoal,
        "dietary_preference": _selectedDiet
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Save to Firebase using UID
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('diets').doc(uid).set({
          'age': _ageController.text,
          'gender': _selectedGender,
          'height': _heightController.text,
          'weight': _weightController.text,
          'goal': _selectedGoal,
          'diet': _selectedDiet,
          'activity_level': _activityLevel,
          'breakfast': data['breakfast'],
          'lunch': data['lunch'],
          'dinner': data['dinner'],
          'snack': data['snack'],
          'daily_calories': data['daily_calories'],
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DietPlanScreen(dietData: data),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch diet plan")),
      );
    }
  }

  Widget _buildDropdown(String label, String? selectedValue,
      List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: options
              .map((e) => DropdownMenuItem(child: Text(e), value: e))
              .toList(),
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Diet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Age"),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Height (cm)"),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Weight (kg)"),
            ),
            SizedBox(height: 12),
            _buildDropdown("Gender", _selectedGender, _genders,
                (val) => setState(() => _selectedGender = val)),
            _buildDropdown("Select Goal", _selectedGoal, _goals,
                (val) => setState(() => _selectedGoal = val)),
            _buildDropdown("Diet Preference", _selectedDiet, _diets,
                (val) => setState(() => _selectedDiet = val)),
            _buildDropdown("Activity Level", _activityLevel, _activityLevels,
                (val) => setState(() => _activityLevel = val)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateDiet,
              child: Text("Generate & Save Diet"),
            )
          ],
        ),
      ),
    );
  }
}

class DietPlanScreen extends StatelessWidget {
  final Map<String, dynamic> dietData;

  const DietPlanScreen({required this.dietData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Diet Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Based on your preferences:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            _buildMealTile("Breakfast", dietData["breakfast"]),
            _buildMealTile("Lunch", dietData["lunch"]),
            _buildMealTile("Dinner", dietData["dinner"]),
            _buildMealTile("Snack", dietData["snack"]),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTile(String title, dynamic value) {
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? "Not Available"),
      ),
    );
  }
}
