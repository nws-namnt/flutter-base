import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Content type of a single [IntroItem] slide.
enum IntroItemType {
  /// Slide renders an image via [Image.asset] or [Image.network].
  image,

  /// Slide renders a solid background color.
  color,
}

/// A single onboarding slide rendered by [IntroPage]'s [PageView].
///
/// Use [IntroItem.image] for an asset/network-backed slide or
/// [IntroItem.color] for a plain color slide. [type] determines which of
/// [imagePath] / [color] is non-null.
class IntroEntity extends Equatable {
  /// Which visual variant this slide renders.
  final IntroItemType type;

  /// Image path used when [type] is [IntroItemType.image].
  final String? imagePath;

  /// Background color used when [type] is [IntroItemType.color].
  final Color? color;

  /// Headline shown below the visual.
  final String title;

  /// Supporting copy shown below [title].
  final String description;

  /// Creates an image-backed slide.
  const IntroEntity.image({
    required this.imagePath,
    required this.title,
    required this.description,
  }) : type = IntroItemType.image,
       color = null;

  /// Creates a solid-color slide.
  const IntroEntity.color({
    required this.color,
    required this.title,
    required this.description,
  }) : type = IntroItemType.color,
       imagePath = null;

  /// Default slides used when [IntroPage] is created without `items`.
  static const List<IntroEntity> sample = [
    IntroEntity.color(
      color: Color(0xFF6C63FF),
      title: 'Welcome',
      description: 'Discover everything the app has to offer.',
    ),
    IntroEntity.color(
      color: Color(0xFF00BFA6),
      title: 'Stay in sync',
      description: 'Your data follows you across every device.',
    ),
    IntroEntity.color(
      color: Color(0xFFFF6584),
      title: 'Get started',
      description: 'You are all set. Let\'s begin!',
    ),
  ];

  @override
  List<Object?> get props => [type, imagePath, color, title, description];
}
