import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar la integridad de datos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRestaurantData();
    });
  }

  // Verificar si los datos del restaurante están actualizados
  Future<void> _checkRestaurantData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final restaurant = authService.currentRestaurant;
    
    if (restaurant != null && restaurant.id.isNotEmpty) {
      try {
        // Verificar si el restaurante aún existe en la base de datos
        final isValid = await authService.validateRestaurant(restaurant.id);
        if (!isValid && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Restaurante no encontrado. Verifique su conexión.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        print('Error checking restaurant data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final restaurant = authService.currentRestaurant;
    
    // Obtener el tamaño de pantalla para responsividad
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    if (user == null || restaurant == null || restaurant.id.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No tienes un restaurante asignado',
              style: TextStyle(fontSize: isTablet ? 18 : 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

  // Método para refrescar los datos del restaurante
  Future<void> _refreshRestaurantData(AuthService authService, String restaurantId) async {
    try {
      // Usar el método del AuthService para refrescar datos
      await authService.refreshRestaurantData();
      
      // Forzar actualización de la UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error refreshing restaurant data: $e');
      
      // Si hay error, intentar validar el restaurante
      final isValid = await authService.validateRestaurant(restaurantId);
      if (!isValid && mounted) {
        // Si el restaurante no existe, redirigir o mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El restaurante ya no existe o ha sido eliminado'),
            backgroundColor: Colors.red,
          ),
        );
        // Opcional: redirigir a una pantalla de error o login
        // Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

    Future<void> signOut(BuildContext context) async {
      try {
        await Supabase.instance.client.auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }

    final primaryColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant.nombre,
          style: TextStyle(fontSize: isTablet ? 22 : 20),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => signOut(context),
            icon: Icon(
              Icons.exit_to_app,
              size: isTablet ? 28 : 24,
            ),
          ),
        ],
      ),

      drawer: Drawer(
        width: screenWidth * 0.85, // Ancho responsivo del drawer
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              accountName: Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: isTablet ? 20 : 18
                ),
              ),
              accountEmail: Text(
                user.email,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              otherAccountsPictures: [
                Container(
                  width: isTablet ? 50 : 40,
                  height: isTablet ? 50 : 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: isTablet ? 25 : 20,
                  ),
                ),
              ],
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                radius: isTablet ? 35 : 30,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: isTablet ? 45 : 35,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Card con información del restaurante - Responsivo
            Container(
              margin: EdgeInsets.all(isTablet ? 20 : 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu, 
                            color: primaryColor,
                            size: isTablet ? 24 : 20,
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Text(
                            'Mi Restaurante',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildRestaurantInfo('Nombre', restaurant.nombre, isTablet, 
                          isEditable: true, fieldKey: 'nombre', context: context),
                      _buildRestaurantInfo('Descripción', restaurant.description!, isTablet,
                          isEditable: true, fieldKey: 'descripcion', context: context),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.menu_book,
                    text: 'Menú del Restaurante',
                    onTap: () => Navigator.pushNamed(context, '/admin/product-manager'),
                    primaryColor: primaryColor,
                    isTablet: isTablet,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people,
                    text: 'Gestión de Empleados',
                    onTap: () => Navigator.pushNamed(context, '/admin/worker-management'),
                    primaryColor: primaryColor,
                    isTablet: isTablet,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bar_chart,
                    text: 'Estadísticas',
                    onTap: () => Navigator.pushNamed(context, '/admin/restaurant-stats'),
                    primaryColor: primaryColor,
                    isTablet: isTablet,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    text: 'Configuración del Restaurante',
                    onTap: () => Navigator.pushNamed(context, '/admin/restaurant-settings'),
                    primaryColor: primaryColor,
                    isTablet: isTablet,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: Size.fromHeight(isTablet ? 56 : 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                ),
                icon: Icon(
                  Icons.logout,
                  size: isTablet ? 24 : 20,
                ),
                label: Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
                onPressed: () async {
                  await signOut(context);
                },
              ),
            ),
          ],
        ),
      ),
      
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% del ancho de pantalla
              vertical: isTablet ? 24 : 16,
            ),
            child: Column(
              children: [
                // Espaciado superior responsivo
                SizedBox(height: screenHeight * 0.02),
                
                // Card principal de información
                Card(
                  elevation: isTablet ? 8 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 32 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de la card
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline, 
                              color: primaryColor,
                              size: isTablet ? 28 : 24,
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Expanded(
                              child: Text(
                                'Información del Restaurante',
                                style: TextStyle(
                                  fontSize: isTablet ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        
                        // Grid responsivo de información
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Determinar número de columnas según el ancho disponible
                            int crossAxisCount = 1;
                            if (constraints.maxWidth > 600) {
                              crossAxisCount = 2;
                            }
                            if (constraints.maxWidth > 900) {
                              crossAxisCount = 3;
                            }
                            
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: isTablet ? 3.5 : 3,
                              crossAxisSpacing: isTablet ? 20 : 12,
                              mainAxisSpacing: isTablet ? 16 : 12,
                              children: [
                                _buildInfoCard('ID', restaurant.id, Icons.tag, isTablet, isEditable: false),
                                _buildInfoCard('Nombre', restaurant.nombre, Icons.restaurant, isTablet, 
                                    isEditable: true, fieldKey: 'nombre', context: context),
                                _buildInfoCard('Descripción', restaurant.description!, Icons.list, isTablet,
                                    isEditable: true, fieldKey: 'descripcion', context: context),
                                _buildInfoCard(
                                  'Fecha de registro', 
                                  restaurant.createdAt?.toString().split(' ')[0] ?? 'N/A', 
                                  Icons.calendar_today,
                                  isTablet,
                                  isEditable: false,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Espaciado inferior
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para editar campos
  void _editField(BuildContext context, String fieldName, String currentValue, String fieldKey) {
    final TextEditingController controller = TextEditingController(text: currentValue);
    final authService = Provider.of<AuthService>(context, listen: false);
    final restaurant = authService.currentRestaurant;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text('Editar $fieldName'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingrese el nuevo valor para $fieldName:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: fieldKey == 'descripcion' ? 3 : 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  labelText: fieldName,
                  prefixIcon: Icon(
                    fieldKey == 'nombre' ? Icons.restaurant : Icons.description,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El campo no puede estar vacío'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Actualizar en Supabase
                  await Supabase.instance.client
                      .from('Restaurantes')
                      .update({fieldKey: controller.text.trim()})
                      .eq('id', restaurant!.id);

                  // Actualizar el estado local si tienes un método para ello
                  // await authService.refreshRestaurantData();

                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$fieldName actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Opcional: Recargar la pantalla para mostrar los cambios
                  // Puedes implementar un setState si conviertes esto a StatefulWidget
                  // o usar Provider.of<AuthService>(context, listen: false).notifyListeners();
                  
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantInfo(String label, String value, bool isTablet, 
      {bool isEditable = false, String? fieldKey, BuildContext? context}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 4 : 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 90 : 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.black87,
              ),
            ),
          ),
          if (isEditable && context != null && fieldKey != null)
            GestureDetector(
              onTap: () => _editField(context, label, value, fieldKey),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 6 : 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                ),
                child: Icon(
                  Icons.edit,
                  size: isTablet ? 16 : 12,
                  color: Colors.deepPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, bool isTablet, 
      {bool isEditable = false, String? fieldKey, BuildContext? context}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon, 
                size: isTablet ? 20 : 16, 
                color: Colors.grey[600]
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              if (isEditable && context != null && fieldKey != null)
                GestureDetector(
                  onTap: () => _editField(context, label, value, fieldKey),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 6 : 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: isTablet ? 16 : 14,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 15 : 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isTablet,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: primaryColor,
        size: isTablet ? 28 : 24,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 18 : 16,
          color: Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      hoverColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 28 : 24, 
        vertical: isTablet ? 8 : 6,
      ),
      minVerticalPadding: isTablet ? 12 : 8,
    );
  }
}