import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/models/chat_model.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherPartyName;
  final String currentUserId;
  final String currentUserName;
  final String currentUserType; // 'customer' or 'shop'

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.otherPartyName,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Mark messages as read when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopService>().markMessagesAsRead(
            widget.chatRoomId,
            widget.currentUserType,
          );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await context.read<ShopService>().sendMessage(
            chatRoomId: widget.chatRoomId,
            senderId: widget.currentUserId,
            senderName: widget.currentUserName,
            senderType: widget.currentUserType,
            message: message,
          );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            _buildVintageHeader(),
            Expanded(child: _buildMessageList()),
            _buildVintageMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildVintageHeader() {
    final isShop = widget.currentUserType == 'customer';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar with vintage frame
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isShop ? AppColors.shopColor : AppColors.customerColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  widget.otherPartyName.isNotEmpty
                      ? widget.otherPartyName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.rye(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherPartyName,
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isShop ? 'Establishment' : 'Valued Patron',
                      style: GoogleFonts.crimsonText(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Decorative element
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isShop ? Icons.store_rounded : Icons.person_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ivory,
        image: DecorationImage(
          image: const AssetImage('assets/images/paper_texture.png'),
          fit: BoxFit.cover,
          opacity: 0.05,
          onError: (_, __) {},
        ),
      ),
      child: StreamBuilder<List<ChatMessage>>(
        stream: context.read<ShopService>().getMessages(widget.chatRoomId),
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
                    'Loading correspondence...',
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
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary, width: 2),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Vintage envelope icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.parchmentGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: Icon(
                          Icons.mail_outline_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Correspondence',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Begin your conversation\nwith a friendly greeting',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.crimsonText(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final messages = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isMe = message.senderId == widget.currentUserId;
              final showDate = index == 0 ||
                  !_isSameDay(messages[index - 1].timestamp, message.timestamp);

              return Column(
                children: [
                  if (showDate) _buildVintageDateDivider(message.timestamp),
                  _buildVintageMessageBubble(message, isMe),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildVintageDateDivider(DateTime date) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isYesterday = _isSameDay(date, now.subtract(const Duration(days: 1)));

    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isYesterday) {
      dateText = 'Yesterday';
    } else {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      dateText = '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  dateText,
                  style: GoogleFonts.crimsonText(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
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
    );
  }

  Widget _buildVintageMessageBubble(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Sender avatar for received messages
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                gradient: AppColors.leatherGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: Center(
                child: Text(
                  message.senderName.isNotEmpty
                      ? message.senderName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.rye(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 6),
                bottomRight: Radius.circular(isMe ? 6 : 20),
              ),
              border: Border.all(
                color: isMe ? AppColors.primaryDark : AppColors.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 6),
                bottomRight: Radius.circular(isMe ? 6 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      message.message,
                      style: GoogleFonts.crimsonText(
                        fontSize: 16,
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // Time footer
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 10,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.6)
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: GoogleFonts.crimsonText(
                            fontSize: 11,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppColors.textTertiary,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.done_all_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            // Sender avatar for sent messages
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, bottom: 4),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: Center(
                child: Text(
                  widget.currentUserName.isNotEmpty
                      ? widget.currentUserName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.rye(
                    color: AppColors.woodDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildVintageMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        border: Border(
          top: BorderSide(color: AppColors.secondary, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input with vintage styling
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Decorative quill icon
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 12),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.crimsonText(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Compose your message...',
                        hintStyle: GoogleFonts.crimsonText(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send button with vintage styling
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: _isSending ? null : AppColors.goldGradient,
                color: _isSending ? AppColors.surface : null,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.gold,
                  width: 2,
                ),
                boxShadow: _isSending
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Center(
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: AppColors.woodDark,
                        size: 24,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
