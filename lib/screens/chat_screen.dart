import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hộp thư'),
        actions: [
          IconButton(icon: const Icon(Iconsax.search_normal), onPressed: () {}),
          IconButton(icon: const Icon(Iconsax.more), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return _buildChatItem(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Iconsax.edit_2),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, int index) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orange[300],
            child: const Icon(Iconsax.user, color: Colors.white),
          ),
          if (index % 3 == 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        'Chef ${index + 1}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        index % 2 == 0
            ? 'Cảm ơn bạn đã chia sẻ công thức!'
            : 'Bạn: Món này rất ngon',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: index % 2 == 0 ? Colors.black87 : Colors.grey[600],
          fontWeight: index % 2 == 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            index % 2 == 0 ? '10:30' : 'Yesterday',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (index % 2 == 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {},
    );
  }
}
