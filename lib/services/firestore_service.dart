import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── KULLANICI İŞLEMLERİ ──

  // Kullanıcı oluştur veya güncelle
  Future<void> createUser(UserModel user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  // Kullanıcıyı getir
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  // Kullanıcıyı dinle (realtime)
  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    });
  }

  // Kullanıcı güncelle
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Ghost mode güncelle
  Future<void> updateGhostMode(String uid, bool isGhost) async {
    await _db.collection('users').doc(uid).update({'ghostMode': isGhost});
  }

  // Jeton güncelle
  Future<void> updateJetons(String uid, int amount) async {
    await _db.collection('users').doc(uid).update({
      'jetons': FieldValue.increment(amount),
    });
  }

  // Profil tamamlandı işaretle
  Future<void> markProfileCompleted(String uid) async {
    await _db.collection('users').doc(uid).set({
      'profileCompleted': true,
    }, SetOptions(merge: true));
    debugPrint('=== markProfileCompleted YAZILDI: $uid ===');
  }

  // ── ÇOCUK İŞLEMLERİ ──

  // Çocuk ekle
  Future<void> addChild(String uid, ChildModel child) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .add(child.toFirestore());
  }

  // Çocukları getir
  Future<List<ChildModel>> getChildren(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .get();
    return snapshot.docs.map((doc) => ChildModel.fromFirestore(doc)).toList();
  }

  // Çocukları dinle (realtime)
  Stream<List<ChildModel>> childrenStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ChildModel.fromFirestore(doc)).toList(),
        );
  }

  // Çocuk güncelle
  Future<void> updateChild(
    String uid,
    String childId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId)
        .update(data);
  }

  // Çocuk sil
  Future<void> deleteChild(String uid, String childId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId)
        .delete();
  }
}
