# Flutter应用自动更新功能实现任务清单

## 目标
实现Flutter应用的自动更新功能，通过GitHub Actions发布新版本，应用能够自动检测并提示用户更新。

## 前提条件
- 所有flutter/dart命令需要添加`fvm`前缀
- 使用GitHub Actions进行CI/CD
- 支持Android平台的APK自动更新

## 任务分解

### 第一阶段：Flutter依赖配置

#### 1. 添加必要的依赖包
- [ ] 使用命令行添加依赖包（Flutter会自动选择兼容版本）：
  ```bash
  fvm flutter pub add dio
  fvm flutter pub add package_info_plus
  fvm flutter pub add pub_semver
  fvm flutter pub add flutter_downloader
  fvm flutter pub add open_filex
  fvm flutter pub add flutter_local_notifications
  fvm flutter pub add badges
  ```
- [ ] 验证依赖已正确添加到 `pubspec.yaml`

#### 2. Android权限配置
- [ ] 在`android/app/src/main/AndroidManifest.xml`中添加必要权限：
  - INTERNET权限
  - WRITE_EXTERNAL_STORAGE权限
  - REQUEST_INSTALL_PACKAGES权限
- [ ] 配置FileProvider（用于flutter_downloader）
- [ ] 创建`android/app/src/main/res/xml/provider_paths.xml`文件
- [ ] 验证minSdkVersion配置（至少API 19）

### 第二阶段：核心功能实现

#### 3. 配置网络请求拦截器
- [ ] 创建`lib/utils/dio_config.dart`文件
- [ ] 配置dio实例与拦截器：
  - 请求拦截器（记录请求信息）
  - 响应拦截器（记录响应信息）
  - 错误拦截器（记录错误信息）
- [ ] 集成现有logger工具
- [ ] 设置超时和重试配置

#### 4. 创建更新管理器类
- [ ] 创建`lib/utils/update_manager.dart`文件
- [ ] 实现版本检查功能：
  - 获取当前应用版本
  - 使用dio从GitHub API获取最新Release信息（https://github.com/CrossEvol/what_todo）
  - 版本比较逻辑
  - 实现每日一次的静默检查（使用shared_preferences记录上次检查时间）
- [ ] 实现更新提示对话框（使用badges红点提示）
- [ ] 实现权限请求功能：
  - 安装未知应用权限

#### 5. 实现下载和安装功能
- [ ] 集成flutter_downloader：
  - 初始化配置
  - 下载进度监听
  - 下载完成回调
- [ ] 集成flutter_local_notifications实现下载进度通知
- [ ] 实现APK下载逻辑
- [ ] 实现安装引导功能（使用open_filex）
- [ ] 添加错误处理和用户反馈

#### 6. 应用集成
- [ ] 在`main.dart`中初始化flutter_downloader和flutter_local_notifications
- [ ] 在应用启动时进行静默更新检查（每日一次）
- [ ] 在侧边栏（SideDrawer）中添加更新配置入口，位置在`UNKNOWN`上方
- [ ] 使用badges在更新入口添加红点提示（有更新时显示）

### 第三阶段：用户体验优化

#### 7. UI/UX改进
- [ ] 设计更新提示对话框界面
- [ ] 在首页添加下载进度条组件（类似游戏更新界面）
- [ ] 配置通知栏下载进度显示
- [ ] 实现优雅的错误提示
- [ ] 添加"稍后更新"选项
- [ ] 显示更新日志内容
- [ ] 在侧边栏更新入口添加badges红点提示

#### 8. 后台处理优化
- [ ] 实现每日一次的静默版本检查（基于shared_preferences时间戳）
- [ ] 优化下载失败重试机制
- [ ] 添加网络状态检查
- [ ] 实现下载任务管理
- [ ] 配置dio的请求日志输出

### 第四阶段：安全性和稳定性

#### 9. 安全性增强
- [ ] 确保使用HTTPS下载
- [ ] 添加APK校验和验证（可选，高级功能）
- [ ] 验证下载来源的安全性
- [ ] 添加下载超时处理

#### 10. 兼容性处理
- [ ] 适配Android 10+的Scoped Storage
- [ ] 处理不同Android版本的权限差异
- [ ] 测试在不同设备上的兼容性
- [ ] 处理低版本Android的特殊情况

### 第五阶段：测试和发布

#### 11. 功能测试
- [ ] 单元测试：版本比较逻辑
- [ ] 测试badges红点提示功能

## 重要注意事项

### 技术要点
1. **FVM使用**：所有flutter命令都需要添加`fvm`前缀
2. **网络请求**：使用dio替代http，配置拦截器输出请求和响应日志
3. **权限处理**：Android 8.0+需要特别处理安装未知应用权限
4. **存储策略**：Android 10+需要适配Scoped Storage
5. **更新检查频率**：每日一次静默检查，避免频繁请求GitHub API
6. **通知系统**：使用flutter_local_notifications显示下载进度
7. **UI提示**：使用badges红点在侧边栏提示有更新
8. **错误处理**：网络、权限、下载、安装各环节都需要充分的错误处理

### 用户体验
1. **非阻塞式检查**：避免在启动时阻塞UI，每日一次静默检查
2. **直观的更新提示**：侧边栏badges红点提示，点击显示对话框
3. **清晰的进度提示**：首页进度条 + 通知栏进度显示
4. **可选更新**：提供"稍后更新"选项
5. **详细说明**：显示更新内容和版本信息
6. **便捷访问**：更新配置放在侧边栏，位于UNKNOWN上方

### 安全考虑
1. **HTTPS下载**：确保APK下载的安全性
2. **来源验证**：验证下载来源的可信度
3. **权限最小化**：只请求必要的权限
4. **用户确认**：重要操作需要用户明确确认

## 预期成果
完成后，用户将能够：
- 每日自动检测应用更新（静默进行）
- 通过侧边栏红点提示了解有新版本
- 点击更新入口查看更新详情对话框
- 在首页和通知栏查看下载进度
- 一键下载并安装更新
- 查看详细的更新说明
- 享受流畅的更新体验

## 风险评估
- **权限被拒绝**：用户可能拒绝必要权限，需要提供明确的权限说明
- **网络问题**：下载过程可能因网络问题中断，需要重试机制
- **设备兼容性**：不同Android版本可能有不同表现，需要充分测试
- **GitHub API限制**：每日一次检查避免频繁调用，降低达到速率限制的风险
- **通知权限**：Android 13+需要特别处理通知权限
- **下载进度同步**：确保首页进度条与通知栏进度保持同步