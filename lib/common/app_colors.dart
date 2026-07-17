import 'dart:ui';

import 'package:flutter/material.dart';

/// Semantic color palette used across the app.
///
/// All colors are compile-time constants. Prefer [Theme.of(context).colorScheme]
/// for M3 roles; use these constants only for specific, non-M3 surfaces.
///
/// Colors are grouped into variant sections by hue family.
class AppColors {
  // Base ──────────────────────────────────────────────────────────────────────
  static const pureWhite = Color(0xFFFFFFFF);
  static const pureBlack = Color(0xFF000000);

  // White variants ────────────────────────────────────────────────────────────
  static const aliceBlue = Color(0xFFF0F8FF);
  static const ghostWhite = Color(0xFFF8F8FF);
  static const whiteSmoke = Color(0xFFF5F5F5);
  static const oldLace = Color(0xFFFDF5E6);
  static const decoratorsWhite = Color(0xFFECEFEC);
  static const whitewash = Color(0xFFFEFFFC);
  static const featherWhite = Color(0xFFE7EAE5);
  static const snow = Color(0xFFFFFAFA);
  static const honeydew = Color(0xFFF0FFF0);
  static const alabasterWhite = Color(0xFFFAFAFA);
  static const antiqueWhite = Color(0xFFFAEBD7);
  static const offWhite = Color(0xFFF2F0EF);
  static const ivory = Color(0xFFFFFFE3);
  static const cream = Color(0xFFFDFBD4);
  static const seashell = Color(0xFFFFF1E7);
  static const eggshell = Color(0xFFF0EAD6);
  static const linen = Color(0xFFFAF0E6);
  static const parchment = Color(0xFFF1E9D2);

  // Black variants ────────────────────────────────────────────────────────────
  static const obsidian = Color(0xFF0B1215);
  static const lavaBlack = Color(0xFF352F36);
  static const oilBlack = Color(0xFF0C0C0C);
  static const oilSlick = Color(0xFF031602);
  static const techBlack = Color(0xFF0D0E0E);
  static const darkRaisin = Color(0xFF1A0F0F);
  static const inkBlack = Color(0xFF212122);
  static const darkCharcoal = Color(0xFF333333);
  static const premiumBlack = Color(0xFF100E09);
  static const jetBlack = Color(0xFF252525);
  static const aubergine = Color(0xFF372528);

  // Gray variants ─────────────────────────────────────────────────────────────
  static const slateGray = Color(0xFF6D8196);
  static const lightGray = Color(0xFFD3D3D3);
  static const gray = Color(0xFF898989);
  static const onyx = Color(0xFF353839);
  static const platinum = Color(0xFFD9D9D9);
  static const gunmetalGray = Color(0xFF353E43);
  static const charcoal = Color(0xFF4A4A4A);
  static const silver = Color(0xFFC4C4C4);
  static const pewter = Color(0xFF909EAE);
  static const coolGray = Color(0xFFCBCBCB);
  static const darkCoolGray = Color(0xFF8C92AC);
  static const warmGray = Color(0xFFA49A87);
  static const ebony = Color(0xFF5D6658);
  static const xanadu = Color(0xFF738678);
  static const opal = Color(0xFFA8C3BC);
  static const roseQuartz = Color(0xFFAA98A9);

  // Brown / tan variants ──────────────────────────────────────────────────────
  static const sepiaBrown = Color(0xFF704214);
  static const nude = Color(0xFFF7D9BC);
  static const roseGold = Color(0xFFDEA193);
  static const beige = Color(0xFFEDE8D0);
  static const almond = Color(0xFFEED9C4);
  static const darkBrown = Color(0xFF654321);
  static const copper = Color(0xFFC68346);
  static const ecru = Color(0xFFE0CD95);
  static const champagne = Color(0xFFF7E6CA);
  static const mocha = Color(0xFF6D3B07);
  static const sand = Color(0xFFCBBD93);
  static const cognac = Color(0xFFA2574F);
  static const tan = Color(0xFFD6B588);
  static const brown = Color(0xFF895129);
  static const bronze = Color(0xFFCE8946);
  static const cinnamon = Color(0xFFD47E30);
  static const chocolate = Color(0xFF713600);
  static const oatmeal = Color(0xFFD1B399);
  static const chestnut = Color(0xFF954535);
  static const redwood = Color(0xFFA45A52);
  static const russet = Color(0xFF80461B);
  static const pearl = Color(0xFFEAE0C8);
  static const fawn = Color(0xFFE5AA70);
  static const sienna = Color(0xFF882D17);
  static const lion = Color(0xFFDECC9C);
  static const marsala = Color(0xFF964F4C);
  static const coffee = Color(0xFF6F4E37);
  static const umber = Color(0xFF635147);
  static const taupe = Color(0xFF54463A);
  static const khaki = Color(0xFFD5C58A);
  static const buff = Color(0xFFF0DC82);
  static const ochre = Color(0xFFCC7722);

  // Red variants ──────────────────────────────────────────────────────────────
  static const chiliRed = Color(0xFFCD1C18);
  static const strawberry = Color(0xFFFA5053);
  static const carnelian = Color(0xFFB31B1B);
  static const rustyRed = Color(0xFFDA2C43);
  static const red = Color(0xFFFF2C2C);
  static const pastelRed = Color(0xFFFF746C);
  static const bloodRed = Color(0xFF780606);
  static const amaranth = Color(0xFFE83256);
  static const cinnabar = Color(0xFFE84B3D);
  static const vermilion = Color(0xFFE73121);
  static const rubyRed = Color(0xFF9B111E);
  static const cardinalRed = Color(0xFFC41E3A);
  static const crimsonRed = Color(0xFFB22222);
  static const roseRed = Color(0xFFFA003F);
  static const darkRed = Color(0xFF950606);
  static const scarlet = Color(0xFFED2100);
  static const cherry = Color(0xFFD20A2E);
  static const ruby = Color(0xFFE0115F);
  static const carmineRed = Color(0xFFFF0038);
  static const carmine = Color(0xFF960018);
  static const radicalRed = Color(0xFFFF355E);
  static const brightRed = Color(0xFFEE4B2B);
  static const alizarin = Color(0xFFDB2D43);
  static const oxblood = Color(0xFF4A0404);
  static const brickRed = Color(0xFFC04657);
  static const redBrown = Color(0xFF942222);
  static const maroon = Color(0xFF550000);
  static const wine = Color(0xFF722F37);
  static const burgundy = Color(0xFF660033);
  static const claret = Color(0xFF7F1734);
  static const bordeaux = Color(0xFF7B1B38);

  // Orange variants ───────────────────────────────────────────────────────────
  static const pastelOrange = Color(0xFFFFC067);
  static const mahogany = Color(0xFFC04000);
  static const burntOrange = Color(0xFFBE5103);
  static const pumpkin = Color(0xFFFF7518);
  static const spanishOrange = Color(0xFFE86100);
  static const neonOrange = Color(0xFFFF5C00);
  static const salmon = Color(0xFFFF7E70);
  static const orange = Color(0xFFFFA500);
  static const coral = Color(0xFFFF8559);
  static const redOrange = Color(0xFFFF4B33);
  static const burntSienna = Color(0xFFED7B58);
  static const darkOrange = Color(0xFFC76E00);
  static const apricot = Color(0xFFFFB27F);
  static const peach = Color(0xFFFFD3AC);
  static const tangerine = Color(0xFFFFA800);
  static const brightOrange = Color(0xFFFF991C);
  static const persimmon = Color(0xFFEC5800);
  static const rust = Color(0xFFB7410E);
  static const sunsetOrange = Color(0xFFFD5E53);
  static const lightOrange = Color(0xFFFFDBBB);
  static const yellowOrange = Color(0xFFFFB343);
  static const coralPink = Color(0xFFF88379);
  static const melon = Color(0xFFFDBCB4);
  static const poppy = Color(0xFFE35335);
  static const terracotta = Color(0xFFE35336);

  // Yellow / gold variants ────────────────────────────────────────────────────
  static const citrine = Color(0xFFE4D00A);
  static const straw = Color(0xFFE4D96F);
  static const lightYellow = Color(0xFFFFFFC5);
  static const mimosa = Color(0xFFF2B949);
  static const mustardYellow = Color(0xFFFFCE1B);
  static const canaryYellow = Color(0xFFFFEF00);
  static const maize = Color(0xFFFBEC5D);
  static const gold = Color(0xFFEFBF04);
  static const yellow = Color(0xFFFFDE21);
  static const darkYellow = Color(0xFFBA8E23);
  static const brightYellow = Color(0xFFFFED29);
  static const saffron = Color(0xFFF1C338);
  static const marigold = Color(0xFFEAA221);
  static const amber = Color(0xFFFFBF00);
  static const pastelYellow = Color(0xFFFFEE8C);
  static const canary = Color(0xFFFFFF99);
  static const lemon = Color(0xFFFFF700);
  static const mango = Color(0xFFFDBE02);
  static const goldenrod = Color(0xFFDAA520);
  static const metallicGold = Color(0xFFD3AF37);
  static const honeysuckle = Color(0xFFEAE86F);
  static const jasmine = Color(0xFFF8DE7E);
  static const sandDollar = Color(0xFFECD540);
  static const vanilla = Color(0xFFF3E5AB);
  static const brass = Color(0xFFB5A642);

  // Green variants ────────────────────────────────────────────────────────────
  static const greenSage = Color(0xFF98A869);
  static const forestGreen = Color(0xFF2E6F40);
  static const oliveGreen = Color(0xFF636B2F);
  static const malachite = Color(0xFF0BDA51);
  static const emerald = Color(0xFF50C878);
  static const evergreen = Color(0xFF05472A);
  static const avocadoGreen = Color(0xFF568203);
  static const springGreen = Color(0xFF00FF7F);
  static const mintGreen = Color(0xFFADEBB3);
  static const hunterGreen = Color(0xFF2C5F34);
  static const darkGreen = Color(0xFF06402B);
  static const limeGreen = Color(0xFF89F336);
  static const pastelGreen = Color(0xFF80EF80);
  static const jadeGreen = Color(0xFF00BB77);
  static const green = Color(0xFF008000);
  static const pistachio = Color(0xFF84B067);
  static const mossGreen = Color(0xFF7E8C54);
  static const neonGreen = Color(0xFF2CFF05);
  static const kellyGreen = Color(0xFF4CBB17);
  static const sage = Color(0xFFBBB791);
  static const eucalyptus = Color(0xFF44D7A8);
  static const celadon = Color(0xFFA8DCAB);
  static const lime = Color(0xFF00FF00);
  static const grassGreen = Color(0xFF7CFC00);
  static const seaGreen = Color(0xFF2E8B57);
  static const lightGreen = Color(0xFF88E788);
  static const emeraldGreen = Color(0xFF00674F);
  static const viridian = Color(0xFF40826D);
  static const yellowGreen = Color(0xFFCCFF00);
  static const aquamarine = Color(0xFF66F1C2);
  static const fernGreen = Color(0xFF4F7942);
  static const mintBlue = Color(0xFF98FBCB);
  static const armyGreen = Color(0xFF5D6532);
  static const pear = Color(0xFFD1E231);
  static const chartreuse = Color(0xFF7FFF00);

  // Teal / cyan variants ──────────────────────────────────────────────────────
  static const aqua = Color(0xFF00FFF0);
  static const cyan = Color(0xFF00FFFF);
  static const darkCyan = Color(0xFF008B8B);
  static const blueGreen = Color(0xFF00CEC8);
  static const turquoise = Color(0xFF40E0D0);
  static const darkTurquoise = Color(0xFF00CED1);
  static const turquoiseBlue = Color(0xFF00FFEF);
  static const teal = Color(0xFF069494);
  static const peacockBlue = Color(0xFF096C6C);
  static const electricBlue = Color(0xFF00F0FF);
  static const tiffanyBlue = Color(0xFF81D8D0);
  static const seafoam = Color(0xFF8DDCDC);
  static const verdigris = Color(0xFF43B3AE);
  static const lightSeaGreen = Color(0xFF20B2AA);
  static const celeste = Color(0xFFB2FFFF);

  // Blue variants ─────────────────────────────────────────────────────────────
  static const cerulean = Color(0xFF007BA7);
  static const steelBlue = Color(0xFF4682B4);
  static const trueBlue = Color(0xFF2D68C4);
  static const mediumBlue = Color(0xFF0000CD);
  static const royalBlue = Color(0xFF305CDE);
  static const mistyBlue = Color(0xFFB5C7EB);
  static const skyBlue = Color(0xFF82C8E5);
  static const cornflowerBlue = Color(0xFF6395EE);
  static const powderBlue = Color(0xFFB8E3E9);
  static const babyBlue = Color(0xFF8FD9FB);
  static const cobaltBlue = Color(0xFF0047AB);
  static const pastelBlue = Color(0xFFB3EBF2);
  static const lightBlue = Color(0xFF90D5FF);
  static const blue = Color(0xFF0000FF);
  static const slateBlue = Color(0xFF557C99);
  static const columbiaBlue = Color(0xFFC4D8E2);
  static const cadetBlue = Color(0xFF5F9EA0);
  static const midnightBlue = Color(0xFF272757);
  static const neonBlue = Color(0xFF2323FF);
  static const navyBlue = Color(0xFF000080);
  static const blueGray = Color(0xFF6A89A7);
  static const glaucous = Color(0xFF678DC6);
  static const serenity = Color(0xFFB3CEE5);
  static const chambray = Color(0xFFA4C8E1);
  static const ultramarineBlue = Color(0xFF4166F5);
  static const azure = Color(0xFF007FFF);
  static const sapphireBlue = Color(0xFF0F52BA);
  static const zaffre = Color(0xFF0014A8);
  static const darkBlue = Color(0xFF111184);
  static const denimColor = Color(0xFF1560BD);

  // Purple / violet variants ──────────────────────────────────────────────────
  static const violet = Color(0xFF7F00FF);
  static const orchid = Color(0xFFED80E9);
  static const plum = Color(0xFF8E4585);
  static const neonPurple = Color(0xFF8A00C4);
  static const mauvePink = Color(0xFFE0B0FF);
  static const purpleBlue = Color(0xFF6A5ACD);
  static const darkMagenta = Color(0xFF8B008B);
  static const lightPurple = Color(0xFFDAB1DA);
  static const mauve = Color(0xFFE0AFFF);
  static const purple = Color(0xFF9D00FF);
  static const lilac = Color(0xFFA47DAB);
  static const royalPurple = Color(0xFF6C3BAA);
  static const indigo = Color(0xFF560591);
  static const darkPurple = Color(0xFF341539);
  static const electricPurple = Color(0xFFBF00FF);
  static const blueViolet = Color(0xFF8A2BE2);
  static const pastelPurple = Color(0xFFB39EB5);
  static const byzantium = Color(0xFF702963);
  static const amethyst = Color(0xFF9966CC);
  static const heliotrope = Color(0xFFDF73FF);
  static const purplePlum = Color(0xFF9C51B6);
  static const wisteria = Color(0xFFC9A0DC);
  static const thistle = Color(0xFFD8BFD8);
  static const lavender = Color(0xFFD3D3FF);
  static const periwinkle = Color(0xFFCCCCFF);
  static const blueIris = Color(0xFF5A4FCF);
  static const eggplant = Color(0xFF614051);
  static const darkViolet = Color(0xFF9400D3);
  static const redViolet = Color(0xFFC71585);
  static const velvet = Color(0xFF750851);

  // Pink / magenta variants ───────────────────────────────────────────────────
  static const darkPink = Color(0xFFC11C84);
  static const carnationPink = Color(0xFFFFA6C9);
  static const orchidPink = Color(0xFFF2BDCD);
  static const flamingoPink = Color(0xFFFC8EAC);
  static const hotMagenta = Color(0xFFFF1DCE);
  static const lightPink = Color(0xFFFFB5C0);
  static const neonPink = Color(0xFFFF13F0);
  static const blush = Color(0xFFDE5D83);
  static const rose = Color(0xFFFF1D8D);
  static const fuchsia = Color(0xFFFF00FF);
  static const dustyRose = Color(0xFFDCA1A1);
  static const pink = Color(0xFFFF8DA1);
  static const blushPink = Color(0xFFFF7782);
  static const magenta = Color(0xFFFD3DB5);
  static const mulberry = Color(0xFFC54B8C);
  static const softPink = Color(0xFFE89EB8);
  static const hotPink = Color(0xFFFF46A2);
  static const pastelPink = Color(0xFFFFC5D3);
  static const boysenberry = Color(0xFF873260);
  static const deepPink = Color(0xFFFF1493);
  static const neonMagenta = Color(0xFFFF0090);
  static const cerise = Color(0xFFDE3163);
  static const raspberry = Color(0xFFE30B5D);
  static const razzmatazz = Color(0xFFE3256B);
  static const puce = Color(0xFFE491A6);
  static const salmonPink = Color(0xFFFF91A4);
  static const watermelon = Color(0xFFFC6C85);
  static const violetRed = Color(0xFFF75394);
  static const redPurple = Color(0xFFE40078);
  static const rosewater = Color(0xFFFFD6D1);
}
