import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mevcut kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  // Auth durumunu dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // SMS gönder
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android'de otomatik doğrulama
          onAutoVerified(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          String message = 'Bir hata oluştu';
          if (e.code == 'invalid-phone-number') {
            message = 'Geçersiz telefon numarası';
          } else if (e.code == 'too-many-requests') {
            message = 'Çok fazla deneme. Lütfen bekleyin';
          } else if (e.code == 'quota-exceeded') {
            message = 'SMS kotası doldu. Lütfen sonra deneyin';
          }
          onError(message);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('OTP timeout: $verificationId');
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // OTP ile giriş yap
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String message = 'Doğrulama hatası';
      if (e.code == 'invalid-verification-code') {
        message = 'Hatalı kod. Lütfen tekrar deneyin';
      } else if (e.code == 'session-expired') {
        message = 'Kodun süresi doldu. Tekrar gönderin';
      }
      throw Exception(message);
    }
  }

  // Credential ile giriş
  Future<UserCredential?> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
