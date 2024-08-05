import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/service/auth/auth_provider.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer_title.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => MyDrawerState();
}

class MyDrawerState extends State<MyDrawer> {
  late Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null) {
      setState(() {
        userData = jsonDecode(userJsonString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Image.asset(
              'assets/logo.png',
              width: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                  context,
                  userData['role'] == 'technical'
                      ? '/request-list'
                      : userData['role'] == 'admin'
                          ? '/dashboard'
                          : '/home');
            },
            child: const MyDrawerTitle(
              text: "HOME",
              icon: Icons.home,
            ),
          ),
          GestureDetector(
            onTap: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const MyDrawerTitle(
              text: "CERRAR SESION",
              icon: Icons.door_sliding_sharp,
            ),
          ),
        ],
      ),
    );
  }
}
