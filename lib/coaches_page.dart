import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoachesPage extends StatefulWidget {
  const CoachesPage({super.key});

  @override
  _CoachesPageState createState() => _CoachesPageState();
}

class _CoachesPageState extends State<CoachesPage> {
  String? selectedSport;

  final List<String> sports = [
    "Basketball",
    "Cricket",
    "Football",
    "Swimming",
    "Tennis"
  ]..sort();

  final Map<String, List<Map<String, dynamic>>> coaches = {
    "Football": [
      {
        "name": "John Smith",
        "age": 35,
        "location": "New York",
        "rating": 4.8,
        "fee": "\$50/hr"
      },
      {
        "name": "Mike Johnson",
        "age": 40,
        "location": "Los Angeles",
        "rating": 4.5,
        "fee": "\$45/hr"
      },
    ],
    "Basketball": [
      {
        "name": "Sarah Brown",
        "age": 30,
        "location": "Chicago",
        "rating": 4.9,
        "fee": "\$60/hr"
      },
      {
        "name": "David Wilson",
        "age": 42,
        "location": "Houston",
        "rating": 4.6,
        "fee": "\$55/hr"
      },
    ],
    "Cricket": [
      {
        "name": "Rahul Sharma",
        "age": 38,
        "location": "Mumbai",
        "rating": 4.7,
        "fee": "\$40/hr"
      },
      {
        "name": "Steve Williams",
        "age": 45,
        "location": "Sydney",
        "rating": 4.5,
        "fee": "\$50/hr"
      },
    ],
    "Swimming": [
      {
        "name": "Emily Watson",
        "age": 29,
        "location": "Miami",
        "rating": 4.9,
        "fee": "\$55/hr"
      },
      {
        "name": "Jake Martin",
        "age": 36,
        "location": "San Diego",
        "rating": 4.6,
        "fee": "\$48/hr"
      },
    ],
    "Tennis": [
      {
        "name": "Roger Blake",
        "age": 41,
        "location": "London",
        "rating": 4.8,
        "fee": "\$65/hr"
      },
      {
        "name": "Anna Rodriguez",
        "age": 34,
        "location": "Madrid",
        "rating": 4.7,
        "fee": "\$60/hr"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF778090),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text("Find Coaches", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select a Sport",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSport,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: sports.map((sport) {
                return DropdownMenuItem(
                    value: sport,
                    child: Text(sport,
                        style: const TextStyle(color: Colors.black)));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSport = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedSport == null
                  ? const Center(
                      child: Text("Select a sport to view coaches",
                          style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: coaches[selectedSport]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final coach = coaches[selectedSport]![index];
                        return CoachCard(
                          name: coach["name"],
                          age: coach["age"],
                          location: coach["location"],
                          rating: coach["rating"],
                          fee: coach["fee"],
                          sport: selectedSport!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoachCard extends StatelessWidget {
  final String name;
  final int age;
  final String location;
  final double rating;
  final String fee;
  final String sport;

  const CoachCard(
      {super.key,
      required this.name,
      required this.age,
      required this.location,
      required this.rating,
      required this.fee,
      required this.sport});

  void saveCoachSelection(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('coaches').doc(user.uid).set({
        'selectedSport': sport,
        'selectedCoach': {
          'name': name,
          'age': age,
          'location': location,
          'rating': rating,
          'fee': fee
        },
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Coach $name selected!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => saveCoachSelection(context), // Let the user tap to select
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white)),
          title:
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              "Age: $age | Location: $location\nRating: ⭐$rating | Fee: $fee"),
          isThreeLine: true,
        ),
      ),
    );
  }
}
