import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'welcomescreen.dart';
import 'homescreen.dart';
import 'walker/walker_homescreen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getUserRole(String uid) async {
  debugPrint("Auth UID: $uid");

  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    debugPrint("Doc exists? ${doc.exists}");
    debugPrint("Doc data: ${doc.data()}");

    if (!doc.exists) return null;

    final role = doc.data()?['role'] as String?;
    debugPrint("ROLE from Firestore: $role");

    return role;
  } catch (e) {
    debugPrint("ERROR reading role: $e");
    return null;
  }
}



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        // loading
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnap.data;

        // not logged in -> welcome
        if (user == null) return const WelcomeScreen();

        // logged in -> check role
        return FutureBuilder<String?>(
          future: _getUserRole(user.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnap.data ?? 'user';

            if (role == 'walker') return const WalkerHomeScreen();
            
            return const HomeShell();
          },
        );
      },
    );
  }
}
