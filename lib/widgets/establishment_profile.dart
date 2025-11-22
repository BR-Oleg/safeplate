import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/establishment.dart';
import '../models/user.dart';
import '../services/favorites_service.dart';
import '../services/gamification_service.dart';
import '../providers/review_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/review_form.dart';
import '../widgets/custom_notification.dart';
import '../utils/translations.dart';

/// Widget que mostra o perfil completo do restaurante
/// Substitui os cards da lista quando um restaurante é selecionado
class EstablishmentProfile extends StatefulWidget {
  final Establishment establishment;
  final VoidCallback? onClose;

  const EstablishmentProfile({
    super.key,
    required this.establishment,
    this.onClose,
  });

  @override
  State<EstablishmentProfile> createState() => _EstablishmentProfileState();
}

class _EstablishmentProfileState extends State<EstablishmentProfile> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = false;
  
  void _refreshReviews() {
    setState(() {}); // Atualizar para refletir novas avaliações
  }

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar status de favorito quando o usuário mudar (login/logout)
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
      }
      return;
    }
    final isFav = await _favoritesService.isFavorite(widget.establishment.id, userId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  int _getEstimatedWalkingMinutes(double distanceKm) {
    final minutes = (distanceKm / 4.0 * 60).round();
    return minutes < 1 ? 1 : minutes;
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        CustomNotification.warning(
          context,
          Translations.getText(context, 'pleaseLogin'),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await _favoritesService.removeFavorite(widget.establishment.id, userId);
      } else {
        await _favoritesService.saveFavorite(widget.establishment, userId);
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isLoading = false;
        });

        CustomNotification.success(
          context,
          _isFavorite
              ? '${widget.establishment.name} ${Translations.getText(context, 'addedToFavorites')}'
              : '${widget.establishment.name} ${Translations.getText(context, 'removedFromFavorites')}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomNotification.error(
          context,
          '${Translations.getText(context, 'errorSaving')} $e',
        );
      }
    }
  }

  Future<void> _shareEstablishment() async {
    try {
      final text = '${widget.establishment.name} - ${CategoryTranslator.translate(context, widget.establishment.category)}\n'
          '${widget.establishment.address ?? 'Localização: ${widget.establishment.latitude}, ${widget.establishment.longitude}'}\n'
          '${Translations.getText(context, 'appName')}';
      
      final uri = 'https://www.google.com/maps/search/?api=1&query=${widget.establishment.latitude},${widget.establishment.longitude}';
      
      await Share.share('$text\n$uri');
    } catch (e) {
      if (mounted) {
        CustomNotification.warning(
          context,
          '${Translations.getText(context, 'errorSharing')} $e',
        );
      }
    }
  }

  Future<void> _doCheckIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      if (mounted) {
        CustomNotification.warning(
          context,
          Translations.getText(context, 'pleaseLogin'),
        );
      }
      return;
    }

    if (user.type != UserType.user) {
      if (mounted) {
        CustomNotification.warning(
          context,
          Translations.getText(context, 'onlyUsersCanCheckIn'),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await GamificationService.registerCheckIn(
        userId: user.id,
        establishmentId: widget.establishment.id,
        establishmentName: widget.establishment.name,
      );

      // Recarregar dados do usuário para atualizar pontos e estatísticas
      await authProvider.reloadUser();
      
      // Notificar listeners para atualizar UI em tempo real
      authProvider.notifyListeners();

      if (mounted) {
        CustomNotification.success(
          context,
          Translations.getText(context, 'checkInSuccess'),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomNotification.error(
          context,
          '${Translations.getText(context, 'checkInError')} ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateRoute() async {
    try {
      final lat = widget.establishment.latitude;
      final lng = widget.establishment.longitude;
      final name = Uri.encodeComponent(widget.establishment.name);
      
      // Tentar abrir diretamente com google.navigation primeiro
      try {
        final uri = Uri.parse('google.navigation:q=$lat,$lng');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        // Se falhar, tentar com maps URL
        try {
          final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          // Última tentativa: geo URI
          try {
            final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            if (mounted) {
              CustomNotification.error(
                context,
                '${Translations.getText(context, 'errorOpeningNavigation')} $e',
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        CustomNotification.error(
          context,
          '${Translations.getText(context, 'errorGeneratingRoute')} $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final establishment = widget.establishment;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com foto, nome e botões
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto do restaurante
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: establishment.avatarUrl.isNotEmpty
                    ? Image.network(
                        establishment.avatarUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Nome e informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            establishment.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${establishment.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            CategoryTranslator.translate(context, establishment.category),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Tag de dificuldade e selo de certificação (se houver)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: establishment.difficultyLevel.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            establishment.difficultyLevel.getLabel(context),
                            style: TextStyle(
                              color: establishment.difficultyLevel.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (establishment.certificationStatus == TechnicalCertificationStatus.certified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  Translations.getText(context, 'certifiedPlaceBadge'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botão favorito
              IconButton(
                onPressed: _isLoading ? null : _toggleFavorite,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                tooltip: Translations.getText(context, 'addToFavorites'),
              ),
              // Botão compartilhar
              IconButton(
                onPressed: _shareEstablishment,
                icon: const Icon(
                  Icons.share,
                  color: Colors.grey,
                  size: 28,
                ),
                tooltip: Translations.getText(context, 'share'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${Translations.getText(context, 'estimatedWalkingTime')} ~${_getEstimatedWalkingMinutes(establishment.distance)} min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Opções dietéticas
          if (establishment.dietaryOptions.isNotEmpty) ...[
            Text(
              Translations.getText(context, 'optionsAvailable'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: establishment.dietaryOptions.map((filter) {
                return Chip(
                  label: Text(filter.getLabel(context)),
                  backgroundColor: Colors.green.shade50,
                  labelStyle: const TextStyle(fontSize: 12),
                );
              }).toList(),
            ),
            if (establishment.dietaryOptions.contains(DietaryFilter.halal)) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Translations.getText(context, 'dietaryHalalExplanation'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
          
          // Status (aberto/fechado)
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: establishment.isOpen ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                establishment.isOpen 
                    ? Translations.getText(context, 'openNow')
                    : Translations.getText(context, 'closed'),
                style: TextStyle(
                  fontSize: 14,
                  color: establishment.isOpen ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          if (establishment.certificationStatus != TechnicalCertificationStatus.none ||
              establishment.lastInspectionDate != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.green.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Translations.getText(context, 'trustSafetyTitle'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (establishment.certificationStatus ==
                        TechnicalCertificationStatus.certified)
                      Text(
                        Translations.getText(
                          context,
                          'trustCertificationCertified',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      )
                    else if (establishment.certificationStatus ==
                            TechnicalCertificationStatus.pending ||
                        establishment.certificationStatus ==
                            TechnicalCertificationStatus.scheduled)
                      Text(
                        Translations.getText(
                          context,
                          'trustCertificationInProgress',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      )
                    else
                      Text(
                        Translations.getText(
                          context,
                          'trustCertificationNone',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    if (establishment.lastInspectionDate != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${Translations.getText(context, 'lastInspectionLabel')}: '
                        '${DateFormat('dd/MM/yyyy').format(establishment.lastInspectionDate!)}'
                        '${establishment.lastInspectionStatus != null && establishment.lastInspectionStatus!.isNotEmpty ? ' – ${establishment.lastInspectionStatus}' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 24),
          ],
          
          // Botões de ação
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateRoute,
                  icon: const Icon(Icons.directions),
                  label: Text(
                    Translations.getText(context, 'goToLocation'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _doCheckIn,
                  icon: const Icon(Icons.location_on),
                  label: Text(
                    Translations.getText(context, 'checkIn'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
                  // Seção de Avaliações
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, _) {
                      // Carregar avaliações do Firestore se necessário
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        reviewProvider.loadReviewsForEstablishment(widget.establishment.id);
                      });
                      
                      final reviews = reviewProvider.getReviewsForEstablishment(widget.establishment.id);
                      final averageRating = reviewProvider.getAverageRating(widget.establishment.id);
                      final reviewCount = reviewProvider.getReviewCount(widget.establishment.id);
                      
                      return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header de avaliações com média
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 28),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            averageRating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '/ 5.0',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$reviewCount ${reviewCount == 1 ? Translations.getText(context, 'review') : Translations.getText(context, 'reviewsPlural')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Formulário de avaliação (se usuário estiver logado)
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  if (!authProvider.isAuthenticated) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        Translations.getText(context, 'loginToReview'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  
                                  // Verificar se o usuário é o dono do estabelecimento
                                  if (widget.establishment.ownerId != null && 
                                      widget.establishment.ownerId == authProvider.user!.id) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.orange.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.orange.shade700),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              Translations.getText(context, 'ownerCannotReview'),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  // Verificar se já avaliou
                                  final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
                                  final userReview = reviewProvider.getUserReviewForEstablishment(
                                    widget.establishment.id,
                                    authProvider.user!.id,
                                  );
                          
                                  if (userReview != null) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green.shade700),
                                          const SizedBox(width: 8),
                                          Text(
                                            Translations.getText(context, 'alreadyReviewed'),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                          
                                  return ReviewForm(
                                    establishment: widget.establishment,
                                    onSubmitted: _refreshReviews,
                                  );
                                },
                              ),
                  
                              const SizedBox(height: 24),
                              
                              // Lista de avaliações
                              if (reviews.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.reviews, size: 48, color: Colors.grey.shade400),
                                        const SizedBox(height: 12),
                                        Text(
                                          Translations.getText(context, 'noReviewsYet'),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Translations.getText(context, 'reviews'),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ...reviews.map((review) => ReviewCard(review: review)),
                                  ],
                                ),
                            ],
                          );
                    },
                  ),
        ],
      ),
    );
  }
}

