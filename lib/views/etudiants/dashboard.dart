import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modible_edt/views/etudiants/etdPage.dart';
import 'package:modible_edt/views/etudiants/homePage.dart';
import 'package:modible_edt/views/etudiants/notificationPage.dart';
import 'package:modible_edt/views/etudiants/profilePage.dart';

import '../../core/theme/colors.dart';
import '../../widgets/EtudiantBottomNavBar.dart';

class EtudiantDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EtudiantDashboardPage({super.key, this.userData});

  @override
  State<EtudiantDashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<EtudiantDashboardPage> {
  int _indexcourrant = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(userData: widget.userData),
      EdtPage(),
      NotificationPage(),
      ProfilePage(),
    ];
  }

  void _changerPage(int index) {
    setState(() {
      _indexcourrant = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _pages[_indexcourrant],
      bottomNavigationBar: BottomNavBarWidget(
        indexCourant: _indexcourrant,
        changerPage: _changerPage,
        primaryColor: primaryColor,
      ),
    );
  }
}
