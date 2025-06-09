import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/world_state.dart';
import '../models/parking_spot.dart';

/// Widget que permite buscar vehículos por placa en el estacionamiento
class VehicleSearch extends StatefulWidget {
  final Function(ParkingSpot)? onSpotFound;
  
  const VehicleSearch({
    Key? key,
    this.onSpotFound,
  }) : super(key: key);

  @override
  State<VehicleSearch> createState() => _VehicleSearchState();
}

class _VehicleSearchState extends State<VehicleSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<ParkingSpot> _searchResults = [];
  bool _isSearching = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _performSearch(WorldState state, String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    // Filtrar spots por placa
    final results = state.spots.where((spot) {
      if (spot.vehiclePlate == null || spot.vehiclePlate!.isEmpty) {
        return false;
      }
      return spot.vehiclePlate!.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WorldState>(
      builder: (context, state, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buscar Vehículo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Campo de búsqueda
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ingrese placa a buscar',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch(state, '');
                        },
                      )
                    : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: (value) => _performSearch(state, value),
              ),
              
              // Resultados de búsqueda
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'No se encontraron vehículos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_searchResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultados (${_searchResults.length})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final spot = _searchResults[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, 
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: spot.categoryColor.withOpacity(0.2),
                                foregroundColor: spot.categoryColor,
                                child: Icon(spot.typeIcon, size: 20),
                              ),
                              title: Text(
                                spot.vehiclePlate ?? 'Sin placa',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Espacio ${spot.label} - ${spot.categoryName}',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  if (widget.onSpotFound != null) {
                                    widget.onSpotFound!(spot);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('Localizar'),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
} 