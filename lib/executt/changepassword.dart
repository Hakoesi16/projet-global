import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import '../cubit/themecubit.dart';
import 'editeprofile.dart';
import 'homepage.dart';

class ChangepasswordPage extends StatefulWidget{
  final String token;
  const ChangepasswordPage({super.key,required this.token});

  @override
  State<StatefulWidget> createState() => _ChangepasswordPageState();

}
class _ChangepasswordPageState extends State<ChangepasswordPage>{
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState(){
    super.initState();
    context.read<AuthCubit>().updatePassword(token: '',password: '');
  }
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocBuilder<AuthCubit,AuthState>(builder: (context,state){
        if(state is AuthLoading){
          return const Center(child: CircularProgressIndicator());
        }
        if(state is PasswordUpdatedSuccess){
          return const Center(child: Text("Password updated successfully"));
        }
        if(state is ProfileError){
          return Center(child: Text(state.message));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeadCard(),
              const SizedBox(height: 24,),
            ],
          ),
        );

      }),
    );
  }
Widget _buildHeadCard(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.white54.withValues(alpha: 0.05),blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.lock_reset_outlined,color: Color(0xFF013D73),),
          ),
          const SizedBox(height: 12,),
          Text("Change PassWord",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
          Text("Enter your current password and choose a strong",style: TextStyle(color: Color(0xFF64748B),fontWeight: FontWeight.w600)),
          const SizedBox(height: 7,),
          Text("new one to keep your account secure",style: TextStyle(color: Color(0xFF64748B),fontWeight: FontWeight.w600)),
        ],
      ),
    );
}
Widget _buildInfoCard(Map<String,dynamic>user){
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _infodata("Current Password",user["password"]?? "******/N"),
          const Divider(),
          _infodata("New Password",user["password"]?? "******/N"),
        ],
      ),
    );
}
Widget _infodata(String label,String value){
    return Column(
      children: [
        Text(label),
        TextField(),
      ],
    );
}
}