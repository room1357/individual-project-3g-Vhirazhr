import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  // ===== THEME SAMA HOME/STATISTICS =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);
  static const Color softSurface = Color(0xFFFEF7F8);

  @override
  Widget build(BuildContext context) {
    // Dummy data pesan
    final List<Map<String, String>> messages = [
      {
        "sender": "System",
        "content": "Welcome to the app! 🎉",
        "date": "08/01/2024",
      },
      {
        "sender": "System",
        "content": "Your profile has been updated.",
        "date": "19/09/2024",
      },
      {
        "sender": "Support",
        "content": "Don’t forget to check our new features.",
        "date": "18/09/2025",
      },
    ];

    return Scaffold(
      backgroundColor: pinkBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: maroon,
        foregroundColor: white,
        centerTitle: true,
        title: const Text(
          "Messages",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: white),
      ),
      body:
          messages.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final sender = message["sender"] ?? "-";
                  final content = message["content"] ?? "-";
                  final date = message["date"] ?? "-";

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showMessageDetail(context, message),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: maroon.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: maroon.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: pinkSoft.withOpacity(0.5),
                            child: Icon(
                              Icons.message_rounded,
                              color: maroon.withOpacity(0.9),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender,
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 13,
                                    color: darkText.withOpacity(0.75),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 11,
                              color: darkText.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: maroon.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: pinkSoft.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: 40,
                  color: maroon.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Belum ada pesan",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Pesan dari sistem atau support akan muncul di sini",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: darkText.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Detail pesan
  void _showMessageDetail(BuildContext context, Map<String, String> message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              message["sender"] ?? "-",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w800,
                color: maroon,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tanggal: ${message["date"] ?? "-"}",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12.5,
                    color: darkText.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pesan:",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message["content"] ?? "-",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13.5,
                    color: darkText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Tutup",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    color: maroon,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
