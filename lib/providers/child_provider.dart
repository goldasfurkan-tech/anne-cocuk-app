import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/child_model.dart';

class ChildProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ChildModel> _children = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChildModel> get children => _children;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasChildren => _children.isNotEmpty;

  // Çocukları yükle
  Future<void> loadChildren(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _children = await _firestoreService.getChildren(uid);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Çocukları dinle (realtime)
  void listenChildren(String uid) {
    _firestoreService.childrenStream(uid).listen((children) {
      _children = children;
      notifyListeners();
    });
  }

  // Çocuk ekle
  Future<bool> addChild(String uid, ChildModel child) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.addChild(uid, child);
      await loadChildren(uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Çocuk sil
  Future<void> deleteChild(String uid, String childId) async {
    try {
      await _firestoreService.deleteChild(uid, childId);
      _children.removeWhere((c) => c.id == childId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
