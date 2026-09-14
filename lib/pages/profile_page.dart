import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'orders_page.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile(String uid, String email) async {
    if (_formKey.currentState!.validate()) {
      UserProfile updatedProfile = UserProfile(
        uid: uid,
        name: _nameController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        email: email,
      );

      try {
        await _userService.updateUserProfile(updatedProfile);
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: _userService.userProfileStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data;
          
          // Initialize controllers with current data if not editing or if first load
          if (!_isEditing) {
            _nameController.text = profile?.name ?? '';
            _addressController.text = profile?.address ?? '';
            _phoneController.text = profile?.phoneNumber ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Header
                  const Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFF667EEA),
                          child: Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.email ?? 'No Email',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Profile Fields
                  _buildProfileField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    isEditing: _isEditing,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                    label: 'Address',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                    isEditing: _isEditing,
                    maxLines: 2,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  
                  const SizedBox(height: 40),

                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _saveProfile(user.uid, user.email ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrdersPage()),
                        ),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('My Orders'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF667EEA)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
