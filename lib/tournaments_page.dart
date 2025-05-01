import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({Key? key}) : super(key: key);

  @override
  _TournamentsPageState createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  String? selectedCountry;
  String? selectedState;

  final Map<String, List<String>> countryStates = {
    "USA": ["California", "Texas", "New York"],
    "India": ["Maharashtra", "Karnataka", "Tamil Nadu"],
    "UK": ["London", "Manchester", "Birmingham"],
    "Australia": ["New South Wales", "Victoria", "Queensland"],
  };

  final Map<String, List<Map<String, String>>> tournaments = {
    "California": [
      {
        "name": "LA Open",
        "date": "June 10, 2025",
        "ground": "LA Stadium",
        "prize": "\$10,000"
      },
      {
        "name": "SF Grand Slam",
        "date": "July 5, 2025",
        "ground": "SF Arena",
        "prize": "\$15,000"
      },
    ],
    "Texas": [
      {
        "name": "Texas Masters",
        "date": "August 12, 2025",
        "ground": "Dallas Court",
        "prize": "\$8,000"
      },
    ],
    "Maharashtra": [
      {
        "name": "Mumbai Open",
        "date": "May 20, 2025",
        "ground": "Wankhede Stadium",
        "prize": "₹1,00,000"
      },
    ],
    "Karnataka": [
      {
        "name": "Bangalore Championship",
        "date": "April 15, 2025",
        "ground": "Chinnaswamy Stadium",
        "prize": "₹50,000"
      },
    ],
    "London": [
      {
        "name": "London Cup",
        "date": "September 8, 2025",
        "ground": "Wimbledon",
        "prize": "£5,000"
      },
    ],
    "New South Wales": [
      {
        "name": "Sydney Open",
        "date": "October 3, 2025",
        "ground": "Sydney Cricket Ground",
        "prize": "A12,000 USD"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Tournaments"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Country",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedCountry,
              items: countryStates.keys.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountry = value;
                  selectedState = null; // Reset state selection
                });
              },
            ),
            const SizedBox(height: 16),
            const Text("Select State",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedState,
              items: selectedCountry != null
                  ? countryStates[selectedCountry!]!.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state));
                    }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedState = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text("Available Tournaments",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: selectedState == null
                  ? const Center(
                      child: Text("Select a state to see tournaments."))
                  : ListView(
                      children: tournaments[selectedState] != null
                          ? tournaments[selectedState]!.map((tournament) {
                              return TournamentCard(
                                name: tournament["name"]!,
                                date: tournament["date"]!,
                                ground: tournament["ground"]!,
                                prize: tournament["prize"]!,
                                country: selectedCountry!,
                                state: selectedState!,
                              );
                            }).toList()
                          : [
                              const Center(
                                  child: Text("No tournaments available."))
                            ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TournamentCard extends StatelessWidget {
  final String name;
  final String date;
  final String ground;
  final String prize;
  final String country;
  final String state;

  const TournamentCard({
    Key? key,
    required this.name,
    required this.date,
    required this.ground,
    required this.prize,
    required this.country,
    required this.state,
  }) : super(key: key);

  void saveTournamentToFirebase(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection("tournaments").add({
        "userId": user.uid,
        "name": name,
        "date": date,
        "ground": ground,
        "prize": prize,
        "country": country,
        "state": state,
        "timestamp": FieldValue.serverTimestamp(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$name selected successfully!")),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving tournament: $error")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $date"),
            Text("Ground: $ground"),
            Text("Prize: $prize"),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => saveTournamentToFirebase(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: const Text("Select", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
