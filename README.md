# 🏥 actionClinic

> 🎯 行动治疗所是一款基于 Flutter 的跨平台拖延干预与专注监督应用原型。

它围绕“计划任务、开始行动、倒计时监督、超时提醒、惩罚反馈、桌面小组件”构建完整闭环，适合作为移动端效率产品、行为干预工具和 Flutter 跨平台原型的参考项目。

![Flutter](https://img.shields.io/badge/Flutter-cross--platform-40C4FF)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-22C55E)
![Version](https://img.shields.io/badge/Version-1.0.0%2B1-111827)

---

## ✨ 项目简介

🧠 actionClinic 的目标不是普通待办清单，而是把“拖延前的计划”和“拖延后的惩罚提醒”都做进一个可交互应用里。用户可以创建今日行动计划，设置开始时间、截止时间、专注时长、宽限时间、验证方式和惩罚强度；应用会在规定时间内进行倒计时监督，并在超时后触发提醒或全屏惩罚页。

🚀 当前版本已完成可运行 MVP，并包含 Android 原生能力接入、桌面小组件 Provider、持久化任务数据、真实统计计算和分层工程结构。

---

## 🌟 功能亮点

- 🏠 首页总览：展示今日主目标、任务进度、专注时长、拖延次数、执行率和今日任务列表。
- 📝 行动计划：支持新增任务、编辑任务、删除任务、时间选择、专注时长、宽限时间、验证方式、惩罚规则和强度设置。
- ⏱️ 专注执行：支持开始、暂停、完成、放弃、倒计时监督、快速操作和惩罚倒计时。
- 💾 任务持久化：任务列表、设置项、状态流转和统计数据均保存到本地，不再依赖 mock 数据。
- 📊 真实统计：专注时长、拖延次数、执行率来自任务记录和运行状态计算。
- 🔔 弹窗提醒：App 内弹窗、SnackBar、高优先级通知和 Android 定时提醒链路已接入。
- 🛡️ 强制专注：Android 侧接入全屏提醒与锁定任务能力，用于减少切换应用。
- 📱 桌面小组件：Android 已注册任务、专注倒计时、拖延提醒三类 App Widget，并提供应用内添加入口。
- 🪟 悬浮小窗：App 内可拖拽、可收起的小窗，用于展示当前倒计时和快速操作。
- 🌍 跨平台工程：保留 Android、iOS、Web、Windows、macOS、Linux 工程结构。

---

## 🧩 页面模块

- 🏠 首页：今日目标、任务列表、统计卡片、惩罚模式入口。
- 📋 计划：任务创建与编辑、时间配置、行动验证、惩罚规则、退出拦截。
- ⏳ 专注：倒计时圆环、监督规则、快捷操作、惩罚倒计时。
- 🚨 惩罚页：超时后的全屏提醒页，强化开始行动反馈。
- 👤 我的：提醒开关、悬浮窗开关、小组件同步与添加、权限说明、数据重置。

## 🛠️ 技术栈

- 🐦 Flutter / Dart
- 🎨 Material Design 组件体系
- 🤖 Android Kotlin MethodChannel
- ⏰ Android AlarmManager / Notification / App Widget
- 💽 本地 JSON 持久化存储
- ✅ Flutter Test / Analyze

---

## 📁 目录结构

```text
actionClinic/
├── android/                 # Android 原生工程与小组件/提醒/强制专注能力
├── ios/                     # iOS 工程
├── macos/                   # macOS 桌面端
├── windows/                 # Windows 桌面端
├── linux/                   # Linux 桌面端
├── assets/                  # 图片、图标、插画、动画、字体资源
├── lib/
│   ├── app.dart             # App Shell、主导航与全局弹窗
│   ├── main.dart            # Flutter 入口
│   ├── core/                # 主题、常量、工具、路由、扩展
│   ├── data/                # 模型、本地存储、仓储
│   ├── features/            # 首页、计划、专注、惩罚、小窗、统计、我的
│   ├── services/            # 通知、闹钟、后台、权限、平台通道、小组件
│   └── shared/              # 复用组件、动画、弹窗
├── native_widgets/          # 原生小组件参考代码
├── scripts/                 # 运行和版本构建脚本
├── test/                    # 单元测试
├── integration_test/        # 集成测试占位
└── docs/                    # 产品与技术文档
```

## 🚀 快速开始

### 🔧 环境要求

- Flutter stable
- Dart 3.x
- Android Studio / Android SDK
- Chrome 或 Edge，用于 Web 调试

### 📦 安装依赖

```powershell
flutter pub get
```

### 🌐 运行 Web

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_web.ps1
```

脚本会固定使用 `3000` 端口；如果端口已被占用，会先结束占用进程再启动。

### 🤖 运行 Android

```powershell
flutter run -d android
```

### 🧪 构建 Debug APK

```powershell
flutter build apk --debug
```

### 📦 版本构建

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_version.ps1 -Target apk
```

默认输出到：

```text
releases/行动治疗所_v1.0.0+1/行动治疗所_v1.0.0+1.apk
```

---

## 📱 Android 小组件

安装 Android App 后，可以通过两种方式添加桌面小组件：

1. 打开 App，进入“我的”页面，在“桌面小组件预览”里点击添加任务组件、添加专注组件或添加惩罚组件。
2. 长按手机桌面，进入系统“小组件”面板，找到“行动治疗所”，选择对应组件添加。

### 💡 说明

- Web 页面无法展示真实系统桌面小组件，因为 Android App Widget 必须由系统桌面承载。
- 应用内一键添加依赖 Android 8.0 及以上的 `requestPinAppWidget`，并要求当前系统桌面支持固定小组件。

---

## 🔐 权限说明

- 🔔 通知权限：用于触发监督提醒和超时提醒。
- ⏰ 精准闹钟：用于在规定时间内自动提醒。
- 🪟 悬浮窗权限：用于后续系统级悬浮窗能力扩展。
- 🛡️ 强制专注：Android 侧使用全屏提醒和锁定任务能力；完全禁止 Home 键通常需要设备所有者或系统屏幕固定授权。

## 💾 数据与持久化

应用已移除 mock 任务数据。首次启动不会自动生成默认任务，用户创建的任务和设置会保存到本地。

桌面端本地状态路径使用：

```text
actionClinic/state.json
```

Web 端使用浏览器本地存储。

---

## ✅ 验证

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

当前验证结果：

- `flutter analyze` 通过
- `flutter test` 通过
- `flutter build apk --debug` 通过

## 📝 备注

`pubspec.yaml` 中的 Dart 包名保留为 `procrastination_treatment_app`，这是 Flutter/Dart 包名规范要求。项目目录、原生工程标识、窗口标题和持久化目录已统一为更短的驼峰命名 `actionClinic`。
