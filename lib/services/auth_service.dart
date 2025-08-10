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
  }) : 
    _supabase = supabaseClient ?? Supabase.instance.client,
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

      final userData = await _supabase
          .from('usuarios')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = User.fromJson(userData);

      if (_currentUser!.restaurantId != null) {
        _currentRestaurant = await _restaurantService.getRestaurantById(
          _currentUser!.restaurantId!,
        );
      }

      _authState = AuthState.authenticated;
    } catch (e) {
      _authState = AuthState.error;
      debugPrint('Error loading user data: $e');
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
  }) async {
    try {
      _authState = AuthState.loading;
      notifyListeners();

      // 1. Registrar usuario en Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (authResponse.user == null) {
        throw Exception('User registration failed');
      }

      // 2. Crear registro en tabla usuarios
      final userResponse = await _supabase.from('usuarios').insert({
        'id': authResponse.user!.id,
        'nombre': name,
        'email': email,
        'rol': role.value,
        'id_restaurante': null,
      }).select().single();

      final user = User.fromJson(userResponse);
      _currentUser = user;

      // 3. Si es admin, crear restaurante
      if (role == UserRole.restaurantAdmin && restaurantName != null) {
        final restaurant = await _restaurantService.createRestaurant(
          nombre: restaurantName,
          description: restaurantDescription,
        );

        await _supabase.from('usuarios').update({
          'id_restaurante': restaurant.id,
        }).eq('id', user.id);

        _currentRestaurant = restaurant;
        _currentUser = user.copyWith(restaurantId: restaurant.id);
      }

      _authState = AuthState.authenticated;
      notifyListeners();
      return _currentUser!;
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
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}