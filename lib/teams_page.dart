import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  String? selectedSport;
  String? selectedTeam;

  final List<String> sports = ["Basketball", "Football", "Tennis"];

  final Map<String, List<Map<String, String>>> teams = {
    "Basketball": [
      {
        "name": "City Hoopers",
        "coach": "Coach John",
        "court": "Downtown Court",
        "matchesWon": "12"
      },
      {
        "name": "Thunder Strikers",
        "coach": "Coach Mike",
        "court": "Uptown Arena",
        "matchesWon": "9"
      },
    ],
    "Football": [
      {
        "name": "Elite Kickers",
        "coach": "Coach Dave",
        "court": "Central Park",
        "matchesWon": "15"
      },
      {
        "name": "Golden Boots",
        "coach": "Coach Sam",
        "court": "West Field",
        "matchesWon": "11"
      },
    ],
    "Tennis": [
      {
        "name": "Ace Masters",
        "coach": "Coach Chris",
        "court": "Sunrise Club",
        "matchesWon": "8"
      },
      {
        "name": "Smashers",
        "coach": "Coach Alex",
        "court": "Elite Tennis Center",
        "matchesWon": "14"
      },
    ],
  };

  Future<void> requestToJoinTeam() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedTeam != null) {
      try {
        await FirebaseFirestore.instance
            .collection('teams')
            .doc(selectedTeam)
            .set(
          {
            'requests':
                FieldValue.arrayUnion([user.uid]) // Adds user to requests
          },
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request sent to join $selectedTeam ✅")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Could not send request ❌")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Teams"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a Sport:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedSport,
              isExpanded: true,
              hint: Text("Choose a sport"),
              items: sports.map((sport) {
                return DropdownMenuItem<String>(
                  value: sport,
                  child: Text(sport),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSport = value;
                  selectedTeam = null; // Reset team selection
                });
              },
            ),
            SizedBox(height: 16),
            if (selectedSport != null) ...[
              Text(
                "Available Teams:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: teams[selectedSport]!.length,
                  itemBuilder: (context, index) {
                    var team = teams[selectedSport]![index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(team["name"]!),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("🏀 Sport: $selectedSport"),
                            Text("👨‍🏫 Coach: ${team["coach"]}"),
                            Text("📍 Court: ${team["court"]}"),
                            Text("🏆 Matches Won: ${team["matchesWon"]}"),
                          ],
                        ),
                        trailing: Radio<String>(
                          value: team["name"]!,
                          groupValue: selectedTeam,
                          onChanged: (value) {
                            setState(() {
                              selectedTeam = value;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (selectedTeam != null)
              Center(
                child: ElevatedButton(
                  onPressed: requestToJoinTeam,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text("Request to Join $selectedTeam"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
