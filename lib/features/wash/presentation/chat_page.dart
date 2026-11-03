import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/firestore_repository.dart';
import '../domain/app_models.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.booking});

  final WashBooking booking;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _message = TextEditingController();
  final _repository = FirestoreRepository();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.booking.customerName.isEmpty
                ? 'MAK360 chat'
                : widget.booking.customerName,
          ),
          Text(
            '${widget.booking.vehicleNumber} • ${widget.booking.serviceName}',
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _repository.messages(widget.booking.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Could not load chat: ${snapshot.error}'),
                );
              }
              final messages = snapshot.data ?? const <ChatMessage>[];
              if (messages.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Start a conversation about pickup, timing or the wash status.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                );
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, reverseIndex) {
                  final item = messages[messages.length - 1 - reverseIndex];
                  final mine =
                      item.senderId == FirebaseAuth.instance.currentUser?.uid;
                  return Align(
                    alignment: mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 310),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: mine ? AppColors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: mine
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        item.text,
                        style: TextStyle(
                          color: mine ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write a message…',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _send() async {
    final text = _message.text;
    _message.clear();
    await _repository.sendMessage(widget.booking.id, text);
  }
}
