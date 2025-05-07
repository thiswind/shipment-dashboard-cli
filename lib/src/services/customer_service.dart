import '../models/customer.dart';
import '../storage/storage_service.dart';

class CustomerService {
  // 创建新客户
  static Future<Customer> createCustomer({
    required String code,
    required String name,
    required String contact,
    required String country,
    required String language,
    required int timezone,
  }) async {
    final customers = await StorageService.loadCustomers();
    
    // 检查客户代码是否已存在
    if (customers.any((c) => c.code == code)) {
      throw Exception('客户代码已存在: $code');
    }
    
    final customer = Customer(
      code: code,
      name: name,
      contact: contact,
      country: country,
      language: language,
      timezone: timezone,
    );
    
    customers.add(customer);
    await StorageService.saveCustomers(customers);
    return customer;
  }

  // 获取客户信息
  static Future<Customer?> getCustomer(String code) async {
    final customers = await StorageService.loadCustomers();
    try {
      return customers.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  // 验证客户代码
  static Future<bool> validateCustomerCode(String code) async {
    final customer = await getCustomer(code);
    return customer != null;
  }
} 