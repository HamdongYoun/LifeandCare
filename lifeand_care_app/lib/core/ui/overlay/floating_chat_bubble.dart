import 'package:flutter/material.dart';
import 'package:lifeand_care_app/features/tab1_chat/chat_screen.dart';

/**
 * [FloatingChatBubble]
 * 紐⑤뱺 ?붾㈃ ?꾩뿉  덈뒗 ?뚮줈 곷떞 踰꾪듉 (Z-Index 理쒖긽 
 * @param {BuildContext} context - 紐⑤떖 諛뷀? ?쒗듃 ?ㅽ뻾 꾪븳 而⑦뀓?ㅽ듃
 */
class FloatingChatBubble extends StatelessWidget {
  const FloatingChatBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: const ChatScreen(),
          ),
        );
      },
      backgroundColor: const Color(0xFF2563EB),
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
    );
  }
}
