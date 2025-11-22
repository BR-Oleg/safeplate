import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/user_seal.dart';
import '../models/establishment.dart';
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
import 'register_trail_screen.dart';
import 'leaderboard_screen.dart';
import 'followers_list_screen.dart';
import 'following_list_screen.dart';
import 'notifications_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;
  bool _dietNudgeChecked = false;
  final ImagePicker _imagePicker = ImagePicker();

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
        
        _maybeShowDietPreferencesNudge(user);

        return Scaffold(
          backgroundColor: Colors.white,
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 420,
                    pinned: true,
                    title: innerBoxIsScrolled 
                        ? Text(user.name ?? 'Perfil', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                        : null,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.black),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () => _shareAchievements(user),
                      ),
                      if (user.isPremiumActive)
                         Padding(
                           padding: const EdgeInsets.only(right: 8.0),
                           child: Chip(
                             label: const Text('PREMIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                             backgroundColor: Colors.amber.shade700,
                             visualDensity: VisualDensity.compact,
                           ),
                         ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildSocialProfileHeader(user),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(56),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          indicatorColor: AppTheme.primaryGreen,
                          labelColor: AppTheme.primaryGreen,
                          unselectedLabelColor: Colors.grey,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: Translations.getText(context, 'trailMap') ?? 'Trilha'),
                            Tab(text: Translations.getText(context, 'achievements') ?? 'Conquistas'),
                            Tab(text: Translations.getText(context, 'about') ?? 'Sobre'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildActivitiesTab(user),
                  _buildAchievementsTab(user),
                  _buildAboutTab(user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialProfileHeader(User user) {
    final isPremium = user.isPremiumActive;
    return Stack(
      children: [
        // Capa (Cover Photo)
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(user.coverPhotoUrl ?? 'https://images.unsplash.com/photo-1493770348161-369560ae357d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.8),
                  Colors.white,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        
        // Botão alterar capa (Câmera)
        Positioned(
          top: 140,
          right: 16,
          child: GestureDetector(
             onTap: () async {
               // TODO: Implementar mudança de capa
               await _changeCoverPhoto();
             },
             child: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: Colors.grey.shade200,
                 shape: BoxShape.circle,
                 border: Border.all(color: Colors.white, width: 2),
               ),
               child: Icon(Icons.camera_alt, color: Colors.grey.shade800, size: 20),
             ),
          ),
        ),

        // Conteúdo do Perfil
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Avatar com Borda de Selo e Botão de Edição
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPremium ? AppTheme.premiumGold : user.seal.color,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPremium ? AppTheme.premiumGold : user.seal.color).withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                      color: Colors.white,
                    ),
                  ),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null
                        ? Text(
                            _getInitials(user.name ?? user.email),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: user.seal.color,
                            ),
                          )
                        : null,
                  ),
                  // Ícone Premium (Se tiver)
                  if (isPremium)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.premiumGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.star, color: Colors.white, size: 16),
                      ),
                    ),
                  // Botão de Alterar Foto (Câmera)
                  Positioned(
                    bottom: 0,
                    right: isPremium ? 28 : 0, // Ajusta posição se tiver estrela
                    child: GestureDetector(
                      onTap: () async {
                         // TODO: Implementar mudança de foto
                         await _changeProfilePhoto();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Nome e Selo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.name ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isPremium) 
                    const Icon(Icons.verified, color: AppTheme.premiumGold, size: 20),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Editar perfil
                      CustomNotification.info(context, 'Editar perfil em breve');
                    },
                    child: Icon(Icons.edit, color: Colors.grey.shade600, size: 18),
                  ),
                ],
              ),
              
              // Nível/Selo Texto
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user.seal.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${Translations.getText(context, 'seal')} ${user.seal.label}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user.seal.color,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Stats Row (Social)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(user.followersCount.toString(), Translations.getText(context, 'followers'), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FollowersListScreen(userId: user.id)));
                  }),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  _buildStatItem(user.followingCount.toString(), Translations.getText(context, 'following'), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FollowingListScreen(userId: user.id)));
                  }),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  _buildStatItem(user.totalReviews.toString(), Translations.getText(context, 'reviews'), () {}),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // ...

  // Placeholder tabs (implementações abaixo)
  Widget _buildActivitiesTab(User user) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Padding(
           padding: const EdgeInsets.only(bottom: 16),
           child: Text(
             Translations.getText(context, 'trailMap'),
             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
           ),
        ),
        _buildTrailTimelineItem(
           context, 
           isFirst: true, 
           isLast: false, 
           title: 'Bem-vindo ao Prato Seguro!', 
           subtitle: 'Sua jornada começou.', 
           time: 'Inicio',
           icon: Icons.flag
        ),
        // Simulação de itens de trilha (check-ins)
        if (user.totalCheckIns > 0)
          _buildTrailTimelineItem(
             context, 
             isFirst: false, 
             isLast: false, 
             title: '${user.totalCheckIns} locais visitados', 
             subtitle: 'Continue explorando!', 
             time: 'Agora',
             icon: Icons.place,
             isActive: true
          ),
        _buildTrailTimelineItem(
           context, 
           isFirst: false, 
           isLast: true, 
           title: 'Próxima Conquista', 
           subtitle: 'Faça mais check-ins para evoluir', 
           time: 'Futuro',
           icon: Icons.emoji_events_outlined
        ),
        
        const SizedBox(height: 24),
        _buildCheckInsSection(context, user),
        const SizedBox(height: 100), // Espaço para o menu inferior
      ],
    );
  }

  Widget _buildTrailTimelineItem(BuildContext context, {
     required bool isFirst,
     required bool isLast,
     required String title,
     required String subtitle,
     required String time,
     required IconData icon,
     bool isActive = false,
  }) {
     return IntrinsicHeight(
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           SizedBox(
             width: 60,
             child: Column(
               children: [
                 if (!isFirst) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
                 Container(
                   margin: const EdgeInsets.symmetric(vertical: 4),
                   width: 40,
                   height: 40,
                   decoration: BoxDecoration(
                     color: isActive ? AppTheme.primaryGreen : Colors.white,
                     shape: BoxShape.circle,
                     border: Border.all(color: isActive ? AppTheme.primaryGreen : Colors.grey.shade300, width: 2),
                   ),
                   child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
                 ),
                 if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
               ],
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Padding(
               padding: const EdgeInsets.symmetric(vertical: 12),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   Text(subtitle, style: const TextStyle(color: Colors.grey)),
                 ],
               ),
             ),
           ),
         ],
       ),
     );
  }

  // ... _buildAchievementsTab e _buildAboutTab permanecem iguais, apenas _buildPointsCard precisa ser atualizado

  Widget _buildPointsCard(User user) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user.points} pts',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (user.points % 1000) / 1000,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${1000 - (user.points % 1000)} ${Translations.getText(context, 'pointsToRedeemPremium')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            
            // Progresso para o próximo selo
            _buildSealProgress(user),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSealProgress(User user) {
      final reviews = user.totalReviews.toDouble();
      final checkIns = user.totalCheckIns.toDouble();
      final referrals = user.totalReferrals.toDouble();

      String? nextSealName;
      double? sealProgress;
      
      // Lógica simplificada para exemplo. Deve ser consistente com GamificationService
      bool meetsSilver() => reviews >= 10 && checkIns >= 5 && referrals >= 2;
      
      if (user.seal != UserSeal.gold) {
        if (user.seal == UserSeal.silver || meetsSilver()) {
          nextSealName = UserSeal.gold.label;
          // Exemplo de cálculo
          sealProgress = (reviews / 25).clamp(0.0, 1.0);
        } else {
          nextSealName = UserSeal.silver.label;
          sealProgress = (reviews / 10).clamp(0.0, 1.0);
        }
      }

      if (nextSealName == null || sealProgress == null) return const SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Próximo nível: $nextSealName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
           const SizedBox(height: 8),
           ClipRRect(
             borderRadius: BorderRadius.circular(8),
             child: LinearProgressIndicator(
               value: sealProgress,
               minHeight: 12,
               backgroundColor: Colors.grey.shade300,
               valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
             ),
           ),
           const SizedBox(height: 4),
           Text('${(sealProgress * 100).toInt()}% completo', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
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

  Widget _buildCheckInsSection(BuildContext context, User user) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
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
                    const Icon(Icons.place, color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      Translations.getText(context, 'checkInHistory'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
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
            const SizedBox(height: 12),
            if (user.totalCheckIns == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Nenhum check-in registrado ainda.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              Text(
                '${user.totalCheckIns} ${Translations.getText(context, 'checkInsCompleted')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterTrailScreen()),
                  );
                },
                icon: const Icon(Icons.hiking),
                label: const Text('Registrar Trilha'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineModeCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.flight_takeoff, color: Colors.blue.shade700),
        ),
        title: Text(
          Translations.getText(context, 'travelMode'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(Translations.getText(context, 'downloadRegionData')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OfflineModeScreen()),
          );
        },
      ),
    );
  }

  Widget _buildCouponsSection(BuildContext context, User user) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_offer, color: Colors.orange.shade700),
        ),
        title: Text(
          Translations.getText(context, 'myCoupons'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: FutureBuilder<List<Coupon>>(
          future: GamificationService.getUserCoupons(user.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Carregando...');
            final active = snapshot.data!.where((c) => c.canUse).length;
            return Text('$active ${Translations.getText(context, 'activeCoupons')}');
          },
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CouponsScreen()),
          );
        },
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

  Future<File?> _pickImageFile() async {
    final source = await showDialog<ImageSource?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar imagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return null;

    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (picked == null) return null;
    return File(picked.path);
  }

  Future<void> _changeProfilePhoto() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final file = await _pickImageFile();
    if (file == null) return;

    try {
      final url = await FirebaseService.uploadUserImage(file, user.id);
      await authProvider.updateProfilePhoto(url);
      if (!mounted) return;
      CustomNotification.success(
        context,
        Translations.getText(context, 'profilePhotoUpdated'),
      );
    } catch (e) {
      if (!mounted) return;
      CustomNotification.error(
        context,
        'Erro ao atualizar foto de perfil: $e',
      );
    }
  }

  Future<void> _changeCoverPhoto() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final file = await _pickImageFile();
    if (file == null) return;

    try {
      final url = await FirebaseService.uploadUserCoverImage(file, user.id);
      await authProvider.updateCoverPhoto(url);
      if (!mounted) return;
      CustomNotification.success(
        context,
        Translations.getText(context, 'coverPhotoUpdated'),
      );
    } catch (e) {
      if (!mounted) return;
      CustomNotification.error(
        context,
        'Erro ao atualizar capa: $e',
      );
    }
  }

  Future<void> _refreshUserData() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      await FirebaseService.getUserData(user.id);
      // Provider deve atualizar automaticamente se estiver ouvindo stream ou se chamarmos update
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

Baixe o Prato Seguro!
''';
    await Share.share(text);
  }

  Future<void> _maybeShowDietPreferencesNudge(User user) async {
    if (_dietNudgeChecked) return;
    _dietNudgeChecked = true;
    
    if (user.dietaryPreferences.isNotEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'diet_nudge_shown_${user.id}';
      final alreadyShown = prefs.getBool(key) ?? false;
      if (alreadyShown) return;

      await prefs.setBool(key, true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText(context, 'dietPreferencesNudge')),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // Ignorar erros de SP
    }
  }

  Widget _buildAchievementsTab(User user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMascotCard(user),
        const SizedBox(height: 16),
        _buildSealCard(user),
        const SizedBox(height: 16),
        _buildPointsCard(user),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildAboutTab(User user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDietPreferencesCard(user),
        const SizedBox(height: 16),
        _buildCouponsSection(context, user),
        const SizedBox(height: 16),
        _buildOfflineModeCard(context),
        const SizedBox(height: 16),
        _buildQuickActions(context, user),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatItem(String count, String? label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, User user) {
    return Column(
      children: [
        _buildQuickActionTile(
          context,
          icon: Icons.hiking,
          title: 'Registrar Trilha',
          subtitle: 'Ganhe pontos mapeando locais',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterTrailScreen())),
        ),
        _buildQuickActionTile(
          context,
          icon: Icons.share,
          title: Translations.getText(context, 'referEstablishment'),
          subtitle: Translations.getText(context, 'helpCommunity'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferEstablishmentScreen())),
        ),
        _buildQuickActionTile(
          context,
          icon: Icons.emoji_events,
          title: Translations.getText(context, 'leaderboard'),
          subtitle: 'Veja o ranking da comunidade',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green.shade700),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMascotCard(User user) {
    final hasReviews = user.totalReviews > 0;
    final hasCheckIns = user.totalCheckIns > 0;
    final totalReferrals = user.totalReferrals;
    final isGold = user.seal == UserSeal.gold;
    final isSilver = user.seal == UserSeal.silver;
    final isBronze = user.seal == UserSeal.bronze;

    final hasManyReferrals = totalReferrals >= 10;
    final hasSomeReferrals = totalReferrals >= 3;

    String title;
    String message;

    if (hasManyReferrals) {
      title = Translations.getText(context, 'mascotTitleReferralChampion');
      message = Translations.getText(context, 'mascotMessageReferralChampion');
    } else if (hasSomeReferrals) {
      title = Translations.getText(context, 'mascotTitleReferralHero');
      message = Translations.getText(context, 'mascotMessageReferralHero');
    } else if (isGold) {
      title = Translations.getText(context, 'mascotTitleGold');
      message = Translations.getText(context, 'mascotMessageGold');
    } else if (isSilver) {
      title = Translations.getText(context, 'mascotTitleSilver');
      message = Translations.getText(context, 'mascotMessageSilver');
    } else if (isBronze && (hasReviews || hasCheckIns)) {
      title = Translations.getText(context, 'mascotTitleBronze');
      message = Translations.getText(context, 'mascotMessageBronze');
    } else {
      title = Translations.getText(context, 'mascotTitleStart');
      message = Translations.getText(context, 'mascotMessageStart');
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Card(
            color: Colors.green.shade50,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.green.shade200,
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_emotions,
                        color: Colors.green.shade600,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade800.withOpacity(0.9),
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
      },
    );
  }

  Widget _buildSealCard(User user) {
    final seal = user.seal;
    return Card(
      elevation: 0,
      color: seal.color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: seal.color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: seal.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                color: seal.color,
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

  Widget _buildDietPreferencesCard(User user) {
    final prefs = user.dietaryPreferences;

    return Card(
      elevation: user.isPremiumActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.green.shade100,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 20,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  Translations.getText(context, 'dietPreferencesTitle'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _openDietPreferencesEditor(user),
                  child: Text(
                    Translations.getText(context, 'manage'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (prefs.isEmpty)
              Text(
                Translations.getText(context, 'dietPreferencesEmpty'),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prefs.map((code) {
                  final filter = DietaryFilter.fromString(code);
                  return Chip(
                    label: Text(filter.getLabel(context)),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDietPreferencesEditor(User user) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final initial = user.dietaryPreferences
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .map(DietaryFilter.fromString)
        .toSet();

    final selected = Set<DietaryFilter>.from(initial);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setStateModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        size: 20,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          Translations.getText(context, 'dietPreferencesTitle'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Translations.getText(context, 'dietPreferencesEmpty'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DietaryFilter.values.map((filter) {
                      final isSelected = selected.contains(filter);
                      return FilterChip(
                        label: Text(filter.getLabel(context)),
                        selected: isSelected,
                        onSelected: (value) {
                          setStateModal(() {
                            if (value) {
                              selected.add(filter);
                            } else {
                              selected.remove(filter);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(Translations.getText(context, 'cancel')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final codes = selected
                              .map((e) => e.toString().split('.').last)
                              .toList();
                          await authProvider.updateDietaryPreferences(codes);
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  Translations.getText(context, 'dietPreferencesNudge'),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(Translations.getText(context, 'save') ?? 'Salvar'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

