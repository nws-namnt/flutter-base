import 'package:equatable/equatable.dart';

import '../generated/app_assets.dart';

class CarouselEntity extends Equatable {
  /// Image path used when [type] is [IntroItemType.image].
  final String imagePath;

  /// Headline shown below the visual.
  final String title;

  /// Supporting copy shown below [title].
  final String description;

  /// Creates an image-backed slide.
  const CarouselEntity({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  /// Default slides used when [IntroPage] is created without `items`.
  static const List<CarouselEntity> sample = [
    CarouselEntity(
      imagePath: R.imagesFox1,
      title: 'Meet the Fox',
      description: 'Clever, curious and full of surprises — just like this app.',
    ),
    CarouselEntity(
      imagePath: R.imagesFox2,
      title: 'Quick as a Fox',
      description: 'Lightning-fast performance that keeps up with your pace.',
    ),
    CarouselEntity(
      imagePath: R.imagesFox3,
      title: 'Wild & Free',
      description: 'Explore without limits. The adventure starts here.',
    ),
    CarouselEntity(
      imagePath: R.imagesFox4,
      title: 'Ready to Run',
      description: 'You\'re all set. Let the fox guide your way!',
    ),
  ];

  @override
  List<Object?> get props => [imagePath, title, description];
}
