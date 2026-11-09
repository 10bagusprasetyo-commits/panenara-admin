// lib/features/admin_web/super_admin/domain/entities/super_admin_entities.dart

import 'package:equatable/equatable.dart';
import '../../../shared/domain/entities/admin_user.dart';

// ─── Dashboard ───────────────────────────────────────────────────────────────

class SuperDashboardStats extends Equatable {
  const SuperDashboardStats({
    required this.totalUsers,
    required this.activeAdmins,
    required this.monthlyTransactionValue,
    required this.activeAuctions,
    required this.alerts,
    required this.recentActivities,
  });

  final int totalUsers;
  final int activeAdmins;
  final String monthlyTransactionValue;
  final int activeAuctions;
  final List<AlertItem> alerts;
  final List<ActivityItem> recentActivities;

  @override
  List<Object?> get props => [totalUsers, activeAdmins, activeAuctions];
}

class AlertItem extends Equatable {
  const AlertItem({
    required this.title,
    required this.subtitle,
    required this.pillLabel,
    required this.pillVariant,
  });

  final String title;
  final String subtitle;
  final String pillLabel;
  final String pillVariant; // ok | wn | bd | mt

  @override
  List<Object?> get props => [title, subtitle];
}

class ActivityItem extends Equatable {
  const ActivityItem({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  List<Object?> get props => [title, subtitle];
}

// ─── Admin Management ─────────────────────────────────────────────────────────

class AdminAccount extends Equatable {
  const AdminAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.access,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final String access;
  final UserStatus status;

  @override
  List<Object?> get props => [id, email];
}

// ─── Users ───────────────────────────────────────────────────────────────────

enum UserRole { petani, pembeli, pengamat, admin, superAdmin }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.region,
    required this.joinedAt,
    required this.status,
    this.verificationStatus,
  });

  final String id;
  final String name;
  final UserRole role;
  final String region;
  final String joinedAt;
  final UserStatus status;
  final String? verificationStatus;

  String get roleLabel => switch (role) {
        UserRole.petani => 'Petani',
        UserRole.pembeli => 'Pembeli',
        UserRole.pengamat => 'Pengamat',
        UserRole.admin => 'Admin',
        UserRole.superAdmin => 'Super Admin',
      };

  @override
  List<Object?> get props => [id, name, role];
}

// ─── Reports ─────────────────────────────────────────────────────────────────

class MonthlyVolume extends Equatable {
  const MonthlyVolume({required this.month, required this.valueMillions});

  final String month;
  final double valueMillions;

  @override
  List<Object?> get props => [month, valueMillions];
}

class TopCommodity extends Equatable {
  const TopCommodity({
    required this.name,
    required this.volume,
    required this.value,
    required this.growth,
    required this.growthPositive,
  });

  final String name;
  final String volume;
  final String value;
  final String growth;
  final bool growthPositive;

  @override
  List<Object?> get props => [name, volume];
}

// ─── Settings ────────────────────────────────────────────────────────────────

class SystemSetting extends Equatable {
  const SystemSetting({
    required this.key,
    required this.label,
    required this.description,
    required this.value,
  });

  final String key;
  final String label;
  final String description;
  final dynamic value; // bool for toggle, String for text

  bool get isBool => value is bool;
  bool get asBool => value as bool;
  String get asString => value?.toString() ?? '';

  @override
  List<Object?> get props => [key, value];
}

// ─── Audit Log ───────────────────────────────────────────────────────────────

class AuditLog extends Equatable {
  const AuditLog({
    required this.id,
    required this.actor,
    required this.action,
    required this.module,
    required this.ip,
    required this.timestamp,
  });

  final String id;
  final String actor;
  final String action;
  final String module;
  final String ip;
  final String timestamp;

  @override
  List<Object?> get props => [id];
}
