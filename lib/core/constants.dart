const Duration kScryfallMinDelay = Duration(milliseconds: 100);
const int kScryfallMaxRetries = 5;

const Map<String, String> kScryfallHeaders = {
  'Accept': 'application/json',
  'User-Agent': 'MTGArtworkPicker/1.0 (Flutter; dorian.bermond@thot-it.com)',
};

const Duration kMagicVilleDelay = Duration(milliseconds: 150);
const int kMagicVilleMaxRetries = 5;
