import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/routes.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';
import '../browse/browse_pages.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage(this.page, {super.key});
  final AppPage page;
  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late int index = [
    AppPage.channelPast,
    AppPage.channelClips,
    AppPage.channelOverview,
    AppPage.channelGallery,
  ].indexOf(widget.page);
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(Art.banner, fit: BoxFit.cover),
                  Positioned(
                    top: 0,
                    left: 4,
                    child: IconButton(
                      tooltip: 'Back',
                      onPressed: context.back,
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (_) => showInfo(
                        context,
                        'Faker T1',
                        'Professional League of Legends player · Utubee demo channel.',
                      ),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'about',
                          child: Text('About this channel'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Avatar(Art.faker, size: 64),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Faker T1', style: heading()),
                          const SizedBox(height: 5),
                          const Text(
                            'League of Legends',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          const Tags(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Faker streams live on Twitch! Check out their videos, sign up ... T1 Faker.',
                    style: TextStyle(fontSize: 13, height: 1.65),
                  ),
                  const SizedBox(height: 24),
                  const ProfileStats(),
                  const SizedBox(height: 24),
                  AppButton(
                    'Watching with 66,778 viewers',
                    onPressed: () => openStream(context, streams.first),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    state.followed.contains('T1 Faker')
                        ? 'Following'
                        : 'Follow',
                    outlined: true,
                    key: const ValueKey('follow_channel'),
                    onPressed: () => state.toggleFollow('T1 Faker'),
                  ),
                ],
              ),
            ),
            LineTabs(
              labels: const ['Past Stream', 'Clip', 'Overview', 'Gallery'],
              selected: index,
              onChanged: (i) => setState(() => index = i),
            ),
            if (index == 0) ...[
              const SizedBox(height: 16),
              StreamRail([streams[0], streams[1]], live: false),
              ...List.generate(3, (i) => PastVideoRow(streams[i], index: i)),
            ] else if (index == 1)
              ClipCard(stream: streams.first)
            else if (index == 2)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• Lee Sang-hyeok (Korean: 이상혁; born May 7, 1996), better known by his in-game name Faker, is a South Korean professional League of Legends player. Formerly known as “GoJeonPa” on the Korean server, he was picked up by LCK team SK Telecom T1 in 2013 and has played as the team’s mid laner since.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.8),
                    ),
                    const SizedBox(height: 24),
                    Text('SOCIAL', style: heading(14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final name in ['Facebook', 'Instagram'])
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: TextButton(
                              onPressed: () => showInfo(
                                context,
                                name,
                                'Social links can be connected to the channel backend.',
                              ),
                              child: Text(name),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showImage(context, Art.gallery[0]),
                        child: Image.asset(Art.gallery[0], fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          for (final path in Art.gallery.skip(1))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () => _showImage(context, path),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(path, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImage(BuildContext context, String image) => showDialog<void>(
    context: context,
    builder: (c) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(image),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => context.go(AppPage.followers),
            child: Column(
              children: [
                const Text(
                  'Followers',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text('23,556,345', style: heading(14)),
              ],
            ),
          ),
        ),
        VerticalDivider(color: Theme.of(context).dividerColor),
        Expanded(
          child: InkWell(
            onTap: () => context.go(AppPage.channelFollowing),
            child: Column(
              children: [
                const Text(
                  'Following',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text('6,345', style: heading(14)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key, this.following = false});
  final bool following;
  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  String query = '';
  final Set<String> friends = {};
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final matches = List.generate(people.length, (i) => i)
        .where((i) => people[i].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: const PageHeader('Faker T1'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.following ? 'Following' : 'Followers',
                    style: heading(28),
                  ),
                ),
                Text(
                  widget.following ? '6,345' : '23,556,345',
                  style: heading(14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: widget.following
                    ? 'Search following...'
                    : 'Search followers...',
                hintStyle: const TextStyle(color: muted, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: matches.isEmpty
                  ? const EmptyState('No people found', 'Try another name.')
                  : ListView(
                      children: [
                        for (final i in matches)
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: .5,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        context.go(AppPage.channelPast),
                                    child: Avatar(Art.people[i], size: 48),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      people[i],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Follow ${people[i]}',
                                    onPressed: () =>
                                        state.toggleFollow(people[i]),
                                    icon: Icon(
                                      state.followed.contains(people[i])
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 19,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Add friend',
                                    onPressed: () => setState(() {
                                      friends.contains(people[i])
                                          ? friends.remove(people[i])
                                          : friends.add(people[i]);
                                    }),
                                    icon: Icon(
                                      friends.contains(people[i])
                                          ? Icons.person
                                          : Icons.person_add_alt,
                                      size: 19,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Message ${people[i]}',
                                    onPressed: () => context.go(
                                      AppPage.messages,
                                      arguments: people[i],
                                    ),
                                    icon: const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
