import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_constants.dart';
import '../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../../features/settings/presentation/cubit/settings_state.dart';
import '../../utils/app_directories.dart';
import '../../theme/cubit/theme_cubit.dart';

class PremiumDrawer extends StatelessWidget {
  const PremiumDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    // We inject the SettingsCubit here to ensure the Drawer always has fresh profile data
    return BlocProvider.value(
      value: GetIt.instance<SettingsCubit>()..loadProfile(),
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // --- Premium Header ---
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                final profile = state.profile;
                final bool hasLogo = profile?.logoPath != null;

                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.4),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundImage: hasLogo
                              ? FileImage(File(
                                  AppDirectories.constructImagePath(
                                      profile!.logoPath!)))
                              : null,
                          child: !hasLogo
                              ? const Icon(Icons.storefront_rounded,
                                  size: 36, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile?.businessName ?? 'Business Name',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (profile?.email != null &&
                            profile!.email!.isNotEmpty)
                          Text(
                            profile.email!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // --- Drawer Items ---
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.business_center_outlined,
                    title: 'Business Profile',
                    isSelected: currentLocation == AppRoutes.settings,
                    onTap: () {
                      context.pop(); // Close drawer
                      context.push(AppRoutes.settings);
                    },
                  ),
                  const SizedBox(height: 4),
                  _DrawerItem(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Backup & Restore',
                    isSelected: currentLocation == AppRoutes.backupRestore,
                    onTap: () {
                      context.pop();
                      context.push(AppRoutes.backupRestore);
                    },
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Divider(height: 1),
                  ),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, currentTheme) {
                    return ListTile(
                      leading: Icon(Icons.palette_outlined,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      title: const Text('Theme',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      trailing: DropdownButton<ThemeMode>(
                        value: currentTheme,
                        underline: const SizedBox(), // hide default line
                        items: const [
                          DropdownMenuItem(
                              value: ThemeMode.system, child: Text('System')),
                          DropdownMenuItem(
                              value: ThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(
                              value: ThemeMode.dark, child: Text('Dark')),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            context.read<ThemeCubit>().updateTheme(mode);
                          }
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  _DrawerItem(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    isSelected: false,
                    onTap: () {
                      context.pop();
                    },
                  ),
                ],
              ),
            ),

            // --- Footer ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'InvoiceFlow Pro',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Text('Version 1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer,
      onTap: onTap,
    );
  }
}
