import 'package:dev_rpg/src/game_screen/character_modal.dart';
import 'package:dev_rpg/src/game_screen/character_style.dart';
import 'package:dev_rpg/src/shared_state/game/character.dart';
import 'package:dev_rpg/src/shared_state/game/character_pool.dart';
import 'package:dev_rpg/src/style.dart';
import 'package:dev_rpg/src/widgets/flare/hiring_bust.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays a list of [Character]s that are available to the player.
class CharacterPoolPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var characterPool = Provider.of<CharacterPool>(context);
    return Stack(
      children: [
        GridView.builder(
          padding:
              const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 128.0),
          itemCount: characterPool.children.length,
          gridDelegate: _gridStructure,
          itemBuilder: (context, index) => ChangeNotifierProvider<Character>(
                notifier: characterPool.children[index],
                key: ValueKey(characterPool.children[index]),
                child: CharacterListItem(),
              ),
        ),
        _fadeOverlay,
      ],
    );
  }

  SliverGridDelegate get _gridStructure =>
      const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 15.0,
          childAspectRatio: 0.65);

  Widget get _fadeOverlay {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.0,
        child: IgnorePointer(
          child: Container(
            height: 128,
            decoration: const BoxDecoration(
              // Box decoration takes a gradient
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(59, 59, 73, 0.0),
                  Color.fromRGBO(59, 59, 73, 1.0)
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the current state of an individual [Character]
/// Tapping on the [Character] opens up a modal window which
/// offers more details about stats and options to upgrade.
class CharacterListItem extends StatefulWidget {
  @override
  _CharacterListItemState createState() => _CharacterListItemState();
}

class _CharacterListItemState extends State<CharacterListItem> {
  // True if the *mouse* is hovering over this widget.
  bool _isOver;

  @override
  void initState() {
    super.initState();
    _isOver = false;
  }

  void _startPlaying(PointerEnterEvent _) => setState(() => _isOver = true);
  void _stopPlaying(PointerExitEvent _) => setState(() => _isOver = false);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerEnter: _startPlaying,
      onPointerExit: _stopPlaying,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Stack(
          children: <Widget>[
            const CharacterBox(),
            CharacterDisplay(isAnimating: _isOver),
          ],
        ),
      ),
    );
  }
}

class CharacterDisplay extends StatelessWidget {
  const CharacterDisplay({
    bool isAnimating,
  }) : _isAnimating = isAnimating;

  final bool _isAnimating;

  @override
  Widget build(BuildContext context) {
    var character = Provider.of<Character>(context);
    var characterStyle = CharacterStyle.from(character);
    HiringBustState bustState = character.isHired
        ? HiringBustState.hired
        : character.canUpgrade
            ? HiringBustState.available
            : HiringBustState.locked;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: _inkWellBorder,
        onTap: () => _showModal(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: HiringBust(
                particleColor: attentionColor,
                filename: characterStyle.flare,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                hiringState: bustState,
                isPlaying: _isAnimating,
              ),
            ),
            const SizedBox(height: 20.0),
            HiringInformation(bustState),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  RoundedRectangleBorder get _inkWellBorder =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0));

  void _showModal(BuildContext context) {
    var character = Provider.of<Character>(context);
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ChangeNotifierProvider<Character>(
            notifier: character,
            child: CharacterModal(),
          );
        });
  }
}

class HiringInformation extends StatelessWidget {
  const HiringInformation(this.bustState);

  final HiringBustState bustState;

  @override
  Widget build(BuildContext context) {
    var character = Provider.of<Character>(context);
    return Opacity(
      opacity: character.isHired || character.canUpgrade ? 1.0 : 0.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          character.isHired
              ? Container()
              : Icon(
                  bustState == HiringBustState.available
                      ? Icons.add_circle
                      : Icons.lock,
                  color: !character.isHired && character.canUpgrade
                      ? attentionColor
                      : Colors.white),
          const SizedBox(width: 4.0),
          Text(
            bustState == HiringBustState.hired
                ? 'Hired'
                : bustState == HiringBustState.available ? 'Hire!' : 'Locked',
            style: contentStyle.apply(
                color: bustState == HiringBustState.available
                    ? attentionColor
                    : Colors.white),
          )
        ],
      ),
    );
  }
}

class CharacterBox extends StatelessWidget {
  const CharacterBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromRGBO(69, 69, 82, 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.0,
          ),
        ],
      ),
    );
  }
}
