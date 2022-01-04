import 'package:utilx/utilities/locale.dart';
import '../translations.dart';

class Sentences extends TranslationSentences {
  @override
  Locale get locale => const Locale(LanguageCodes.en);

  @override
  String home() => 'ホーム';

  @override
  String search() => '検索';

  @override
  String settings() => '設定';

  @override
  String episodes() => 'エピソード';

  @override
  String episode(final String episode) => '第$episode話';

  @override
  String noValidSources() => '有効なソースが見つかりませんでした。';

  @override
  String prohibitedPage() => "アクセスが拒否されました。";

  @override
  String selectPlugin() => 'プラグインを選択';

  @override
  String searchInPlugin(final String plugin) => '$plugin で検索';

  @override
  String enterToSearch() => '検索窓に入力して検索できます';

  @override
  String noResultsFound() => '結果が見つかりませんでした。';

  @override
  String failedToGetResults() => '結果の取得に失敗しました。';

  @override
  String preferences() => '一般';

  @override
  String landscapeVideoPlayer() => '横画面の動画プレイヤー';

  @override
  String landscapeVideoPlayerDetail() =>
      '動画の再生時に強制的に横画面で表示するようにします';

  @override
  String theme() => 'テーマ';

  @override
  String systemPreferredTheme() => 'システム設定に従う';

  @override
  String defaultTheme() => '規定のテーマ';

  @override
  String darkMode() => 'ダークテーマ';

  @override
  String close() => '閉じる';

  @override
  String back() => '戻る';

  @override
  String of(final String prefix, final String suffix) => '第$prefix話/$suffix';

  @override
  String chooseTheme() => 'テーマを選択';

  @override
  String language() => '言語';

  @override
  String chooseLanguage() => '言語を選択';

  @override
  String anime() => 'アニメ';

  @override
  String manga() => 'マンガ';

  @override
  String chapters() => 'チャプター';

  @override
  String volumes() => '巻';

  @override
  String chapter(final String chapter) => '第$chapter章';

  @override
  String volume(final String volume) => '第$volume巻';

  @override
  String page() => 'ページ';

  @override
  String noPagesFound() => '正しいページが見つかりませんでした。';

  @override
  String vol() => 'Vol.'; //?

  @override
  String ch() => 'Ch.'; //?

  @override
  String mangaReaderDirection() => '漫画リーダーの向き';

  @override
  String mangaReaderSwipeDirection() => '漫画リーダーのスワイプ方向を指定します';

  @override
  String horizontal() => '横方向';

  @override
  String vertical() => '縦方向';

  @override
  String leftToRight() => '左から右';

  @override
  String rightToLeft() => '右から左';

  @override
  String mangaReaderMode() => '漫画リーダーのモード';

  @override
  String list() => 'リスト';

  @override
  String previous() => '前へ';

  @override
  String next() => '次へ';

  @override
  String skipIntro() => 'イントロをスキップ';

  @override
  String skipIntroDuration() => 'イントロ時間をスキップ';

  @override
  String seekDuration() => 'シーク時間';

  @override
  String seconds() => '秒';

  @override
  String autoPlay() => '自動再生';

  @override
  String autoPlayDetail() => '動画の再生を自動的に開始します';

  @override
  String autoNext() => '自動で次の動画を開く';

  @override
  String autoNextDetail() =>
      '現在の動画の終了後に、自動的に次のビデオの再生を開始します';

  @override
  String speed() => '速度';

  @override
  String doubleTapToSwitchChapter() => 'ダブルタップでチャプターを切り替え';

  @override
  String doubleTapToSwitchChapterDetail() =>
      'ダブルタップ時に前または次のチャプターに切り替えます';

  @override
  String tapAgainToSwitchPreviousChapter() =>
      'もう一度タップすると前のチャプターに移動します';

  @override
  String tapAgainToSwitchNextChapter() => 'もう一度タップすると次のチャプターに移動します';

  @override
  String selectSource() => 'ソースを選択';

  @override
  String sources() => 'ソース';

  @override
  String refetch() => '再取得';

  @override
  String anilist() => 'AniList';

  @override
  String authenticating() => '認証中';

  @override
  String successfullyAuthenticated() => '正常に認証されました!';

  @override
  String autoAnimeFullscreen() => '自動でフルスクリーン再生';

  @override
  String autoAnimeFullscreenDetail() =>
      'アニメの再生時に自動でフルスクリーン表示します';

  @override
  String autoMangaFullscreen() => '自動でフルスクリーン表示';

  @override
  String autoMangaFullscreenDetail() =>
      'マンガの表示時に自動でフルスクリーン表示します';

  @override
  String authenticationFailed() => '認証に失敗しました!';

  @override
  String connections() => '接続';

  @override
  String logIn() => 'ログイン';

  @override
  String view() => '表示';

  @override
  String logOut() => 'ログアウト';

  @override
  String nothingWasFoundHere() => '何も見つかりませんでした。';

  @override
  String progress() => '進行';

  @override
  String finishedOf(final int progress, final int? total) =>
      '$progress / ${total ?? '?'} 完了';

  @override
  String startedOn() => '開始時:';

  @override
  String completedOn() => '完了時:';

  @override
  String edit() => '編集';

  @override
  String vols() => '巻';

  @override
  String editing() => '編集';

  @override
  String save() => '保存';

  @override
  String status() => 'ステータス';

  @override
  String noOfEpisodes() => 'エピソード数';

  @override
  String noOfChapters() => 'チャプター数';

  @override
  String noOfVolumes() => '巻数';

  @override
  String score() => 'スコア';

  @override
  String repeat() => '繰り返し';

  @override
  String characters() => 'キャラクター';

  @override
  String play() => '再生';

  @override
  String computedAs() => 'Computed as'; //?

  @override
  String notThis() => 'これではありませんか？';

  @override
  String selectAnAnime() => 'アニメを選択してください';

  @override
  String read() => '読む';

  @override
  String animeSyncPercent() => '完了後同期する'; //?

  @override
  String extensions() => 'プラグイン';

  @override
  String install() => 'インストール';

  @override
  String uninstall() => 'アンインストール';

  @override
  String installing() => 'インストール中';

  @override
  String uninstalling() => 'アンインストール中';

  @override
  String installed() => 'インストール済み';

  @override
  String by() => 'By'; //?

  @override
  String cancel() => 'キャンセル';

  @override
  String version() => 'バージョン';

  @override
  String topAnimes() => '人気のアニメ';

  @override
  String recentlyUpdated() => '最近の更新';

  @override
  String recommendedBy(final String by) => '$by によっておすすめされています';

  @override
  String seasonalAnimes() => '今季のアニメ';

  @override
  String selectAPluginToGetResults() => 'プラグインを選択して結果を取得します';

  @override
  String initializing() => '準備中';

  @override
  String downloadingVersion(
    final String version,
    final String downloaded,
    final String total,
    final String percent,
  ) =>
      'ダウンロード中 $version ($downloaded / $total - $percent)';

  @override
  String unpackingVersion(final String version) => '$version を展開中';

  @override
  String restartingApp() => 'アプリを再起動中';

  @override
  String checkingForUpdates() => 'アップデートを確認中';

  @override
  String updatingToVersion(final String version) => '$version にアップデート中';

  @override
  String failedToUpdate(final String err) => 'アップデートに失敗しました: $err';

  @override
  String startingApp() => 'アプリを開始中';

  @override
  String myAnimeList() => 'MyAnimeList';

  @override
  String episodesWatched() => '視聴したエピソード';

  @override
  String chaptersRead() => '読み終わったチャプター';

  @override
  String volumesCompleted() => '読み終わった巻';

  @override
  String nsfw() => 'NSFW';

  @override
  String restartAppForChangesToTakeEffect() =>
      'アプリケーションを再起動すると変更が反映されます';

  @override
  String copyError() => 'エラーをコピー';

  @override
  String somethingWentWrong() => '何か問題が発生しました';

  @override
  String unknownExtension(final String name) => '未知のプラグイン: $name';

  @override
  String about() => 'Yukinoについて';

  @override
  String copyLogsToClipboard() => 'クリップボードにログをコピー';

  @override
  String copiedLogsToClipboard() => 'クリップボードにログがコピーされました';

  @override
  String github() => 'GitHub';

  @override
  String patreon() => 'Patreon';

  @override
  String website() => 'ウェブサイト';

  @override
  String wiki() => 'Wiki';

  @override
  String discord() => 'Discord';

  @override
  String developers() => '開発者';

  @override
  String reportABug() => 'バグを報告';

  @override
  String disableAnimations() => 'アニメーションを無効化';

  @override
  String keyboardShortcuts() => 'キーボードショートカット';

  @override
  String waitingForKeyStrokes() => 'キーストロークを待機しています...';

  @override
  String playPause() => '再生/停止';

  @override
  String fullscreen() => 'フルスクリーン';

  @override
  String seekBackward() => '巻き戻し';

  @override
  String seekForward() => '先送り';

  @override
  String goBack() => '戻る';

  @override
  String previousEpisode() => '前のエピソード';

  @override
  String nextEpisode() => '次のエピソード';

  @override
  String ignoreBadHttpSslCertificates() => 'SSL証明書の検証をスキップする';

  @override
  String copiedErrorToClipboard() => 'クリップボードにエラーがコピーされました';

  @override
  String noMoreChaptersLeft() => 'これ以上チャプターはありません';

  @override
  String imageSize() => '画像サイズ';

  @override
  String imageCustomWidth() => 'カスタム画像サイズ';

  @override
  String custom() => 'カスタム';

  @override
  String fitWidth() => '横幅を合わせる';

  @override
  String fitHeight() => '高さを合わせる';

  @override
  String previousPage() => '前のページ';

  @override
  String nextPage() => '次のページ';

  @override
  String previousChapter() => '前のチャプター';

  @override
  String nextChapter() => '次のチャプター';
}
