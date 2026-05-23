import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';
import '../theme/app_colors.dart';

String statusText(TaskStatus status) {
  return switch (status) {
    TaskStatus.waiting => '未开始',
    TaskStatus.monitoring => '监督中',
    TaskStatus.running => '进行中',
    TaskStatus.completed => '已完成',
    TaskStatus.punished => '惩罚中',
    TaskStatus.abandoned => '已放弃',
  };
}

Color statusColor(TaskStatus status) {
  return switch (status) {
    TaskStatus.waiting => AppColors.muted,
    TaskStatus.monitoring => AppColors.blue,
    TaskStatus.running => AppColors.green,
    TaskStatus.completed => AppColors.green,
    TaskStatus.punished => AppColors.red,
    TaskStatus.abandoned => AppColors.orange,
  };
}

String verificationText(VerificationType type) {
  return switch (type) {
    VerificationType.manual => '手动打卡',
    VerificationType.appLaunch => '启动应用检测',
    VerificationType.sensor => '传感器检测',
    VerificationType.photo => '拍照证明',
    VerificationType.focusDuration => '专注时长',
  };
}
