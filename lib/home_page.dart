import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'coaches_page.dart';
import 'tournaments_page.dart';
import 'sponsors_page.dart';
import 'teams_page.dart';
import 'physio_page.dart';
import 'diet_page.dart';

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF778090),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Athletepro.png', height: 30),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Dynamic Username Display**
            Text(
              "Hello, $username!",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),

            // **Action Buttons**
            Expanded(
              child: ListView(
                children: [
                  homeButton("Find Coaches", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CoachesPage()),
                    );
                  }),
                  homeButton("Find Sponsors", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SponsorsPage()),
                    );
                  }),
                  homeButton("Find Tournaments", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TournamentsPage()),
                    );
                  }),
                  homeButton("Find Teams", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeamsPage()),
                    );
                  }),
                  homeButton("Find Physio", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PhysioPage()),
                    );
                  }),
                  homeButton("Diet", () {
                    // ✅ Added Diet Tab
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DietPage()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),

      // **Updated Bottom Navigation Bar (Removed Search & Favorites)**
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(username: username)),
            );
          }
        },
      ),
    );
  }

  // **Reusable Button Widget**
  Widget homeButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
