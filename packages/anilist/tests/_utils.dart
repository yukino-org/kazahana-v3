import 'package:anilist/anilist.dart';

String stringifyAnilistCharacterEdge(final AnilistCharacterEdge edge) => '''
id: ${edge.id}
role: ${edge.role}
node: ${padLeftMultilineString(stringifyAnilistCharacter(edge.node))}
'''
    .trim();

String stringifyAnilistCharacter(final AnilistCharacter character) => '''
id: ${character.id}
name: ${character.name}
nameFirst: ${character.nameFirst}
nameMiddle: ${character.nameMiddle}
nameLast: ${character.nameLast}
nameFull: ${character.nameFull}
nameNative: ${character.nameNative}
nameUserPreferred: ${character.nameUserPreferred}
image: ${character.image}
imageLarge: ${character.imageLarge}
imageMedium: ${character.imageMedium}
description: ${character.description}
gender: ${character.gender}
dateOfBirthRaw: ${character.dateOfBirthRaw}
dateOfBirth: ${character.dateOfBirth}
age: ${character.age}
bloodType: ${character.bloodType}
'''
    .trim();

String stringifyAnilistMedia(final AnilistMedia media) => '''
id: ${media.id}
idMal: ${media.idMal}
title: ${media.title}
titleRomaji: ${media.titleRomaji}
titleEnglish: ${media.titleEnglish}
titleNative: ${media.titleNative}
titleUserPreferred: ${media.titleUserPreferred}
type: ${media.type}
format: ${media.format}
description: ${media.description}
startDateRaw: ${media.startDateRaw}
startDate: ${media.startDate}
endDateRaw: ${media.endDateRaw}
endDate: ${media.endDate}
season: ${media.season}
duration: ${media.duration}
chapters: ${media.chapters}
volumes: ${media.volumes}
episodes: ${media.episodes}
coverImage: ${media.coverImage}
coverImageMedium: ${media.coverImageMedium}
coverImageLarge: ${media.coverImageLarge}
coverImageExtraLarge: ${media.coverImageExtraLarge}
coverImageColor: ${media.coverImageColor}
bannerImage: ${media.bannerImage}
genres: ${media.genres}
synonyms: ${media.synonyms}
tags: ${media.tags}
characters:
  ${media.characters.map((final AnilistCharacterEdge x) => '> ${padLeftMultilineString(stringifyAnilistCharacterEdge(x))}').join('\n')}
meanScore: ${media.meanScore}
isAdult: ${media.isAdult}
siteUrl: ${media.siteUrl}
averageScore: ${media.averageScore}
popularity: ${media.popularity}
status: ${media.status}
'''
    .trim();

String padLeftMultilineString(final String text, [final int spaces = 1]) =>
    text.split('\n').map((final String x) => '  ' * spaces + x).join('\n');
