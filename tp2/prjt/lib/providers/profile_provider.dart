// lib/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/userprofile_model.dart'; // Import the UserProfile model

// ProfileNotifier for managing the state
class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null);

  // Update the user profile
  void updateProfile(String name, String email) {
    state = UserProfile(name: name, email: email);
  }

  // Log out (clear the profile)
  void logOut() {
    state = null;
  }
}

// ProfileProvider to manage the profile state
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});
