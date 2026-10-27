import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: context.back,
        icon: const Icon(Icons.chevron_left),
      ),
      title: Text('Notification', style: heading(24)),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () => context.go(AppPage.searchTop),
          icon: const Icon(Icons.search),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
      separatorBuilder: (_, _) => const Divider(height: 28),
      itemBuilder: (_, i) => InkWell(
        onTap: () => context.go(
          i.isEven ? AppPage.channelPast : AppPage.messages,
          arguments: i.isEven ? null : 'T1 Faker',
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              i.isEven
                  ? Art.lckLogo
                  : '${Art.root}ed55aa2089a9121faf660398071c053c480c6c4e.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i.isEven
                        ? 'LCK Korea upload a video, follow us to see newest highlights'
                        : 'T1 Faker has sent you a message. Please check it now!',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    i.isEven ? '▣  3m ago' : '▣  15m ago',
                    style: const TextStyle(color: muted, fontSize: 11),
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

class SocialPage extends StatefulWidget {
  const SocialPage({super.key, this.friends = false, this.recipient});
  final bool friends;
  final Object? recipient;
  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  late bool friends = widget.friends;
  final Map<String, List<String>> _conversations = {};
  @override
  void initState() {
    super.initState();
    if (widget.recipient is String) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) compose(widget.recipient! as String);
      });
    }
  }

  void compose(String name) {
    final input = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, refresh) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.viewInsetsOf(sheet).bottom + 24,
          ),
          child: SizedBox(
            height: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: heading(24)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      const Text(
                        'Hello! Follow my channel and we will show you my skills.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                      ...(_conversations[name] ?? []).map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              color: Theme.of(
                                sheet,
                              ).colorScheme.surfaceContainerHighest,
                              child: Text(m),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: input,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    suffixIcon: IconButton(
                      tooltip: 'Send message',
                      onPressed: () {
                        if (input.text.trim().isEmpty) return;
                        refresh(() {
                          (_conversations[name] ??= []).add(input.text.trim());
                          input.clear();
                        });
                      },
                      icon: const Icon(Icons.send_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(input.dispose);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: context.back,
        icon: const Icon(Icons.chevron_left),
      ),
      title: Text('Social', style: heading(26)),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () => context.go(AppPage.searchTop),
          icon: const Icon(Icons.search),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: Column(
      children: [
        LineTabs(
          labels: const ['Message', 'Friend'],
          selected: friends ? 1 : 0,
          onChanged: (i) => setState(() => friends = i == 1),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (friends) ...[
                Text('ONLINE', style: heading(14)),
                const SizedBox(height: 12),
                ...List.generate(
                  7,
                  (i) => Column(
                    children: [
                      if (i == 4)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('OFFLINE', style: heading(14)),
                          ),
                        ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Avatar(Art.people[i], size: 48),
                        title: Text(
                          people[i],
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: IconButton(
                          tooltip: 'Message ${people[i]}',
                          onPressed: () => compose(people[i]),
                          icon: const Icon(Icons.more_vert, size: 20),
                        ),
                        onTap: () => compose(people[i]),
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                ),
              ] else
                ...List.generate(
                  8,
                  (i) => Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Avatar(
                          i.isEven
                              ? '${Art.root}b40c5e70077fe9e387c3d5be2df0d8d4496a6051.png'
                              : Art.people[0],
                          size: 56,
                        ),
                        title: Text(
                          i.isEven ? 'T1 Teddy' : 'T1 Bang',
                          style: heading(13),
                        ),
                        subtitle: const Text(
                          'Hello! Follow my channel and We will show you my skills.',
                          maxLines: 2,
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            height: 1.8,
                          ),
                        ),
                        trailing: Text(
                          i.isEven ? '14:55' : '12:55',
                          style: const TextStyle(color: muted, fontSize: 10),
                        ),
                        onTap: () => compose(i.isEven ? 'T1 Teddy' : 'T1 Bang'),
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
