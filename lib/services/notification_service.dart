import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user.dart';
import '../models/establishment.dart';
import 'firebase_service.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  /// Envia notificação para usuários Premium sobre novo estabelecimento certificado
  static Future<void> notifyNewCertifiedEstablishment(Establishment establishment) async {
    try {
      // Buscar todos os usuários Premium
      final premiumUsers = await _firestore
          .collection('users')
          .where('isPremium', isEqualTo: true)
          .get();

      // Criar notificação para cada usuário Premium
      for (final userDoc in premiumUsers.docs) {
        await _firestore.collection('notifications').add({
          'userId': userDoc.id,
          'type': 'new_certified_establishment',
          'title': 'Novo estabelecimento certificado!',
          'message': '${establishment.name} foi certificado e está disponível para você.',
          'establishmentId': establishment.id,
          'establishmentName': establishment.name,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      debugPrint('✅ Notificações enviadas para ${premiumUsers.docs.length} usuários Premium');
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificações: $e');
    }
  }

  /// Envia notificação sobre progresso do selo
  static Future<void> notifySealProgress(String userId, String message) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'seal_progress',
        'title': 'Progresso do Selo',
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      debugPrint('✅ Notificação de progresso enviada');
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificação de progresso: $e');
    }
  }

  /// Envia notificação sobre cupom disponível
  static Future<void> notifyCouponAvailable(String userId, String couponTitle, String message) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'coupon_available',
        'title': 'Cupom Disponível!',
        'message': message,
        'couponTitle': couponTitle,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      debugPrint('✅ Notificação de cupom enviada');
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificação de cupom: $e');
    }
  }

  /// Busca notificações do usuário
  static Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar notificações: $e');
      return [];
    }
  }

  /// Marca notificação como lida
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    } catch (e) {
      debugPrint('❌ Erro ao marcar notificação como lida: $e');
    }
  }

  /// Inicializa Firebase Cloud Messaging e registra token
  static Future<void> initialize(String userId) async {
    try {
      // Solicitar permissão para notificações
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Permissão de notificação concedida');
      } else {
        debugPrint('⚠️ Permissão de notificação negada');
        return;
      }

      // Obter token FCM
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        debugPrint('✅ FCM Token obtido: $_fcmToken');
        
        // Salvar token no Firestore
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': _fcmToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ FCM Token salvo no Firestore');
      }

      // Configurar handlers para notificações em foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📢 Notificação recebida (foreground): ${message.notification?.title}');
        // Aqui você pode mostrar uma notificação local ou atualizar a UI
      });

      // Handler para quando o app é aberto a partir de uma notificação
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📢 App aberto a partir de notificação: ${message.notification?.title}');
        // Navegar para a tela apropriada baseado no tipo de notificação
      });

      // Verificar se o app foi aberto a partir de uma notificação (quando estava fechado)
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📢 App aberto a partir de notificação (inicial): ${initialMessage.notification?.title}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao inicializar FCM: $e');
    }
  }

  /// Atualiza o token FCM do usuário
  static Future<void> updateFcmToken(String userId) async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': _fcmToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ FCM Token atualizado');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar FCM token: $e');
    }
  }

  /// Remove o token FCM do usuário (logout)
  static Future<void> removeFcmToken(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('✅ FCM Token removido');
    } catch (e) {
      debugPrint('❌ Erro ao remover FCM token: $e');
    }
  }
}

