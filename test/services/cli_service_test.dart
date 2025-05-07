import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:shipment/src/services/cli_service.dart';
import 'package:shipment/src/services/customer_service.dart';
import 'package:shipment/src/services/shipment_service.dart';

abstract class TestStdin implements Stdin {
  String? readLineSync({Encoding encoding = systemEncoding, bool retainNewlines = false});
}

abstract class TestStdout implements Stdout {
  void writeln([Object? object = ""]);
  void write([Object? object = ""]);
  String getOutput();
}

class MockStdin implements TestStdin {
  final List<String> inputs;
  int _index = 0;

  MockStdin(this.inputs);

  @override
  String? readLineSync({Encoding encoding = systemEncoding, bool retainNewlines = false}) {
    if (_index < inputs.length) {
      return inputs[_index++];
    }
    return null;
  }

  // 实现其他必需的方法，但我们不会使用它们
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockStdout implements TestStdout {
  final StringBuffer buffer = StringBuffer();

  @override
  void writeln([Object? object = ""]) {
    buffer.writeln(object);
  }

  @override
  void write([Object? object = ""]) {
    buffer.write(object);
  }

  @override
  String getOutput() {
    return buffer.toString();
  }

  // 实现其他必需的方法，但我们不会使用它们
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockStdin mockStdin;
  late MockStdout mockStdout;
  late CliService cliService;

  setUp(() async {
    // 清理测试数据
    final dataDir = Directory('data');
    if (await dataDir.exists()) {
      await dataDir.delete(recursive: true);
    }
    await dataDir.create();

    mockStdin = MockStdin([]);
    mockStdout = MockStdout();
    cliService = CliService(
      stdin: mockStdin,
      stdout: mockStdout,
    );
  });

  group('CliService Tests', () {
    test('贸易商登录成功测试', () async {
      mockStdin = MockStdin(['1', 'admin', 'admin123', '5', '3']);
      cliService = CliService(
        stdin: mockStdin,
        stdout: mockStdout,
      );

      await cliService.start();

      expect(mockStdout.getOutput(), contains('欢迎使用外贸发货看板系统'));
      expect(mockStdout.getOutput(), contains('贸易商操作菜单'));
    });

    test('贸易商登录失败测试', () async {
      mockStdin = MockStdin(['1', 'wrong', 'wrong', '3']);
      cliService = CliService(
        stdin: mockStdin,
        stdout: mockStdout,
      );

      await cliService.start();

      expect(mockStdout.getOutput(), contains('账号或密码错误'));
    });

    test('创建新客户测试', () async {
      mockStdin = MockStdin([
        '1', // 选择贸易商登录
        'admin',
        'admin123',
        '1', // 选择创建新客户
        'TEST-001',
        'Test Customer',
        '+1 234567890',
        'US',
        'en',
        '-4',
        '5', // 返回主菜单
        '3', // 退出系统
      ]);

      cliService = CliService(
        stdin: mockStdin,
        stdout: mockStdout,
      );

      await cliService.start();

      expect(mockStdout.getOutput(), contains('客户创建成功'));
      expect(mockStdout.getOutput(), contains('TEST-001'));
    });

    test('创建新运单测试', () async {
      // 先创建测试客户
      await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      mockStdin = MockStdin([
        '1', // 选择贸易商登录
        'admin',
        'admin123',
        '2', // 选择创建新运单
        'TEST-001',
        'ELEC',
        '电子产品',
        '10',
        'SEA',
        '30',
        '5', // 返回主菜单
        '3', // 退出系统
      ]);

      cliService = CliService(
        stdin: mockStdin,
        stdout: mockStdout,
      );

      await cliService.start();

      expect(mockStdout.getOutput(), contains('运单创建成功'));
      expect(mockStdout.getOutput(), contains('ELEC'));
    });

    test('客户登录查看运单测试', () async {
      // 先创建测试客户和运单
      await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: 'TEST-001',
        transportType: 'SEA',
        estimatedDays: 30,
        goodsShort: 'ELEC',
        goodsDetail: '电子产品',
        packageCount: 10,
      );

      mockStdin = MockStdin([
        '2', // 选择客户登录
        'TEST-001',
        '3', // 退出系统
      ]);

      cliService = CliService(
        stdin: mockStdin,
        stdout: mockStdout,
      );

      await cliService.start();

      expect(mockStdout.getOutput(), contains('您的运单列表'));
      expect(mockStdout.getOutput(), contains('ELEC'));
    });

    test('更新运单状态测试', () async {
      // 先创建测试客户和运单
      await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      final shipment = await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: 'TEST-001',
        transportType: 'SEA',
        estimatedDays: 30,
        goodsShort: 'ELEC',
        goodsDetail: '电子产品',
        packageCount: 10,
      );

      mockStdin = MockStdin([
        '1', // 选择贸易商登录
        'admin',
        'admin123',
        '3', // 选择更新运单状态
        shipment.id, // 输入运单号
        '1', // 选择已发货
        '5', // 返回主菜单
        '3', // 退出系统
      ]);

      cliService = CliService(
        stdin: mockStdin,
        stdout: mockStdout,
      );

      await cliService.start();

      expect(mockStdout.getOutput(), contains('状态更新成功'));
    });

    test('查看运单详情测试', () async {
      // 先创建测试客户和运单
      await CustomerService.createCustomer(
        code: 'TEST-001',
        name: 'Test Customer',
        contact: '+1 234567890',
        country: 'US',
        language: 'en',
        timezone: -4,
      );

      final shipment = await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: 'TEST-001',
        transportType: 'SEA',
        estimatedDays: 30,
        goodsShort: 'ELEC',
        goodsDetail: '电子产品',
        packageCount: 10,
      );

      mockStdin = MockStdin([
        '1', // 选择贸易商登录
        'admin',
        'admin123',
        '4', // 选择查看运单详情
        shipment.id, // 输入运单号
        '5', // 返回主菜单
        '3', // 退出系统
      ]);

      cliService = CliService(
        stdin: mockStdin,
        stdout: mockStdout,
      );

      await cliService.start();

      expect(mockStdout.getOutput(), contains('运单详情'));
      expect(mockStdout.getOutput(), contains(shipment.id));
      expect(mockStdout.getOutput(), contains('ELEC'));
    });
  });
} 