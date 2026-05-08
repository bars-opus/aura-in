// lib/features/shops/presentation/screens/all_workers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/app_divider.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/profile_header.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/all_workers_for_shop_provider.dart';

class AllShopWorkersScreen extends ConsumerWidget { 
  final String shopId;  
  final String shopName;

  const AllShopWorkersScreen({
    super.key, 
    required this.shopId,  
    required this.shopName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // ✅ Add WidgetRef
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workersAsync = ref.watch(allWorkersForShopProvider(shopId));  // ✅ Use shopId

    return workersAsync.when(
      data: (workers) => Scaffold(
        appBar: AppBar(
          title: Text('All Workers - $shopName'),  // ✅ Use shopName
          backgroundColor: Colors.transparent,
        ),
        body: workers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64.sp,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    SizedBox(height: Spacing.md.h),
                    Text(
                      'No workers yet',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(Spacing.md.h),
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return Column(
                    children: [
                      ProfileHeader(
                        enableOnProfileNavigatePressed: false,
                        mode: ProfileHeaderMode.compact,
                        textColor: colorScheme.onBackground,
                        displayName: worker.name,
                        userId: worker.id,
                        avatarUrl: worker.profileImage,
                        bio: "${worker.bio}\n${worker.specialties.take(2).join(' • ')}",
                      ),
                      if (index < workers.length - 1) AppDivider(),
                    ],
                  );
                },
              ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularLoadingIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}
