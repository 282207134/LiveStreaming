import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/routes.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';
import '../browse/browse_pages.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(this.page, {super.key});
  final AppPage page;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late int index = [
    AppPage.searchTop,
    AppPage.searchChannels,
    AppPage.searchCategories,
    AppPage.searchVideos,
  ].indexOf(widget.page);
  TextEditingController? _query;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _query ??= TextEditingController(text: AppScope.of(context).query);
  }

  @override
  void dispose() {
    _query?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final query = _query!.text.trim().toLowerCase();
    final matchingGames = games
        .where(
          (g) =>
              g.name.toLowerCase().contains(query) ||
              g.id == 'dota' && query == 'league of legends',
        )
        .toList();
    final matchingStreams = streams
        .where(
          (s) =>
              '${s.title} ${s.channel} ${s.game}'.toLowerCase().contains(query),
        )
        .toList();
    const channels = [
      'LCK Global',
      'T1',
      'CSGO',
      'Griffin',
      'Cloud 9',
      'Fnatic',
    ];
    const channelImages = [
      Art.lckLogo,
      Art.t1,
      '${Art.root}9fa0858f10a77db3e0b48071f9c0bda9ad543a84.png',
      '${Art.root}68fc72a1d542b4318c105d8faf4fef60c6685258.png',
      '${Art.root}774efcf25f39e8b9997b25ff7434999e5a1bd8a2.png',
      '${Art.root}4147974bf93a7518bda5ea1657bcc9182c9c909e.png',
    ];
    final matchingChannels = List.generate(channels.length, (i) => i)
        .where(
          (i) =>
              '${channels[i]} league of legends'.toLowerCase().contains(query),
        )
        .toList();
    final noResults = switch (index) {
      1 => matchingChannels.isEmpty,
      2 => matchingGames.isEmpty,
      3 => matchingStreams.isEmpty,
      _ =>
        matchingStreams.isEmpty &&
            matchingGames.isEmpty &&
            matchingChannels.isEmpty,
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: context.back,
          icon: const Icon(Icons.chevron_left),
        ),
        title: TextField(
          key: const ValueKey('search_input'),
          controller: _query,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Search channels, games, videos',
          ),
          onChanged: (v) {
            state.query = v;
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Clear search',
            onPressed: () {
              _query!.clear();
              state.query = '';
              setState(() {});
            },
            icon: const Icon(Icons.cancel, size: 19, color: muted),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          LineTabs(
            labels: const ['Top', 'Channel', 'Categories', 'Past Videos'],
            selected: index,
            onChanged: (i) => setState(() => index = i),
          ),
          Expanded(
            child: noResults
                ? const EmptyState(
                    'No results found',
                    'Try a different channel, game or video title.',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (index == 0 || index == 1) ...[
                        if (index == 0) const SectionTitle('Channel'),
                        for (final i
                            in (index == 0
                                ? matchingChannels.take(2)
                                : matchingChannels))
                          ChannelRow(channels[i], channelImages[i]),
                      ],
                      if (index == 0 && matchingStreams.isNotEmpty) ...[
                        const SectionTitle('People searching also watching'),
                        StreamRail(matchingStreams),
                      ],
                      if (index == 0 || index == 2) ...[
                        if (index == 0) const SectionTitle('Categories'),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            children:
                                (index == 0
                                        ? matchingGames.take(2)
                                        : matchingGames)
                                    .map(GameRow.new)
                                    .toList(),
                          ),
                        ),
                      ],
                      if (index == 0 || index == 3) ...[
                        if (index == 0) const SectionTitle('Past Videos'),
                        for (
                          var i = 0;
                          i <
                              (index == 3
                                  ? 6
                                  : matchingStreams.length.clamp(0, 3));
                          i++
                        )
                          if (matchingStreams.isNotEmpty)
                            PastVideoRow(
                              matchingStreams[i % matchingStreams.length],
                              index: i,
                            ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
