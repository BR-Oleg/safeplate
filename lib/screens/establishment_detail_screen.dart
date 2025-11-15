import 'package:flutter/material.dart';
import '../models/establishment.dart';
import '../widgets/establishment_profile.dart';
import '../utils/translations.dart';

/// Tela que mostra os detalhes completos do estabelecimento
/// Acessada ao clicar em um marcador no mapa (estilo Uber/iFood)
/// Usa DraggableScrollableSheet para animação de baixo para cima e arrastar para minimizar
class EstablishmentDetailScreen extends StatelessWidget {
  final Establishment establishment;

  const EstablishmentDetailScreen({
    super.key,
    required this.establishment,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Ocupa 90% da tela inicialmente
      minChildSize: 0.3, // Pode ser minimizado até 30%
      maxChildSize: 0.95, // Máximo de 95% da tela
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Barrinha para arrastar (handle)
              _buildDragHandle(),
              // Header com botão de fechar
              _buildHeader(context),
              // Conteúdo do estabelecimento (scrollável)
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: EstablishmentProfile(
                    establishment: establishment,
                    onClose: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Barrinha no topo para indicar que pode ser arrastada
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Header com botão de voltar e título
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).pop();
            },
            tooltip: Translations.getText(context, 'back'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              establishment.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

