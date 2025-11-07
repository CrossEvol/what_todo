# Requirements Document

## Introduction

本功能旨在改进任务资源（图片）的导出和导入机制。当前实现依赖于文件系统的资源文件夹和路径管理，存在跨设备导入时的路径不一致问题。新方案将图片资源通过 base64 编码直接嵌入到导出的 JSON 文件中，实现自包含的数据导出，并在导入时通过任务标题映射还原资源关联关系。

## Glossary

- **ResourceModel**: 表示附加到任务的图片资源的数据模型
- **Base64 Encoding**: 将二进制图片数据编码为文本字符串的编码方式
- **Task Title Mapping**: 任务标题到任务 ID 的映射表，用于导入时建立资源与任务的关联
- **Export System**: 负责将应用数据导出为 JSON 文件的系统组件
- **Import System**: 负责从 JSON 文件导入数据到应用的系统组件
- **Resource Directory**: ResourceDB 管理的 resources/ 目录，用于存储图片文件

## Requirements

### Requirement 1

**User Story:** 作为用户，我希望导出的数据文件是自包含的，这样我可以在不同设备间轻松迁移数据而无需担心资源文件丢失

#### Acceptance Criteria

1. WHEN 用户触发导出操作，THE Export System SHALL 读取每个资源文件的字节数据并使用 base64 编码
2. THE Export System SHALL 将 base64 编码后的图片数据存储在 ResourceModel 的 content 字段中
3. THE Export System SHALL 在导出的 JSON 中包含资源的 content 和 task_title 字段
4. THE Export System SHALL 移除原有的资源文件复制逻辑
5. THE Export System SHALL 确保导出的 JSON 文件包含所有必要的资源数据

### Requirement 2

**User Story:** 作为开发者，我希望 ResourceModel 能够支持存储 base64 编码的图片内容，以便在导出时使用

#### Acceptance Criteria

1. THE ResourceModel SHALL 包含一个可选的 String 类型的 content 字段
2. THE ResourceModel SHALL 在 toMap 方法中包含 content 字段的序列化
3. THE ResourceModel SHALL 在 fromMap 方法中支持 content 字段的反序列化
4. THE ResourceModel SHALL 在 copyWith 方法中支持 content 字段的复制
5. THE ResourceModel SHALL 保持向后兼容，content 字段为可选

### Requirement 3

**User Story:** 作为用户，我希望导入数据时系统能够自动还原图片资源并正确关联到对应的任务

#### Acceptance Criteria

1. WHEN 用户触发导入操作，THE Import System SHALL 首先完成所有任务的导入
2. THE Import System SHALL 创建任务标题到任务 ID 的映射表
3. THE Import System SHALL 从 JSON 中加载资源的 base64 编码数据到 ResourceModel
4. THE Import System SHALL 为每个 ResourceModel 创建异步任务，将 base64 解码为图片文件
5. THE Import System SHALL 将还原的图片文件保存到 Resource Directory 中
6. THE Import System SHALL 使用任务标题映射表获取正确的 task_id
7. THE Import System SHALL 将资源记录（path 和 task_id）插入到 resource 表中

### Requirement 4

**User Story:** 作为用户，我希望导入过程不再依赖外部的 resources 文件夹，简化导入流程

#### Acceptance Criteria

1. THE Import System SHALL 移除对 resources 文件夹存在性的检查
2. THE Import System SHALL 不再从外部 resources 文件夹复制文件
3. THE Import System SHALL 仅依赖 JSON 文件中的 base64 编码数据
4. THE Import System SHALL 在导入失败时提供清晰的错误信息
5. THE Import System SHALL 确保资源导入失败不会影响任务和项目的导入

### Requirement 5

**User Story:** 作为用户，我希望系统能够高效处理大量图片资源的编码和解码操作

#### Acceptance Criteria

1. THE Export System SHALL 使用 File.readAsBytes 方法读取图片文件
2. THE Export System SHALL 使用 base64.encode 方法进行编码
3. THE Import System SHALL 使用 base64.decode 方法进行解码
4. THE Import System SHALL 使用异步任务处理图片文件的生成，避免阻塞主流程
5. THE Import System SHALL 在资源处理过程中记录详细的日志信息
