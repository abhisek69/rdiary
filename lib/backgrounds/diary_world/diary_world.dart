enum DiaryWorld {
  simple,
  moonlightOcean,
  forestFireflies,
  butterflyGarden,
  cosmicUniverse,
  rainyStreet,
}

enum DiaryScene {
  home,
  notes,
  goals,
}

extension DiaryWorldInfo on DiaryWorld {
  String get title {
    switch (this) {
      case DiaryWorld.simple:
        return 'Theme-less';

      case DiaryWorld.moonlightOcean:
        return 'Moonlight Ocean';

      case DiaryWorld.forestFireflies:
        return 'Forest Fireflies';

      case DiaryWorld.butterflyGarden:
        return 'Butterfly Garden';

      case DiaryWorld.cosmicUniverse:
        return 'Cosmic Universe';

      case DiaryWorld.rainyStreet:
        return 'Rainy Street';
    }
  }

  String get description {
    switch (this) {
      case DiaryWorld.simple:
        return 'Clean RDiary without a visual world';

      case DiaryWorld.moonlightOcean:
        return 'A peaceful moonlit ocean';

      case DiaryWorld.forestFireflies:
        return 'A magical forest filled with fireflies';

      case DiaryWorld.butterflyGarden:
        return 'A peaceful garden filled with butterflies';

      case DiaryWorld.cosmicUniverse:
        return 'Explore your diary among the stars';

      case DiaryWorld.rainyStreet:
        return 'A peaceful street on a rainy night';
    }
  }

  bool get isAvailable {
    switch (this) {
      case DiaryWorld.simple:
      case DiaryWorld.cosmicUniverse:
        return true;

      case DiaryWorld.moonlightOcean:
      case DiaryWorld.forestFireflies:
      case DiaryWorld.butterflyGarden:
      case DiaryWorld.rainyStreet:
        return false;
    }
  }
}