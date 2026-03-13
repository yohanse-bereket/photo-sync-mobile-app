import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/login/login_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController(
    text: "mehabawyohanse12@gmail.com",
  );
  final passwordController = TextEditingController(text: "iouprety");

  // Google SignIn instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _handleGoogleSignIn() async {
    try {
      _googleSignIn.initialize(
        clientId:
            "130048263593-ghvc9s5cfkau522auto5hh3bj8ufodd5.apps.googleusercontent.com",
        serverClientId:
            "130048263593-6ig2bjq27q22kbibg8moqdjdb9fovmn4.apps.googleusercontent.com",
      );
      print("1" * 30);
      // Authenticate user with Google
      final GoogleSignInAccount? account = await _googleSignIn.authenticate();
      print("2" * 30);
      print(account);
      if (account == null) return; // user canceled

      // Get tokens
      final GoogleSignInAuthentication auth = await account.authentication;
      print("3" * 30);
      final String? idToken = auth.idToken;
      print("ID Token: $idToken");
      if (idToken != null) {
        // Send ID token to backend via LoginBloc
        context.read<LoginBloc>().add(
          LoginWithGoogleRequested(idToken: idToken),
        );
      }
    } catch (e) {
      print("Google sign-in error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google sign-in failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccessState) {
              context.go("/images");
            }
            if (state is LoginFailureState) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Email/password login
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 20),
                if (state is LoginLoadingState)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      context.read<LoginBloc>().add(
                        LoginRequested(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        ),
                      );
                    },
                    child: const Text("Login"),
                  ),
                const SizedBox(height: 10),

                // Google Sign-In button
                ElevatedButton.icon(
                  icon: Icon(Icons.login),
                  label: const Text("Sign in with Google"),
                  onPressed: _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                // Navigate to registration
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text("Create account"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
