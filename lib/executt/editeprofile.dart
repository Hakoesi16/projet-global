import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

class EditProfilePage extends StatefulWidget {
  final String token;

  const EditProfilePage({super.key, required this.token});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _homePortController = TextEditingController();
  final TextEditingController _boatNameController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchProfile(widget.token);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _homePortController.dispose();
    _boatNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Color(0xFF011A33), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _nameController.text = state.user["name"] ?? "";
            _phoneController.text = state.user["phone"] ?? "";
            _emailController.text = state.user["email"] ?? "";
            _homePortController.text = state.user["homePort"] ?? "";
            _boatNameController.text = state.user["boatName"] ?? "";
          }
          if (state is ProfileUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully")),
            );
            Navigator.pop(context);
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 24),
                _buildPersonalInfoCard(),
                const SizedBox(height: 20),
                _buildVesselCard(),
                const SizedBox(height: 24),
                _buildDeactivateButton(),
                const SizedBox(height: 16),
                _buildSaveButton(),
                const SizedBox(height: 12),
                _buildCancelButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: const Color(0xFFE3F2FD),
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : const NetworkImage('https://via.placeholder.com/150') as ImageProvider,
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF013D73),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: const Text(
            "Change Profile Photo",
            style: TextStyle(color: Color(0xFF013D73), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        )
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return _cardContainer(
      title: "PERSONAL INFORMATION",
      children: [
        _buildTextField("Full Name", _nameController),
        const SizedBox(height: 16),
        _buildTextField("Phone Number", _phoneController),
        const SizedBox(height: 16),
        _buildTextField(
          "Email Address", 
          _emailController, 
          enabled: false, 
          suffixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 8),
        const Text(
          "Email address is verified and cannot be changed.",
          style: TextStyle(color: Color(0xFFAAB8C2), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildVesselCard() {
    return _cardContainer(
      title: "VESSEL & HOME PORT",
      children: [
        _buildTextField("Home Port", _homePortController, prefixIcon: Icons.location_on_outlined),
        const SizedBox(height: 16),
        _buildTextField("Boat Name", _boatNameController, prefixIcon: Icons.directions_boat_outlined),
      ],
    );
  }

  Widget _buildDeactivateButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Deactivate Account",
            style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthCubit>().updateProfile(
          token: widget.token,
          name: _nameController.text,
          phone: _phoneController.text,
          homePort: _homePortController.text,
          boatName: _boatNameController.text,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF013D73),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Save Changes",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Cancel",
        style: TextStyle(color: Color(0xFF7B8D9E), fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, IconData? prefixIcon, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A5568), fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(color: enabled ? Colors.black : const Color(0xFF7B8D9E)),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF013D73)) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFFBDC8D1), size: 18) : null,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardContainer({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF718096), fontSize: 14, letterSpacing: 0.5),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
