import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhysioPage extends StatefulWidget {
  const PhysioPage({super.key});

  @override
  _PhysioPageState createState() => _PhysioPageState();
}

class _PhysioPageState extends State<PhysioPage> {
  String searchQuery = "";

  // Hardcoded physiotherapists list (used if Firebase is empty)
  final List<Map<String, dynamic>> dummyPhysios = [
    {
      "name": "Dr. John Smith",
      "location": "New York",
      "rating": 4.8,
      "fee": 100
    },
    {
      "name": "Dr. Lisa Ray",
      "location": "Los Angeles",
      "rating": 4.5,
      "fee": 120
    },
    {
      "name": "Dr. Mark Johnson",
      "location": "Chicago",
      "rating": 4.7,
      "fee": 110
    },
    {
      "name": "Dr. Sophie Green",
      "location": "Houston",
      "rating": 4.6,
      "fee": 90
    },
    {
      "name": "Dr. Emma White",
      "location": "San Francisco",
      "rating": 4.9,
      "fee": 130
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Physio"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Physiotherapists...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('physiotherapists')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                List<Map<String, dynamic>> physiosList = [];

                // If Firebase has data, use it; otherwise, use dummy data
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  physiosList = snapshot.data!.docs.map((doc) {
                    return {
                      "name": doc['name'],
                      "location": doc['location'],
                      "rating": doc['rating'],
                      "fee": doc['fee'],
                    };
                  }).toList();
                } else {
                  physiosList = dummyPhysios;
                }

                // Apply search filter
                var filteredPhysios = physiosList.where((physio) {
                  return physio['name']
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredPhysios.length,
                  itemBuilder: (context, index) {
                    var physio = filteredPhysios[index];
                    return ListTile(
                      title: Text(physio['name']),
                      subtitle: Text(
                        "Location: ${physio['location']}\nRating: ${physio['rating']} ⭐\nFee: \$${physio['fee']}",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('user_selections')
                            .add({
                          'type': 'physio',
                          'name': physio['name'],
                          'location': physio['location'],
                          'rating': physio['rating'],
                          'fee': physio['fee'],
                        });
                        Navigator.pop(context); // Navigate back after selection
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
