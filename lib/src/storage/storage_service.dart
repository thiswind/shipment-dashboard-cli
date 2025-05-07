import 'dart:convert';
import 'dart:io';
import '../models/customer.dart';
import '../models/shipment.dart';

class StorageService {
  static const String _customersFile = 'data/customers.json';
  static const String _shipmentsFile = 'data/shipments.json';

  // 确保数据目录存在
  static Future<void> _ensureDataDirectory() async {
    final directory = Directory('data');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  // 确保文件存在
  static Future<void> _ensureFileExists(String filePath) async {
    try {
      await _ensureDataDirectory();
      final file = File(filePath);
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString('[]');
      } else {
        final content = await file.readAsString();
        if (content.isEmpty) {
          await file.writeAsString('[]');
        }
      }
    } catch (e) {
      print('Warning: Error ensuring file exists: $e');
      rethrow;
    }
  }

  // 保存客户数据
  static Future<void> saveCustomers(List<Customer> customers) async {
    try {
      await _ensureFileExists(_customersFile);
      final file = File(_customersFile);
      final jsonList = customers.map((c) => c.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print('Warning: Error saving customers: $e');
      rethrow;
    }
  }

  // 读取客户数据
  static Future<List<Customer>> loadCustomers() async {
    try {
      await _ensureFileExists(_customersFile);
      final file = File(_customersFile);
      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      print('Warning: Error loading customers: $e');
      rethrow;
    }
  }

  // 保存运单数据
  static Future<void> saveShipments(List<Shipment> shipments) async {
    try {
      await _ensureFileExists(_shipmentsFile);
      final file = File(_shipmentsFile);
      final jsonList = shipments.map((s) => s.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print('Warning: Error saving shipments: $e');
      rethrow;
    }
  }

  // 读取运单数据
  static Future<List<Shipment>> loadShipments() async {
    try {
      await _ensureFileExists(_shipmentsFile);
      final file = File(_shipmentsFile);
      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Shipment.fromJson(json)).toList();
    } catch (e) {
      print('Warning: Error loading shipments: $e');
      rethrow;
    }
  }
} 