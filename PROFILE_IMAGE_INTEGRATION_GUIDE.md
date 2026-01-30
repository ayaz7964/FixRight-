╔══════════════════════════════════════════════════════════════════════════════╗
║          USING PROFILE IMAGES ACROSS THE APP - INTEGRATION GUIDE            ║
╚══════════════════════════════════════════════════════════════════════════════╝

## 📋 WHERE PROFILE IMAGES SHOULD APPEAR

1. ✅ Profile Edit Screen (Done)
2. ⏳ Chat List (Show sender avatar)
3. ⏳ Chat Messages (Show message sender avatar)
4. ⏳ Seller Card (Show seller profile pic)
5. ⏳ Buyer Profile (Show buyer profile pic)
6. ⏳ User mentions/tags (Show user avatar)

---

## 🔧 INTEGRATION PATTERN 1: SIMPLE (FutureBuilder)

### When to use: Static screens, one-time load

```dart
import '../../services/profile_image_service.dart';

class UserProfileAvatar extends StatelessWidget {
  final String uid;
  final double radius;
  
  const UserProfileAvatar({
    required this.uid,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ProfileImageService().getProfileImageUrl(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final imageUrl = snapshot.data;
        
        return CircleAvatar(
          radius: radius,
          backgroundImage: imageUrl != null 
            ? NetworkImage(imageUrl)
            : null,
          child: imageUrl == null 
            ? Icon(Icons.person, size: radius * 0.6)
            : null,
        );
      },
    );
  }
}

// Usage:
UserProfileAvatar(uid: "1234567890", radius: 28)
```

---

## 🔧 INTEGRATION PATTERN 2: REAL-TIME (StreamBuilder)

### When to use: Screens showing user updates, need real-time sync

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/profile_image_service.dart';

class UserProfileCardRealTime extends StatelessWidget {
  final String uid;
  
  const UserProfileCardRealTime({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('User not found');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl = userData['profileImageUrl'] as String?;
        final firstName = userData['firstName'] as String? ?? 'Unknown';
        final lastName = userData['lastName'] as String? ?? '';

        return Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: imageUrl != null 
                ? NetworkImage(imageUrl)
                : null,
              child: imageUrl == null 
                ? const Icon(Icons.person, size: 40)
                : null,
            ),
            const SizedBox(height: 12),
            Text(
              '$firstName $lastName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Usage:
UserProfileCardRealTime(uid: "1234567890")
```

---

## 🔧 INTEGRATION PATTERN 3: OPTIMIZED (With Cache)

### When to use: High-performance lists, many users displayed

```dart
import '../../services/profile_image_service.dart';

class OptimizedUserAvatar extends StatefulWidget {
  final String uid;
  final double radius;
  
  const OptimizedUserAvatar({
    required this.uid,
    this.radius = 20,
  });

  @override
  State<OptimizedUserAvatar> createState() => _OptimizedUserAvatarState();
}

class _OptimizedUserAvatarState extends State<OptimizedUserAvatar> {
  late Future<String?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _getImageUrl();
  }

  Future<String?> _getImageUrl() async {
    // Check cache first (instant)
    final cached = ProfileImageService.getCachedImageUrl(widget.uid);
    if (cached != null) {
      return cached;
    }

    // Fetch from Firestore if not cached
    final url = await ProfileImageService().getProfileImageUrl(widget.uid);
    if (url != null && mounted) {
      ProfileImageService.setCachedImageUrl(widget.uid, url);
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;
        
        return CircleAvatar(
          radius: widget.radius,
          backgroundImage: imageUrl != null 
            ? NetworkImage(imageUrl)
            : null,
          child: imageUrl == null 
            ? Icon(Icons.person, size: widget.radius * 0.6)
            : null,
        );
      },
    );
  }
}

// Usage in list:
ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    return ListTile(
      leading: OptimizedUserAvatar(uid: users[index].uid),
      title: Text(users[index].name),
    );
  },
)
```

---

## 🛠️ EXAMPLE 1: Chat List Screen

```dart
import '../../services/profile_image_service.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index].data() as Map<String, dynamic>;
            final otherUid = chat['participants']
              .firstWhere((uid) => uid != currentUid);
            final lastMessage = chat['lastMessage'] as String?;
            final timestamp = chat['timestamp'] as Timestamp?;

            return ChatListTile(
              otherUid: otherUid,
              lastMessage: lastMessage,
              timestamp: timestamp,
            );
          },
        );
      },
    );
  }
}

class ChatListTile extends StatelessWidget {
  final String otherUid;
  final String? lastMessage;
  final Timestamp? timestamp;

  const ChatListTile({
    required this.otherUid,
    this.lastMessage,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
        .collection('users')
        .doc(otherUid)
        .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl = userData['profileImageUrl'] as String?;
        final firstName = userData['firstName'] as String? ?? 'Unknown';
        final lastName = userData['lastName'] as String? ?? '';

        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: imageUrl != null 
              ? NetworkImage(imageUrl)
              : null,
            child: imageUrl == null 
              ? const Icon(Icons.person)
              : null,
          ),
          title: Text('$firstName $lastName'),
          subtitle: Text(lastMessage ?? 'No messages yet'),
          trailing: Text(
            _formatTime(timestamp),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            // Open chat
          },
        );
      },
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    
    if (now.difference(dateTime).inDays == 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.month}/${dateTime.day}';
  }
}
```

---

## 🛠️ EXAMPLE 2: Chat Message Bubbles

```dart
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const ChatBubble({
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            FutureBuilder<String?>(
              future: ProfileImageService()
                .getProfileImageUrl(message.senderId),
              builder: (context, snapshot) {
                final imageUrl = snapshot.data;
                return CircleAvatar(
                  radius: 16,
                  backgroundImage: imageUrl != null 
                    ? NetworkImage(imageUrl)
                    : null,
                  child: imageUrl == null 
                    ? const Icon(Icons.person, size: 12)
                    : null,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue[300] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(message.content),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            FutureBuilder<String?>(
              future: ProfileImageService()
                .getProfileImageUrl(message.senderId),
              builder: (context, snapshot) {
                final imageUrl = snapshot.data;
                return CircleAvatar(
                  radius: 16,
                  backgroundImage: imageUrl != null 
                    ? NetworkImage(imageUrl)
                    : null,
                  child: imageUrl == null 
                    ? const Icon(Icons.person, size: 12)
                    : null,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 🛠️ EXAMPLE 3: Seller Card

```dart
class SellerCard extends StatelessWidget {
  final String sellerId;

  const SellerCard({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final seller = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl = seller['profileImageUrl'] as String?;
        final firstName = seller['firstName'] as String? ?? 'Unknown';
        final lastName = seller['lastName'] as String? ?? '';
        final rating = seller['rating'] as double? ?? 0;
        final reviews = seller['reviewCount'] as int? ?? 0;

        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl != null 
                    ? NetworkImage(imageUrl)
                    : null,
                  child: imageUrl == null 
                    ? const Icon(Icons.person, size: 50)
                    : null,
                ),
                const SizedBox(height: 12),
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('$rating ($reviews reviews)'),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Message seller
                  },
                  child: const Text('Message Seller'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 📝 INTEGRATION CHECKLIST

- [ ] Chat List: Show sender avatars
- [ ] Chat Messages: Show message author avatars
- [ ] Seller Card: Show seller profile image
- [ ] Buyer Profile: Show buyer profile image
- [ ] User Search Results: Show user avatars
- [ ] Team Members: Show member avatars
- [ ] Comments/Reviews: Show reviewer avatars

---

## ⚡ PERFORMANCE TIPS

1. **Use cache in lists:**
   - Check `ProfileImageService.getCachedImageUrl()` first
   - Avoid repeated Firestore calls

2. **Lazy load images:**
   - Only load when visible (use visibility_detector package)
   
3. **Use CachedNetworkImage:**
   ```dart
   import 'package:cached_network_image/cached_network_image.dart';
   
   CachedNetworkImage(
     imageUrl: imageUrl,
     placeholder: (context, url) => CircleAvatar(
       child: CircularProgressIndicator(),
     ),
     errorWidget: (context, url, error) => CircleAvatar(
       child: Icon(Icons.person),
     ),
   )
   ```

4. **Stream optimization:**
   - Only stream when necessary
   - Use FutureBuilder for static data

---

Done! Pick any pattern above and integrate profile images throughout your app.
