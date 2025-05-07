class Shipment {
  final int portTimezone;
  final String id;
  final String customerCode;
  final String transportType;
  final int estimatedDays;
  final String status;
  final DateTime createdAt;
  final DateTime? sentDate;
  final DateTime? arrivedDate;
  final DateTime? pickedDate;
  final String goodsShort;
  final String goodsDetail;
  final int packageCount;

  Shipment({
    required this.portTimezone,
    required this.id,
    required this.customerCode,
    required this.transportType,
    required this.estimatedDays,
    required this.status,
    required this.createdAt,
    this.sentDate,
    this.arrivedDate,
    this.pickedDate,
    required this.goodsShort,
    required this.goodsDetail,
    required this.packageCount,
  });

  // 从JSON转换为Shipment对象
  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      portTimezone: json['portTimezone'] as int,
      id: json['id'] as String,
      customerCode: json['customerCode'] as String,
      transportType: json['transportType'] as String,
      estimatedDays: json['estimatedDays'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentDate: json['sentDate'] != null ? DateTime.parse(json['sentDate'] as String) : null,
      arrivedDate: json['arrivedDate'] != null ? DateTime.parse(json['arrivedDate'] as String) : null,
      pickedDate: json['pickedDate'] != null ? DateTime.parse(json['pickedDate'] as String) : null,
      goodsShort: json['goodsShort'] as String,
      goodsDetail: json['goodsDetail'] as String,
      packageCount: json['packageCount'] as int,
    );
  }

  // 将Shipment对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'portTimezone': portTimezone,
      'id': id,
      'customerCode': customerCode,
      'transportType': transportType,
      'estimatedDays': estimatedDays,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'sentDate': sentDate?.toIso8601String(),
      'arrivedDate': arrivedDate?.toIso8601String(),
      'pickedDate': pickedDate?.toIso8601String(),
      'goodsShort': goodsShort,
      'goodsDetail': goodsDetail,
      'packageCount': packageCount,
    };
  }

  @override
  String toString() {
    return '运单号: $id\n'
        '客户代码: $customerCode\n'
        '运输方式: $transportType\n'
        '预计运输时间: $estimatedDays天\n'
        '状态: $status\n'
        '创建时间: ${createdAt.toString()}\n'
        '发货时间: ${sentDate?.toString() ?? "未发货"}\n'
        '到达时间: ${arrivedDate?.toString() ?? "未到达"}\n'
        '提货时间: ${pickedDate?.toString() ?? "未提货"}\n'
        '货物简称: $goodsShort\n'
        '货物明细: $goodsDetail\n'
        '包裹数量: $packageCount';
  }
} 