# 外贸发货看板系统

这是一个基于Dart开发的外贸发货看板命令行程序，用于管理外贸发货流程。系统支持贸易商和客户两种角色，提供完整的运单管理功能。

## 功能特点

### 贸易商功能

- 客户管理
  - 创建新客户
  - 管理客户信息
- 运单管理
  - 创建新运单
  - 更新运单状态
  - 查看运单详情
  - 跟踪运单进度

### 客户功能

- 查看所有相关运单
- 跟踪运单状态
- 查看运单详细信息

## 系统要求

- Dart SDK 3.0.0 或更高版本
- 操作系统：支持 Windows、macOS 和 Linux

## 安装步骤

1. 确保已安装Dart SDK
2. 克隆项目到本地
3. 在项目根目录运行：

   ```bash
   dart pub get
   ```

## 运行程序

在项目根目录运行：

```bash
dart run bin/main.dart
```

## 使用说明

### 贸易商登录

- 默认账号：admin
- 默认密码：admin123

### 客户登录

- 使用客户代码登录
- 首次使用需要贸易商创建客户信息

### 运单状态说明

- 已创建：运单刚刚创建
- 已发货：货物已发出
- 已到达：货物已到达目的地
- 已提货：客户已提货

## 数据存储

- 所有数据存储在 `data` 目录下的JSON文件中
- `customers.json`: 存储客户信息
- `shipments.json`: 存储运单信息

## 项目结构

```shell
lib/
  ├── src/
  │   ├── models/          # 数据模型
  │   │   ├── customer.dart
  │   │   └── shipment.dart
  │   ├── services/        # 业务服务
  │   │   ├── cli_service.dart
  │   │   ├── customer_service.dart
  │   │   └── shipment_service.dart
  │   └── storage/         # 数据存储
  │       └── storage_service.dart
  └── main.dart            # 程序入口
test/
  ├── services/           # 服务测试
  │   ├── cli_service_test.dart
  │   ├── customer_service_test.dart
  │   └── shipment_service_test.dart
  └── models/             # 模型测试
      ├── customer_test.dart
      └── shipment_test.dart
```

## 运行测试

运行所有测试：

```bash
dart test
```

运行特定测试：

```bash
dart test test/services/cli_service_test.dart
```

## 开发说明

### 添加新功能

1. 在 `lib/src/models` 中添加新的数据模型
2. 在 `lib/src/services` 中实现相关服务
3. 在 `test` 目录下添加对应的测试用例

### 代码规范

- 使用 Dart 官方代码规范
- 所有代码必须包含单元测试
- 提交前确保所有测试通过

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License
