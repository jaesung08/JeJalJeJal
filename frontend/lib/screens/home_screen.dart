import 'package:flutter/material.dart';
import 'package:jejal_project/screens/main_call_screen.dart';
import 'package:jejal_project/screens/select_file_screen.dart';

import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,  // 여기서 탭의 수를 정확하게 설정
      vsync: this,
      initialIndex: 0,
      animationDuration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),  // 상단 여백 추가
            child: Image.asset(
              'assets/images/jejal_logo.png',
              width: 150,
              height: 100,
            ),
          ),
          SizedBox(height: 10),  // 로고와 탭바 사이의 여백 조절
          _tabBar(),
          Expanded(child: _tabBarView()),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return TabBar(
      controller: tabController,
      tabs: const [
        Tab(text: "전화 통역"),
        Tab(text: "파일 통역"),
      ],
      indicatorColor: Colors.orange,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      overlayColor: MaterialStateProperty.all(
        Colors.amber.shade100,
      ),
    );
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        MainCallScreen(databaseService: DatabaseService()),
        SelectFileScreen(),
      ],
    );
  }
}
