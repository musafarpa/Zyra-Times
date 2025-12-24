import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/models/chat_model.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/features/chat/screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserType; // 'customer' or 'shop'
  final String? shopId; // Required if userType is 'shop'

  const ChatListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
    this.shopId,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            _buildVintageHeader(),
            Expanded(child: _buildChatList()),
          ],
        ),
      ),
    );
  }

  Widget _buildVintageHeader() {
    final isShopOwner = widget.currentUserType == 'shop';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        border: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Title with decorative elements
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            isShopOwner ? Icons.support_agent_rounded : Icons.mail_rounded,
                            color: AppColors.woodDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Correspondence',
                              style: GoogleFonts.playfairDisplay(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isShopOwner ? 'Customer Inquiries' : 'Your Messages',
                              style: GoogleFonts.crimsonText(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Decorative divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.secondary.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.diamond_rounded,
                  size: 16,
                  color: AppColors.gold,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final shopService = context.read<ShopService>();

    Stream<List<ChatRoom>> chatRoomsStream;
    if (widget.currentUserType == 'shop' && widget.shopId != null) {
      chatRoomsStream = shopService.getShopChatRooms(widget.shopId!);
    } else {
      chatRoomsStream = shopService.getCustomerChatRooms(widget.currentUserId);
    }

    return StreamBuilder<List<ChatRoom>>(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                  child: const CircularProgressIndicator(
                    color: AppColors.secondary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fetching messages...',
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final chatRooms = snapshot.data!;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildVintageChatRoomTile(room),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.secondary, width: 2),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vintage mailbox icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.parchmentGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Empty Mailbox',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Decorative line
              Container(
                width: 80,
                height: 2,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.currentUserType == 'customer'
                    ? 'Your correspondence with\nestablishments will appear here'
                    : 'Messages from your valued\npatrons will appear here',
                textAlign: TextAlign.center,
                style: GoogleFonts.crimsonText(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Decorative footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVintageChatRoomTile(ChatRoom room) {
    final otherPartyName =
        widget.currentUserType == 'customer' ? room.shopName : room.customerName;
    final unreadCount = widget.currentUserType == 'customer'
        ? room.unreadCountCustomer
        : room.unreadCountShop;
    final hasUnread = unreadCount > 0;
    final isShop = widget.currentUserType == 'customer';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: room.id,
              otherPartyName: otherPartyName,
              currentUserId: widget.currentUserId,
              currentUserName: widget.currentUserName,
              currentUserType: widget.currentUserType,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasUnread ? AppColors.gold : AppColors.border,
            width: hasUnread ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: hasUnread
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.shadow.withValues(alpha: 0.08),
              blurRadius: hasUnread ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with vintage frame
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: hasUnread ? AppColors.goldGradient : null,
                      color: hasUnread ? null : AppColors.border,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: hasUnread
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: isShop
                            ? AppColors.woodGradient
                            : AppColors.leatherGradient,
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Center(
                        child: Text(
                          otherPartyName.isNotEmpty
                              ? otherPartyName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.rye(
                            color: AppColors.textGold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and time row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      otherPartyName,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 17,
                                        fontWeight: hasUnread
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (hasUnread) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.gold,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.gold.withValues(alpha: 0.5),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (room.lastMessageTime != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: hasUnread
                                      ? AppColors.gold.withValues(alpha: 0.1)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatMessageTime(room.lastMessageTime!),
                                  style: GoogleFonts.crimsonText(
                                    fontSize: 11,
                                    color: hasUnread
                                        ? AppColors.gold
                                        : AppColors.textTertiary,
                                    fontWeight: hasUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Type badge
                        Row(
                          children: [
                            Icon(
                              isShop ? Icons.store_rounded : Icons.person_rounded,
                              size: 12,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isShop ? 'Establishment' : 'Patron',
                              style: GoogleFonts.crimsonText(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Last message
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                room.lastMessage ?? 'No messages yet',
                                style: GoogleFonts.crimsonText(
                                  fontSize: 14,
                                  color: hasUnread
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasUnread)
                              Container(
                                margin: const EdgeInsets.only(left: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.goldGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: GoogleFonts.crimsonText(
                                    fontSize: 13,
                                    color: AppColors.woodDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow indicator
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: hasUnread ? AppColors.gold : AppColors.textTertiary,
                    size: 24,
                  ),
                ],
              ),
            ),

            // Bottom decorative border for unread
            if (hasUnread)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
  }
}
