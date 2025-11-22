import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/review_provider.dart';
import '../models/user.dart';
import '../models/establishment.dart';
import '../services/firebase_service.dart';
import 'business_register_establishment_screen.dart';
import '../widgets/review_card.dart';
import '../utils/translations.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || user.type != UserType.business) {
      return Center(
        child: Text(Translations.getText(context, 'restrictedAccess')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.getText(context, 'businessDashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BusinessRegisterEstablishmentScreen(),
                ),
              );
            },
            tooltip: Translations.getText(context, 'registerEstablishment'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com informações da empresa
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.name?.substring(0, 1).toUpperCase() ?? 'E',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'Empresa',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildBusinessPitchAndPlans(context),
            const SizedBox(height: 24),
            
            // Estatísticas rápidas
            _buildQuickStats(context, user.id),
            const SizedBox(height: 24),
            
            // Estabelecimentos cadastrados
            _buildEstablishmentsList(context, user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessPitchAndPlans(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Translations.getText(context, 'businessInstitutionalPitchTitle'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Translations.getText(context, 'businessInstitutionalPitchDescription'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Translations.getText(context, 'businessPlans'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildPlanChip(context, 'basicPlan')),
                const SizedBox(width: 8),
                Expanded(child: _buildPlanChip(context, 'intermediatePlan')),
                const SizedBox(width: 8),
                Expanded(child: _buildPlanChip(context, 'goldPlan')),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              Translations.getText(context, 'whatsAppContactForPlans'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _launchWhatsApp(
                    context,
                    Translations.getText(context, 'businessPlansWhatsAppMessage'),
                  );
                },
                icon: const Icon(Icons.chat),
                label: Text(Translations.getText(context, 'talkOnWhatsApp')),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.purple.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  Translations.getText(context, 'investorPitchTitle'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Translations.getText(context, 'investorPitchDescription'),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _launchWhatsApp(
                    context,
                    Translations.getText(context, 'investorPitchWhatsAppMessage'),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  Translations.getText(context, 'investorPitchButton'),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanChip(BuildContext context, String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Center(
        child: Text(
          Translations.getText(context, key),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, String userId) {
    return FutureBuilder<List<Establishment>>(
      future: FirebaseService.getEstablishmentsByOwner(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final establishments = snapshot.data!;
        if (establishments.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Calcular estatísticas
        int totalEstablishments = establishments.length;
        int openEstablishments = establishments.where((e) => e.isOpen).length;
        double avgRating = 0.0;
        int totalReviews = 0;
        
        // TODO: Calcular média de avaliações quando tiver ReviewProvider integrado
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.restaurant,
                label: Translations.getText(context, 'totalEstablishments'),
                value: totalEstablishments.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.access_time,
                label: Translations.getText(context, 'openNow'),
                value: openEstablishments.toString(),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.star,
                label: Translations.getText(context, 'averageRating'),
                value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '-',
                color: Colors.amber,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstablishmentsList(BuildContext context, String userId) {
    return FutureBuilder<List<Establishment>>(
      future: FirebaseService.getEstablishmentsByOwner(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final establishments = snapshot.data!;

        if (establishments.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    Translations.getText(context, 'noEstablishmentsRegistered'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BusinessRegisterEstablishmentScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(Translations.getText(context, 'registerEstablishment')),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translations.getText(context, 'registeredEstablishments'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BusinessRegisterEstablishmentScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(Translations.getText(context, 'add') ?? 'Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...establishments.map((establishment) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: establishment.avatarUrl.isNotEmpty
                        ? NetworkImage(establishment.avatarUrl)
                        : null,
                    child: establishment.avatarUrl.isEmpty
                        ? const Icon(Icons.restaurant)
                        : null,
                  ),
                  title: Text(establishment.name),
                  subtitle: Text(CategoryTranslator.translate(context, establishment.category)),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BusinessManageEstablishmentScreen(
                            establishment: establishment,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BusinessManageEstablishmentScreen(
                          establishment: establishment,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// Tela para gerenciar um estabelecimento específico
class BusinessManageEstablishmentScreen extends StatelessWidget {
  final Establishment establishment;

  const BusinessManageEstablishmentScreen({
    super.key,
    required this.establishment,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(establishment.name),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info), text: Translations.getText(context, 'basicInformation')),
              Tab(icon: Icon(Icons.reviews), text: Translations.getText(context, 'reviewsTab')),
              Tab(icon: Icon(Icons.restaurant_menu), text: Translations.getText(context, 'menu') ?? 'Cardápio'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab de Informações
            _buildInfoTab(context),
            // Tab de Avaliações
            _buildReviewsTab(context),
            // Tab de Cardápio
            _buildMenuTab(context),
          ],
        ),
      ),
    );
  }

  Future<void> _requestTechnicalCertification(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText(context, 'certificationRequestError') ?? 'Erro ao solicitar certificação'),
          ),
        );
        return;
      }

      await FirebaseService.createCertificationRequest(
        establishmentId: establishment.id,
        establishmentName: establishment.name,
        ownerId: user.id,
        ownerName: user.name ?? '',
      );

      await FirebaseService.updateEstablishment(establishment.id, {
        'certificationStatus': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText(context, 'certificationRequestSent') ?? 'Solicitação de certificação enviada com sucesso'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText(context, 'certificationRequestError') ?? 'Erro ao solicitar certificação'),
        ),
      );
    }
  }

  Widget _buildInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto do estabelecimento
          Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: establishment.avatarUrl.isNotEmpty
                      ? Image.network(
                          establishment.avatarUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.restaurant, size: 80),
                          ),
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.restaurant, size: 80),
                        ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      // TODO: Implementar upload de foto
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(Translations.getText(context, 'uploadPhotoFeatureInDevelopment') ?? 'Funcionalidade de upload de foto em desenvolvimento'),
                        ),
                      );
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Informações básicas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translations.getText(context, 'basicInformation'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildInfoRow(Translations.getText(context, 'name'), establishment.name),
                  _buildInfoRow(Translations.getText(context, 'category'), CategoryTranslator.translate(context, establishment.category)),
                  _buildInfoRow(Translations.getText(context, 'address'), Translations.getText(context, 'toDefine')),
                  _buildInfoRow(Translations.getText(context, 'status'), establishment.isOpen ? Translations.getText(context, 'open') : Translations.getText(context, 'closed')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translations.getText(context, 'technicalCertification'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Text(
                    Translations.getText(context, 'technicalCertificationDescription'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Translations.getText(context, 'certificationStatusLabel'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        establishment.certificationStatus.getLabel(context),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: establishment.certificationStatus == TechnicalCertificationStatus.certified
                              ? Colors.green
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _requestTechnicalCertification(context);
                      },
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(Translations.getText(context, 'requestTechnicalCertification') ?? 'Solicitar certificação técnica'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final baseMessage = Translations.getText(context, 'technicalCertificationWhatsAppMessage');
                        final fullMessage = '$baseMessage\nEstabelecimento: ${establishment.name}';
                        await _launchWhatsApp(context, fullMessage);
                      },
                      icon: const Icon(Icons.chat),
                      label: Text(Translations.getText(context, 'talkOnWhatsApp')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botão de editar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar edição
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Translations.getText(context, 'editFeatureInDevelopment')),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: Text(Translations.getText(context, 'editInformation')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        // Carregar avaliações do Firestore se necessário
        WidgetsBinding.instance.addPostFrameCallback((_) {
          reviewProvider.loadReviewsForEstablishment(establishment.id);
        });
        
        final reviews = reviewProvider.getReviewsForEstablishment(establishment.id);
        final averageRating = reviewProvider.getAverageRating(establishment.id);
        final reviewCount = reviewProvider.getReviewCount(establishment.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo de avaliações
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 32),
                                  const SizedBox(width: 8),
                                  Text(
                                    averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$reviewCount ${reviewCount == 1 ? 'avaliação' : 'avaliações'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista de avaliações
                  if (reviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.reviews, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              Translations.getText(context, 'noReviews'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...reviews.map((review) => ReviewCard(review: review)),
                ],
              ),
            );
      },
    );
  }

  Widget _buildMenuTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Translations.getText(context, 'menuDishes'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implementar adicionar prato
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(Translations.getText(context, 'addDishFeatureInDevelopment') ?? 'Funcionalidade de adicionar prato em desenvolvimento'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(Translations.getText(context, 'addDish') ?? 'Adicionar Prato'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            Translations.getText(context, 'noDishesRegistered'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchWhatsApp(BuildContext context, String message) async {
  const phone = '5511999999999';
  final encodedMessage = Uri.encodeComponent(message);
  final uri = Uri.parse('https://wa.me/$phone?text=$encodedMessage');

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Não foi possível abrir o WhatsApp: $e'),
      ),
    );
  }
}

