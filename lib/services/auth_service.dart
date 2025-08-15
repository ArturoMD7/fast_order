import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';
import '../models/restaurant.dart';
import './restaurant_service.dart';

class AuthService with ChangeNotifier {
  final SupabaseClient _supabase;
  final RestaurantService _restaurantService;
  
  User? _currentUser;
  Restaurant? _currentRestaurant;
  AuthState _authState = AuthState.initial;

  User? get currentUser => _currentUser;
  Restaurant? get currentRestaurant => _currentRestaurant;
  AuthState get authState => _authState;

  AuthService({
    SupabaseClient? supabaseClient,
    RestaurantService? restaurantService,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _restaurantService = restaurantService ?? RestaurantService() {
    _initAuthListener();
  }

  Future<void> _initAuthListener() async {
    _supabase.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      
      if (session != null && _currentUser == null) {
        await _loadUserData(session.user.id);
      } else if (session == null) {
        _resetAuthState();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
  try {
    _authState = AuthState.loading;
    notifyListeners();

    // Reset current user and restaurant
    _currentUser = null;
    _currentRestaurant = null;

    final userData = await _supabase
        .from('Usuarios')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (userData == null) {
      throw Exception('User data not found in database');
    }

    // Convert all fields to String if needed
    final processedUserData = userData.map<String, dynamic>((key, value) {
      if (value is int) {
        return MapEntry(key, value.toString());
      }
      return MapEntry(key, value);
    });

    // Validate required fields
    if (processedUserData['rol'] == null || processedUserData['rol'].toString().isEmpty) {
      throw Exception('User role is missing or empty');
    }

    if (processedUserData['email'] == null || processedUserData['email'].toString().isEmpty) {
      throw Exception('User email is missing or empty');
    }

    if (processedUserData['nombre'] == null || processedUserData['nombre'].toString().isEmpty) {
      throw Exception('User name is missing or empty');
    }

    // Create user - handle both "restaurant_admin" and "administrador" roles
    final roleValue = processedUserData['rol'].toString();
    final normalizedRole = roleValue == 'administrador' 
        ? 'restaurant_admin' 
        : roleValue;
    final normalizedUserData = {
      ...processedUserData,
      'rol': normalizedRole
    };

    _currentUser = User.fromJson(normalizedUserData);

    // Load restaurant if needed
    if ((_currentUser!.isWorker || _currentUser!.isRestaurantAdmin) && 
        _currentUser!.restaurantId != null && 
        _currentUser!.restaurantId!.isNotEmpty) {
      try {
        _currentRestaurant = await _restaurantService.getRestaurantById(
          _currentUser!.restaurantId!,
        );
      } catch (e) {
        debugPrint('Error loading restaurant: $e');
        // Continue without restaurant data
        _currentRestaurant = null;
      }
    }

    _authState = AuthState.authenticated;
  } catch (e) {
    debugPrint('Error in _loadUserData: $e');
    _authState = AuthState.error;
    _currentUser = null;
    _currentRestaurant = null;
  } finally {
    notifyListeners();
  }
}

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? restaurantName,
    String? restaurantDescription,
    String? existingRestaurantId,
  }) async {
    try {
      _authState = AuthState.loading;
      notifyListeners();

      // Validación de datos para roles que requieren restaurante
      if (role == UserRole.restaurantAdmin && (restaurantName == null || restaurantName.isEmpty)) {
        throw Exception('Los administradores deben proporcionar nombre de restaurante');
      }

      if (role == UserRole.worker && existingRestaurantId == null) {
        throw Exception('Los trabajadores deben tener un restaurante asignado');
      }

      // 1. Registrar usuario en Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (authResponse.user == null) {
        throw Exception('Registro de usuario fallido');
      }

      // 2. Preparar datos para la tabla Usuarios
      final userData = {
        'id': authResponse.user!.id,
        'nombre': name,
        'email': email,
        'rol': role.value,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 3. Manejo específico por rol
      if (role == UserRole.restaurantAdmin) {
        final restaurant = await _restaurantService.createRestaurant(
          nombre: restaurantName!,
          description: restaurantDescription ?? '',
        );
        userData['id_restaurante'] = restaurant.id;
      } else if (role == UserRole.worker) {
        userData['id_restaurante'] = existingRestaurantId!;
      }

      // 4. Crear registro en tabla usuarios
      final userResponse = await _supabase.from('Usuarios')
          .insert(userData)
          .select()
          .single();

      // Normalize role if necessary
      final responseData = userResponse;
      if (responseData['rol'] == 'administrador') {
        responseData['rol'] = 'restaurant_admin';
      }

      final user = User.fromJson(responseData);
      _currentUser = user;

      // 5. Cargar restaurante si corresponde
      if (user.restaurantId != null) {
        try {
          _currentRestaurant = await _restaurantService.getRestaurantById(user.restaurantId!);
        } catch (e) {
          debugPrint('Error loading restaurant after registration: $e');
          _currentRestaurant = null;
        }
      }

      _authState = AuthState.authenticated;
      notifyListeners();
      return user;
    } catch (e) {
      _authState = AuthState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<User> login(String email, String password) async {
    try {
      _authState = AuthState.loading;
      notifyListeners();

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _loadUserData(authResponse.user!.id);
      if (_currentUser == null) {
        throw Exception('Failed to load user data after login');
      }
      return _currentUser!;
    } catch (e) {
      _authState = AuthState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _resetAuthState();
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null && _currentUser == null) {
      await _loadUserData(session.user.id);
    }
    return _currentUser;
  }

  void _resetAuthState() {
    _currentUser = null;
    _currentRestaurant = null;
    _authState = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> updateUserRestaurant(String restaurantId) async {
    if (_currentUser == null || restaurantId.isEmpty) {
      debugPrint('Cannot update restaurant - no user or empty restaurantId');
      return;
    }

    try {
      await _supabase.from('Usuarios')
          .update({'id_restaurante': restaurantId})
          .eq('id', _currentUser!.id);

      _currentUser = _currentUser!.copyWith(restaurantId: restaurantId);
      
      try {
        _currentRestaurant = await _restaurantService.getRestaurantById(restaurantId);
      } catch (e) {
        debugPrint('Error loading updated restaurant: $e');
        _currentRestaurant = null;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user restaurant: $e');
      rethrow;
    }
  }
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}