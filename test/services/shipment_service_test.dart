import 'package:test/test.dart';
import 'package:shipment/src/services/shipment_service.dart';
import 'package:shipment/src/services/customer_service.dart';
import 'package:shipment/src/models/shipment.dart';
import 'dart:io';

void main() {
  group('ShipmentService Tests', () {
    // 每个测试前清理测试数据并创建测试客户
    setUp(() async {
      try {
        final dataDir = Directory('data');
        if (await dataDir.exists()) {
          await dataDir.delete(recursive: true);
        }
        await dataDir.create();
        
        // 创建测试客户
        await CustomerService.createCustomer(
          code: 'TEST-001',
          name: 'Test Customer',
          contact: '+1 234567890',
          country: 'US',
          language: 'en',
          timezone: -4,
        );
      } catch (e) {
        print('Warning: Error during test setup: $e');
      }
    });

    test('创建新运单测试', () async {
      final shipment = await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: 'TEST-001',
        transportType: 'SEA',
        estimatedDays: 30,
        goodsShort: 'ELEC',
        goodsDetail: '电子产品',
        packageCount: 10,
      );

      expect(shipment.customerCode, equals('TEST-001'));
      expect(shipment.transportType, equals('SEA'));
      expect(shipment.estimatedDays, equals(30));
      expect(shipment.status, equals('未发货'));
      expect(shipment.goodsShort, equals('ELEC'));
      expect(shipment.goodsDetail, equals('电子产品'));
      expect(shipment.packageCount, equals(10));
    });

    test('更新运单状态测试', () async {
      final shipment = await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: 'TEST-001',
        transportType: 'SEA',
        estimatedDays: 30,
        goodsShort: 'ELEC',
        goodsDetail: '电子产品',
        packageCount: 10,
      );

      await ShipmentService.updateShipmentStatus(shipment.id, '已发货');
      var updatedShipment = await ShipmentService.getShipment(shipment.id);
      expect(updatedShipment?.status, equals('已发货'));
      expect(updatedShipment?.sentDate, isNotNull);

      await ShipmentService.updateShipmentStatus(shipment.id, '已到达');
      updatedShipment = await ShipmentService.getShipment(shipment.id);
      expect(updatedShipment?.status, equals('已到达'));
      expect(updatedShipment?.arrivedDate, isNotNull);

      await ShipmentService.updateShipmentStatus(shipment.id, '已提货');
      updatedShipment = await ShipmentService.getShipment(shipment.id);
      expect(updatedShipment?.status, equals('已提货'));
      expect(updatedShipment?.pickedDate, isNotNull);
    });

    test('查询客户运单测试', () async {
      // 创建多个运单
      await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: 'TEST-001',
        transportType: 'SEA',
        estimatedDays: 30,
        goodsShort: 'ELEC1',
        goodsDetail: '电子产品1',
        packageCount: 10,
      );

      await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: 'TEST-001',
        transportType: 'AIR',
        estimatedDays: 7,
        goodsShort: 'ELEC2',
        goodsDetail: '电子产品2',
        packageCount: 5,
      );

      final shipments = await ShipmentService.getCustomerShipments('TEST-001');
      expect(shipments.length, equals(2));
      expect(shipments[0].customerCode, equals('TEST-001'));
      expect(shipments[1].customerCode, equals('TEST-001'));
    });

    test('查询不存在的运单测试', () async {
      final shipment = await ShipmentService.getShipment('NONEXISTENT');
      expect(shipment, isNull);
    });

    test('更新不存在的运单状态测试', () async {
      expect(() => ShipmentService.updateShipmentStatus('NONEXISTENT', '已发货'),
          throwsException);
    });
  });
} 