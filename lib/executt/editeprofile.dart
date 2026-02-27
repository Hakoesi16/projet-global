import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 24),
                _buildPersonalInfoCard(),
                const SizedBox(height: 24),
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
            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.person, size: 60, color: Color(0xFF013D73)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF013D73),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Change Profile Photo",
          style: TextStyle(
              color: Color(0xFF044079), fontWeight: FontWeight.w600),
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
        _buildTextField("Email Address", _emailController, enabled: false),
        const SizedBox(height: 8),
        const Text(
          "Email address is verified and cannot be changed.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildVesselCard() {
    return _cardContainer(
      title: "VESSEL & HOME PORT",
      children: [
        _buildTextField("Home Port", _homePortController),
        const SizedBox(height: 16),
        _buildTextField("Boat Name", _boatNameController),
      ],
    );
  }

  Widget _buildDeactivateButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: const Text(
        "Deactivate Account",
        style: TextStyle(color: Colors.red),
      ),
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
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "Save Changes",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Cancel",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F7F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
  Widget _cardContainer({
    required String title,
    required List<Widget> children,
    Color titleColor = Colors.grey, // 👈 ajout paramètre couleur
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: titleColor, // 👈 utilise la couleur ici
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
//   Widget _cardContainer(
//       {required String title, required List<Widget> children}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...children,
//         ],
//       ),
//     );
//   }
 }