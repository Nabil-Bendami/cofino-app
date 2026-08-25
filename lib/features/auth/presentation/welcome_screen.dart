import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/auth_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: AuthPalette.darkRoast,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AuthPalette.darkRoastGradientTop,
              AuthPalette.darkRoast,
            ],
          ),
        ),
        child: Column(
          children: [
            // Upper hero image section with gradient blend
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'lib/menu-image/coffee_splash_hero.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.2),
                    errorBuilder: (_, __, ___) => Image.asset(
                      'lib/menu-image/coffe-normal.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: AuthPalette.darkRoast,
                        child: Center(
                          child: Icon(
                            Icons.coffee,
                            size: 80,
                            color: AuthPalette.goldenAmber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay blending image smoothly into dark background
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.55, 0.85, 1.0],
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.transparent,
                            AuthPalette.darkRoastGradientTop.withValues(alpha: 0.85),
                            AuthPalette.darkRoast,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lower text and action button section
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Choice your\nFavorite Coffee',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'The best grain, the finest roast, the most powerful flavour.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AuthPalette.subtitleTaupe,
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.045),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () => context.go('/login'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AuthPalette.goldenAmber,
                          foregroundColor: AuthPalette.darkAmberText,
                          elevation: 6,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

