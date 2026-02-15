import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send/executt/succes.dart';
import '../../cubit/authcubit.dart';
import '../../cubit/authstate.dart';

class Fivepage extends StatefulWidget {
  final String email;
  const Fivepage({super.key, required this.email});

  @override
  State<Fivepage> createState() => _FivepageState();
}

class _FivepageState extends State<Fivepage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Fonction pour vérifier si le mot de passe contient au moins un chiffre
  bool _hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create your password 3 / 3"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordSentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account created successfully!")),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView( // Pour éviter les erreurs de dépassement sur petits écrans
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Masque si false
                    decoration: InputDecoration(
                      hintText: "Enter a strong password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // Inverse l'état
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("- minimum 6 characters and maximum 20 characters", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const Text("- must have at least one symbol (@, #, &, ...)", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const Text("- must have numbers", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF013D73),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        final password = _passwordController.text;

                        // VALIDATIONS
                        bool isLengthValid = password.length >= 6 && password.length <= 20;
                        bool hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                        bool hasDigit = _hasNumber(password);

                        if (isLengthValid && hasSymbol && hasDigit) {
                          context.read<AuthCubit>().registerUser(widget.email, password);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Sixpage()));
                        } else {
                          String errorMsg = "";
                          if (!isLengthValid) errorMsg = "Password must be 6-20 characters";
                          else if (!hasSymbol) errorMsg = "Password must have at least one symbol";
                          else if (!hasDigit) errorMsg = "Password must have at least one number";

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMsg)),
                          );
                        }
                      },
                      child: state is AuthLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text("Continue", style: TextStyle(color: Colors.white)),
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
}