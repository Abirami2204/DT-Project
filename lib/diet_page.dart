import 'package:flutter/material.dart';
import 'create_diet_page.dart';
import 'view_diet_page.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  _DietPageState createState() => _DietPageState();
}

class _DietPageState extends State<DietPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet"),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Create Diet"),
            Tab(text: "View Diet"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CreateDietScreen(),
          ViewDietPage(),
        ],
      ),
    );
  }
}
