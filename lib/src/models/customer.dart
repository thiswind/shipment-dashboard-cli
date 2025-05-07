class Customer {
  final String code;
  final String name;
  final String contact;
  final String country;
  final String language;
  final int timezone;

  Customer({
    required this.code,
    required this.name,
    required this.contact,
    required this.country,
    required this.language,
    required this.timezone,
  });

  // 从JSON转换为Customer对象
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      code: json['code'] as String,
      name: json['name'] as String,
      contact: json['contact'] as String,
      country: json['country'] as String,
      language: json['language'] as String,
      timezone: json['timezone'] as int,
    );
  }

  // 将Customer对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'contact': contact,
      'country': country,
      'language': language,
      'timezone': timezone,
    };
  }

  @override
  String toString() {
    return '客户代码: $code\n'
        '客户姓名: $name\n'
        '联系方式: $contact\n'
        '国家: $country\n'
        '语言: $language\n'
        '时区: $timezone';
  }
} 