import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../models/child_model.dart';

const _cardColor = Color(0xFFFEF9F0);
const _cardShadow = Color(0x0D8B6914);
const _tagBg = Color(0xFFEEE0C4);
const _tagBorder = Color(0xFFD4B896);
const _tagText = Color(0xFF7A5C2E);
const _dividerColor = Color(0xFFE8D9C0);
const _accentBrown = Color(0xFF8B6914);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _distanceNotifications = false;

  final List<String> _allInterests = [
    'Diş çıkarıyor',
    'Uyku eğitimi',
    'Park canavarı',
    'Montessori',
    'Ek gıda reddi',
    'Oyun grupları',
    'Doğal beslenme',
    'Kitap kurdu',
    'Emzirme',
    'Katı gıdaya geçiş',
    'Aşı takibi',
    'Gelişim oyunları',
    'Müzik & ritim',
    'Sanat atölyesi',
    'Doğa yürüyüşü',
    'Spor & hareket',
    'Kitap okuma',
  ];

  final Map<String, List<String>> _turkeyData = {
    'Adana': ['Çukurova', 'Seyhan', 'Yüreğir', 'Ceyhan', 'Kozan'],
    'Ankara': [
      'Çankaya',
      'Keçiören',
      'Mamak',
      'Yenimahalle',
      'Etimesgut',
      'Altındağ',
      'Sincan',
      'Pursaklar',
    ],
    'Antalya': [
      'Muratpaşa',
      'Konyaaltı',
      'Kepez',
      'Alanya',
      'Manavgat',
      'Serik',
    ],
    'Bursa': [
      'Osmangazi',
      'Nilüfer',
      'Yıldırım',
      'İnegöl',
      'Gemlik',
      'Mudanya',
    ],
    'İstanbul': [
      'Kadıköy',
      'Beşiktaş',
      'Şişli',
      'Fatih',
      'Üsküdar',
      'Ataşehir',
      'Maltepe',
      'Kartal',
      'Pendik',
      'Beyoğlu',
      'Bakırköy',
      'Zeytinburnu',
    ],
    'İzmir': [
      'Konak',
      'Karşıyaka',
      'Bornova',
      'Buca',
      'Çiğli',
      'Gaziemir',
      'Karabağlar',
      'Narlıdere',
    ],
    'Kocaeli': ['İzmit', 'Gebze', 'Körfez', 'Darıca', 'Çayırova', 'Kartepe'],
    'Konya': ['Selçuklu', 'Meram', 'Karatay', 'Ereğli', 'Akşehir'],
    'Mersin': [
      'Yenişehir',
      'Akdeniz',
      'Mezitli',
      'Toroslar',
      'Tarsus',
      'Erdemli',
    ],
    'Muğla': ['Bodrum', 'Fethiye', 'Marmaris', 'Milas', 'Menteşe', 'Datça'],
  };

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.firebaseUser != null) {
      context.read<ChildProvider>().loadChildren(
        authProvider.firebaseUser!.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final childProvider = context.watch<ChildProvider>();
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F4E8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, authProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentityCard(
                      context,
                      user,
                      childProvider.children,
                      authProvider,
                    ),
                    const SizedBox(height: 16),
                    _buildInterestsSection(context, authProvider),
                    const SizedBox(height: 16),
                    _buildWalletCard(context, authProvider),
                    const SizedBox(height: 16),
                    _buildActivitiesSection(context),
                    const SizedBox(height: 16),
                    _buildPrivacySection(context, authProvider),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.userModel;
    final hasPhoto = user?.photoBase64 != null && user!.photoBase64!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF9F4E8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8D9C0),
            backgroundImage: hasPhoto
                ? MemoryImage(base64Decode(user!.photoBase64!))
                : null,
            child: !hasPhoto
                ? const Icon(Icons.person, color: _accentBrown, size: 22)
                : null,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D2C1E),
                ),
              ),
            ),
          ),          
          IconButton(
            onPressed: () => _showEditProfile(context, authProvider),
            icon: const Icon(Icons.settings_outlined),
            color: const Color(0xFF8B7355),
          ),
          IconButton(
            onPressed: () async {
              await authProvider.signOut();
            },
            icon: const Icon(Icons.logout_outlined),
            color: const Color(0xFF8B7355),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(
    BuildContext context,
    dynamic user,
    List<ChildModel> children,
    AuthProvider authProvider,
  ) {
    final hasPhoto =
        user?.photoBase64 != null &&
        (user?.photoBase64 as String?)?.isNotEmpty == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8D9C0),
                  border: Border.all(color: const Color(0xFFD4A574), width: 2),
                  image: hasPhoto
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(user!.photoBase64!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasPhoto
                    ? const Icon(
                        Icons.person,
                        color: Color(0xFF8B6914),
                        size: 36,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null
                          ? '${user.name} ${user.surname}'
                          : 'İsim Yükleniyor...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Oyun oynamayı seven, kahve tutkunu bir anne.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8B7355)),
                    ),
                    if (user?.city != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFFD4547A),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${user!.city}, ${user.district}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B7355),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (children.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: _dividerColor),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Çocuklar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B6914),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showChildrenManager(
                    context,
                    authProvider,
                    context.read<ChildProvider>(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEE0C4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _tagBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: Color(0xFF7A5C2E),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Düzenle',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A5C2E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: children.map((child) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: child.gender == 'male'
                                  ? const Color(0xFFDCEEF9)
                                  : const Color(0xFFF9DCE8),
                              child: Text(
                                child.gender == 'male' ? '👦' : '👧',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4547A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  child.ageLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D2C1E),
                              ),
                            ),
                            Text(
                              '${child.age} Yaş',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8B7355),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: _dividerColor),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showChildrenManager(
                context,
                authProvider,
                context.read<ChildProvider>(),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EAD8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _tagBorder),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF8B6914),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Çocuk Ekle',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B6914),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInterestsSection(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final interests = authProvider.userModel?.interests ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ortak Dertler & İlgi Alanları',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D2C1E),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  _showInterestsPicker(context, authProvider, interests),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEE0C4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _tagBorder),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFF7A5C2E),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Düzenle',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A5C2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        interests.isEmpty
            ? GestureDetector(
                onTap: () =>
                    _showInterestsPicker(context, authProvider, interests),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EAD8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _tagBorder),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF8B6914),
                        size: 28,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'İlgi alanlarını ekle',
                        style: TextStyle(
                          color: Color(0xFF8B6914),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Benzer anneleri bulmana yardımcı olur',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests
                    .map(
                      (interest) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _tagBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _tagBorder),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _tagText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, AuthProvider authProvider) {
    final jetons = authProvider.userModel?.jetons ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cüzdanım',
                style: TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8A020),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          Text(
            '$jetons Jeton',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D2C1E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aktivite davetlerini öne çıkarmak için jeton kullan.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8B7355)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showJetonPurchase(context, authProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4547A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Jeton Satın Al (100 TL)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'İşlem Geçmişi',
                style: TextStyle(color: Color(0xFFD4547A), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(BuildContext context) {
    final activities = [
      {
        'name': 'Boya Atölyesi',
        'status': 'Katıldı',
        'rating': '4.8',
        'date': '15 Haz',
        'emoji': '🎨',
      },
      {
        'name': 'Merkez Kafe',
        'status': 'Değerlendirildi',
        'rating': '5.0',
        'date': '12 Haz',
        'emoji': '☕',
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etkinliklerim & Değerlendirmelerim',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3D2C1E),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: activities
              .map(
                (activity) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: activity == activities.first ? 8 : 0,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _dividerColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: _cardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['emoji']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity['name']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3D2C1E),
                          ),
                        ),
                        Text(
                          '(${activity['status']})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFE8A020),
                              size: 14,
                            ),
                            Text(
                              ' ${activity['rating']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D2C1E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              activity['date']!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8B7355),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, AuthProvider authProvider) {
    final isGhost = authProvider.userModel?.ghostMode ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gizlilik & Ayarlar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D2C1E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Görünmezlik Modu (Ghost Mode)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D2C1E),
                      ),
                    ),
                    Text(
                      'Haritada görünme.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B7355)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isGhost,
                onChanged: (val) async {
                  await authProvider.toggleGhostMode(val);
                },
                activeColor: const Color(0xFFD4547A),
              ),
            ],
          ),
          Divider(height: 20, color: _dividerColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesafe Bildirimleri',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D2C1E),
                      ),
                    ),
                    Text(
                      'Sadece 3 km içindeki davetleri göster.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B7355)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _distanceNotifications,
                onChanged: (val) {
                  setState(() => _distanceNotifications = val);
                },
                activeColor: const Color(0xFFD4547A),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── YARDIMCI ──
  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B6914),
        ),
      ),
    );
  }

  Widget _editField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5EAD8),
        prefixIcon: Icon(icon, color: const Color(0xFF8B6914), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _tagBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _tagBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD4547A), width: 2),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EAD8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _tagBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: const Color(0xFF8B6914), size: 20),
              const SizedBox(width: 12),
              Text(
                hint,
                style: const TextStyle(color: Color(0xFF8B7355), fontSize: 14),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8B6914)),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          selectedItemBuilder: (context) => items
              .map(
                (item) => Row(
                  children: [
                    Icon(icon, color: const Color(0xFF8B6914), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3D2C1E),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _datePickerField({
    required DateTime? date,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EAD8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _tagBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: Color(0xFF8B6914), size: 20),
            const SizedBox(width: 12),
            Text(
              date == null ? hint : '${date.day}.${date.month}.${date.year}',
              style: TextStyle(
                fontSize: 14,
                color: date == null
                    ? const Color(0xFF8B7355)
                    : const Color(0xFF3D2C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PROFİL DÜZENLE ──
  void _showEditProfile(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.userModel;
    final nameController = TextEditingController(text: user?.name ?? '');
    final surnameController = TextEditingController(text: user?.surname ?? '');
    final neighborhoodController = TextEditingController(
      text: user?.neighborhood ?? '',
    );
    DateTime? selectedDate = user?.dateOfBirth;
    String? selectedCity = user?.city;
    String? selectedDistrict = user?.district;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFEF9F0),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final districts = selectedCity != null
              ? (_turkeyData[selectedCity!] ?? [])
              : <String>[];
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Profili Düzenle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2C1E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Kişisel Bilgiler'),
                  const SizedBox(height: 10),
                  _editField(nameController, 'Ad', Icons.person_outline),
                  const SizedBox(height: 10),
                  _editField(surnameController, 'Soyad', Icons.person_outline),
                  const SizedBox(height: 10),
                  _datePickerField(
                    date: selectedDate,
                    hint: 'Doğum Tarihi Seç',
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime(now.year - 25),
                        firstDate: DateTime(1960),
                        lastDate: DateTime(now.year - 18),
                        helpText: 'Doğum Tarihin',
                        cancelText: 'İptal',
                        confirmText: 'Seç',
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFFD4547A),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null)
                        setModalState(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Adres Bilgileri'),
                  const SizedBox(height: 10),
                  _dropdownField(
                    value: selectedCity,
                    hint: 'Şehir Seç',
                    icon: Icons.location_city_outlined,
                    items: _turkeyData.keys.toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedCity = val;
                        selectedDistrict = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _dropdownField(
                    value: selectedDistrict,
                    hint: selectedCity == null ? 'Önce şehir seç' : 'İlçe Seç',
                    icon: Icons.map_outlined,
                    items: districts,
                    onChanged: selectedCity == null
                        ? null
                        : (val) {
                            setModalState(() => selectedDistrict = val);
                          },
                  ),
                  const SizedBox(height: 10),
                  _editField(
                    neighborhoodController,
                    'Mahalle',
                    Icons.home_outlined,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await authProvider.updateUserModel(
                          authProvider.userModel!.copyWith(
                            name: nameController.text.trim(),
                            surname: surnameController.text.trim(),
                            dateOfBirth: selectedDate,
                            city: selectedCity,
                            district: selectedDistrict,
                            neighborhood: neighborhoodController.text.trim(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4547A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── ÇOCUK YÖNETİMİ ──
  void _showChildrenManager(
    BuildContext context,
    AuthProvider authProvider,
    ChildProvider childProvider,
  ) {
    final uid = authProvider.firebaseUser!.uid;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFEF9F0),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final children = childProvider.children;
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Çocuk Bilgileri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2C1E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...children.map(
                    (child) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EAD8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _tagBorder),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: child.gender == 'male'
                                ? const Color(0xFFDCEEF9)
                                : const Color(0xFFF9DCE8),
                            child: Text(
                              child.gender == 'male' ? '👦' : '👧',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${child.name} ${child.surname}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3D2C1E),
                                  ),
                                ),
                                Text(
                                  '${child.age} Yaş • ${child.gender == 'male' ? 'Erkek' : 'Kız'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8B7355),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await childProvider.deleteChild(uid, child.id);
                              setModalState(() {});
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFD4547A),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showAddChild(context, authProvider, childProvider);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEE0C4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _tagBorder),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF8B6914),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Yeni Çocuk Ekle',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B6914),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddChild(
    BuildContext context,
    AuthProvider authProvider,
    ChildProvider childProvider,
  ) {
    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    String gender = 'male';
    DateTime? dateOfBirth;
    final uid = authProvider.firebaseUser!.uid;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFEF9F0),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yeni Çocuk Ekle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2C1E),
                  ),
                ),
                const SizedBox(height: 20),
                _editField(nameController, 'Çocuğun Adı', Icons.child_care),
                const SizedBox(height: 10),
                _editField(
                  surnameController,
                  'Çocuğun Soyadı',
                  Icons.child_care,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => gender = 'male'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: gender == 'male'
                                ? const Color(0xFFDCEEF9)
                                : const Color(0xFFF5EAD8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: gender == 'male'
                                  ? const Color(0xFF4FC3F7)
                                  : _tagBorder,
                              width: gender == 'male' ? 2 : 1,
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
                        onTap: () => setModalState(() => gender = 'female'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: gender == 'female'
                                ? const Color(0xFFF9DCE8)
                                : const Color(0xFFF5EAD8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: gender == 'female'
                                  ? const Color(0xFFD4547A)
                                  : _tagBorder,
                              width: gender == 'female' ? 2 : 1,
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
                _datePickerField(
                  date: dateOfBirth,
                  hint: 'Doğum Tarihi Seç',
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(now.year - 2),
                      firstDate: DateTime(now.year - 12),
                      lastDate: now,
                      helpText: 'Çocuğun Doğum Tarihi',
                      cancelText: 'İptal',
                      confirmText: 'Seç',
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFFD4547A),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null)
                      setModalState(() => dateOfBirth = picked);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || dateOfBirth == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ad ve doğum tarihi zorunlu!'),
                            backgroundColor: Color(0xFFD4547A),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      await childProvider.addChild(
                        uid,
                        ChildModel(
                          id: '',
                          name: nameController.text.trim(),
                          surname: surnameController.text.trim(),
                          gender: gender,
                          dateOfBirth: dateOfBirth!,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4547A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Çocuğu Ekle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── İLGİ ALANLARI ──
  void _showInterestsPicker(
    BuildContext context,
    AuthProvider authProvider,
    List<String> currentInterests,
  ) {
    final selected = List<String>.from(currentInterests);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFEF9F0),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'İlgi Alanlarını Seç',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D2C1E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Benzer anneleri bulmak için seç',
                style: TextStyle(fontSize: 13, color: Color(0xFF8B7355)),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allInterests.map((interest) {
                  final isSelected = selected.contains(interest);
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        if (isSelected)
                          selected.remove(interest);
                        else
                          selected.add(interest);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD4547A)
                            : const Color(0xFFF5EAD8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD4547A)
                              : _tagBorder,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF7A5C2E),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await authProvider.updateUserModel(
                      authProvider.userModel!.copyWith(interests: selected),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4547A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    '${selected.length} Alan Seçildi — Kaydet',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── JETON ──
  void _showJetonPurchase(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFEF9F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jeton Satın Al',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D2C1E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jetonlarla aktivite davetlerini öne çıkar!',
              style: TextStyle(color: Color(0xFF8B7355)),
            ),
            const SizedBox(height: 24),
            _jetonPackage(context, authProvider, '10 Jeton', '10 TL', 10),
            const SizedBox(height: 10),
            _jetonPackage(context, authProvider, '50 Jeton', '45 TL', 50),
            const SizedBox(height: 10),
            _jetonPackage(context, authProvider, '100 Jeton', '80 TL', 100),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _jetonPackage(
    BuildContext context,
    AuthProvider authProvider,
    String label,
    String price,
    int amount,
  ) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await authProvider.purchaseJetons(amount);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$amount jeton eklendi! 🎉'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EAD8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _tagBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Color(0xFFE8A020),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D2C1E),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4547A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
