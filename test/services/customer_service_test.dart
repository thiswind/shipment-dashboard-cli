import 'package:test/test.dart';
import 'package:shipment/src/services/customer_service.dart';
import 'dart:io';

void main() {
  group('CustomerService Tests', () {
    // 每个测试前清理测试数据
    setUp(() async {
      try {
        final dataDir = Directory('data');
        if (await dataDir.exists()) {
          await dataDir.delete(recursive: true);
        }
        await dataDir.create();
      } catch (e) {
        print('Warning: Error during test setup: $e');
      }
    });

    test('创建新客户测试', () async {
      final customer = await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      expect(customer.code, equals('TEST-001'));
      expect(customer.name, equals('Test Customer'));
      expect(customer.contact, equals('+1 234567890'));
      expect(customer.country, equals('US'));
      expect(customer.language, equals('en'));
      expect(customer.timezone, equals(-4));
    });

    test('创建重复客户代码测试', () async {
      await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer 1',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      expect(() => CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer 2',
        contact: '+1 987654321',
        country: 'CA',
        language: 'en',
        timezone: -5,
      ), throwsException);
    });

    test('获取客户信息测试', () async {
      await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      final customer = await CustomerService.getCustomer('TEST-001');
      expect(customer, isNotNull);
      expect(customer?.code, equals('TEST-001'));
      expect(customer?.name, equals('Test Customer'));
    });

    test('获取不存在的客户测试', () async {
      final customer = await CustomerService.getCustomer('NONEXISTENT');
      expect(customer, isNull);
    });

    test('验证客户代码测试', () async {
      await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      expect(await CustomerService.validateCustomerCode('TEST-001'), isTrue);
      expect(await CustomerService.validateCustomerCode('NONEXISTENT'), isFalse);
    });
  });
} 