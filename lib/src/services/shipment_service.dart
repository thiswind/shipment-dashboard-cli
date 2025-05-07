import '../models/shipment.dart';
import '../storage/storage_service.dart';

class ShipmentService {
  // 创建新运单
  static Future<Shipment> createShipment({
    required int portTimezone,
    required String customerCode,
    required String transportType,
    required int estimatedDays,
    required String goodsShort,
    required String goodsDetail,
    required int packageCount,
  }) async {
    final shipments = await StorageService.loadShipments();
    
    // 生成运单号
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final id = '${customerCode}_${goodsShort}_${packageCount}_$timestamp';
    
    final shipment = Shipment(
      portTimezone: portTimezone,
      id: id,
      customerCode: customerCode,
      transportType: transportType,
      estimatedDays: estimatedDays,
      status: '未发货',
      createdAt: DateTime.now(),
      goodsShort: goodsShort,
      goodsDetail: goodsDetail,
      packageCount: packageCount,
    );
    
    shipments.add(shipment);
    await StorageService.saveShipments(shipments);
    return shipment;
  }

  // 更新运单状态
  static Future<void> updateShipmentStatus(String id, String newStatus) async {
    final shipments = await StorageService.loadShipments();
    final index = shipments.indexWhere((s) => s.id == id);
    
    if (index == -1) {
      throw Exception('运单不存在');
    }
    
    final oldShipment = shipments[index];
    final now = DateTime.now();
    
    final updatedShipment = Shipment(
      id: oldShipment.id,
      portTimezone: oldShipment.portTimezone,
      customerCode: oldShipment.customerCode,
      transportType: oldShipment.transportType,
      estimatedDays: oldShipment.estimatedDays,
      status: newStatus,
      createdAt: oldShipment.createdAt,
      goodsShort: oldShipment.goodsShort,
      goodsDetail: oldShipment.goodsDetail,
      packageCount: oldShipment.packageCount,
      sentDate: newStatus == '已发货' ? now : oldShipment.sentDate,
      arrivedDate: newStatus == '已到达' ? now : oldShipment.arrivedDate,
      pickedDate: newStatus == '已提货' ? now : oldShipment.pickedDate,
    );
    
    shipments[index] = updatedShipment;
    await StorageService.saveShipments(shipments);
  }

  // 查询客户的所有运单
  static Future<List<Shipment>> getCustomerShipments(String customerCode) async {
    final shipments = await StorageService.loadShipments();
    return shipments.where((s) => s.customerCode == customerCode).toList();
  }

  // 查询单个运单
  static Future<Shipment?> getShipment(String id) async {
    final shipments = await StorageService.loadShipments();
    final index = shipments.indexWhere((s) => s.id == id);
    if (index == -1) {
      return null;
    }
    return shipments[index];
  }
} 