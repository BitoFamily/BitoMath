import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' hide Image;
import '../../../core/constants/app_constants.dart';

/// The 7 animation states from issue #19's design brief. [idle] is the
/// resting/default state; every other value is a one-shot reaction that
/// [CompanionAnimatedAvatar] fires as a boolean input on the Rive state
/// machine, then the caller is expected to fall back to [idle] once the
/// reaction has played out (matching the "no loop -> returns to idle"
/// behavior documented per-state in the issue).
enum CompanionAnimState {
  idle,
  correct,
  wrong,
  streak,
  complete,
  unlock,
  encourage,
}

/// Rive-animated companion avatar with a graceful static-PNG fallback.
///
/// Real `.riv` character files don't exist yet — issue #19 explicitly
/// scopes "Rive file creation (design/animation work)" out of this issue,
/// since it requires an illustrator + Rive Studio (see the issue's
/// "Production prerequisite" note about layered source art). This widget
/// is the code-side integration: it looks for
/// `assets/animations/<name>.riv`, and if that file doesn't exist (true
/// today, for every character), it renders the same static PNG the app
/// already used before this issue — so nothing breaks, and dropping in
/// real .riv files later requires zero further wiring here.
///
/// State machine / input naming is a placeholder assumption
/// ([stateMachineName], [CompanionAnimState.name] as the boolean input
/// name) since no real file exists to confirm the artist's actual naming.
/// Adjust both once real assets land.
class CompanionAnimatedAvatar extends StatefulWidget {
  final int characterIndex; // matches CompanionData.all / AppConstants.characterImages
  final CompanionAnimState triggerState;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String stateMachineName;

  const CompanionAnimatedAvatar({
    super.key,
    required this.characterIndex,
    this.triggerState = CompanionAnimState.idle,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.stateMachineName = 'State Machine 1',
  });

  static const List<String> _riveAssetNames = ['coco', 'kato', 'sona'];

  String get _rivePath => 'assets/animations/${_riveAssetNames[characterIndex]}.riv';
  String get _fallbackImagePath => AppConstants.characterImages[characterIndex];

  @override
  State<CompanionAnimatedAvatar> createState() =>
      _CompanionAnimatedAvatarState();
}

class _CompanionAnimatedAvatarState extends State<CompanionAnimatedAvatar> {
  late Future<bool> _hasRiveAsset;
  StateMachineController? _controller;

  @override
  void initState() {
    super.initState();
    _hasRiveAsset = _assetExists(widget._rivePath);
  }

  @override
  void didUpdateWidget(covariant CompanionAnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.characterIndex != widget.characterIndex) {
      _controller = null;
      _hasRiveAsset = _assetExists(widget._rivePath);
    }
    if (oldWidget.triggerState != widget.triggerState) {
      _fireInput(widget.triggerState);
    }
  }

  /// `RiveAnimation.asset` throws an uncatchable-by-us async error deep
  /// inside its own State when the asset is missing, so we check first via
  /// rootBundle and only ever construct RiveAnimation when we know the
  /// file is really there.
  static Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      widget.stateMachineName,
    );
    if (controller == null) return;
    artboard.addController(controller);
    _controller = controller;
    _fireInput(widget.triggerState);
  }

  void _fireInput(CompanionAnimState state) {
    _controller?.findInput<bool>(state.name)?.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasRiveAsset,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return RiveAnimation.asset(
            widget._rivePath,
            stateMachines: [widget.stateMachineName],
            fit: widget.fit,
            onInit: _onRiveInit,
          );
        }
        return Image.asset(
          widget._fallbackImagePath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }
}
