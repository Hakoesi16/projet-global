// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubit/authcubit.dart';
// import '../cubit/authstate.dart';
//
// class ChangepasswordPage extends StatefulWidget {
//   final String token;
//   const ChangepasswordPage({super.key, required this.token});
//
//   @override
//   State<ChangepasswordPage> createState() => _ChangepasswordPageState();
// }
//
// class _ChangepasswordPageState extends State<ChangepasswordPage> {
//   final TextEditingController _currentPasswordController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//
//   bool _obscureCurrent = true;
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//
//   @override
//   void dispose() {
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   void _submitUpdate() {
//     final currentPass = _currentPasswordController.text.trim();
//     final newPass = _newPasswordController.text.trim();
//     final confirmPass = _confirmPasswordController.text.trim();
//
//     if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all fields")),
//       );
//       return;
//     }
//
//     if (newPass != confirmPass) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Passwords do not match")),
//       );
//       return;
//     }
//
//     if (newPass.length < 8) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Password must be at least 8 characters")),
//       );
//       return;
//     }
//     if (!newPass.contains("1") && !newPass.contains("2") && !newPass.contains("3") && !newPass.contains("4") && !newPass.contains("5") && !newPass.contains("0") && !newPass.contains("6") && !newPass.contains("7") && !newPass.contains("8") && !newPass.contains("9")) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Password must have number (0-9)")),
//       );
//       return;
//     }
//     if (!newPass.contains("@") && !newPass.contains("%") && !newPass.contains("!") && !newPass.contains("#") && !newPass.contains("*") && !newPass.contains("&") && !newPass.contains("?")) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Password must have at least one special character(@,#,%,&,*,!,?")),
//       );
//       return;
//     }
//
//     // Appel API dynamique via le Cubit
//     context.read<AuthCubit>().updatePassword(
//       token: widget.token,
//       password: newPass,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F9),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF011A33)),
//         ),
//         title: Text(
//           "Change Password",
//           style: TextStyle(
//             color: isDark ? Colors.white : const Color(0xFF011A33),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) {
//           if (state is PasswordUpdatedSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Password updated successfully!")),
//             );
//             Navigator.pop(context); // Retourne à la page précédente après le succès
//           } else if (state is ProfileError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 _buildIconHeader(isDark),
//                 const SizedBox(height: 24),
//                 const Text(
//                   "Change Password",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   "Enter your current password and choose a strong new one to keep your account secure.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//                 const SizedBox(height: 32),
//                 _buildInputCard(isDark, state is AuthLoading),
//                 const SizedBox(height: 24),
//                 _buildSecurityStandards(isDark),
//                 const SizedBox(height: 32),
//                 _buildUpdateButton(state is AuthLoading),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildIconHeader(bool isDark) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE3F2FD),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Icon(Icons.lock_reset, size: 40, color: Color(0xFF013D73)),
//     );
//   }
//
//   Widget _buildInputCard(bool isDark, bool isLoading) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildFieldLabel("Current Password"),
//           _buildPasswordField(_currentPasswordController, _obscureCurrent, (val) {
//             setState(() => _obscureCurrent = !val);
//           }, isDark, enabled: !isLoading),
//           const SizedBox(height: 20),
//           _buildFieldLabel("New password"),
//           _buildPasswordField(_newPasswordController, _obscureNew, (val) {
//             setState(() => _obscureNew = !val);
//           }, isDark, enabled: !isLoading),
//           const SizedBox(height: 12),
//           _buildFieldLabel("Confirm new password"),
//           _buildPasswordField(_confirmPasswordController, _obscureConfirm, (val) {
//             setState(() => _obscureConfirm = !val);
//           }, isDark, hint: "Confirm your password", enabled: !isLoading),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFieldLabel(String label) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         label,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
//       ),
//     );
//   }
//
//   Widget _buildPasswordField(
//     TextEditingController controller,
//     bool obscure,
//     Function(bool) onToggle,
//     bool isDark, {
//     String hint = "••••••••",
//     bool enabled = true,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       enabled: enabled,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: isDark ? Colors.white54 : const Color(0xFFF8FAFB),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         suffixIcon: IconButton(
//           icon: Icon(
//             obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//             color: Colors.grey,
//             size: 20,
//           ),
//           onPressed: () => onToggle(obscure),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSecurityStandards(bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(left: 8, bottom: 12),
//           child: Text(
//             "SECURITY STANDARDS",
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Column(
//             children: [
//               _buildStandardRow("At least 8 characters", if(newPass.length < 8){
//                 return false;
//         }),
//               const SizedBox(height: 12),
//               _buildStandardRow("Include a number (0-9)", if(!newPass.contains("1") && !newPass.contains("2") && !newPass.contains("3") && !newPass.contains("4") && !newPass.contains("5") && !newPass.contains("0") && !newPass.contains("6") && !newPass.contains("7") && !newPass.contains("8") && !newPass.contains("9")){
//                 return false;
//     }),
//               const SizedBox(height: 12),
//               _buildStandardRow("Include a special character", if(!newPass.contains("@") && !newPass.contains("%") && !newPass.contains("!") && !newPass.contains("#") && !newPass.contains("*") && !newPass.contains("&") && !newPass.contains("?")){
//                 return false;
//     }),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStandardRow(String text, bool isValid) {
//     return Row(
//       children: [
//         Icon(
//           isValid ? Icons.check_circle : Icons.circle_outlined,
//           color: isValid ? Colors.green : Colors.grey,
//           size: 20,
//         ),
//         const SizedBox(width: 12),
//         Text(text, style: const TextStyle(fontSize: 14)),
//       ],
//     );
//   }
//
//   Widget _buildUpdateButton(bool isLoading) {
//     return ElevatedButton(
//       onPressed: isLoading ? null : _submitUpdate,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF013D73),
//         minimumSize: const Size(double.infinity, 56),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: isLoading
//           ? const CircularProgressIndicator(color: Colors.white)
//           : Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(Icons.save_outlined, color: Colors.white, size: 20),
//                 SizedBox(width: 10),
//                 Text(
//                   "Update Password",
//                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

class ChangepasswordPage extends StatefulWidget {
  final String token;
  const ChangepasswordPage({super.key, required this.token});

  @override
  State<ChangepasswordPage> createState() => _ChangepasswordPageState();
}

class _ChangepasswordPageState extends State<ChangepasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // ✅ Ajouté — pour mettre à jour les indicateurs en temps réel
  String _newPass = "";

  @override
  void initState() {
    super.initState();
    // ✅ Écouter les changements du champ new password
    _newPasswordController.addListener(() {
      setState(() {
        _newPass = _newPasswordController.text;
      });
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ Fonctions de validation séparées
  bool _hasMinLength() => _newPass.length >= 8;

  bool _hasNumber() => _newPass.contains(RegExp(r'[0-9]'));

  bool _hasSpecialChar() =>
      _newPass.contains(RegExp(r'[@%!#*&?]'));

  void _submitUpdate() {
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (!_hasMinLength()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }

    if (!_hasNumber()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must have a number (0-9)")),
      );
      return;
    }

    if (!_hasSpecialChar()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password must have a special character (@,#,%,&,*,!,?)")),
      );
      return;
    }

    context.read<AuthCubit>().updatePassword(
      token: widget.token,
      password: newPass,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFF011A33)),
        ),
        title: Text(
          "Change Password",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF011A33),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Password updated successfully!"),
                  backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildIconHeader(),
                const SizedBox(height: 24),
                const Text(
                  "Change Password",
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Enter your current password and choose a strong new one to keep your account secure.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _buildInputCard(isDark, isLoading),
                const SizedBox(height: 24),
                _buildSecurityStandards(isDark), // ✅ corrigé
                const SizedBox(height: 32),
                _buildUpdateButton(isLoading),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.lock_reset,
          size: 40, color: Color(0xFF013D73)),
    );
  }

  Widget _buildInputCard(bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Current Password"),
          _buildPasswordField(
            _currentPasswordController,
            _obscureCurrent,
                () => setState(() => _obscureCurrent = !_obscureCurrent),
            isDark,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("New Password"),
          _buildPasswordField(
            _newPasswordController,
            _obscureNew,
                () => setState(() => _obscureNew = !_obscureNew),
            isDark,
            enabled: !isLoading,
          ),
          const SizedBox(height: 12),
          _buildFieldLabel("Confirm New Password"),
          _buildPasswordField(
            _confirmPasswordController,
            _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
            isDark,
            hint: "Confirm your password",
            enabled: !isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller,
      bool obscure,
      VoidCallback onToggle,   // ✅ VoidCallback au lieu de Function(bool)
      bool isDark, {
        String hint = "........",
        bool enabled = true,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark
            ? Colors.white54
            : const Color(0xFFF8FAFB),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: onToggle, // ✅ simplifié
        ),
      ),
    );
  }

  // ✅ Corrigé — utilise les fonctions de validation
  Widget _buildSecurityStandards(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            "SECURITY STANDARDS",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // ✅ Passe les bool directement
              _buildStandardRow(
                "At least 8 characters",
                _hasMinLength(),
              ),
              const SizedBox(height: 12),
              _buildStandardRow(
                "Include a number (0-9)",
                _hasNumber(),
              ),
              const SizedBox(height: 12),
              _buildStandardRow(
                "Include a special character (@,#,%,&,*,!,?)",
                _hasSpecialChar(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandardRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _submitUpdate,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF013D73),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save_outlined, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Text(
            "Update Password",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
