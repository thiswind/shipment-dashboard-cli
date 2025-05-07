import 'dart:io';
import '../services/customer_service.dart';
import '../services/shipment_service.dart';

class CliService {
  final Stdin stdin;
  final Stdout stdout;

  CliService({
    required this.stdin,
    required this.stdout,
  });

  Future<void> start() async {
    stdout.writeln('欢迎使用外贸发货看板系统');
    
    while (true) {
      stdout.writeln('\n请选择操作：');
      stdout.writeln('1. 贸易商登录');
      stdout.writeln('2. 客户登录');
      stdout.writeln('3. 退出系统');
      
      final choice = stdin.readLineSync();
      
      switch (choice) {
        case '1':
          await traderLogin();
          break;
        case '2':
          await customerLogin();
          break;
        case '3':
          stdout.writeln('感谢使用，再见！');
          return;
        default:
          stdout.writeln('无效的选择，请重试');
      }
    }
  }

  Future<void> traderLogin() async {
    stdout.writeln('\n请输入贸易商账号：');
    final username = stdin.readLineSync();
    stdout.writeln('请输入密码：');
    final password = stdin.readLineSync();
    
    if (username != 'admin' || password != 'admin123') {
      stdout.writeln('账号或密码错误');
      return;
    }
    
    await traderMenu();
  }

  Future<void> traderMenu() async {
    while (true) {
      stdout.writeln('\n贸易商操作菜单：');
      stdout.writeln('1. 创建新客户');
      stdout.writeln('2. 创建新运单');
      stdout.writeln('3. 更新运单状态');
      stdout.writeln('4. 查看运单详情');
      stdout.writeln('5. 返回主菜单');
      
      final choice = stdin.readLineSync();
      
      switch (choice) {
        case '1':
          await createNewCustomer();
          break;
        case '2':
          await createNewShipment();
          break;
        case '3':
          await updateShipmentStatus();
          break;
        case '4':
          await viewShipmentDetails();
          break;
        case '5':
          return;
        default:
          stdout.writeln('无效的选择，请重试');
      }
    }
  }

  Future<void> createNewCustomer() async {
    try {
      stdout.writeln('\n请输入客户代码：');
      final code = stdin.readLineSync() ?? '';
      
      stdout.writeln('请输入客户姓名：');
      final name = stdin.readLineSync() ?? '';
      
      stdout.writeln('请输入客户联系方式：');
      final contact = stdin.readLineSync() ?? '';
      
      stdout.writeln('请输入客户国家（如：SA）：');
      final country = stdin.readLineSync() ?? '';
      
      stdout.writeln('请输入客户语言（如：ar）：');
      final language = stdin.readLineSync() ?? '';
      
      stdout.writeln('请输入客户时区（如：+3）：');
      final timezoneStr = stdin.readLineSync() ?? '';
      final timezone = int.tryParse(timezoneStr.replaceAll('+', ''));
      if (timezone == null) {
        stdout.writeln('无效的时区');
        return;
      }
      
      final customer = await CustomerService.createCustomer(
        code: code,
        name: name,
        contact: contact,
        country: country,
        language: language,
        timezone: timezone,
      );
      
      stdout.writeln('\n客户创建成功：');
      stdout.writeln(customer);
    } catch (e) {
      stdout.writeln('创建客户失败：$e');
    }
  }

  Future<void> createNewShipment() async {
    try {
      stdout.writeln('\n请输入客户代码：');
      final customerCode = stdin.readLineSync() ?? '';
      
      if (!await CustomerService.validateCustomerCode(customerCode)) {
        stdout.writeln('客户代码不存在');
        return;
      }
      
      stdout.writeln('请输入货物简称（不超过16字符）：');
      final goodsShort = stdin.readLineSync() ?? '';
      if (goodsShort.length > 16) {
        stdout.writeln('货物简称过长');
        return;
      }
      
      stdout.writeln('请输入货物明细：');
      final goodsDetail = stdin.readLineSync() ?? '';
      
      stdout.writeln('请输入包裹数量：');
      final packageCount = int.tryParse(stdin.readLineSync() ?? '');
      if (packageCount == null || packageCount <= 0) {
        stdout.writeln('无效的包裹数量');
        return;
      }
      
      stdout.writeln('请选择运输方式（Sea/Air）：');
      final transportType = stdin.readLineSync()?.toUpperCase() ?? '';
      if (transportType != 'SEA' && transportType != 'AIR') {
        stdout.writeln('无效的运输方式');
        return;
      }
      
      stdout.writeln('请输入预计运输时间（天）：');
      final estimatedDays = int.tryParse(stdin.readLineSync() ?? '');
      if (estimatedDays == null || estimatedDays <= 0) {
        stdout.writeln('无效的运输时间');
        return;
      }
      
      final shipment = await ShipmentService.createShipment(
        portTimezone: 8,
        customerCode: customerCode,
        transportType: transportType,
        estimatedDays: estimatedDays,
        goodsShort: goodsShort,
        goodsDetail: goodsDetail,
        packageCount: packageCount,
      );
      
      stdout.writeln('\n运单创建成功：');
      stdout.writeln(shipment);
    } catch (e) {
      stdout.writeln('创建运单失败：$e');
    }
  }

  Future<void> updateShipmentStatus() async {
    stdout.writeln('\n请输入运单号：');
    final id = stdin.readLineSync() ?? '';
    
    final shipment = await ShipmentService.getShipment(id);
    if (shipment == null) {
      stdout.writeln('运单不存在');
      return;
    }
    
    stdout.writeln('\n当前运单状态：${shipment.status}');
    stdout.writeln('请选择新状态：');
    stdout.writeln('1. 已发货');
    stdout.writeln('2. 已到达');
    stdout.writeln('3. 已提货');
    
    final choice = stdin.readLineSync();
    String newStatus;
    
    switch (choice) {
      case '1':
        newStatus = '已发货';
        break;
      case '2':
        newStatus = '已到达';
        break;
      case '3':
        newStatus = '已提货';
        break;
      default:
        stdout.writeln('无效的选择');
        return;
    }
    
    try {
      await ShipmentService.updateShipmentStatus(id, newStatus);
      stdout.writeln('状态更新成功');
    } catch (e) {
      stdout.writeln('状态更新失败：$e');
    }
  }

  Future<void> viewShipmentDetails() async {
    stdout.writeln('\n请输入运单号：');
    final id = stdin.readLineSync() ?? '';
    
    final shipment = await ShipmentService.getShipment(id);
    if (shipment == null) {
      stdout.writeln('运单不存在');
      return;
    }
    
    stdout.writeln('\n运单详情：');
    stdout.writeln(shipment);
  }

  Future<void> customerLogin() async {
    stdout.writeln('\n请输入客户代码：');
    final customerCode = stdin.readLineSync() ?? '';
    
    if (!await CustomerService.validateCustomerCode(customerCode)) {
      stdout.writeln('客户代码不存在');
      return;
    }
    
    final shipments = await ShipmentService.getCustomerShipments(customerCode);
    
    if (shipments.isEmpty) {
      stdout.writeln('暂无相关运单');
      return;
    }
    
    stdout.writeln('\n您的运单列表：');
    for (var shipment in shipments) {
      stdout.writeln('\n${shipment.id} - ${shipment.status}');
      stdout.writeln('货物：${shipment.goodsShort}');
      stdout.writeln('运输方式：${shipment.transportType}');
      stdout.writeln('创建时间：${shipment.createdAt}');
      stdout.writeln('------------------------');
    }
  }
} 