import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/data/product_model.dart';
import 'vehicle_load_line.dart';
import '../data/vehicle_model.dart';
import '../data/vehicles_repository.dart';

class NewVehicleLoadState {
  const NewVehicleLoadState({this.vehicle, this.salesRep, this.lines = const []});

  final VehicleModel? vehicle;
  final SalesRepModel? salesRep;
  final List<VehicleLoadLine> lines;

  NewVehicleLoadState copyWith({VehicleModel? vehicle, SalesRepModel? salesRep, List<VehicleLoadLine>? lines}) {
    return NewVehicleLoadState(
      vehicle: vehicle ?? this.vehicle,
      salesRep: salesRep ?? this.salesRep,
      lines: lines ?? this.lines,
    );
  }
}

class NewVehicleLoadController extends Notifier<NewVehicleLoadState> {
  @override
  NewVehicleLoadState build() => const NewVehicleLoadState();

  void setVehicle(VehicleModel vehicle) => state = state.copyWith(vehicle: vehicle);

  void setSalesRep(SalesRepModel rep) => state = state.copyWith(salesRep: rep);

  void addProduct(ProductModel product) {
    final unit = product.defaultSaleUnit;
    final existingIndex = state.lines.indexWhere((l) => l.product.id == product.id);
    if (existingIndex >= 0) {
      final updated = [...state.lines];
      updated[existingIndex] = updated[existingIndex].copyWith(quantity: updated[existingIndex].quantity + 1);
      state = state.copyWith(lines: updated);
    } else {
      state = state.copyWith(lines: [...state.lines, VehicleLoadLine(product: product, unit: unit, quantity: 1)]);
    }
  }

  void updateQuantity(int index, double quantity) {
    if (quantity <= 0) {
      removeLine(index);
      return;
    }
    final updated = [...state.lines];
    updated[index] = updated[index].copyWith(quantity: quantity);
    state = state.copyWith(lines: updated);
  }

  void removeLine(int index) {
    final updated = [...state.lines]..removeAt(index);
    state = state.copyWith(lines: updated);
  }

  Future<void> submit(int warehouseId) async {
    final vehicle = state.vehicle;
    final rep = state.salesRep;
    if (vehicle == null || rep == null || state.lines.isEmpty) {
      throw StateError('incomplete_vehicle_load');
    }

    await ref.read(vehiclesRepositoryProvider).createLoad(
          vehicleId: vehicle.id,
          salesRepId: rep.id,
          warehouseId: warehouseId,
          items: state.lines.map((l) => (productId: l.product.id, quantityBase: l.quantityBase)).toList(),
        );
  }
}

final newVehicleLoadControllerProvider =
    NotifierProvider.autoDispose<NewVehicleLoadController, NewVehicleLoadState>(NewVehicleLoadController.new);
