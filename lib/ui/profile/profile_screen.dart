import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/model/profile.dart';
import 'package:pushapp/provider/profile_provider.dart';
import 'package:pushapp/storage/SharedPrefs.dart';
import 'package:pushapp/ui/res/colors.dart';

class ProfileScreen extends StatefulWidget {
  final String platform; // 'android' or 'ios'

  const ProfileScreen({super.key, required this.platform});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = widget.platform == 'android';
    final accentColor = isAndroid ? COLOR_ANDROID_GREEN : const Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () {
            if (kIsWeb) {
              context.go('/');
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          "${isAndroid ? 'Android' : 'iOS'} Profiles",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final profiles = isAndroid
              ? provider.androidProfiles
              : provider.iosProfiles;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAndroid
                                ? Icons.android_rounded
                                : Icons.apple_rounded,
                            color: accentColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Manage Profiles",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Each profile stores its own service config & payload templates independently.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Profile list
                    Expanded(
                      child: profiles.isEmpty
                          ? _buildEmptyState(accentColor)
                          : _buildProfileGrid(profiles, accentColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProfileDialog(context),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "New Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color accentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No profiles yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create a profile to get started with push testing",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGrid(List<Profile> profiles, Color accentColor) {
    return GridView.builder(
      itemCount: profiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _ProfileCard(
          profile: profile,
          accentColor: accentColor,
          onTap: () => _selectProfile(profile),
          onDelete: () => _deleteProfile(profile),
          onRename: () => _showRenameDialog(profile),
        );
      },
    );
  }

  void _selectProfile(Profile profile) {
    final provider = context.read<ProfileProvider>();
    provider.setActiveProfile(profile);
    SharedPrefs.activeProfileId = profile.id;

    // Navigate via the profile deep link URL so the URL is shareable
    final route = '/${widget.platform}/profiles/${profile.id}';
    if (kIsWeb) {
      context.go(route);
    } else {
      context.push(route);
    }
  }

  void _deleteProfile(Profile profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Profile"),
        content: Text(
          "Are you sure you want to delete \"${profile.name}\"? This will remove all its saved configurations and payloads.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileProvider>().deleteProfile(profile);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(Profile profile) {
    final controller = TextEditingController(text: profile.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rename Profile"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.read<ProfileProvider>().renameProfile(profile, newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  void _showCreateProfileDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Create Profile"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "e.g. My App - Dev",
            labelText: "Profile Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                final provider = context.read<ProfileProvider>();
                await provider.createProfile(name, widget.platform);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.platform == 'android'
                  ? COLOR_ANDROID_GREEN
                  : const Color(0xFF007AFF),
              foregroundColor: Colors.white,
            ),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final Profile profile;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ProfileCard({
    required this.profile,
    required this.accentColor,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDefault = widget.profile.isDefault;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered
                  ? widget.accentColor.withOpacity(0.4)
                  : isDefault
                      ? widget.accentColor.withOpacity(0.25)
                      : const Color(0xFFE8E8E8),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.03),
                blurRadius: _isHovered ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDefault ? Icons.verified_rounded : Icons.person_rounded,
                      size: 18,
                      color: widget.accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.profile.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isDefault)
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "DEFAULT",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: widget.accentColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isDefault)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.grey[400],
                      ),
                      onSelected: (value) {
                        if (value == 'rename') widget.onRename();
                        if (value == 'delete') widget.onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 16),
                              SizedBox(width: 8),
                              Text("Rename"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded,
                                  size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Text(
                isDefault
                    ? "Remote payloads"
                    : "Created ${_formatDate(widget.profile.createdAt)}",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}
