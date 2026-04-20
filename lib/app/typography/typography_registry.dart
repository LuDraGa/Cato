import 'cato_typography.dart';

const availableTypographies = <CatoTypography>[
  CatoTypography(
    id: 'classic',
    name: 'Classic',
    description: 'Editorial and modern',
    serifFont: 'Source Serif 4',
    sansFont: 'Inter',
  ),
  CatoTypography(
    id: 'bookish',
    name: 'Bookish',
    description: 'Warm, purpose-built for reading',
    serifFont: 'Literata',
    sansFont: 'Inter',
  ),
  CatoTypography(
    id: 'editorial',
    name: 'Editorial',
    description: 'Tight, magazine-like',
    serifFont: 'DM Serif Display',
    sansFont: 'DM Sans',
  ),
  CatoTypography(
    id: 'rational',
    name: 'Rational',
    description: 'Precise, systematic',
    serifFont: 'IBM Plex Serif',
    sansFont: 'IBM Plex Sans',
  ),
  CatoTypography(
    id: 'gentle',
    name: 'Gentle',
    description: 'Vintage warmth, friendly',
    serifFont: 'Crimson Pro',
    sansFont: 'Karla',
  ),
  CatoTypography(
    id: 'craft',
    name: 'Craft',
    description: 'Artisan, soft and expressive',
    serifFont: 'Fraunces',
    sansFont: 'Outfit',
  ),
  CatoTypography(
    id: 'warm',
    name: 'Warm',
    description: 'Calligraphy roots, rounded',
    serifFont: 'Lora',
    sansFont: 'Rubik',
  ),
  CatoTypography(
    id: 'universal',
    name: 'Universal',
    description: 'Clean, international',
    serifFont: 'Noto Serif',
    sansFont: 'Noto Sans',
  ),
  CatoTypography(
    id: 'elegant',
    name: 'Elegant',
    description: 'English editorial, refined',
    serifFont: 'Libre Baskerville',
    sansFont: 'Lato',
  ),
  CatoTypography(
    id: 'dramatic',
    name: 'Dramatic',
    description: 'Bold contrast, striking',
    serifFont: 'Playfair Display',
    sansFont: 'Lato',
  ),
  CatoTypography(
    id: 'mono',
    name: 'Monospace',
    description: 'Developer-craft, precise',
    serifFont: 'JetBrains Mono',
    sansFont: 'JetBrains Mono',
  ),
  CatoTypography(
    id: 'delicate',
    name: 'Delicate',
    description: 'High contrast beauty, gentle',
    serifFont: 'Cormorant Garamond',
    sansFont: 'Quicksand',
  ),
];

const defaultTypographyId = 'classic';

CatoTypography typographyById(String id) {
  return availableTypographies.firstWhere(
    (t) => t.id == id,
    orElse: () => availableTypographies.first,
  );
}
