import '../../model.dart';
import './model.dart';
import './sbplay_org.dart' as sbplay_org;
import './streamtape_com.dart' as streamtape_com;

abstract class SourceRetrievers {
  static final sources = mapName([
    sbplay_org.SbPlayOrg(),
    streamtape_com.StreamTapeCom(),
  ]);

  static SourceRetriever? match(String url) {
    for (final src in sources.values) {
      if (src.validate(url)) {
        return src;
      }
    }
    return null;
  }
}
