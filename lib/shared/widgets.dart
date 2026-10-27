import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../core/routes.dart';
import '../data/catalog.dart';

const muted = Color(0xff7f8b8b);
TextStyle heading([double size = 16]) =>
    TextStyle(fontSize: size, fontWeight: FontWeight.w600, height: 1.45);
void toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );

class AppButton extends StatelessWidget {
  const AppButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.outlined = false,
    this.light = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool outlined, light;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = light ? Colors.black : scheme.onPrimary;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: outlined
              ? Colors.transparent
              : light
              ? Colors.white
              : scheme.primary,
          foregroundColor: outlined ? scheme.primary : fg,
          shape: RoundedRectangleBorder(
            side: outlined
                ? BorderSide(color: scheme.primary)
                : BorderSide.none,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        onPressed: onPressed,
        child: Text(label.toUpperCase(), textAlign: TextAlign.center),
      ),
    );
  }
}

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader(
    this.title, {
    super.key,
    this.actions = const [],
    this.back = true,
  });
  final String title;
  final List<Widget> actions;
  final bool back;
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    centerTitle: true,
    leading: back
        ? IconButton(
            tooltip: 'Back',
            onPressed: context.back,
            icon: const Icon(Icons.chevron_left),
          )
        : null,
    title: Text(title, style: heading()),
    actions: actions,
  );
}

class HomeFrame extends StatelessWidget {
  const HomeFrame({
    super.key,
    required this.title,
    required this.selected,
    required this.child,
    this.trailing,
  });
  final String title;
  final int selected;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (trailing != null)
                  trailing!
                else ...[
                  IconButton(
                    tooltip: 'Cast to device',
                    onPressed: () => showInfo(
                      context,
                      'Connect a device',
                      'No casting devices found on this network. The demo uses local preview images.',
                    ),
                    icon: const Icon(Icons.cast, size: 22),
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => context.go(AppPage.notifications),
                    icon: const Icon(Icons.notifications_none, size: 23),
                  ),
                  IconButton(
                    tooltip: 'Social',
                    onPressed: () => context.go(AppPage.messages),
                    icon: const Icon(Icons.chat_bubble_outline, size: 22),
                  ),
                  IconButton(
                    tooltip: 'Search',
                    onPressed: () => context.go(AppPage.searchTop),
                    icon: const Icon(Icons.search, size: 24),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(title, style: heading(28)),
          ),
          Expanded(child: child),
        ],
      ),
    ),
    bottomNavigationBar: BottomTabs(selected: selected),
  );
}

class BottomTabs extends StatelessWidget {
  const BottomTabs({super.key, required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.explore_outlined,
      Icons.favorite_border,
      Icons.video_library_outlined,
      Icons.person_outline,
    ];
    const labels = ['DISCOVER', 'FOLLOWING', 'BROWSER', 'PROFILE'];
    const pages = [
      AppPage.discover,
      AppPage.following,
      AppPage.browseCategories,
      AppPage.profileSaved,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (i) => Semantics(
                selected: i == selected,
                button: true,
                label: labels[i],
                child: InkWell(
                  key: ValueKey('nav_${labels[i]}'),
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    if (i != selected) context.home(pages[i]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: i == selected
                          ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(icons[i], size: 22),
                        if (i == selected) ...[
                          const SizedBox(width: 8),
                          Text(
                            labels[i],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LineTabs extends StatelessWidget {
  const LineTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Theme.of(context).dividerColor, width: .5),
      ),
    ),
    child: Row(
      children: List.generate(
        labels.length,
        (i) => Expanded(
          child: InkWell(
            onTap: () => onChanged(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.5,
                    color: i == selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
              ),
              child: Text(
                labels[i],
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: i == selected ? null : muted,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.onTap});
  final String title;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 16),
      child: Row(
        children: [
          Expanded(child: Text(title.toUpperCase(), style: heading(15))),
          if (onTap != null) const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar(this.image, {super.key, this.size = 40});
  final String image;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(image, width: size, height: size, fit: BoxFit.cover),
  );
}

class Tags extends StatelessWidget {
  const Tags({super.key, this.values = const ['Esport', 'MOBA', 'LCK']});
  final List<String> values;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 4,
    children: values
        .map(
          (v) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              v,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
            ),
          ),
        )
        .toList(),
  );
}

void openStream(BuildContext context, LiveStream stream) {
  AppScope.of(context).recordWatch(stream.id);
  context.go(AppPage.watchControls, arguments: stream.id);
}

class StreamCard extends StatelessWidget {
  const StreamCard(this.stream, {super.key, this.width, this.live = true});
  final LiveStream stream;
  final double? width;
  final bool live;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => openStream(context, stream),
          child: AspectRatio(
            aspectRatio: 280 / 157,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(stream.image, fit: BoxFit.cover),
                if (live)
                  const Positioned(
                    top: 10,
                    left: 10,
                    child: ColoredBox(
                      color: Color(0xffff3b3b),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 7,
                  left: 10,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      '${stream.views} VIEWS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.go(AppPage.channelPast),
              child: Avatar(stream.avatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => openStream(context, stream),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: heading(),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stream.channel,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stream.game,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 7),
                    Tags(
                      values: [
                        'Esport',
                        'MOBA',
                        stream.gameId == 'dota' ? 'DOTA 2' : 'LCK',
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 20,
              height: 28,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                tooltip: 'Stream options',
                icon: const Icon(Icons.more_vert, size: 18),
                onSelected: (v) {
                  if (v == 'save') {
                    AppScope.of(context).toggleSaved(stream.id);
                  } else {
                    context.go(AppPage.channelPast);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'save',
                    child: Text(
                      AppScope.of(context).saved.contains(stream.id)
                          ? 'Remove from saved'
                          : 'Save stream',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'channel',
                    child: Text('View channel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class StreamRail extends StatelessWidget {
  const StreamRail(this.items, {super.key, this.live = true});
  final List<LiveStream> items;
  final bool live;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 292,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 24),
      itemBuilder: (_, i) => StreamCard(items[i], width: 280, live: live),
    ),
  );
}

class GameTile extends StatelessWidget {
  const GameTile(this.game, {super.key, this.selectable = false});
  final Game game;
  final bool selectable;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return InkWell(
      onTap: () {
        if (selectable) {
          state.update(() {
            state.favoriteGames.contains(game.id)
                ? state.favoriteGames.remove(game.id)
                : state.favoriteGames.add(game.id);
          });
        } else {
          context.go(AppPage.categoryLive, arguments: game.id);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 127 / 170,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(game.image, fit: BoxFit.cover),
                if (selectable) ...[
                  ColoredBox(color: Colors.black.withValues(alpha: .18)),
                  Center(
                    child: Icon(
                      state.favoriteGames.contains(game.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            game.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: heading(selectable ? 16 : 11),
          ),
          if (!selectable) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.visibility, size: 14),
                const SizedBox(width: 7),
                Text(game.viewers, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class GameRail extends StatelessWidget {
  const GameRail(this.items, {super.key});
  final List<Game> items;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 225,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, i) => SizedBox(width: 127, child: GameTile(items[i])),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.title, this.message, {super.key});
  final String title, message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.video_library_outlined, size: 40, color: muted),
        const SizedBox(height: 16),
        Text(title, style: heading(20)),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, height: 1.6),
        ),
      ],
    ),
  );
}

void showInfo(BuildContext context, String title, String text) =>
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK'),
          ),
        ],
      ),
    );
