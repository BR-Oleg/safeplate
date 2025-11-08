import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/establishment.dart';
import '../services/favorites_service.dart';
import '../providers/auth_provider.dart';
import '../utils/translations.dart';

class EstablishmentCard extends StatefulWidget {
  final Establishment establishment;
  final VoidCallback? onSave;
  final VoidCallback? onTap;

  const EstablishmentCard({
    super.key,
    required this.establishment,
    this.onSave,
    this.onTap,
  });

  @override
  State<EstablishmentCard> createState() => _EstablishmentCardState();
}

class _EstablishmentCardState extends State<EstablishmentCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = false;

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

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText(context, 'pleaseLogin')),
            backgroundColor: Colors.orange,
          ),
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

        if (widget.onSave != null) {
          widget.onSave!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? '${widget.establishment.name} adicionado aos favoritos!'
                  : '${widget.establishment.name} removido dos favoritos!',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Translations.getText(context, 'errorSaving')} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateRoute() async {
    final shouldRoute = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.establishment.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${CategoryTranslator.translate(context, widget.establishment.category)} - ${widget.establishment.distance.toStringAsFixed(1)} km'),
            if (widget.establishment.dietaryOptions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: widget.establishment.dietaryOptions.map((filter) {
                  return Chip(
                            label: Text(filter.getLabel(context)),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: const TextStyle(fontSize: 10),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text(Translations.getText(context, 'doYouWantToGo')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translations.getText(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(Translations.getText(context, 'generateRoute')),
          ),
        ],
      ),
    );

    if (shouldRoute == true && mounted) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${Translations.getText(context, 'errorOpeningNavigation')} $e'),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${Translations.getText(context, 'errorGeneratingRoute')} $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final establishment = widget.establishment;
    return InkWell(
      onTap: widget.onTap ?? _generateRoute,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: establishment.avatarUrl.isNotEmpty
                  ? NetworkImage(establishment.avatarUrl)
                  : null,
              onBackgroundImageError: (_, __) {
                // Ignorar erros de imagem
              },
              child: establishment.avatarUrl.isEmpty
                  ? const Icon(Icons.restaurant, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e Tag
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          establishment.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: establishment.difficultyLevel.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            establishment.difficultyLevel.getLabel(context),
                            style: TextStyle(
                              color: establishment.difficultyLevel.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Distância e categoria
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${establishment.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CategoryTranslator.translate(context, establishment.category),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Botão Salvar/Favorito
            IconButton(
              onPressed: _isLoading ? null : _toggleFavorite,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.blue,
                    ),
              tooltip: _isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
            ),
          ],
        ),
      ),
    ),
    );
  }
}

