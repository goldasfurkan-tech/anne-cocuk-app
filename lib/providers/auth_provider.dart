import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  UserModel? _userModel;
  String? _verificationId;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isProfileCompleted => _userModel?.profileCompleted ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserModel(user.uid);
        _status = AuthStatus.authenticated;
      } else {
        _userModel = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      _userModel = await _firestoreService.getUser(uid);
      debugPrint('=== USER MODEL: ${_userModel?.profileCompleted} ===');

      // Firestore'da kullanıcı yoksa yeni oluştur
      if (_userModel == null) {
        final newUser = UserModel(
          uid: uid,
          name: '',
          surname: '',
          phone: _firebaseUser?.phoneNumber ?? '',
          createdAt: DateTime.now(),
          profileCompleted: false,
        );
        await _firestoreService.createUser(newUser);
        _userModel = newUser;
        debugPrint('=== YENİ USER OLUŞTURULDU ===');
      }
    } catch (e) {
      debugPrint('Kullanıcı yüklenemedi: $e');
    }
  }

  // SMS gönder
  Future<void> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _authService.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
      },
      onAutoVerified: (credential) async {
        await _signInWithCredential(credential);
      },
    );
  }

  // OTP doğrula
  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (result.user != null) {
        _firebaseUser = result.user;

        // Firestore'dan kullanıcıyı yükle
        _userModel = await _firestoreService.getUser(_firebaseUser!.uid);

        // Yeni kullanıcıysa oluştur
        if (_userModel == null) {
          final newUser = UserModel(
            uid: _firebaseUser!.uid,
            name: '',
            surname: '',
            phone: _firebaseUser!.phoneNumber ?? '',
            createdAt: DateTime.now(),
            profileCompleted: false,
          );
          await _firestoreService.createUser(newUser);
          _userModel = newUser;
          debugPrint('=== YENİ USER OLUŞTURULDU ===');
        }

        _status = AuthStatus.authenticated;
        _isLoading = false;
        debugPrint('=== VERIFY BASARILI: ${_userModel?.profileCompleted} ===');
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'invalid-verification-code') {
        _errorMessage = 'Hatalı kod. Lütfen tekrar deneyin';
      } else if (e.code == 'session-expired') {
        _errorMessage = 'Kodun süresi doldu. Tekrar gönderin';
      } else {
        _errorMessage = e.message ?? 'Doğrulama hatası';
      }
    } catch (e) {
      debugPrint('Genel hata: $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final result = await _authService.signInWithCredential(credential);
      if (result?.user != null) {
        _firebaseUser = result!.user;
        await _loadUserModel(_firebaseUser!.uid);
        _status = AuthStatus.authenticated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Profil güncelle
  Future<void> updateUserModel(UserModel updatedUser) async {
    try {
      await _firestoreService.createUser(updatedUser);
      _userModel = updatedUser;
      debugPrint(
        '=== NOTIFY: profileCompleted=${updatedUser.profileCompleted} ===',
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('=== UPDATE HATA: $e ===');
      notifyListeners();
    }
  }

  // Ghost mode toggle
  Future<void> toggleGhostMode(bool value) async {
    if (_firebaseUser == null) return;
    await _firestoreService.updateGhostMode(_firebaseUser!.uid, value);
    _userModel = _userModel?.copyWith(ghostMode: value);
    notifyListeners();
  }

  // Jeton satın al (mock)
  Future<void> purchaseJetons(int amount) async {
    if (_firebaseUser == null) return;
    await _firestoreService.updateJetons(_firebaseUser!.uid, amount);
    _userModel = _userModel?.copyWith(
      jetons: (_userModel?.jetons ?? 0) + amount,
    );
    notifyListeners();
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
