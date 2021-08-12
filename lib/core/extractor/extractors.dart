import './animes/animeparadise_org.dart' as animeparadise_org;
import './animes/gogoanime_pe.dart' as gogoanime_pe;
import './animes/kawaiifu_com.dart' as kawaiifu_com;
import './animes/model.dart' show AnimeExtractor;
import './animes/tenshi_moe.dart' as tenshi_moe;
import './animes/twist_moe.dart' as twist_moe;
import './manga/comick_fun.dart' as comick_fun;
import './manga/fanfox_net.dart' as fanfox_net;
import './manga/mangadex_org.dart' as mangadex_org;
import './manga/mangainn_net.dart' as mangainn_net;
import './manga/manganato_com.dart' as manganato_com;
import './manga/model.dart' show MangaExtractor;
import './manga/readm_org.dart' as readm_org;
import './model.dart';

abstract class Extractors {
  static Map<String, AnimeExtractor> anime = mapName(<AnimeExtractor>[
    gogoanime_pe.GogoAnimePe(),
    kawaiifu_com.KawaiifuCom(),
    tenshi_moe.TenshiMoe(),
    animeparadise_org.AnimePradiseOrg(),
    twist_moe.TwistMoe(),
  ]);

  static Map<String, MangaExtractor> manga = mapName(<MangaExtractor>[
    mangadex_org.MangaDexOrg(),
    comick_fun.ComicKFun(),
    fanfox_net.FanFoxNet(),
    mangainn_net.MangaInnNet(),
    manganato_com.MangaNatoCom(),
    readm_org.ReadMOrg(),
  ]);
}
