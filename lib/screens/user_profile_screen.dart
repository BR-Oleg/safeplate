import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/user_seal.dart';
import '../models/checkin.dart';
import '../models/coupon.dart';
import '../services/gamification_service.dart';
import '../services/firebase_service.dart';
import '../services/referral_service.dart';
import '../widgets/custom_notification.dart';
import '../utils/translations.dart';
import 'checkins_screen.dart';
import 'coupons_screen.dart';
import 'premium_screen.dart';
import 'offline_mode_screen.dart';
import 'refer_establishment_screen.dart';
import 'package:share_plus/share_plus.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null || user.type != UserType.user) {
          return Scaffold(
            body: Center(child: Text(Translations.getText(context, 'onlyUsersCanAccessProfile'))),
          );
        }

        return Scaffold(
      appBar: AppBar(
        title: Text(Translations.getText(context, 'myProfile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAchievements(user),
            tooltip: Translations.getText(context, 'shareAchievements'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _refreshUserData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Premium (se ativo) - no topo
                    if (user.isPremiumActive) _buildPremiumBanner(user),
                    if (user.isPremiumActive) const SizedBox(height: 16),
                    // Header com foto e nome
                    _buildProfileHeader(user),
                    const SizedBox(height: 24),
                    // Botão Tornar-se Premium (se não for Premium) - no topo
                    if (!user.isPremiumActive) _buildBecomePremiumButton(context),
                    if (!user.isPremiumActive) const SizedBox(height: 16),
                    // Selo atual
                    _buildSealCard(user),
                    const SizedBox(height: 16),
                    // Pontos e progresso
                    _buildPointsCard(user),
                    const SizedBox(height: 16),
                    // Status Premium (se ativo)
                    if (user.isPremiumActive) _buildPremiumCard(user),
                    if (user.isPremiumActive) const SizedBox(height: 16),
                    // Ações rápidas
                    _buildQuickActions(context, user),
                    const SizedBox(height: 16),
                    // Modo Viagem
                    _buildOfflineModeCard(context),
                    const SizedBox(height: 16),
                    // Estatísticas
                    _buildStatsCard(user),
                    const SizedBox(height: 16),
                    // Histórico de check-ins
                    _buildCheckInsSection(context, user),
                    const SizedBox(height: 16),
                    // Cupons ativos
                    _buildCouponsSection(context, user),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }

  Widget _buildPremiumBanner(User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.amber.shade600,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade300.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.shade200,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translations.getText(context, 'premiumAccountActive'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  if (user.premiumExpiresAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${Translations.getText(context, 'expiresIn')} ${_formatDate(context, user.premiumExpiresAt!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.verified,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBecomePremiumButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade300.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            CustomNotification.info(
              context,
              Translations.getText(context, 'becomePremiumInfo'),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translations.getText(context, 'becomePremium'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Translations.getText(context, 'premiumBenefits'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Card(
      elevation: user.isPremiumActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: user.isPremiumActive
            ? BorderSide(
                color: Colors.amber.shade400,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: user.isPremiumActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade50,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: user.isPremiumActive
                        ? Colors.amber.shade100
                        : Colors.green.shade100,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null
                        ? Text(
                            _getInitials(user.name ?? user.email),
                            style: TextStyle(
                              fontSize: 32,
                              color: user.isPremiumActive
                                  ? Colors.amber.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (user.isPremiumActive)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name ?? Translations.getText(context, 'user'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: user.isPremiumActive
                                  ? Colors.amber.shade900
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (user.isPremiumActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.orange.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  Translations.getText(context, 'premium'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSealCard(User user) {
    final seal = user.seal;
    return Card(
      color: seal.color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: seal.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Translations.getText(context, 'seal')} ${seal.label}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: seal.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seal.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(User user) {
    return Card(
      elevation: user.isPremiumActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: user.isPremiumActive
            ? BorderSide(
                color: Colors.amber.shade300,
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: user.isPremiumActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade50,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translations.getText(context, 'points'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.points} pts',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (user.points % 1000) / 1000,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  user.isPremiumActive
                      ? Colors.amber.shade400
                      : Colors.green.shade400,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${1000 - (user.points % 1000)} ${Translations.getText(context, 'pointsToRedeemPremium')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.amber.shade400,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade600,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translations.getText(context, 'premiumAccountActive'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  if (user.premiumExpiresAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${Translations.getText(context, 'expiresIn')} ${_formatDate(context, user.premiumExpiresAt!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.verified,
              color: Colors.amber.shade700,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Translations.getText(context, 'quickActions'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CouponsScreen()),
                      );
                    },
                    icon: const Icon(Icons.local_offer),
                    label: Text(Translations.getText(context, 'myCoupons')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckInsScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: Text(Translations.getText(context, 'history')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReferEstablishmentScreen()),
                  );
                },
                icon: const Icon(Icons.add_location),
                label: Text(Translations.getText(context, 'referNewPlace')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(User user) {
    return Card(
      elevation: user.isPremiumActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: user.isPremiumActive
            ? BorderSide(
                color: Colors.amber.shade300,
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: user.isPremiumActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade50,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    Translations.getText(context, 'statistics'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (user.isPremiumActive) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade700,
                      size: 18,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.location_on, Translations.getText(context, 'checkIns'), user.totalCheckIns.toString(), user.isPremiumActive),
                  _buildStatItem(Icons.star, Translations.getText(context, 'reviews'), user.totalReviews.toString(), user.isPremiumActive),
                  _buildStatItem(Icons.share, Translations.getText(context, 'referrals'), user.totalReferrals.toString(), user.isPremiumActive),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, bool isPremium) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: isPremium ? Colors.amber.shade700 : Colors.green.shade700,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isPremium ? Colors.amber.shade700 : Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }


  Widget _buildCheckInsSection(BuildContext context, User user) {
    return Card(
      elevation: user.isPremiumActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: user.isPremiumActive
            ? BorderSide(
                color: Colors.amber.shade300,
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: user.isPremiumActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade50,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        Translations.getText(context, 'checkInHistory'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (user.isPremiumActive) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade700,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckInsScreen()),
                      );
                    },
                    child: Text(Translations.getText(context, 'seeAll')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${user.totalCheckIns} ${Translations.getText(context, 'checkInsCompleted')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineModeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.flight_takeoff, color: Colors.green.shade700, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      Translations.getText(context, 'travelMode'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OfflineModeScreen()),
                    );
                  },
                  child: Text(Translations.getText(context, 'manage')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Translations.getText(context, 'downloadRegionData'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponsSection(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translations.getText(context, 'myCoupons'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CouponsScreen()),
                    );
                  },
                  child: Text(Translations.getText(context, 'seeAll')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Coupon>>(
              future: GamificationService.getUserCoupons(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final coupons = snapshot.data ?? [];
                final activeCoupons = coupons.where((c) => c.canUse).length;
                return Text(
                  '$activeCoupons ${Translations.getText(context, 'activeCoupons')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String text) {
    if (text.isEmpty) return '?';
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${Translations.getText(context, 'days')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${Translations.getText(context, 'hours')}';
    } else {
      return Translations.getText(context, 'today');
    }
  }

  Future<void> _refreshUserData() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      // Recarregar dados do usuário do Firestore
      final updatedUser = await FirebaseService.getUserData(user.id);
      if (updatedUser != null) {
        // Atualizar no provider (se houver método para isso)
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _shareAchievements(User user) async {
    final text = '''
🏆 Minhas Conquistas no Prato Seguro

Selo: ${user.seal.label} (${user.seal.description})
Pontos: ${user.points} pts
Check-ins: ${user.totalCheckIns}
Avaliações: ${user.totalReviews}
Indicações: ${user.totalReferrals}

${user.isPremiumActive ? '⭐ Conta Premium Ativa!' : ''}

Baixe o Prato Seguro e descubra lugares seguros para suas restrições alimentares!
''';
    await Share.share(text);
  }
}

