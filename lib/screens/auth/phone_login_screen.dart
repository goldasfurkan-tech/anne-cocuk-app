import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber => '+90${_phoneController.text.trim()}';

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOTP(_fullPhoneNumber);

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
      authProvider.clearError();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phoneNumber: _fullPhoneNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan görseli — tam ekran
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/images/login_illustration.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: const Color(0xFFF9F4E8)),
            ),
          ),

          // Alt kart — ekranın en altında
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EDD8).withOpacity(0.97),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hoş Geldin! 👋',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anneleri ve çocuklarını buluşturuyoruz',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Telefon input
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFDF6E3),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🇹🇷',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+90',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 1,
                                height: 24,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                        ),
                        hintText: '5XX XXX XX XX',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color(0xFFD4B896).withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color(0xFFD4B896).withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Telefon numaranı gir';
                        }
                        if (value.length < 10) {
                          return 'Geçerli bir numara gir';
                        }
                        if (!value.startsWith('5')) {
                          return 'Numara 5 ile başlamalı';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    GradientButton(
                      text: 'Kod Gönder',
                      isLoading: authProvider.isLoading,
                      onPressed: _sendOTP,
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Devam ederek Gizlilik Politikamızı ve\nKullanım Koşullarımızı kabul etmiş olursunuz.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
