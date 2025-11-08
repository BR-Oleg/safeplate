import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/establishment.dart';
import '../models/review.dart';
import '../models/user.dart';

// Helper para converter dados do Firestore para formato JSON
Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
  final converted = Map<String, dynamic>.from(data);
  
  // Converter Timestamps do Firestore para strings ISO8601
  converted.forEach((key, value) {
    if (value is Timestamp) {
      converted[key] = value.toDate().toIso8601String();
    } else if (value is DateTime) {
      converted[key] = value.toIso8601String();
    }
  });
  
  return converted;
}

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============ ESTABELECIMENTOS ============
  
  /// Salva um estabelecimento no Firestore
  static Future<String> saveEstablishment(Establishment establishment) async {
    try {
      // Remover o campo 'id' dos dados, pois o Firestore gera o ID do documento automaticamente
      final data = establishment.toJson();
      data.remove('id'); // O ID do documento do Firestore será o ID real
      
      final docRef = await _firestore
          .collection('establishments')
          .add(data)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Timeout ao salvar estabelecimento no Firestore');
            },
          );
      debugPrint('✅ Estabelecimento salvo com ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Erro ao salvar estabelecimento: $e');
      rethrow;
    }
  }

  /// Atualiza um estabelecimento no Firestore
  static Future<void> updateEstablishment(String establishmentId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('establishments')
          .doc(establishmentId)
          .update(data)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Timeout ao atualizar estabelecimento no Firestore');
            },
          );
      debugPrint('✅ Estabelecimento atualizado: $establishmentId');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar estabelecimento: $e');
      rethrow;
    }
  }

  /// Busca estabelecimentos de um dono específico
  static Future<List<Establishment>> getEstablishmentsByOwner(String ownerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('establishments')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Establishment.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar estabelecimentos: $e');
      return [];
    }
  }

  /// Busca todos os estabelecimentos
  static Future<List<Establishment>> getAllEstablishments() async {
    try {
      final querySnapshot = await _firestore
          .collection('establishments')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Establishment.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar estabelecimentos: $e');
      return [];
    }
  }

  /// Stream de estabelecimentos (atualização em tempo real)
  static Stream<List<Establishment>> establishmentsStream() {
    return _firestore
        .collection('establishments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Establishment.fromJson(data);
      }).toList();
    });
  }

  // ============ AVALIAÇÕES ============

  /// Salva uma avaliação no Firestore
  static Future<String> saveReview(Review review) async {
    try {
      final docRef = await _firestore
          .collection('reviews')
          .add(review.toJson());
      debugPrint('✅ Avaliação salva com ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Erro ao salvar avaliação: $e');
      rethrow;
    }
  }

  /// Atualiza as URLs das fotos de uma avaliação
  static Future<void> updateReviewPhotos(String reviewId, List<String> photoUrls) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'photos': photoUrls,
      });
      debugPrint('✅ Fotos da avaliação atualizadas: $reviewId');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar fotos da avaliação: $e');
      rethrow;
    }
  }

  /// Busca avaliações de um estabelecimento específico
  static Future<List<Review>> getReviewsForEstablishment(String establishmentId) async {
    try {
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('reviews')
            .where('establishmentId', isEqualTo: establishmentId)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // Se orderBy falhar (índice não criado), tentar sem orderBy
        debugPrint('⚠️ Erro com orderBy, tentando sem: $e');
        querySnapshot = await _firestore
            .collection('reviews')
            .where('establishmentId', isEqualTo: establishmentId)
            .get();
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar avaliações: $e');
      return [];
    }
  }

  /// Stream de avaliações de um estabelecimento (atualização em tempo real)
  static Stream<List<Review>> reviewsStream(String establishmentId) {
    return _firestore
        .collection('reviews')
        .where('establishmentId', isEqualTo: establishmentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();
    });
  }

  /// Verifica se um usuário já avaliou um estabelecimento
  static Future<Review?> getUserReviewForEstablishment(String establishmentId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('establishmentId', isEqualTo: establishmentId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return Review.fromJson(data);
    } catch (e) {
      debugPrint('❌ Erro ao verificar avaliação do usuário: $e');
      return null;
    }
  }

  /// Deleta uma avaliação
  static Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      debugPrint('✅ Avaliação deletada: $reviewId');
    } catch (e) {
      debugPrint('❌ Erro ao deletar avaliação: $e');
      rethrow;
    }
  }

  // ============ UPLOAD DE IMAGENS ============

  /// Upload de imagem de perfil do estabelecimento
  static Future<String> uploadEstablishmentImage(File imageFile, String establishmentId) async {
    try {
      final fileName = 'establishments/$establishmentId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      debugPrint('✅ Imagem do estabelecimento enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem: $e');
      rethrow;
    }
  }

  /// Upload de imagem de perfil do usuário
  static Future<String> uploadUserImage(File imageFile, String userId) async {
    try {
      final fileName = 'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      debugPrint('✅ Imagem do usuário enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem: $e');
      rethrow;
    }
  }

  /// Upload de imagem de prato do cardápio
  static Future<String> uploadDishImage(File imageFile, String establishmentId, String dishId) async {
    try {
      final fileName = 'establishments/$establishmentId/dishes/${dishId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      debugPrint('✅ Imagem do prato enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem: $e');
      rethrow;
    }
  }

  /// Upload de fotos de avaliação
  static Future<String> uploadReviewPhoto(File imageFile, String reviewId, int photoIndex) async {
    try {
      final fileName = 'reviews/$reviewId/photo_${photoIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      debugPrint('✅ Foto da avaliação enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da foto da avaliação: $e');
      rethrow;
    }
  }

  /// Upload de múltiplas fotos de avaliação
  static Future<List<String>> uploadReviewPhotos(List<File> imageFiles, String reviewId) async {
    try {
      final List<String> photoUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final photoUrl = await uploadReviewPhoto(imageFiles[i], reviewId, i);
        photoUrls.add(photoUrl);
      }
      
      debugPrint('✅ ${photoUrls.length} foto(s) da avaliação enviada(s)');
      return photoUrls;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload das fotos da avaliação: $e');
      rethrow;
    }
  }

  /// Deleta imagem do Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ Imagem deletada: $imageUrl');
    } catch (e) {
      debugPrint('❌ Erro ao deletar imagem: $e');
      // Não relança erro - pode ser que a imagem já não exista
    }
  }

  // ============ ESTATÍSTICAS ============

  /// Calcula média de avaliações de um estabelecimento
  static Future<double> getAverageRating(String establishmentId) async {
    try {
      final reviews = await getReviewsForEstablishment(establishmentId);
      
      if (reviews.isEmpty) {
        return 0.0;
      }

      final sum = reviews.fold(0.0, (sum, review) => sum + review.rating);
      return sum / reviews.length;
    } catch (e) {
      debugPrint('❌ Erro ao calcular média: $e');
      return 0.0;
    }
  }

  // ============ USUÁRIOS ============

  /// Salva ou atualiza dados do usuário no Firestore
  static Future<void> saveUserData(User user) async {
    try {
      final userData = user.toJson();
      debugPrint('💾 Salvando dados do usuário no Firestore: ${user.id}');
      debugPrint('📋 Dados: ${userData.keys.join(", ")}');
      
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(userData, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      debugPrint('✅ Dados do usuário salvos com sucesso: ${user.id}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar dados do usuário: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      // Não relançar erro para não bloquear o login
      // O erro será tratado pelo chamador
    }
  }

  /// Atualiza estatísticas do usuário
  static Future<void> updateUserStats(
    String userId, {
    int? reviewsIncrement,
    int? checkInsIncrement,
    int? referralsIncrement,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (reviewsIncrement != null) {
        updates['totalReviews'] = FieldValue.increment(reviewsIncrement);
      }
      if (checkInsIncrement != null) {
        updates['totalCheckIns'] = FieldValue.increment(checkInsIncrement);
      }
      if (referralsIncrement != null) {
        updates['totalReferrals'] = FieldValue.increment(referralsIncrement);
      }
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
        debugPrint('✅ Estatísticas do usuário atualizadas: $userId');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar estatísticas do usuário: $e');
      // Não relançar erro para não bloquear operações
    }
  }

  /// Busca dados do usuário do Firestore
  static Future<User?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        // Garantir que o ID do documento seja usado (pode não estar no data)
        data['id'] = doc.id;
        // Converter Timestamps do Firestore para formato compatível
        final convertedData = _convertFirestoreData(data);
        return User.fromJson(convertedData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados do usuário: $e');
      // Retornar null em caso de erro (não bloquear login)
      return null;
    }
  }

  /// Atualiza apenas o idioma preferido do usuário
  static Future<void> updateUserPreferredLanguage(String userId, String languageCode) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'preferredLanguage': languageCode})
          .timeout(const Duration(seconds: 5));
      debugPrint('✅ Idioma preferido atualizado: $languageCode');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar idioma preferido: $e');
      // Não relançar erro para não bloquear a atualização
    }
  }
}

