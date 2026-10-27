import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_controller.dart';
import '../../core/routes.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

class WatchPage extends StatefulWidget {
  const WatchPage(this.page, {super.key, this.streamId});
  final AppPage page;
  final Object? streamId;
  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late bool controls = widget.page == AppPage.watchControls;
  late int? picker = widget.page == AppPage.watchSticker
      ? 0
      : widget.page == AppPage.watchGif
      ? 1
      : widget.page == AppPage.watchEmoji
      ? 2
      : null;
  final _comment = TextEditingController();
  final _scroll = ScrollController();
  bool paused = false;
  @override
  void dispose() {
    _comment.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void send([String? value]) {
    final text = value ?? _comment.text;
    if (text.trim().isEmpty) return;
    AppScope.of(context).sendMessage(text);
    _comment.clear();
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context), stream = streamById(widget.streamId);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final preview = stream.gameId == 'lol' ? Art.player : stream.image;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => controls = !controls),
              child: AspectRatio(
                aspectRatio: keyboard ? 375 / 140 : 375 / 210,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(preview, fit: BoxFit.cover),
                    if (controls) ...[
                      const ColoredBox(color: Colors.black26),
                      Positioned(
                        left: 4,
                        top: 2,
                        child: IconButton(
                          tooltip: 'Minimize player',
                          onPressed: () => context.home(AppPage.discoverMini),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 2,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: 'Cast to device',
                              onPressed: () => showInfo(
                                context,
                                'Cast',
                                'Connect a casting device to play this stream.',
                              ),
                              icon: const Icon(
                                Icons.cast,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Share stream',
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: 'Utubee · ${stream.title}',
                                  ),
                                );
                                if (context.mounted) {
                                  toast(context, 'Stream title copied');
                                }
                              },
                              icon: const Icon(
                                Icons.ios_share,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                            IconButton(
                              key: const ValueKey('save_stream'),
                              tooltip: 'Save stream',
                              onPressed: () => state.toggleSaved(stream.id),
                              icon: Icon(
                                state.saved.contains(stream.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: IconButton(
                          tooltip: paused ? 'Resume preview' : 'Pause preview',
                          onPressed: () => setState(() => paused = !paused),
                          icon: Icon(
                            paused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 12,
                        child: Row(
                          children: [
                            Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${stream.views} VIEWS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 0,
                        child: IconButton(
                          tooltip: 'Expand preview',
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (c) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  Image.asset(preview, fit: BoxFit.contain),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      tooltip: 'Close expanded preview',
                                      onPressed: () => Navigator.pop(c),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ] else
                      Positioned(
                        left: 0,
                        top: 0,
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: context.back,
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (controls && !keyboard)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => context.go(AppPage.channelPast),
                      child: Avatar(stream.avatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => context.go(AppPage.channelPast),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stream.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: heading(14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              stream.channel,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stream.game,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Tags(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: .7,
                  ),
                ),
              ),
              child: Text('CHATTING', style: heading(16)),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(24, 14, 14, 8),
                itemCount: 12 + state.sentMessages.length,
                itemBuilder: (_, i) {
                  final sent = i >= 12;
                  final line = chatLines[i % chatLines.length];
                  final text = sent ? state.sentMessages[i - 12] : line.$2;
                  final media = text.startsWith('asset:');
                  final color = sent
                      ? Theme.of(context).colorScheme.primary
                      : [
                          const Color(0xffff2828),
                          const Color(0xff9b80ff),
                          const Color(0xff91d9d4),
                          muted,
                        ][i % 4];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: media
                        ? Row(
                            children: [
                              Text(
                                '${state.username}: ',
                                style: TextStyle(color: color, fontSize: 13),
                              ),
                              Image.asset(
                                text.substring(6),
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                            ],
                          )
                        : Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${sent ? state.username : line.$1}: ',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: text),
                              ],
                            ),
                            style: const TextStyle(fontSize: 14, height: 1.35),
                          ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: TextField(
                key: const ValueKey('chat_input'),
                controller: _comment,
                style: const TextStyle(fontSize: 13),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => send(),
                decoration: InputDecoration(
                  hintText: 'Comment...',
                  hintStyle: const TextStyle(color: muted, fontSize: 12),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Send message',
                        onPressed: () => send(),
                        icon: const Icon(Icons.send_outlined, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Emoji and stickers',
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            picker = picker == null ? 2 : null;
                            controls = false;
                          });
                        },
                        icon: const Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (picker != null && !keyboard)
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .32,
                child: Column(
                  children: [
                    LineTabs(
                      labels: const ['Sticker', 'GIF', 'Emoji'],
                      selected: picker!,
                      onChanged: (i) => setState(() => picker = i),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: picker == 2 ? 6 : 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: picker == 2
                            ? emoji.length
                            : picker == 1
                            ? Art.gifs.length
                            : Art.stickers.length,
                        itemBuilder: (_, i) => InkWell(
                          onTap: () => send(
                            picker == 2
                                ? emoji[i]
                                : 'asset:${picker == 1 ? Art.gifs[i] : Art.stickers[i]}',
                          ),
                          child: picker == 2
                              ? Center(
                                  child: Text(
                                    emoji[i],
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                )
                              : Image.asset(
                                  picker == 1 ? Art.gifs[i] : Art.stickers[i],
                                  fit: BoxFit.contain,
                                ),
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
