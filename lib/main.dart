import 'dart:io';
import 'package:shipment/src/services/customer_service.dart';
import 'package:shipment/src/services/shipment_service.dart';

Future<void> main() async {
  print('欢迎使用外贸发货看板系统');
  
  while (true) {
    print('\n请选择操作：');
    print('1. 贸易商登录');
    print('2. 客户登录');
    print('3. 退出系统');
    
    final choice = stdin.readLineSync();
    
    switch (choice) {
      case '1':
        await traderLogin();
        break;
      case '2':
        await customerLogin();
        break;
      case '3':
        print('感谢使用，再见！');
        return;
      default:
        print('无效的选择，请重试');
    }
  }
}

Future<void> traderLogin() async {
  print('\n请输入贸易商账号：');
  final username = stdin.readLineSync();
  print('请输入密码：');
  final password = stdin.readLineSync();
  
  // 这里简化了登录验证，实际应用中应该使用更安全的方式
  if (username != 'admin' || password != 'admin123') {
    print('账号或密码错误');
    return;
  }
  
  await traderMenu();
}

Future<void> traderMenu() async {
  while (true) {
    print('\n贸易商操作菜单：');
    print('1. 创建新客户');
    print('2. 创建新运单');
    print('3. 更新运单状态');
    print('4. 查看运单详情');
    print('5. 返回主菜单');
    
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
        print('无效的选择，请重试');
    }
  }
}

Future<void> createNewCustomer() async {
  try {
    print('\n请输入客户代码：');
    final code = stdin.readLineSync() ?? '';
    
    print('请输入客户姓名：');
    final name = stdin.readLineSync() ?? '';
    
    print('请输入客户联系方式：');
    final contact = stdin.readLineSync() ?? '';
    
    print('请输入客户国家（如：SA）：');
    final country = stdin.readLineSync() ?? '';
    
    print('请输入客户语言（如：ar）：');
    final language = stdin.readLineSync() ?? '';
    
    print('请输入客户时区（如：+3）：');
    final timezoneStr = stdin.readLineSync() ?? '';
    final timezone = int.tryParse(timezoneStr.replaceAll('+', ''));
    if (timezone == null) {
      print('无效的时区');
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
    
    print('\n客户创建成功：');
    print(customer);
  } catch (e) {
    print('创建客户失败：$e');
  }
}

Future<void> createNewShipment() async {
  try {
    print('\n请输入客户代码：');
    final customerCode = stdin.readLineSync() ?? '';
    
    if (!await CustomerService.validateCustomerCode(customerCode)) {
      print('客户代码不存在');
      return;
    }
    
    print('请输入货物简称（不超过16字符）：');
    final goodsShort = stdin.readLineSync() ?? '';
    if (goodsShort.length > 16) {
      print('货物简称过长');
      return;
    }
    
    print('请输入货物明细：');
    final goodsDetail = stdin.readLineSync() ?? '';
    
    print('请输入包裹数量：');
    final packageCount = int.tryParse(stdin.readLineSync() ?? '');
    if (packageCount == null || packageCount <= 0) {
      print('无效的包裹数量');
      return;
    }
    
    print('请选择运输方式（Sea/Air）：');
    final transportType = stdin.readLineSync()?.toUpperCase() ?? '';
    if (transportType != 'SEA' && transportType != 'AIR') {
      print('无效的运输方式');
      return;
    }
    
    print('请输入预计运输时间（天）：');
    final estimatedDays = int.tryParse(stdin.readLineSync() ?? '');
    if (estimatedDays == null || estimatedDays <= 0) {
      print('无效的运输时间');
      return;
    }
    
    final shipment = await ShipmentService.createShipment(
      portTimezone: 8, // 默认中国时区
      customerCode: customerCode,
      transportType: transportType,
      estimatedDays: estimatedDays,
      goodsShort: goodsShort,
      goodsDetail: goodsDetail,
      packageCount: packageCount,
    );
    
    print('\n运单创建成功：');
    print(shipment);
  } catch (e) {
    print('创建运单失败：$e');
  }
}

Future<void> updateShipmentStatus() async {
  print('\n请输入运单号：');
  final id = stdin.readLineSync() ?? '';
  
  final shipment = await ShipmentService.getShipment(id);
  if (shipment == null) {
    print('运单不存在');
    return;
  }
  
  print('\n当前运单状态：${shipment.status}');
  print('请选择新状态：');
  print('1. 已发货');
  print('2. 已到达');
  print('3. 已提货');
  
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
      print('无效的选择');
      return;
  }
  
  try {
    await ShipmentService.updateShipmentStatus(id, newStatus);
    print('状态更新成功');
  } catch (e) {
    print('状态更新失败：$e');
  }
}

Future<void> viewShipmentDetails() async {
  print('\n请输入运单号：');
  final id = stdin.readLineSync() ?? '';
  
  final shipment = await ShipmentService.getShipment(id);
  if (shipment == null) {
    print('运单不存在');
    return;
  }
  
  print('\n运单详情：');
  print(shipment);
}

Future<void> customerLogin() async {
  print('\n请输入客户代码：');
  final customerCode = stdin.readLineSync() ?? '';
  
  if (!await CustomerService.validateCustomerCode(customerCode)) {
    print('客户代码不存在');
    return;
  }
  
  final shipments = await ShipmentService.getCustomerShipments(customerCode);
  
  if (shipments.isEmpty) {
    print('暂无相关运单');
    return;
  }
  
  print('\n您的运单列表：');
  for (var shipment in shipments) {
    print('\n${shipment.id} - ${shipment.status}');
    print('货物：${shipment.goodsShort}');
    print('运输方式：${shipment.transportType}');
    print('创建时间：${shipment.createdAt}');
    print('------------------------');
  }
} 