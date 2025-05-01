import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SponsorsPage extends StatefulWidget {
  @override
  _SponsorsPageState createState() => _SponsorsPageState();
}

class _SponsorsPageState extends State<SponsorsPage> {
  String? selectedSponsor;

  final List<Map<String, String>> sponsorsList = [
    {'name': 'Nike', 'location': 'New York', 'funding': '\$100,000'},
    {'name': 'Adidas', 'location': 'Los Angeles', 'funding': '\$80,000'},
    {'name': 'Puma', 'location': 'Chicago', 'funding': '\$70,000'},
  ];

  Future<void> _selectSponsor(String sponsorName) async {
    try {
      await FirebaseFirestore.instance.collection('sponsors').add({
        'sponsor': sponsorName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        selectedSponsor = sponsorName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$sponsorName selected successfully!')),
      );
    } catch (e) {
      print('Error saving sponsor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select sponsor. Try again!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Sponsors')),
      body: ListView.builder(
        itemCount: sponsorsList.length,
        itemBuilder: (context, index) {
          final sponsor = sponsorsList[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(sponsor['name']!),
              subtitle: Text(
                'Location: ${sponsor['location']}\nFunding: ${sponsor['funding']}',
              ),
              trailing: ElevatedButton(
                onPressed: () => _selectSponsor(sponsor['name']!),
                child: Text('Select'),
              ),
            ),
          );
        },
      ),
    );
  }
}
