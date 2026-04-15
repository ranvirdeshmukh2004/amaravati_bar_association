import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import '../../core/constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;
  String? _errorMessage;

  // First-run setup state
  bool _isFirstRun = false;
  bool _isCheckingFirstRun = true;
  final _setupPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _setupFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final isFirst = await ref.read(authProvider.notifier).isFirstRun();
    if (mounted) {
      setState(() {
        _isFirstRun = isFirst;
        _isCheckingFirstRun = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _setupPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final success = await ref
          .read(authProvider.notifier)
          .login(_passwordController.text);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!success) {
            _errorMessage = 'Incorrect Password';
          }
        });
      }
    }
  }

  Future<void> _handleSetup() async {
    if (_setupFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await ref
          .read(authProvider.notifier)
          .setupPassword(_setupPasswordController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          setState(() => _isFirstRun = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password set! You can now login.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _showDeveloperLoginDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Access'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(
            labelText: 'Enter PIN',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          autofocus: true,
          onSubmitted: (_) async {
            _attemptDevLogin(pinController.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _attemptDevLogin(pinController.text),
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }

  Future<void> _attemptDevLogin(String pin) async {
    final success = await ref
        .read(authProvider.notifier)
        .loginAsDeveloper(pin);
    if (mounted) {
      Navigator.pop(context);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access Denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstRun) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _isFirstRun ? _buildSetupForm() : _buildLoginForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupForm() {
    return Form(
      key: _setupFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 64,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'First Time Setup',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your admin password',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _setupPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              if (value.length < 4) return 'Minimum 4 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.check_circle_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              if (value != _setupPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSetup,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Set Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onLongPress: _showDeveloperLoginDialog,
            child: const Icon(
              Icons.security,
              size: 64,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Admin Login',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Local Storage Mode',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _passwordController,
            obscureText: _isObscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _errorMessage,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}
