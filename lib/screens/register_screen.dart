import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await ServiceLocator.instance.apiService.post('/auth/register', body: {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      setState(() {
        _message = response['message']?.toString() ?? 'Registration successful';
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.person_add_alt_1, size: 56, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Create account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter first name',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Color(0xFFF4F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter first name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter last name',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Color(0xFFF4F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter last name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black87),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Color(0xFFF4F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Color(0xFFF4F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 20),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _message!,
                          style: TextStyle(color: _message!.toLowerCase().contains('error') || _message!.toLowerCase().contains('exception') ? Colors.red : Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Sign Up'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
