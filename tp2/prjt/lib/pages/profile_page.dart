import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart'; // Import the ProfileProvider
import '../models/userprofile_model.dart'; // Import the UserProfile model

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the profile state
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: profile == null
          ? Center(child: Text('No profile found. Please log in.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${profile.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: ${profile.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Edit profile logic (if needed)
              },
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 20),
            // Log out button - only appears if the user is logged in
            ElevatedButton(
              onPressed: () {
                // Log out action
                ref.read(profileProvider.notifier).logOut();
              },
              child: Text('Log Out'),
              style: ElevatedButton.styleFrom(
               backgroundColor: Colors.red, // Red color for log out button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
