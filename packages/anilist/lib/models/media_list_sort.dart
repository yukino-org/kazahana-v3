import 'package:utilx/utils.dart';

enum AnilistMediaListSort {
  mediaId,
  mediaIdDesc,
  score,
  scoreDesc,
  status,
  statusDesc,
  progress,
  progressDesc,
  progressVolumes,
  progressVolumesDesc,
  repeat,
  repeatDesc,
  priority,
  priorityDesc,
  startedOn,
  startedOnDesc,
  finishedOn,
  finishedOnDesc,
  addedTime,
  addedTimeDesc,
  updatedTime,
  updatedTimeDesc,
  mediaTitleRomaji,
  mediaTitleRomajiDesc,
  mediaTitleEnglish,
  mediaTitleEnglishDesc,
  mediaTitleNative,
  mediaTitleNativeDesc,
  mediaPopularity,
  mediaPopularityDesc,
}

extension AnilistMediaListSortUtils on AnilistMediaListSort {
  String get stringify => StringCase(name).snakeCase.toUpperCase();
}
