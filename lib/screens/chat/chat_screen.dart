import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/initials_avatar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _familyId;
  String? _currentUserId;
  String? _currentUserName;
  final Set<String> _blockedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = context.read<AuthProvider>();
    final current = auth.user;
    if (current == null) return;
    final profile = await FirestoreService.getUserProfile(current.uid);
    if (!mounted) return;
    setState(() {
      _currentUserId = current.uid;
      _familyId = profile?['familyId'];
      _currentUserName = '${profile?['name'] ?? ''} ${profile?['lastNames'] ?? ''}'.trim();
      if (_currentUserName!.isEmpty) _currentUserName = 'Usuario';
      _blockedUserIds
        ..clear()
        ..addAll(
          (profile?['blockedUsers'] as List?)?.map((e) => e.toString()) ?? [],
        );
    });
  }

  Future<void> _reportMessage(String messageId, Map<String, dynamic> data) async {
    if (_familyId == null || _currentUserId == null) return;
    final reason = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '¿Por qué reportas este mensaje?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final r in const [
              'Contenido ofensivo o abusivo',
              'Acoso o amenazas',
              'Spam o publicidad',
              'Otro',
            ])
              ListTile(
                title: Text(r),
                onTap: () => Navigator.pop(context, r),
              ),
          ],
        ),
      ),
    );
    if (reason == null) return;
    await FirestoreService.reportMessage(
      familyId: _familyId!,
      messageId: messageId,
      message: data,
      reportedBy: _currentUserId!,
      reason: reason,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gracias. Tu reporte fue enviado.')),
    );
  }

  Future<void> _blockUser(String uid, String name) async {
    if (_currentUserId == null) return;
    await FirestoreService.blockUser(_currentUserId!, uid);
    if (!mounted) return;
    setState(() => _blockedUserIds.add(uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Has bloqueado a $name'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await FirestoreService.unblockUser(_currentUserId!, uid);
            if (!mounted) return;
            setState(() => _blockedUserIds.remove(uid));
          },
        ),
      ),
    );
  }

  void _showMessageOptions(String messageId, Map<String, dynamic> data) {
    final senderId = data['senderId']?.toString();
    final senderName = data['senderName']?.toString() ?? 'el usuario';
    if (senderId == null || senderId == _currentUserId) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.flag_outlined, color: Colors.orange),
              title: Text('Reportar mensaje'),
              onTap: () {
                Navigator.pop(context);
                _reportMessage(messageId, data);
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Bloquear a $senderName'),
              onTap: () {
                Navigator.pop(context);
                _blockUser(senderId, senderName);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _familyId == null || _currentUserId == null) return;

    _messageController.clear();
    await FirestoreService.sendMessage(
      _familyId!,
      text,
      _currentUserId!,
      _currentUserName!,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_familyId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chat Familiar')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text('Chat Familiar'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'Mantén pulsado un mensaje para reportarlo o bloquear al usuario',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Moderación del chat'),
                  content: Text(
                    'Mantén pulsado cualquier mensaje de otro miembro para '
                    'reportarlo o bloquear al usuario. Los mensajes que '
                    'reportes serán revisados por los administradores.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.getChatMessages(_familyId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar mensajes'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs
                    .where((doc) =>
                        !_blockedUserIds.contains(doc.data()['senderId']))
                    .toList();
                if (messages.isEmpty) {
                  return Center(
                    child: Text('No hay mensajes todavía. ¡Sé el primero en saludar!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = doc.data();
                    final isMe = data['senderId'] == _currentUserId;
                    return GestureDetector(
                      onLongPress: () => _showMessageOptions(doc.id, data),
                      child: _buildMessageBubble(data, isMe),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    final text = data['text'] ?? '';
    final senderName = data['senderName'] ?? 'Alguien';
    final timestamp = data['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            InitialsAvatar(
              initials: senderName.isNotEmpty ? senderName[0] : 'U',
              size: 32,
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              textColor: AppTheme.primaryColor,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primaryColor : context.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  if (!isMe) SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : context.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
