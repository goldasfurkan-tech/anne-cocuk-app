import 'package:anne_cocuk_bulusma/screens/main_nav/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../models/child_model.dart';
import '../../services/firestore_service.dart';
import 'package:flutter/foundation.dart';

class ChildSetupScreen extends StatefulWidget {
  const ChildSetupScreen({super.key});

  @override
  State<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends State<ChildSetupScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<_ChildFormData> _children = [_ChildFormData()];
  bool _isLoading = false;

  Future<void> _saveChildren() async {
    debugPrint('=== PROFIL TAMAMLA BASILDI ===');

    bool allValid = true;
    for (final child in _children) {
      if (!child.formKey.currentState!.validate()) {
        allValid = false;
      }
      if (child.dateOfBirth == null) {
        allValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen tüm çocukların doğum tarihini seç'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    if (!allValid) return;

    debugPrint('=== VALIDASYON GECTI ===');
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final childProvider = context.read<ChildProvider>();
      final uid = authProvider.firebaseUser!.uid;

      debugPrint('=== UID: $uid ===');

      for (int i = 0; i < _children.length; i++) {
        final child = _children[i];
        debugPrint('=== COCUK $i EKLENIYOR ===');
        final childModel = ChildModel(
          id: '',
          name: child.nameController.text.trim(),
          surname: child.surnameController.text.trim(),
          gender: child.gender,
          dateOfBirth: child.dateOfBirth!,
        );
        await childProvider.addChild(uid, childModel);
        debugPrint('=== COCUK $i EKLENDI ===');
      }

      debugPrint('=== FIRESTORE YAZILIYOR UID: $uid ===');
      await _firestoreService.markProfileCompleted(uid);
      debugPrint('=== FIRESTORE YAZILDI ===');

      if (authProvider.userModel != null) {
        final updatedUser = authProvider.userModel!.copyWith(
          profileCompleted: true,
        );
        debugPrint('=== AUTH PROVIDER GUNCELLENIYOR ===');
        await authProvider.updateUserModel(updatedUser);
        debugPrint('=== AUTH PROVIDER GUNCELLENDI ===');
        debugPrint('=== AUTH PROVIDER GUNCELLENDI ===');

        if (mounted) {
          setState(() => _isLoading = false);
          // Manuel geçiş
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('=== HATA: $e ===');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Üst başlık
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.child_friendly,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Çocuk Bilgileri',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Adım 2/2 — Çocuk Profili',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Çocuk kartları
                    ..._children.asMap().entries.map((entry) {
                      final index = entry.key;
                      final child = entry.value;
                      return _ChildCard(
                        index: index,
                        data: child,
                        canDelete: _children.length > 1,
                        onDelete: () {
                          setState(() => _children.removeAt(index));
                        },
                        onUpdate: () => setState(() {}),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Çocuk ekle butonu
                    if (_children.length < 5)
                      GestureDetector(
                        onTap: () {
                          setState(() => _children.add(_ChildFormData()));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Başka Çocuk Ekle',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Tamamla butonu
                    GradientButton(
                      text: 'Profili Tamamla 🎉',
                      isLoading: _isLoading,
                      onPressed: _saveChildren,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Çocuk form verisi
class _ChildFormData {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  String gender = 'male';
  DateTime? dateOfBirth;
}

// Çocuk kartı widget
class _ChildCard extends StatefulWidget {
  final int index;
  final _ChildFormData data;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const _ChildCard({
    required this.index,
    required this.data,
    required this.canDelete,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<_ChildCard> {
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 2),
      firstDate: DateTime(now.year - 12),
      lastDate: now,
      helpText: 'Çocuğun Doğum Tarihi',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => widget.data.dateOfBirth = picked);
      widget.onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: widget.data.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kart başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.index + 1}. Çocuk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (widget.canDelete)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // İsim
            TextFormField(
              controller: widget.data.nameController,
              validator: (v) => v!.isEmpty ? 'Ad gir' : null,
              decoration: _inputDecoration('Çocuğun Adı', Icons.child_care),
            ),
            const SizedBox(height: 12),

            // Soyisim
            TextFormField(
              controller: widget.data.surnameController,
              validator: (v) => v!.isEmpty ? 'Soyad gir' : null,
              decoration: _inputDecoration('Çocuğun Soyadı', Icons.child_care),
            ),
            const SizedBox(height: 12),

            // Cinsiyet toggle
            Text(
              'Cinsiyet',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => widget.data.gender = 'male');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.data.gender == 'male'
                            ? const Color(0xFF4FC3F7).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.data.gender == 'male'
                              ? const Color(0xFF4FC3F7)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text('👦', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 4),
                          Text(
                            'Erkek',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => widget.data.gender = 'female');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.data.gender == 'female'
                            ? AppColors.primaryLight.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.data.gender == 'female'
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text('👧', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 4),
                          Text(
                            'Kız',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Doğum tarihi
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cake_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.data.dateOfBirth == null
                          ? 'Doğum Tarihi Seç'
                          : DateFormat(
                              'dd MMMM yyyy',
                              'tr',
                            ).format(widget.data.dateOfBirth!),
                      style: TextStyle(
                        color: widget.data.dateOfBirth == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.textHint.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.textHint.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
