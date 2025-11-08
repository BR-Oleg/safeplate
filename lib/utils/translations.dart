import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class Translations {
  static String getText(BuildContext context, String key) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final languageCode = locale.languageCode;

    switch (key) {
      // Tabs
      case 'search':
        return languageCode == 'pt' ? 'Buscar' : languageCode == 'es' ? 'Buscar' : 'Search';
      case 'nearby':
        return languageCode == 'pt' ? 'Próximos' : languageCode == 'es' ? 'Cercanos' : 'Nearby';
      case 'openNow':
        return languageCode == 'pt' ? 'Abertos' : languageCode == 'es' ? 'Abiertos' : 'Open Now';
      
      // Menu
      case 'favorites':
        return languageCode == 'pt' ? 'Favoritos' : languageCode == 'es' ? 'Favoritos' : 'Favorites';
      case 'profile':
        return languageCode == 'pt' ? 'Perfil' : languageCode == 'es' ? 'Perfil' : 'Profile';
      case 'account':
        return languageCode == 'pt' ? 'Conta' : languageCode == 'es' ? 'Cuenta' : 'Account';
      case 'login':
        return languageCode == 'pt' ? 'Login' : languageCode == 'es' ? 'Iniciar sesión' : 'Login';
      case 'pleaseLogin':
        return languageCode == 'pt' ? 'Por favor, faça login para adicionar favoritos' : languageCode == 'es' ? 'Por favor, inicia sesión para agregar favoritos' : 'Please login to add favorites';
      
      // Search
      case 'searchHint':
        return languageCode == 'pt' 
            ? 'Encontrar restaurantes, padarias, hotéis...' 
            : languageCode == 'es' 
                ? 'Encontrar restaurantes, panaderías, hoteles...'
                : 'Find restaurants, bakeries, hotels...';
      
      // Filters
      case 'celiac':
        return languageCode == 'pt' ? 'Celíaco' : languageCode == 'es' ? 'Celíaco' : 'Celiac';
      case 'lactoseFree':
        return languageCode == 'pt' ? 'Sem Lactose' : languageCode == 'es' ? 'Sin Lactosa' : 'Lactose Free';
      case 'nutFree':
        return languageCode == 'pt' ? 'Sem Amendoim' : languageCode == 'es' ? 'Sin Cacahuetes' : 'Nut Free';
      case 'vegan':
        return languageCode == 'pt' ? 'Vegano' : languageCode == 'es' ? 'Vegano' : 'Vegan';
      case 'halal':
        return 'Halal'; // Mesmo em todos os idiomas
      
      // Dietary Filters (para uso no getLabel)
      case 'dietaryCeliac':
        return languageCode == 'pt' ? 'Celíaco' : languageCode == 'es' ? 'Celíaco' : 'Celiac';
      case 'dietaryLactoseFree':
        return languageCode == 'pt' ? 'Sem Lactose' : languageCode == 'es' ? 'Sin Lactosa' : 'Lactose Free';
      case 'dietaryNutFree':
        return languageCode == 'pt' ? 'Sem Amendoim' : languageCode == 'es' ? 'Sin Cacahuetes' : 'Nut Free';
      case 'dietaryVegan':
        return languageCode == 'pt' ? 'Vegano' : languageCode == 'es' ? 'Vegano' : 'Vegan';
      case 'dietaryHalal':
        return 'Halal'; // Mesmo em todos os idiomas
      
      // Dialog
      case 'generateRoute':
        return languageCode == 'pt' ? 'Gerar Rota' : languageCode == 'es' ? 'Generar Ruta' : 'Generate Route';
      case 'cancel':
        return languageCode == 'pt' ? 'Cancelar' : languageCode == 'es' ? 'Cancelar' : 'Cancel';
      case 'close':
        return languageCode == 'pt' ? 'Fechar' : languageCode == 'es' ? 'Cerrar' : 'Close';
      case 'doYouWantToGo':
        return languageCode == 'pt' 
            ? 'Deseja gerar rota até este local?' 
            : languageCode == 'es' 
                ? '¿Deseas ir a este lugar?'
                : 'Do you want to go to this location?';
      
      // Messages
      case 'noEstablishments':
        return languageCode == 'pt' 
            ? 'Nenhum estabelecimento encontrado' 
            : languageCode == 'es' 
                ? 'No se encontraron establecimientos'
                : 'No establishments found';
      case 'clearFilters':
        return languageCode == 'pt' ? 'Limpar filtros' : languageCode == 'es' ? 'Limpiar filtros' : 'Clear filters';
      case 'advancedFilters':
        return languageCode == 'pt' ? 'Filtros Avançados' : languageCode == 'es' ? 'Filtros Avanzados' : 'Advanced Filters';
      case 'maxDistance':
        return languageCode == 'pt' ? 'Distância Máxima' : languageCode == 'es' ? 'Distancia Máxima' : 'Max Distance';
      case 'sortByDistance':
        return languageCode == 'pt' ? 'Mais Próximos' : languageCode == 'es' ? 'Más Cercanos' : 'Nearest';
      case 'sortByRating':
        return languageCode == 'pt' ? 'Melhor Avaliados' : languageCode == 'es' ? 'Mejor Calificados' : 'Best Rated';
      case 'sortByName':
        return languageCode == 'pt' ? 'Nome (A-Z)' : languageCode == 'es' ? 'Nombre (A-Z)' : 'Name (A-Z)';
      case 'sortByOpenFirst':
        return languageCode == 'pt' ? 'Abertos Primeiro' : languageCode == 'es' ? 'Abiertos Primero' : 'Open First';
      case 'share':
        return languageCode == 'pt' ? 'Compartilhar' : languageCode == 'es' ? 'Compartir' : 'Share';
      case 'addToFavorites':
        return languageCode == 'pt' ? 'Adicionar aos Favoritos' : languageCode == 'es' ? 'Agregar a Favoritos' : 'Add to Favorites';
      case 'errorSharing':
        return languageCode == 'pt' ? 'Erro ao compartilhar:' : languageCode == 'es' ? 'Error al compartir:' : 'Error sharing:';
      case 'totalEstablishments':
        return languageCode == 'pt' ? 'Total' : languageCode == 'es' ? 'Total' : 'Total';
      
      // App name
      case 'appName':
        return 'Prato Seguro'; // Mesmo em todos os idiomas
      
      // Establishment Profile
      case 'optionsAvailable':
        return languageCode == 'pt' ? 'Opções disponíveis:' : languageCode == 'es' ? 'Opciones disponibles:' : 'Available options:';
      case 'openNow':
        return languageCode == 'pt' ? 'Aberto agora' : languageCode == 'es' ? 'Abierto ahora' : 'Open now';
      case 'closed':
        return languageCode == 'pt' ? 'Fechado' : languageCode == 'es' ? 'Cerrado' : 'Closed';
      case 'goToLocation':
        return languageCode == 'pt' ? 'Ir até o local' : languageCode == 'es' ? 'Ir al lugar' : 'Go to location';
      case 'reviews':
        return languageCode == 'pt' ? 'Avaliações' : languageCode == 'es' ? 'Reseñas' : 'Reviews';
      case 'noReviewsYet':
        return languageCode == 'pt' ? 'Nenhuma avaliação ainda' : languageCode == 'es' ? 'Aún no hay reseñas' : 'No reviews yet';
      case 'review':
        return languageCode == 'pt' ? 'avaliação' : languageCode == 'es' ? 'reseña' : 'review';
      case 'reviewsPlural':
        return languageCode == 'pt' ? 'avaliações' : languageCode == 'es' ? 'reseñas' : 'reviews';
      case 'loginToReview':
        return languageCode == 'pt' ? 'Faça login para deixar uma avaliação' : languageCode == 'es' ? 'Inicia sesión para dejar una reseña' : 'Login to leave a review';
      case 'alreadyReviewed':
        return languageCode == 'pt' ? 'Você já avaliou este estabelecimento' : languageCode == 'es' ? 'Ya has evaluado este establecimiento' : 'You have already reviewed this establishment';
      case 'leaveYourReview':
        return languageCode == 'pt' ? 'Deixe sua avaliação' : languageCode == 'es' ? 'Deja tu reseña' : 'Leave your review';
      case 'rating':
        return languageCode == 'pt' ? 'Avaliação' : languageCode == 'es' ? 'Calificación' : 'Rating';
      case 'comment':
        return languageCode == 'pt' ? 'Comentário' : languageCode == 'es' ? 'Comentario' : 'Comment';
      case 'tellYourExperience':
        return languageCode == 'pt' ? 'Conte sua experiência...' : languageCode == 'es' ? 'Cuenta tu experiencia...' : 'Tell your experience...';
      case 'pleaseWriteComment':
        return languageCode == 'pt' ? 'Por favor, escreva um comentário' : languageCode == 'es' ? 'Por favor, escribe un comentario' : 'Please write a comment';
      case 'commentMinLength':
        return languageCode == 'pt' ? 'O comentário deve ter pelo menos 10 caracteres' : languageCode == 'es' ? 'El comentario debe tener al menos 10 caracteres' : 'The comment must be at least 10 characters';
      case 'iReallyVisited':
        return languageCode == 'pt' ? 'Eu realmente visitei este estabelecimento' : languageCode == 'es' ? 'Realmente visité este establecimiento' : 'I really visited this establishment';
      case 'ownerCannotReview':
        return languageCode == 'pt' ? 'Você não pode avaliar seu próprio estabelecimento' : languageCode == 'es' ? 'No puedes evaluar tu propio establecimiento' : 'You cannot review your own establishment';
      case 'addedToFavorites':
        return languageCode == 'pt' ? 'adicionado aos favoritos!' : languageCode == 'es' ? 'agregado a favoritos!' : 'added to favorites!';
      case 'removedFromFavorites':
        return languageCode == 'pt' ? 'removido dos favoritos!' : languageCode == 'es' ? 'eliminado de favoritos!' : 'removed from favorites!';
      case 'errorSaving':
        return languageCode == 'pt' ? 'Erro ao salvar:' : languageCode == 'es' ? 'Error al guardar:' : 'Error saving:';
      case 'errorOpeningNavigation':
        return languageCode == 'pt' ? 'Não foi possível abrir navegação. Erro:' : languageCode == 'es' ? 'No se pudo abrir la navegación. Error:' : 'Could not open navigation. Error:';
      case 'errorGeneratingRoute':
        return languageCode == 'pt' ? 'Erro ao gerar rota:' : languageCode == 'es' ? 'Error al generar ruta:' : 'Error generating route:';
      
      // Difficulty Levels
      case 'difficultyPopular':
        return languageCode == 'pt' ? 'Popular' : languageCode == 'es' ? 'Popular' : 'Popular';
      case 'difficultyIntermediate':
        return languageCode == 'pt' ? 'Intermediário' : languageCode == 'es' ? 'Intermedio' : 'Intermediate';
      case 'difficultyTechnical':
        return languageCode == 'pt' ? 'Técnico' : languageCode == 'es' ? 'Técnico' : 'Technical';
      
      // Home Screen
      case 'myProfile':
        return languageCode == 'pt' ? 'Meu Perfil' : languageCode == 'es' ? 'Mi Perfil' : 'My Profile';
      case 'account':
        return languageCode == 'pt' ? 'Conta' : languageCode == 'es' ? 'Cuenta' : 'Account';
      case 'noUserLoggedIn':
        return languageCode == 'pt' ? 'Nenhum usuário logado' : languageCode == 'es' ? 'Ningún usuario conectado' : 'No user logged in';
      case 'businessAccount':
        return languageCode == 'pt' ? 'Conta Empresa' : languageCode == 'es' ? 'Cuenta Empresa' : 'Business Account';
      case 'userAccount':
        return languageCode == 'pt' ? 'Conta Usuário' : languageCode == 'es' ? 'Cuenta Usuario' : 'User Account';
      case 'accountType':
        return languageCode == 'pt' ? 'Tipo de Conta' : languageCode == 'es' ? 'Tipo de Cuenta' : 'Account Type';
      case 'business':
        return languageCode == 'pt' ? 'Empresa' : languageCode == 'es' ? 'Empresa' : 'Business';
      case 'user':
        return languageCode == 'pt' ? 'Usuário' : languageCode == 'es' ? 'Usuario' : 'User';
      case 'logout':
        return languageCode == 'pt' ? 'Sair da Conta' : languageCode == 'es' ? 'Cerrar Sesión' : 'Logout';
      case 'name':
        return languageCode == 'pt' ? 'Nome' : languageCode == 'es' ? 'Nombre' : 'Name';
      case 'noName':
        return languageCode == 'pt' ? 'Sem nome' : languageCode == 'es' ? 'Sin nombre' : 'No name';
      case 'dashboard':
        return languageCode == 'pt' ? 'Dashboard' : languageCode == 'es' ? 'Panel' : 'Dashboard';
      
      // Business Dashboard
      case 'businessDashboard':
        return languageCode == 'pt' ? 'Painel da Empresa' : languageCode == 'es' ? 'Panel de la Empresa' : 'Business Dashboard';
      case 'registerEstablishment':
        return languageCode == 'pt' ? 'Cadastrar Estabelecimento' : languageCode == 'es' ? 'Registrar Establecimiento' : 'Register Establishment';
      case 'restrictedAccess':
        return languageCode == 'pt' ? 'Acesso restrito a empresas' : languageCode == 'es' ? 'Acceso restringido a empresas' : 'Restricted access to businesses';
      case 'registeredEstablishments':
        return languageCode == 'pt' ? 'Estabelecimentos Cadastrados' : languageCode == 'es' ? 'Establecimientos Registrados' : 'Registered Establishments';
      case 'noEstablishmentsRegistered':
        return languageCode == 'pt' ? 'Nenhum estabelecimento cadastrado ainda' : languageCode == 'es' ? 'Aún no hay establecimientos registrados' : 'No establishments registered yet';
      case 'basicInformation':
        return languageCode == 'pt' ? 'Informações Básicas' : languageCode == 'es' ? 'Información Básica' : 'Basic Information';
      case 'category':
        return languageCode == 'pt' ? 'Categoria' : languageCode == 'es' ? 'Categoría' : 'Category';
      case 'address':
        return languageCode == 'pt' ? 'Endereço' : languageCode == 'es' ? 'Dirección' : 'Address';
      case 'toDefine':
        return languageCode == 'pt' ? 'A definir' : languageCode == 'es' ? 'Por definir' : 'To define';
      case 'status':
        return languageCode == 'pt' ? 'Status' : languageCode == 'es' ? 'Estado' : 'Status';
      case 'open':
        return languageCode == 'pt' ? 'Aberto' : languageCode == 'es' ? 'Abierto' : 'Open';
      case 'editInformation':
        return languageCode == 'pt' ? 'Editar Informações' : languageCode == 'es' ? 'Editar Información' : 'Edit Information';
      case 'editFeatureInDevelopment':
        return languageCode == 'pt' ? 'Funcionalidade de edição em desenvolvimento' : languageCode == 'es' ? 'Funcionalidad de edición en desarrollo' : 'Edit feature in development';
      case 'reviewsTab':
        return languageCode == 'pt' ? 'Avaliações' : languageCode == 'es' ? 'Reseñas' : 'Reviews';
      case 'averageRating':
        return languageCode == 'pt' ? 'Avaliação Média' : languageCode == 'es' ? 'Calificación Promedio' : 'Average Rating';
      case 'totalReviews':
        return languageCode == 'pt' ? 'Total de Avaliações' : languageCode == 'es' ? 'Total de Reseñas' : 'Total Reviews';
      case 'noReviews':
        return languageCode == 'pt' ? 'Nenhuma avaliação ainda' : languageCode == 'es' ? 'Aún no hay reseñas' : 'No reviews yet';
      
      // Review Form
      case 'sendReview':
        return languageCode == 'pt' ? 'Enviar Avaliação' : languageCode == 'es' ? 'Enviar Reseña' : 'Send Review';
      case 'mustBeLoggedIn':
        return languageCode == 'pt' ? 'Você precisa estar logado para avaliar' : languageCode == 'es' ? 'Debes iniciar sesión para evaluar' : 'You must be logged in to review';
      case 'reviewSentSuccessfully':
        return languageCode == 'pt' ? 'Avaliação enviada com sucesso! ✅' : languageCode == 'es' ? '¡Reseña enviada con éxito! ✅' : 'Review sent successfully! ✅';
      case 'errorSendingReview':
        return languageCode == 'pt' ? 'Erro ao enviar avaliação. Tente novamente.' : languageCode == 'es' ? 'Error al enviar reseña. Inténtalo de nuevo.' : 'Error sending review. Try again.';
      
      // Login/Signup
      case 'doLogin':
        return languageCode == 'pt' ? 'Fazer Login' : languageCode == 'es' ? 'Iniciar Sesión' : 'Login';
      case 'fillAllFields':
        return languageCode == 'pt' ? 'Por favor, preencha todos os campos' : languageCode == 'es' ? 'Por favor, completa todos los campos' : 'Please fill in all fields';
      case 'loginAs':
        return languageCode == 'pt' ? 'Login realizado como' : languageCode == 'es' ? 'Sesión iniciada como' : 'Logged in as';
      case 'loginError':
        return languageCode == 'pt' ? 'Erro ao fazer login. Tente novamente.' : languageCode == 'es' ? 'Error al iniciar sesión. Inténtalo de nuevo.' : 'Error logging in. Try again.';
      
      // Establishment Detail Screen
      case 'back':
        return languageCode == 'pt' ? 'Voltar' : languageCode == 'es' ? 'Volver' : 'Back';
      
      // Map
      case 'configureMapboxToken':
        return languageCode == 'pt' ? 'Configure Mapbox Token' : languageCode == 'es' ? 'Configurar Token de Mapbox' : 'Configure Mapbox Token';
      
      // Additional translations
      case 'add':
        return languageCode == 'pt' ? 'Adicionar' : languageCode == 'es' ? 'Agregar' : 'Add';
      case 'menu':
        return languageCode == 'pt' ? 'Cardápio' : languageCode == 'es' ? 'Menú' : 'Menu';
      case 'addDish':
        return languageCode == 'pt' ? 'Adicionar Prato' : languageCode == 'es' ? 'Agregar Plato' : 'Add Dish';
      case 'addDishFeatureInDevelopment':
        return languageCode == 'pt' ? 'Funcionalidade de adicionar prato em desenvolvimento' : languageCode == 'es' ? 'Funcionalidad de agregar plato en desarrollo' : 'Add dish feature in development';
      
      // Review Card
      case 'anonymousUser':
        return languageCode == 'pt' ? 'Usuário Anônimo' : languageCode == 'es' ? 'Usuario Anónimo' : 'Anonymous User';
      case 'verified':
        return languageCode == 'pt' ? 'Verificado' : languageCode == 'es' ? 'Verificado' : 'Verified';
      
      // Favorites Screen
      case 'favoritesTitle':
        return languageCode == 'pt' ? 'Favoritos' : languageCode == 'es' ? 'Favoritos' : 'Favorites';
      case 'favorite':
        return languageCode == 'pt' ? 'favorito' : languageCode == 'es' ? 'favorito' : 'favorite';
      case 'favoritesPlural':
        return languageCode == 'pt' ? 'favoritos' : languageCode == 'es' ? 'favoritos' : 'favorites';
      case 'noFavoritesYet':
        return languageCode == 'pt' ? 'Nenhum favorito ainda' : languageCode == 'es' ? 'Aún no hay favoritos' : 'No favorites yet';
      case 'addRestaurantsToFavorites':
        return languageCode == 'pt' ? 'Adicione restaurantes aos favoritos para vê-los aqui' : languageCode == 'es' ? 'Agrega restaurantes a favoritos para verlos aquí' : 'Add restaurants to favorites to see them here';
      case 'removedFromFavorites':
        return languageCode == 'pt' ? 'removido dos favoritos' : languageCode == 'es' ? 'eliminado de favoritos' : 'removed from favorites';
      
      // Time ago translations
      case 'yearAgo':
        return languageCode == 'pt' ? 'ano atrás' : languageCode == 'es' ? 'año atrás' : 'year ago';
      case 'yearsAgo':
        return languageCode == 'pt' ? 'anos atrás' : languageCode == 'es' ? 'años atrás' : 'years ago';
      case 'monthAgo':
        return languageCode == 'pt' ? 'mês atrás' : languageCode == 'es' ? 'mes atrás' : 'month ago';
      case 'monthsAgo':
        return languageCode == 'pt' ? 'meses atrás' : languageCode == 'es' ? 'meses atrás' : 'months ago';
      case 'dayAgo':
        return languageCode == 'pt' ? 'dia atrás' : languageCode == 'es' ? 'día atrás' : 'day ago';
      case 'daysAgo':
        return languageCode == 'pt' ? 'dias atrás' : languageCode == 'es' ? 'días atrás' : 'days ago';
      case 'hourAgo':
        return languageCode == 'pt' ? 'hora atrás' : languageCode == 'es' ? 'hora atrás' : 'hour ago';
      case 'hoursAgo':
        return languageCode == 'pt' ? 'horas atrás' : languageCode == 'es' ? 'horas atrás' : 'hours ago';
      case 'minuteAgo':
        return languageCode == 'pt' ? 'minuto atrás' : languageCode == 'es' ? 'minuto atrás' : 'minute ago';
      case 'minutesAgo':
        return languageCode == 'pt' ? 'minutos atrás' : languageCode == 'es' ? 'minutos atrás' : 'minutes ago';
      case 'now':
        return languageCode == 'pt' ? 'Agora' : languageCode == 'es' ? 'Ahora' : 'Now';
      
      // Categories
      case 'categoryRestaurant':
        return languageCode == 'pt' ? 'Restaurante' : languageCode == 'es' ? 'Restaurante' : 'Restaurant';
      case 'categoryBakery':
        return languageCode == 'pt' ? 'Padaria' : languageCode == 'es' ? 'Panadería' : 'Bakery';
      case 'categoryHotel':
        return languageCode == 'pt' ? 'Hotel' : languageCode == 'es' ? 'Hotel' : 'Hotel';
      case 'categoryCafe':
        return languageCode == 'pt' ? 'Café' : languageCode == 'es' ? 'Café' : 'Cafe';
      case 'categoryMarket':
        return languageCode == 'pt' ? 'Mercado' : languageCode == 'es' ? 'Mercado' : 'Market';
      case 'categoryOther':
        return languageCode == 'pt' ? 'Outro' : languageCode == 'es' ? 'Otro' : 'Other';
      
      // Menu/Dishes
      case 'menuDishes':
        return languageCode == 'pt' ? 'Pratos do Cardápio' : languageCode == 'es' ? 'Platos del Menú' : 'Menu Dishes';
      case 'noDishesRegistered':
        return languageCode == 'pt' ? 'Nenhum prato cadastrado' : languageCode == 'es' ? 'Ningún plato registrado' : 'No dishes registered';
      case 'uploadPhotoFeatureInDevelopment':
        return languageCode == 'pt' ? 'Funcionalidade de upload de foto em desenvolvimento' : languageCode == 'es' ? 'Funcionalidad de subir foto en desarrollo' : 'Upload photo feature in development';
      
      // Language selector
      case 'language':
        return languageCode == 'pt' ? 'Idioma' : languageCode == 'es' ? 'Idioma' : 'Language';
      case 'createAccount':
        return languageCode == 'pt' ? 'Criar Conta' : languageCode == 'es' ? 'Crear Cuenta' : 'Create Account';
      case 'password':
        return languageCode == 'pt' ? 'Senha' : languageCode == 'es' ? 'Contraseña' : 'Password';
      case 'or':
        return languageCode == 'pt' ? 'ou' : languageCode == 'es' ? 'o' : 'or';
      case 'continueWithGoogle':
        return languageCode == 'pt' ? 'Continuar com Google' : languageCode == 'es' ? 'Continuar con Google' : 'Continue with Google';
      case 'dontHaveAccount':
        return languageCode == 'pt' ? 'Não tem uma conta? ' : languageCode == 'es' ? '¿No tienes una cuenta? ' : "Don't have an account? ";
      case 'signUp':
        return languageCode == 'pt' ? 'Cadastrar-se' : languageCode == 'es' ? 'Registrarse' : 'Sign Up';
      case 'termsOfUse':
        return languageCode == 'pt' ? 'Termos de Uso' : languageCode == 'es' ? 'Términos de Uso' : 'Terms of Use';
      case 'privacyPolicy':
        return languageCode == 'pt' ? 'Política de Privacidade' : languageCode == 'es' ? 'Política de Privacidad' : 'Privacy Policy';
      case 'loginAs':
        return languageCode == 'pt' ? 'Login realizado como' : languageCode == 'es' ? 'Inicio de sesión realizado como' : 'Login as';
      case 'googleLoginAs':
        return languageCode == 'pt' ? 'Login com Google realizado como' : languageCode == 'es' ? 'Inicio de sesión con Google realizado como' : 'Google login as';
      case 'loginError':
        return languageCode == 'pt' ? 'Erro ao fazer login. Tente novamente.' : languageCode == 'es' ? 'Error al iniciar sesión. Inténtalo de nuevo.' : 'Login error. Please try again.';
      case 'googleLoginError':
        return languageCode == 'pt' ? 'Erro ao fazer login com Google. Tente novamente.' : languageCode == 'es' ? 'Error al iniciar sesión con Google. Inténtalo de nuevo.' : 'Google login error. Please try again.';
      
      // Check-in
      case 'checkIn':
        return languageCode == 'pt' ? 'Check-in' : languageCode == 'es' ? 'Registro' : 'Check-in';
      case 'onlyUsersCanCheckIn':
        return languageCode == 'pt' ? 'Apenas usuários podem fazer check-in' : languageCode == 'es' ? 'Solo los usuarios pueden hacer registro' : 'Only users can check-in';
      case 'checkInSuccess':
        return languageCode == 'pt' ? 'Check-in realizado! +10 pontos 🎉' : languageCode == 'es' ? '¡Registro realizado! +10 puntos 🎉' : 'Check-in completed! +10 points 🎉';
      case 'checkInError':
        return languageCode == 'pt' ? 'Erro ao fazer check-in:' : languageCode == 'es' ? 'Error al hacer registro:' : 'Error checking in:';
      case 'checkIns':
        return languageCode == 'pt' ? 'Check-ins' : languageCode == 'es' ? 'Registros' : 'Check-ins';
      case 'checkInHistory':
        return languageCode == 'pt' ? 'Histórico de Check-ins' : languageCode == 'es' ? 'Historial de Registros' : 'Check-in History';
      case 'checkInsCompleted':
        return languageCode == 'pt' ? 'check-ins realizados' : languageCode == 'es' ? 'registros realizados' : 'check-ins completed';
      
      // Coupons
      case 'coupons':
        return languageCode == 'pt' ? 'Cupons' : languageCode == 'es' ? 'Cupones' : 'Coupons';
      case 'myCoupons':
        return languageCode == 'pt' ? 'Meus Cupons' : languageCode == 'es' ? 'Mis Cupones' : 'My Coupons';
      case 'redeemCoupon':
        return languageCode == 'pt' ? 'Resgatar Cupom' : languageCode == 'es' ? 'Canjear Cupón' : 'Redeem Coupon';
      case 'redeemCoupons':
        return languageCode == 'pt' ? 'Resgatar Cupons' : languageCode == 'es' ? 'Canjear Cupones' : 'Redeem Coupons';
      case 'redeemCouponConfirm':
        return languageCode == 'pt' ? 'Deseja resgatar' : languageCode == 'es' ? '¿Deseas canjear' : 'Do you want to redeem';
      case 'redeemCouponConfirmPoints':
        return languageCode == 'pt' ? 'por' : languageCode == 'es' ? 'por' : 'for';
      case 'redeemCouponConfirmPointsEnd':
        return languageCode == 'pt' ? 'pontos?' : languageCode == 'es' ? 'puntos?' : 'points?';
      case 'yourPoints':
        return languageCode == 'pt' ? 'Seus pontos:' : languageCode == 'es' ? 'Tus puntos:' : 'Your points:';
      case 'enterCouponCode':
        return languageCode == 'pt' ? 'Digite o código do cupom:' : languageCode == 'es' ? 'Ingresa el código del cupón:' : 'Enter coupon code:';
      case 'couponCode':
        return languageCode == 'pt' ? 'Código do Cupom' : languageCode == 'es' ? 'Código del Cupón' : 'Coupon Code';
      case 'couponCodeExample':
        return languageCode == 'pt' ? 'Ex: CUPOM123' : languageCode == 'es' ? 'Ej: CUPON123' : 'Ex: COUPON123';
      case 'couponCodeInfo':
        return languageCode == 'pt' ? 'Os códigos de cupons são fornecidos pelos estabelecimentos ou através de campanhas especiais.' : languageCode == 'es' ? 'Los códigos de cupones son proporcionados por los establecimientos o a través de campañas especiales.' : 'Coupon codes are provided by establishments or through special campaigns.';
      case 'active':
        return languageCode == 'pt' ? 'Ativos' : languageCode == 'es' ? 'Activos' : 'Active';
      case 'expired':
        return languageCode == 'pt' ? 'Expirados' : languageCode == 'es' ? 'Expirados' : 'Expired';
      case 'all':
        return languageCode == 'pt' ? 'Todos' : languageCode == 'es' ? 'Todos' : 'All';
      case 'noCouponsActive':
        return languageCode == 'pt' ? 'Nenhum cupom ativo' : languageCode == 'es' ? 'Ningún cupón activo' : 'No active coupons';
      case 'noCouponsExpired':
        return languageCode == 'pt' ? 'Nenhum cupom expirado' : languageCode == 'es' ? 'Ningún cupón expirado' : 'No expired coupons';
      case 'noCoupons':
        return languageCode == 'pt' ? 'Nenhum cupom' : languageCode == 'es' ? 'Ningún cupón' : 'No coupons';
      case 'redeemCouponsWithPoints':
        return languageCode == 'pt' ? 'Resgate cupons com seus pontos!' : languageCode == 'es' ? '¡Canjea cupones con tus puntos!' : 'Redeem coupons with your points!';
      case 'discount':
        return languageCode == 'pt' ? 'de desconto' : languageCode == 'es' ? 'de descuento' : 'discount';
      case 'at':
        return languageCode == 'pt' ? 'Em:' : languageCode == 'es' ? 'En:' : 'At:';
      case 'usedOn':
        return languageCode == 'pt' ? 'Usado em' : languageCode == 'es' ? 'Usado en' : 'Used on';
      case 'expiredOn':
        return languageCode == 'pt' ? 'Expirado em' : languageCode == 'es' ? 'Expirado en' : 'Expired on';
      case 'validUntil':
        return languageCode == 'pt' ? 'Válido até' : languageCode == 'es' ? 'Válido hasta' : 'Valid until';
      case 'insufficientPoints':
        return languageCode == 'pt' ? 'Pontos insuficientes! Você precisa de' : languageCode == 'es' ? '¡Puntos insuficientes! Necesitas' : 'Insufficient points! You need';
      case 'pointsRequired':
        return languageCode == 'pt' ? 'pontos.' : languageCode == 'es' ? 'puntos.' : 'points.';
      case 'couponRedeemedSuccess':
        return languageCode == 'pt' ? 'Cupom resgatado com sucesso! 🎉' : languageCode == 'es' ? '¡Cupón canjeado con éxito! 🎉' : 'Coupon redeemed successfully! 🎉';
      case 'couponRedeemError':
        return languageCode == 'pt' ? 'Erro ao resgatar cupom:' : languageCode == 'es' ? 'Error al canjear cupón:' : 'Error redeeming coupon:';
      case 'loadCouponsError':
        return languageCode == 'pt' ? 'Erro ao carregar cupons:' : languageCode == 'es' ? 'Error al cargar cupones:' : 'Error loading coupons:';
      case 'pleaseEnterCouponCode':
        return languageCode == 'pt' ? 'Por favor, digite o código do cupom' : languageCode == 'es' ? 'Por favor, ingresa el código del cupón' : 'Please enter coupon code';
      case 'invalidCouponCode':
        return languageCode == 'pt' ? 'Código de cupom inválido ou expirado' : languageCode == 'es' ? 'Código de cupón inválido o expirado' : 'Invalid or expired coupon code';
      case 'activeCoupons':
        return languageCode == 'pt' ? 'cupons ativos' : languageCode == 'es' ? 'cupones activos' : 'active coupons';
      
      // User Profile
      case 'onlyUsersCanAccessProfile':
        return languageCode == 'pt' ? 'Apenas usuários podem acessar este perfil' : languageCode == 'es' ? 'Solo los usuarios pueden acceder a este perfil' : 'Only users can access this profile';
      case 'shareAchievements':
        return languageCode == 'pt' ? 'Compartilhar conquistas' : languageCode == 'es' ? 'Compartir logros' : 'Share achievements';
      case 'premiumAccountActive':
        return languageCode == 'pt' ? 'Conta Premium Ativa' : languageCode == 'es' ? 'Cuenta Premium Activa' : 'Premium Account Active';
      case 'expiresIn':
        return languageCode == 'pt' ? 'Expira em' : languageCode == 'es' ? 'Expira en' : 'Expires in';
      case 'becomePremium':
        return languageCode == 'pt' ? 'Torne-se Premium' : languageCode == 'es' ? 'Conviértete en Premium' : 'Become Premium';
      case 'premiumBenefits':
        return languageCode == 'pt' ? 'Acesso antecipado, filtros avançados e muito mais!' : languageCode == 'es' ? '¡Acceso anticipado, filtros avanzados y mucho más!' : 'Early access, advanced filters and much more!';
      case 'becomePremiumInfo':
        return languageCode == 'pt' ? 'Para tornar-se Premium, entre em contato com o suporte ou use o painel administrativo.' : languageCode == 'es' ? 'Para convertirte en Premium, contacta con soporte o usa el panel administrativo.' : 'To become Premium, contact support or use the admin panel.';
      case 'premium':
        return languageCode == 'pt' ? 'Premium' : languageCode == 'es' ? 'Premium' : 'Premium';
      case 'seal':
        return languageCode == 'pt' ? 'Selo' : languageCode == 'es' ? 'Sello' : 'Seal';
      case 'points':
        return languageCode == 'pt' ? 'Pontos' : languageCode == 'es' ? 'Puntos' : 'Points';
      case 'pointsToRedeemPremium':
        return languageCode == 'pt' ? 'pontos para resgatar 1 mês Premium' : languageCode == 'es' ? 'puntos para canjear 1 mes Premium' : 'points to redeem 1 month Premium';
      case 'quickActions':
        return languageCode == 'pt' ? 'Ações Rápidas' : languageCode == 'es' ? 'Acciones Rápidas' : 'Quick Actions';
      case 'history':
        return languageCode == 'pt' ? 'Histórico' : languageCode == 'es' ? 'Historial' : 'History';
      case 'referNewPlace':
        return languageCode == 'pt' ? 'Indicar Novo Local' : languageCode == 'es' ? 'Indicar Nuevo Lugar' : 'Refer New Place';
      case 'statistics':
        return languageCode == 'pt' ? 'Estatísticas' : languageCode == 'es' ? 'Estadísticas' : 'Statistics';
      case 'reviews':
        return languageCode == 'pt' ? 'Avaliações' : languageCode == 'es' ? 'Reseñas' : 'Reviews';
      case 'referrals':
        return languageCode == 'pt' ? 'Indicações' : languageCode == 'es' ? 'Referencias' : 'Referrals';
      case 'seeAll':
        return languageCode == 'pt' ? 'Ver todos' : languageCode == 'es' ? 'Ver todos' : 'See all';
      case 'travelMode':
        return languageCode == 'pt' ? 'Modo Viagem' : languageCode == 'es' ? 'Modo Viaje' : 'Travel Mode';
      case 'manage':
        return languageCode == 'pt' ? 'Gerenciar' : languageCode == 'es' ? 'Gestionar' : 'Manage';
      case 'downloadRegionData':
        return languageCode == 'pt' ? 'Baixe dados de uma região para usar sem internet' : languageCode == 'es' ? 'Descarga datos de una región para usar sin internet' : 'Download region data to use without internet';
      case 'days':
        return languageCode == 'pt' ? 'dias' : languageCode == 'es' ? 'días' : 'days';
      case 'hours':
        return languageCode == 'pt' ? 'horas' : languageCode == 'es' ? 'horas' : 'hours';
      case 'today':
        return languageCode == 'pt' ? 'Hoje' : languageCode == 'es' ? 'Hoy' : 'Today';
      
      default:
        return key;
    }
  }
}

