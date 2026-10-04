import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor =
      Color(0xFFA94327);

  static const Color darkText =
      Color(0xFF062B35);

  static const Color backgroundColor =
      Color(0xFFEFF9FD);

  static const Color lightBlue =
      Color(0xFFE4F5FB);

  static const Color tealColor =
      Color(0xFF078F80);

  // ============================================================
  // NOTIFICATION DATA
  // ============================================================

  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'type': 'application',
      'title': 'Application Submitted',
      'message':
          'Your adoption application has been successfully submitted.',
      'time': '10 minutes ago',
      'isRead': false,
    },
    {
      'id': 2,
      'type': 'appointment',
      'title': 'Appointment Reminder',
      'message':
          'You have an upcoming shelter visit appointment.',
      'time': '1 hour ago',
      'isRead': false,
    },
    {
      'id': 3,
      'type': 'pet',
      'title': 'New Pet Available',
      'message':
          'A new pet matching your interests is now available for adoption.',
      'time': '3 hours ago',
      'isRead': true,
    },
    {
      'id': 4,
      'type': 'community',
      'title': 'Community Update',
      'message':
          'There is a new post in the My Future Pet community.',
      'time': 'Yesterday',
      'isRead': true,
    },
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final int unreadCount =
        notifications
            .where(
              (notification) =>
                  notification['isRead'] == false,
            )
            .length;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkText,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Notifications',
          style: TextStyle(
            color: primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Read all',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: notifications.isEmpty
          ? _buildEmptyNotifications()
          : Column(
              children: [

                // ==============================================
                // UNREAD HEADER
                // ==============================================

                if (unreadCount > 0)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      12,
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: primaryColor,
                          size: 20,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ==============================================
                // NOTIFICATION LIST
                // ==============================================

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      30,
                    ),

                    itemCount:
                        notifications.length,

                    itemBuilder:
                        (context, index) {
                      final notification =
                          notifications[index];

                      return _buildNotificationCard(
                        notification,
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    int index,
  ) {
    final bool isRead =
        notification['isRead'] == true;

    final String type =
        notification['type'].toString();

    final IconData icon =
        _getNotificationIcon(type);

    final Color iconColor =
        _getNotificationColor(type);

    return Dismissible(
      key: ValueKey(
        notification['id'],
      ),

      direction:
          DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        alignment:
            Alignment.centerRight,

        padding:
            const EdgeInsets.only(
          right: 25,
        ),

        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),

      onDismissed: (_) {
        final removedNotification =
            notifications[index];

        setState(() {
          notifications.removeAt(index);
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: const Text(
              'Notification deleted.',
            ),

            backgroundColor:
                primaryColor,

            behavior:
                SnackBarBehavior.floating,

            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,

              onPressed: () {
                setState(() {
                  notifications.insert(
                    index,
                    removedNotification,
                  );
                });
              },
            ),
          ),
        );
      },

      child: GestureDetector(
        onTap: () {
          _markAsRead(index);
        },

        child: Container(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),

          padding: const EdgeInsets.all(
            16,
          ),

          decoration: BoxDecoration(
            color: isRead
                ? Colors.white
                : const Color(0xFFF7FCFE),

            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color: isRead
                  ? const Color(0xFFE5EEF1)
                  : primaryColor.withOpacity(
                      0.25,
                    ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.03),

                blurRadius: 6,

                offset:
                    const Offset(0, 2),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ================================================
              // ICON
              // ================================================

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: iconColor
                      .withOpacity(0.12),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              // ================================================
              // TEXT
              // ================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Expanded(
                          child: Text(
                            notification['title']
                                .toString(),

                            style: TextStyle(
                              color: darkText,
                              fontSize: 16,
                              fontWeight:
                                  isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                            ),
                          ),
                        ),

                        if (!isRead)
                          Container(
                            width: 9,
                            height: 9,

                            margin:
                                const EdgeInsets.only(
                              top: 6,
                              left: 8,
                            ),

                            decoration:
                                const BoxDecoration(
                              color: primaryColor,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notification['message']
                          .toString(),

                      style: TextStyle(
                        color:
                            darkText.withOpacity(
                          0.65,
                        ),

                        fontSize: 13.5,

                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      notification['time']
                          .toString(),

                      style: TextStyle(
                        color:
                            darkText.withOpacity(
                          0.42,
                        ),

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GET NOTIFICATION ICON
  // ============================================================

  IconData _getNotificationIcon(
    String type,
  ) {
    switch (type) {
      case 'application':
        return Icons.description_outlined;

      case 'appointment':
        return Icons.calendar_month_outlined;

      case 'pet':
        return Icons.pets_outlined;

      case 'community':
        return Icons.forum_outlined;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  // ============================================================
  // GET NOTIFICATION COLOR
  // ============================================================

  Color _getNotificationColor(
    String type,
  ) {
    switch (type) {
      case 'application':
        return primaryColor;

      case 'appointment':
        return tealColor;

      case 'pet':
        return primaryColor;

      case 'community':
        return darkText;

      default:
        return primaryColor;
    }
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  void _markAsRead(int index) {
    if (notifications[index]['isRead'] ==
        true) {
      return;
    }

    setState(() {
      notifications[index]['isRead'] =
          true;
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  void _markAllAsRead() {
    setState(() {
      for (final notification
          in notifications) {
        notification['isRead'] = true;
      }
    });

    _showMessage(
      'All notifications marked as read.',
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyNotifications() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.notifications_none_rounded,
                color: primaryColor,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Notifications',
              style: TextStyle(
                color: darkText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You are all caught up!',
              style: TextStyle(
                color:
                    darkText.withOpacity(0.55),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor:
            primaryColor,

        behavior:
            SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        margin:
            const EdgeInsets.all(16),
      ),
    );
  }
}