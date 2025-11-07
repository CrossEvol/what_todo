# Implementation Plan

- [x] 1. 扩展 ResourceModel 以支持 base64 内容
  - 在 `lib/models/resource.dart` 中添加 `content` 字段（String? 类型）
  - 更新 `toMap` 方法，包含 `content` 和 `task_title` 字段的序列化
  - 更新 `fromMap` 方法，支持 `content` 和 `task_title` 字段的反序列化
  - 更新 `copyWith` 方法，支持 `content` 字段的复制
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 2. 修改导出逻辑以使用 base64 编码
  - [x] 2.1 更新 ExportBloc 的 `_exportData` 方法
    - 在 `lib/bloc/export/export_bloc.dart` 中修改资源数据处理逻辑
    - 对每个资源使用 `File.readAsBytes()` 读取图片字节
    - 使用 `base64.encode()` 编码图片数据
    - 将编码结果存入资源数据的 `content` 字段
    - 使用 taskIdToTitle 映射获取 `task_title`
    - 只导出 `content` 和 `task_title` 两个字段
    - 添加错误处理，文件读取失败时记录日志并跳过
    - _Requirements: 1.1, 1.2, 1.3, 5.1, 5.2_

  - [x] 2.2 简化 ExportPage 的导出流程
    - 在 `lib/pages/export/export_page.dart` 中删除 `_exportResources` 方法
    - 从 `_performExport` 方法中移除对 `_exportResources` 的调用
    - 移除所有资源文件复制相关的代码
    - _Requirements: 1.4_

- [ ] 3. 修改导入逻辑以处理 base64 编码的资源
  - [ ] 3.1 更新 ImportBloc 的资源解析逻辑
    - 在 `lib/bloc/import/import_bloc.dart` 的 `_onImportLoadData` 方法中
    - 解析 V2 格式的资源数据
    - 从 JSON 中读取 `content` 和 `task_title` 字段
    - 创建 ResourceModel 实例，设置 content 和 taskTitle 属性
    - _Requirements: 3.3_

  - [ ] 3.2 重写资源导入处理方法
    - 在 `lib/bloc/import/import_bloc.dart` 中重写 `_handleResourceImport` 方法
    - 移除对 resources 文件夹存在性的检查
    - 在任务导入完成后，使用 `getTasksByTitles` 获取实际的任务 ID
    - 构建 `Map<String, int>` (task_title → task_id) 映射表
    - 过滤有效的资源（有 content 和 task_title，且能找到对应的任务）
    - 批量插入资源记录到数据库（先使用占位路径）
    - _Requirements: 3.1, 3.2, 3.6, 4.1, 4.2, 4.3_

  - [ ] 3.3 实现异步资源文件生成
    - 在 `lib/bloc/import/import_bloc.dart` 中创建 `_generateResourceFilesAsync` 方法
    - 使用 `Future.microtask` 创建异步任务
    - 对每个资源使用 `base64.decode()` 解码 content
    - 从原始 path 或默认值推断文件扩展名
    - 生成新文件名：`resource{id}.{extension}`
    - 获取 resources 目录路径（根据平台）
    - 使用 `File.writeAsBytes()` 写入图片文件
    - 调用 `ResourceDB.updateResourcePath()` 更新数据库中的路径
    - 添加错误处理，单个资源失败不影响其他资源
    - 记录详细的日志信息
    - _Requirements: 3.4, 3.5, 3.7, 4.4, 5.3, 5.4, 5.5_

  - [ ] 3.4 添加辅助方法获取 resources 目录
    - 在 `lib/bloc/import/import_bloc.dart` 中创建 `_getResourcesDirectory` 方法
    - 根据平台（Android/其他）返回正确的 resources 目录路径
    - 确保目录存在，不存在则创建
    - _Requirements: 3.5_

  - [ ] 3.5 移除旧的资源导入逻辑
    - 删除 `_copyResourcesAsync` 方法
    - 删除所有文件复制相关的代码
    - 移除对外部 resources 文件夹的依赖
    - _Requirements: 4.1, 4.2_

- [x] 4. 添加必要的导入语句
  - 在 `lib/bloc/export/export_bloc.dart` 中添加 `dart:convert` 和 `dart:io` 导入
  - 在 `lib/bloc/import/import_bloc.dart` 中添加 `dart:convert` 导入（如果尚未导入）
  - 在 `lib/bloc/import/import_bloc.dart` 中添加 `package:path/path.dart` 导入（如果尚未导入）
  - _Requirements: 5.1, 5.2, 5.3_

- [ ]* 5. 测试和验证
  - [ ]* 5.1 单元测试 ResourceModel
    - 测试 toMap 包含 content 字段
    - 测试 fromMap 正确解析 content 字段
    - 测试 copyWith 正确复制 content 字段
    - 测试向后兼容性
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ]* 5.2 集成测试导出流程
    - 创建包含资源的测试任务
    - 触发导出操作
    - 验证 JSON 包含 base64 编码的 content
    - 验证 task_title 正确映射
    - _Requirements: 1.1, 1.2, 1.3, 1.5_

  - [ ]* 5.3 集成测试导入流程
    - 准备包含 base64 资源的测试 JSON
    - 触发导入操作
    - 验证任务正确导入
    - 验证资源文件正确生成
    - 验证资源与任务的关联正确
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [ ]* 5.4 端到端测试
    - 导出包含资源的完整数据
    - 清空数据库
    - 导入刚才导出的数据
    - 验证所有数据和资源完整恢复
    - _Requirements: 1.5, 4.5_
