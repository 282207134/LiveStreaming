import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/routes.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key, this.following = false, this.mini = false});
  final bool following, mini;
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _featured = PageController(viewportFraction: .76);
  bool get following => widget.following;
  bool get mini => widget.mini;
  @override
  void dispose() {
    _featured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final favorites = games
        .where((g) => state.favoriteGames.contains(g.id))
        .toList();
    final live = streams
        .where(
          (s) =>
              state.followed.contains(s.channel) ||
              (s.channel == 'T1 Faker' && state.followed.contains('T1')),
        )
        .toList();
    return HomeFrame(
      title: following ? 'Following' : 'Discover',
      selected: following ? 1 : 0,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              if (!following)
                SizedBox(
                  height: 296,
                  child: PageView.builder(
                    controller: _featured,
                    itemCount: 3,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: StreamCard(streams[[0, 1, 4][i]]),
                    ),
                  ),
                ),
              if (following) ...[
                SectionTitle(
                  'Your Categories',
                  onTap: () => context.go(AppPage.chooseGames),
                ),
                if (favorites.isEmpty)
                  const EmptyState(
                    'Choose your games',
                    'Follow categories to see them here.',
                  )
                else
                  GameRail(favorites),
                SectionTitle(
                  'Live Channel',
                  onTap: () => context.go(AppPage.browseLive),
                ),
                if (live.isEmpty)
                  const EmptyState(
                    'Your feed is ready',
                    'Follow a channel to see their streams here.',
                  )
                else
                  StreamRail(live),
                const SectionTitle('Latest Videos'),
                ...List.generate(2, (i) => PastVideoRow(streams[i], index: i)),
                const SectionTitle('Followed Channel'),
                ...state.followed.map(
                  (name) => ChannelRow(
                    name,
                    name == 'T1'
                        ? Art.t1
                        : name == 'T1 Faker'
                        ? Art.faker
                        : Art.lckLogo,
                  ),
                ),
              ] else ...[
                SectionTitle(
                  'Recommended Videos',
                  onTap: () => context.go(AppPage.browseLive),
                ),
                StreamRail([streams[1], streams[4], streams[0]]),
                SectionTitle(
                  'Your Categories',
                  onTap: () => context.go(AppPage.chooseGames),
                ),
                GameRail(
                  favorites.isEmpty ? games.take(3).toList() : favorites,
                ),
                SectionTitle(
                  'Popular Videos',
                  onTap: () => context.go(AppPage.browseLive),
                ),
                StreamRail([streams[2], streams[3], streams[0]]),
              ],
            ],
          ),
          if (mini)
            Positioned(
              right: 16,
              bottom: 12,
              child: Material(
                elevation: 6,
                child: SizedBox(
                  width: 156,
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InkWell(
                        onTap: () => context.replace(AppPage.watchControls),
                        child: Image.asset(Art.player, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          tooltip: 'Close mini player',
                          onPressed: () => context.replace(AppPage.discover),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 8,
                        bottom: 6,
                        child: Text(
                          'LIVE · 66.7K',
                          style: TextStyle(color: Colors.white, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key, this.live = false});
  final bool live;
  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  late bool live = widget.live;
  @override
  Widget build(BuildContext context) => HomeFrame(
    title: 'Browser',
    selected: 2,
    child: Column(
      children: [
        LineTabs(
          labels: const ['Categories', 'Live Channel'],
          selected: live ? 1 : 0,
          onChanged: (i) => setState(() => live = i == 1),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: live
                ? [
                    for (final stream in [streams[4], streams[5], ...streams])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: StreamCard(stream),
                      ),
                  ]
                : [
                    for (final game in [
                      games[0],
                      games[1],
                      games[3],
                      ...games.skip(4),
                    ])
                      GameRow(game),
                  ],
          ),
        ),
      ],
    ),
  );
}

class GameRow extends StatelessWidget {
  const GameRow(this.game, {super.key});
  final Game game;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      onTap: () => context.go(AppPage.categoryLive, arguments: game.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(game.image, width: 127, height: 170, fit: BoxFit.cover),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.name, style: heading(17)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          game.viewers,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people, size: 14),
                        SizedBox(width: 5),
                        Text('25,5M', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Tags(values: game.tags),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.page, this.gameId});
  final AppPage page;
  final Object? gameId;
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late int index = widget.page == AppPage.categoryPast
      ? 1
      : widget.page == AppPage.categoryClips
      ? 2
      : 0;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context), game = gameById(widget.gameId);
    final items = streams
        .where(
          (s) => s.gameId == game.id || game.id == 'lol' && s.gameId == 'lol',
        )
        .toList();
    if (state.filtersActive) {
      items.removeWhere(
        (s) => !state.tags.every(
          (t) => [...game.tags, game.name, 'LCK', 'English'].contains(t),
        ),
      );
      if (state.sortOrder == 0) {
        items.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      }
      if (state.sortOrder == 1) {
        items.sort((a, b) => a.viewCount.compareTo(b.viewCount));
      }
      if (state.sortOrder == 2) {
        final reversed = items.reversed.toList();
        items
          ..clear()
          ..addAll(reversed);
      }
    }
    return Scaffold(
      appBar: PageHeader(
        '',
        actions: [
          IconButton(
            tooltip: 'Cast to device',
            onPressed: () => showInfo(
              context,
              'Connect a device',
              'No casting devices found.',
            ),
            icon: const Icon(Icons.cast, size: 22),
          ),
          IconButton(
            tooltip: 'Sort & Filter',
            onPressed: () => context.go(AppPage.filter),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            tooltip: 'Follow category',
            onPressed: () => state.update(() {
              state.favoriteGames.contains(game.id)
                  ? state.favoriteGames.remove(game.id)
                  : state.favoriteGames.add(game.id);
            }),
            icon: Icon(
              state.favoriteGames.contains(game.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: GameRow(game),
          ),
          LineTabs(
            labels: const ['Live', 'Past Stream', 'Clip'],
            selected: index,
            onChanged: (i) => setState(() => index = i),
          ),
          if (items.isEmpty)
            const EmptyState(
              'No matching streams',
              'Try another category or reset the filters.',
            )
          else if (index == 0) ...[
            for (final s in [items.last, ...items])
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: StreamCard(s),
              ),
          ] else if (index == 1) ...[
            const SectionTitle('Popular'),
            StreamRail(items, live: false),
            const SectionTitle('Recently Uploaded'),
            StreamRail(items.reversed.toList(), live: false),
          ] else
            ...List.generate(
              3,
              (i) => ClipCard(stream: items[i % items.length]),
            ),
        ],
      ),
    );
  }
}

class ClipCard extends StatelessWidget {
  const ClipCard({super.key, required this.stream});
  final LiveStream stream;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            const Avatar(Art.faker),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Faker T1', style: heading(14)),
                const Text(
                  'League of Legends',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      InkWell(
        onTap: () => openStream(context, stream),
        child: AspectRatio(
          aspectRatio: 375 / 211,
          child: Image.asset(Art.clip, fit: BoxFit.cover),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Faker is god with Leblanc 2019!', style: heading(15)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    'Share',
                    outlined: true,
                    onPressed: () => showInfo(
                      context,
                      'Share clip',
                      'Faker is god with Leblanc 2019! · Utubee demo clip',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    'Watch Videos',
                    onPressed: () => openStream(context, stream),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class PastVideoRow extends StatelessWidget {
  const PastVideoRow(this.stream, {super.key, this.index = 0});
  final LiveStream stream;
  final int index;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => openStream(context, stream),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 144,
            height: 81,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  Art.past[index % Art.past.length],
                  fit: BoxFit.cover,
                ),
                const Positioned(
                  left: 5,
                  top: 5,
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Text(
                      ' 6:33 ',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    'T1 vs HLE',
                    'T1 vs DWG',
                    'World Champion',
                    stream.title,
                  ][index % 4],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: heading(13),
                ),
                const SizedBox(height: 6),
                const Text(
                  'LCK Korea',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 6),
                const Text(
                  '25K views · 20 Feb',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ChannelRow extends StatelessWidget {
  const ChannelRow(this.name, this.image, {super.key});
  final String name, image;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    leading: Avatar(image, size: 64),
    title: Row(
      children: [
        Flexible(child: Text(name, style: heading(14))),
        const SizedBox(width: 6),
        const Icon(Icons.verified, color: Color(0xffff6161), size: 13),
      ],
    ),
    subtitle: const Text(
      'League of Legends\n255,8K followers',
      style: TextStyle(color: muted, fontSize: 11, height: 1.8),
    ),
    onTap: () => context.go(AppPage.channelPast),
  );
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key, this.tagsOnly = false});
  final bool tagsOnly;
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    const allTags = [
      'Sport',
      'Multiplayer',
      'MOBA',
      'English',
      'League of Legends',
      'Counter Strike',
      'Left 4 Dead',
      'Fifa Online 4',
      'Esport',
      'FPS',
    ];
    return Scaffold(
      appBar: PageHeader(
        widget.tagsOnly ? 'SEARCH TAGS' : 'SORT & FILTER',
        actions: [
          TextButton(
            onPressed: () {
              if (widget.tagsOnly) {
                context.back();
              } else {
                state.update(() {
                  state.sortOrder = 0;
                  state.tags = {};
                  state.filtersActive = false;
                });
              }
            },
            child: Text(
              widget.tagsOnly ? 'DONE' : 'RESET',
              style: const TextStyle(fontSize: 10, letterSpacing: 1),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.tagsOnly) ...[
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search tag...',
                  hintStyle: TextStyle(fontSize: 12, color: muted),
                ),
              ),
              const SizedBox(height: 28),
              Text('SUGGEST', style: heading(14)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final t in allTags.where(
                      (t) => t.toLowerCase().contains(query.toLowerCase()),
                    ))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          state.tags.contains(t)
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20,
                        ),
                        title: Text(t, style: const TextStyle(fontSize: 13)),
                        onTap: () => state.update(() {
                          state.tags.contains(t)
                              ? state.tags.remove(t)
                              : state.tags.add(t);
                        }),
                      ),
                  ],
                ),
              ),
            ] else ...[
              Text('SORT', style: heading(14)),
              const SizedBox(height: 8),
              ...List.generate(
                4,
                (i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    [
                      Icons.sort,
                      Icons.sort,
                      Icons.schedule,
                      Icons.auto_awesome,
                    ][i],
                    size: 22,
                  ),
                  title: Text(
                    [
                      'Viewers (High to Low)',
                      'Viewers (Low to High)',
                      'Recently Started',
                      'Recommend For You',
                    ][i],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: state.sortOrder == i
                      ? const Icon(Icons.check, size: 20)
                      : null,
                  onTap: () => state.update(() => state.sortOrder = i),
                ),
              ),
              const Divider(height: 40),
              Row(
                children: [
                  Expanded(child: Text('FILTER BY TAGS', style: heading(14))),
                  IconButton(
                    tooltip: 'Search tags',
                    onPressed: () => context.go(AppPage.tags),
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    ['Esport', 'MOBA', 'Multiplayer', 'Sport', 'English', 'FPS']
                        .map(
                          (t) => FilterChip(
                            label: Text(
                              t,
                              style: const TextStyle(fontSize: 10),
                            ),
                            selected: state.tags.contains(t),
                            showCheckmark: false,
                            onSelected: (_) => state.update(() {
                              state.tags.contains(t)
                                  ? state.tags.remove(t)
                                  : state.tags.add(t);
                            }),
                            shape: const RoundedRectangleBorder(),
                          ),
                        )
                        .toList(),
              ),
              const Spacer(),
              AppButton(
                'Apply Filters',
                onPressed: () {
                  state.update(() => state.filtersActive = true);
                  if (Navigator.canPop(context)) {
                    context.back();
                  } else {
                    context.replace(AppPage.categoryLive);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
