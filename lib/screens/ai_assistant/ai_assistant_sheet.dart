import 'package:flutter/material.dart';
import 'package:neostation/services/android_service.dart';

/// First-party ECLIPSE assistant surface.
///
/// The first implementation deliberately keeps command execution local and
/// allowlisted. A cloud conversational provider and native push-to-talk are
/// separate integrations; this UI never pretends a local command is a hosted
/// LLM response.
class AiAssistantSheet extends StatefulWidget {
  const AiAssistantSheet({super.key, required this.onCommand});

  final Future<String> Function(String command) onCommand;

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AssistantMessage {
  const _AssistantMessage(this.text, {required this.fromUser});
  final String text;
  final bool fromUser;
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final _input = TextEditingController();
  final _scrollController = ScrollController();
  final List<_AssistantMessage> _messages = [
    const _AssistantMessage(
      "Hey! I'm ECLIPSE, your frontend assistant. I can navigate ECLIPSE and open supported sections. Try “open settings” or “show achievements”.",
      fromUser: false,
    ),
  ];
  bool _working = false;
  bool _listening = false;

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (_working || _listening) return;
    setState(() => _listening = true);
    try {
      final phrase = await AndroidService.startVoiceRecognition();
      if (!mounted) return;
      if (phrase != null && phrase.trim().isNotEmpty) {
        _input.text = phrase.trim();
        _input.selection = TextSelection.collapsed(
          offset: _input.text.length,
        );
      }
    } finally {
      if (mounted) setState(() => _listening = false);
    }
  }

  Future<void> _send([String? suggested]) async {
    final text = (suggested ?? _input.text).trim();
    if (text.isEmpty || _working) return;
    _input.clear();
    setState(() {
      _messages.add(_AssistantMessage(text, fromUser: true));
      _working = true;
    });
    _scrollToBottom();

    String response;
    try {
      response = await widget.onCommand(text);
    } catch (_) {
      response = "That didn't work. Try another ECLIPSE command.";
    }
    if (!mounted) return;
    setState(() {
      _messages.add(_AssistantMessage(response, fromUser: false));
      _working = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.tertiary],
                        ),
                      ),
                      child: Icon(Icons.auto_awesome, color: colors.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ECLIPSE AI',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Frontend assistant · Local commands',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close assistant',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.outlineVariant),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_working ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final message = _messages[index];
                    return Align(
                      alignment: message.fromUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 560),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: message.fromUser
                              ? colors.primary.withValues(alpha: 0.22)
                              : colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: message.fromUser
                                ? colors.primary.withValues(alpha: 0.35)
                                : colors.outlineVariant,
                          ),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SuggestionChip(
                            label: 'Open settings',
                            onTap: () => _send('open settings'),
                          ),
                          _SuggestionChip(
                            label: 'Show achievements',
                            onTap: () => _send('show achievements'),
                          ),
                          _SuggestionChip(
                            label: 'Open entertainment',
                            onTap: () => _send('open entertainment'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Speak to ECLIPSE',
                          onPressed: _working || _listening ? null : _listen,
                          icon: Icon(_listening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _input,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: InputDecoration(
                              hintText: 'Ask ECLIPSE to do something…',
                              filled: true,
                              fillColor: colors.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _working ? null : _send,
                          icon: const Icon(Icons.arrow_upward_rounded),
                        ),
                      ],
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
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ActionChip(label: Text(label), onPressed: onTap),
  );
}
