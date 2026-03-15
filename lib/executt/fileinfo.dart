import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

class Infopage extends StatefulWidget {
  final String token;
  const Infopage({super.key, required this.token});

  @override
  State<Infopage> createState() => _InfopageState();
}

class _InfopageState extends State<Infopage> {
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _boatNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _homePortController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();
  String _selectedvesselType = "Trawler";
  final double _completionPercent = 0.65;
  final List<String> _vesselTypes = [
    'Trawler', 'Sailboat', 'Motorboat', 'Yacht', 'Fishing Boat'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _boatNameController.dispose();
    _registrationController.dispose();
    _homePortController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    super.dispose();
  }
  void _submit() {
    // Validation basique
    if (_fullNameController.text.isEmpty ||
        _boatNameController.text.isEmpty ||
        _licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    context.read<AuthCubit>().submitSetup(
      token: widget.token,
      fullName: _fullNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      boatName: _boatNameController.text.trim(),
      registrationNumber: _registrationController.text.trim(),
      vesselType: _selectedvesselType,
      homePort: _homePortController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      expiryDate: _expiryController.text.trim(),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Setup",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is SetupSuccess) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        builder: (context, state) {
          if (state is SetupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Color(0xFF033F78),
                                    child: Text("1",style: TextStyle(color: Colors.white),),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                      "Personal Information", style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text("Full Name", style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              customTextField("Entre your full name",_fullNameController),
                              const SizedBox(height: 16),
                              const Text("National ID/Passport", style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              customTextField("Entre National Id",_nationalIdController),
                              const SizedBox(height: 16),
                              const Text("Phone Number", style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              customTextField("Entre your phone number",_phoneController),
                              const SizedBox(height: 16),
                              const Text("Email Address", style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              customTextField("Entre your Email address",_emailController),
                              const SizedBox(height: 16),
                            ]

                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Color(0xFF033F78),
                                    child: Text("2",style: TextStyle(color: Colors.white),),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                      "Boat details", style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text("Boat Name", style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              customTextField("Entre your Boat name",_boatNameController),
                              const SizedBox(height: 16),
                              const Text("Registration Number", style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              customTextField("Entre your Registration Number",_registrationController),
                              const SizedBox(height: 16),
                              const Text("Home Port", style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              portTextField("City,Port Name",_homePortController),
                              const SizedBox(height: 16),
                            ]

                        )
                    ),
                  ]
              ),

            );
          }
        }
),
    );
  }
}


Widget customTextField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xFF6B7280)),
      filled: true,
      fillColor: Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}


Widget portTextField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefix: Icon(Icons.location_on,color: Colors.lightBlueAccent,),
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xFF6B7280)),
      filled: true,
      fillColor: Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}