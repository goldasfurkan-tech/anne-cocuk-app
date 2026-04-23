import 'package:anne_cocuk_bulusma/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  bool _canResend = false;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
        }
      });
      return _secondsLeft > 0;
    });
  }

  Future<void> _verifyOTP() async {
    if (_pinController.text.length < 6) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOTP(_pinController.text);

    if (!mounted) return;

    if (success) {
      // AppWrapper otomatik yönlendirir, navigator stack temizle
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppWrapper()),
        (route) => false,
      );
      return;
    }

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
      authProvider.clearError();
      _pinController.clear();
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOTP(widget.phoneNumber);
    _startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textHint.withOpacity(0.4)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.primaryLight.withOpacity(0.1),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primary.withOpacity(0.08),
        border: Border.all(color: AppColors.primary),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // İkon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Kodu Gir',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.phoneNumber} numarasına\ngönderilen 6 haneli kodu gir',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              // PIN input
              Pinput(
                controller: _pinController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onCompleted: (_) => _verifyOTP(),
              ),

              const SizedBox(height: 32),

              // Doğrula butonu
              GradientButton(
                text: 'Doğrula',
                isLoading: authProvider.isLoading,
                onPressed: _verifyOTP,
              ),

              const SizedBox(height: 24),

              // Tekrar gönder
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kodu almadın mı? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: _canResend ? _resendOTP : null,
                    child: Text(
                      _canResend
                          ? 'Tekrar Gönder'
                          : 'Tekrar gönder ($_secondsLeft s)',
                      style: TextStyle(
                        color: _canResend
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
