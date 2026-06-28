enum SourceProviderId {
  scryfallMagicville,
  custom;

  String get dbValue => switch (this) {
    SourceProviderId.scryfallMagicville => 'SCRYFALL_MAGICVILLE',
    SourceProviderId.custom => 'CUSTOM',
  };
}
