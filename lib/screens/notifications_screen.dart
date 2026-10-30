import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'All'; // 'All', 'Announcements', 'Updates'

  // Colors
  static const Color primaryColor = Color(0xFFA94327);
  static const Color tealColor = Color(0xFF008F82);
  static const Color darkText = Color(0xFF062B35);
  static const Color mutedText = Color(0xFF718096);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _notificationService.fetchNotifications();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  void _showNotificationDetail(BuildContext context, NotificationItem item) {
    _notificationService.markAsRead(item);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Top Badge & Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.isBroadcast
                            ? const Color(0xFFFFF5F2)
                            : const Color(0xFFE6FFFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: item.isBroadcast
                              ? const Color(0xFFFFD8CC)
                              : const Color(0xFFB2F5EA),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isBroadcast
                                ? Icons.campaign_rounded
                                : Icons.notifications_active_rounded,
                            size: 13,
                            color: item.isBroadcast ? primaryColor : tealColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isBroadcast
                                ? 'Shelter Broadcast'
                                : 'Personal Update',
                            style: TextStyle(
                              color: item.isBroadcast ? primaryColor : tealColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatRelativeTime(item.createdAt),
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  item.title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Optional Image
                if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Body Message
                Text(
                  item.body,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),

                // Close / Dismiss Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications & Alerts',
          style: TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _notificationService.unreadCountNotifier,
            builder: (context, unreadCount, _) {
              if (unreadCount == 0) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () async {
                  await _notificationService.markAllAsRead();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read.'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.done_all_rounded, size: 16, color: primaryColor),
                label: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // FILTER TABS & UNREAD SUMMARY
            // ============================================================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Announcements'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Updates'),
                    ],
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _notificationService.unreadCountNotifier,
                    builder: (context, unreadCount, _) {
                      if (unreadCount == 0) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFD8CC)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.mark_email_unread_rounded,
                              color: primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You have $unreadCount unread ${unreadCount == 1 ? 'broadcast' : 'broadcasts'} from Jagna Shelter.',
                                style: const TextStyle(
                                  color: Color(0xFF8C2B11),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: cardBorder),

            // ============================================================
            // NOTIFICATIONS LIST WITH REFRESH INDICATOR
            // ============================================================
            Expanded(
              child: ValueListenableBuilder<List<NotificationItem>>(
                valueListenable: _notificationService.notificationsNotifier,
                builder: (context, allItems, _) {
                  final filtered = allItems.where((item) {
                    if (_selectedFilter == 'Announcements') {
                      return item.isBroadcast;
                    } else if (_selectedFilter == 'Updates') {
                      return !item.isBroadcast;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => _notificationService.fetchNotifications(),
                      color: primaryColor,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          _buildEmptyState(),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _notificationService.fetchNotifications(),
                    color: primaryColor,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildNotificationCard(context, item);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label == 'Announcements'
              ? 'Announcements 📣'
              : (label == 'Updates' ? 'Updates 🐾' : label),
          style: TextStyle(
            color: isSelected ? Colors.white : darkText,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    final bool isUnread = !item.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showNotificationDetail(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : const Color(0xFFFAFBFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? const Color(0xFFFFD8CC) : cardBorder,
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.isBroadcast
                      ? const Color(0xFFFFF5F2)
                      : const Color(0xFFE6FFFA),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isBroadcast
                        ? const Color(0xFFFFD8CC)
                        : const Color(0xFFB2F5EA),
                  ),
                ),
                child: Icon(
                  item.isBroadcast
                      ? Icons.campaign_rounded
                      : Icons.pets_rounded,
                  color: item.isBroadcast ? primaryColor : tealColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Type Pill + Time + Unread Dot
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.isBroadcast
                                ? const Color(0xFFFFF5F2)
                                : const Color(0xFFE6FFFA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.isBroadcast ? 'Shelter Broadcast' : 'Update',
                            style: TextStyle(
                              color: item.isBroadcast ? primaryColor : tealColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatRelativeTime(item.createdAt),
                          style: const TextStyle(
                            color: mutedText,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: darkText,
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Body
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Optional Thumbnail Preview
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD8CC)),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 36,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                color: darkText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'When Jagna Shelter publishes announcements, adoption events, or medical updates, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _notificationService.fetchNotifications(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(color: Color(0xFFFFD8CC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
