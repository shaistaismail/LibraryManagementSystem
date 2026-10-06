
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practiceflutter/Screens/Login_Screen.dart';

import 'package:practiceflutter/widgets/background.dart';


class SignupScreen extends StatelessWidget {

   SignupScreen({super.key});
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  TextEditingController name=TextEditingController();
  TextEditingController confrompassword=TextEditingController();
  TextEditingController phone=TextEditingController();
  final formkey=GlobalKey<FormState>();
  String text='';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formkey,
          child: Stack(
            children: [
          // Animated Background
              Background(),

          // Login Content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

          // Heading
                      Text(
                        'Create Your Account',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

          // Subtitle
                      Text(
                        'join us and start reading amazing things Today!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),

                      const SizedBox(height: 42),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(text='Name',style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
                        ],
                      ),
                      TextFormField(
                        validator: (value){
                          if(value!.isEmpty){
                            return 'Please enter your Name';
                          }else{
                            return null;
                          }
                        },
                        controller: name,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.65),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(text='Email',style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
                        ],
                      ),
                      TextFormField(
                        validator: (value){
                          if(value!.isEmpty){
                            return 'Please enter your Valide email';
                          }return null;
                        },
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.65),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(text='Phone Number',style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
                        ],
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Valide Phone Number';
                          }
                        },
                        controller:phone ,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.65),
                          ),
                          prefixIcon: const Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

          // Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(text='Password',style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
                        ],
                      ),
                      TextFormField(
                        validator: (value){
                          if(value!.length<=6 && value.isEmpty){
                            return 'Please enter letters  less then 6';
                          }
                        },
                        controller:  password,
                        obscureText: true,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.65),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(text='Confirm Password',style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
                        ],
                      ),

                      TextFormField(
                        validator: (value){
                          if(value!.isEmpty){
                            return  'Please enter your password';
                          }else{
                            return null;
                          }
                          },
                        controller: confrompassword,
                        obscureText: true,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Conform Password',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.65),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {

                            if(formkey.currentState!.validate()){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>LoginScreen(),
                                ),
                              );
                            }

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.amber.shade200,
                            foregroundColor: const Color(0xFF2563EB),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            'SignUp',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

          // Signup Text

                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 40,
                        children: [
                          Chip(label: Icon(Icons.apple, size: 35, color: Colors.orange)),
                          Chip(label: Icon(Icons.login, size: 35, color: Colors.orangeAccent,))
                        ],),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
