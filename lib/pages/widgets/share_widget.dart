import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareWidget extends StatefulWidget {
  const ShareWidget({super.key});

  @override
  State<ShareWidget> createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  final ValueNotifier<bool> openNotifier = ValueNotifier(false);

  void _toggleShare() => openNotifier.value = !openNotifier.value;

  @override
  Widget build(BuildContext context) {
    return  ValueListenableBuilder(
      valueListenable: openNotifier,
      builder: (context, isOpen, child) {
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.fastOutSlowIn,
              width: isOpen ? 240 : 48,
              height: 48,
              decoration: ShapeDecoration(
                color: Colors.grey[400],
                shape: const StadiumBorder(),
              ),
            ),
            Container(
              width: 40,
              margin: const EdgeInsets.only(left: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 450),
                firstChild: IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _toggleShare(),
                ),
                secondChild: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _toggleShare(),
                ),
                crossFadeState: !isOpen
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              opacity: isOpen ? 1 : 0,
              child: Container(
                width: 240,
                padding: const EdgeInsets.only(left: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.twitter),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon:const FaIcon(FontAwesomeIcons.squareFacebook),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.instagram),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}