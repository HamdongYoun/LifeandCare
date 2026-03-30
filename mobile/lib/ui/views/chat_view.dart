import 'package:lottie/lottie.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatList = ref.watch(chatProvider);
    final isTyping = ref.watch(chatProvider.notifier).isTyping;
    final emergencyState = ref.watch(emergencyProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Life & Care AI 상담'),
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(chatProvider.notifier).clearChat(),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatList.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatList.length && isTyping) {
                      return _buildTypingIndicator();
                    }
                    final message = chatList[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
        if (emergencyState.isEmergencyActive) _buildEmergencyOverlay(emergencyState),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: Radius.zero),
        ),
        child: SizedBox(
          width: 50,
          child: Lottie.network(
            'https://assets5.lottiefiles.com/packages/lf20_6p80pX.json', // Typing dots
            errorBuilder: (context, error, stackTrace) => const Text('...'),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.sender == MessageSender.user;
    bool isEmergency = message.messageType == MessageType.emergencyAlert;

    if (isEmergency) {
      return _buildEmergencyAlertBubble(message);
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildEmergencyAlertBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                '긴급 상황 감지',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message.content,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(emergencyProvider.notifier).startEmergencyCountdown();
              },
              icon: const Icon(Icons.phone),
              label: const Text('119 즉시 연결'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyOverlay(EmergencyNotifier emergencyState) {
    return Container(
      color: Colors.black87,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              child: Lottie.network(
                'https://assets3.lottiefiles.com/packages/lf20_Tkwb02.json', // Pulse/Warning
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.emergency, color: Colors.redAccent, size: 80),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '119 연결 중...',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '${emergencyState.countdown}',
              style: const TextStyle(color: Colors.redAccent, fontSize: 80, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => ref.read(emergencyProvider.notifier).cancelEmergency(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('취소', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '증상을 입력하세요...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _controller.clear();
    }
  }
}
