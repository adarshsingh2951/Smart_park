import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/image_picker_helper.dart';

class UserProfile {
  String name;
  String email;
  String phone;
  String address;
  String vehicleInfo;
  String preferredTime;
  String preferredZone;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.vehicleInfo,
    required this.preferredTime,
    required this.preferredZone,
  });
}

class ProfileScreen extends StatefulWidget {
  final String email;
  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late UserProfile _user;
  File? _profileImage;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _vehicleController;
  late TextEditingController _timeController;
  late TextEditingController _zoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _vehicleController = TextEditingController();
    _timeController = TextEditingController();
    _zoneController = TextEditingController();

    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vehicleController.dispose();
    _timeController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nameController.text = prefs.getString('name') ?? 'John Doe';

      // Use the email passed via widget.email here
      _emailController.text = widget.email;

      _phoneController.text = prefs.getString('phone') ?? '+91 98765 43210';
      _addressController.text = prefs.getString('address') ?? '123 Smart Street, Mumbai, India';
      _vehicleController.text = prefs.getString('vehicle') ?? 'Honda City - MH12AB1234';
      _timeController.text = prefs.getString('time') ?? '9 AM - 6 PM';
      _zoneController.text = prefs.getString('zone') ?? 'Zone A';

      String? imagePath = prefs.getString('profile_image_path');
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }

      _user = UserProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        vehicleInfo: _vehicleController.text,
        preferredTime: _timeController.text,
        preferredZone: _zoneController.text,
      );
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);

    // Do NOT save email here because it comes from widget.email
    // or save it only if you want to keep updated email in prefs:
    // await prefs.setString('email', _emailController.text);

    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('address', _addressController.text);
    await prefs.setString('vehicle', _vehicleController.text);
    await prefs.setString('time', _timeController.text);
    await prefs.setString('zone', _zoneController.text);

    if (_profileImage != null) {
      await prefs.setString('profile_image_path', _profileImage!.path);
    }
  }

  void _toggleEditing() {
    setState(() {
      if (_isEditing) {
        _user = UserProfile(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          vehicleInfo: _vehicleController.text,
          preferredTime: _timeController.text,
          preferredZone: _zoneController.text,
        );
        _saveUserData();
      }
      _isEditing = !_isEditing;
    });
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/profile_placeholder.png')
                    as ImageProvider,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          ImagePickerHelper.showImageSourceActionSheet(
                            context: context,
                            onImageSelected: (file) {
                              setState(() {
                                _profileImage = file;
                              });
                            },
                          );
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// User Info
            _buildSectionCard(title: 'User Info', children: [
              _buildTextField(label: 'Name', controller: _nameController, enabled: _isEditing),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                enabled: false, // Always disabled so user can't edit email
                keyboardType: TextInputType.emailAddress,
              ),
            ]),

            /// Contact Info
            _buildSectionCard(title: 'Contact Info', children: [
              _buildTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone),
              _buildTextField(label: 'Address', controller: _addressController, enabled: _isEditing),
            ]),

            /// Parking Preferences
            _buildSectionCard(title: 'Parking Preferences', children: [
              _buildTextField(label: 'Vehicle Info', controller: _vehicleController, enabled: _isEditing),
              _buildTextField(
                  label: 'Preferred Time for Parking',
                  controller: _timeController,
                  enabled: _isEditing),
              _buildTextField(
                  label: 'Preferred Zone for Parking',
                  controller: _zoneController,
                  enabled: _isEditing),
            ]),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleEditing,
        icon: Icon(_isEditing ? Icons.save : Icons.edit),
        label: Text(_isEditing ? 'Save' : 'Edit'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
