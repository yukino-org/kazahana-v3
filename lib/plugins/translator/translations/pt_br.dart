import 'package:utilx/utilities/countries.dart';
import 'package:utilx/utilities/languages.dart';
import '../../../core/models/translations.dart';
import 'en.dart' as en;

class Sentences extends en.Sentences {
  @override
  TranslationLocale get locale =>
      TranslationLocale(LanguageCodes.pt, LanguageCountries.br);

  @override
  String home() => 'Menu';

  @override
  String search() => 'Pesquisar';

  @override
  String settings() => 'Configurações';

  @override
  String episodes() => 'Episódios';

  @override
  String episode() => 'Episódio';

  @override
  String noValidSources() => 'Nenhuma fonte válida encontrada.';

  @override
  String prohibitedPage() => 'Você não devia estar aqui.';

  @override
  String selectPlugin() => 'Selecionar Plugin';

  @override
  String searchInPlugin(final String plugin) => 'Pesquisar em $plugin';

  @override
  String enterToSearch() => 'Digite algo para pesquisar!';

  @override
  String noResultsFound() => 'Nenhum resultado encontrado.';

  @override
  String failedToGetResults() => 'Nenhum resultado encontrado.';

  @override
  String preferences() => 'Preferências';

  @override
  String landscapeVideoPlayer() => 'Reproduzir na horizontal';

  @override
  String landscapeVideoPlayerDetail() => 'Forçar vídeo na horizontal';

  @override
  String theme() => 'Tema';

  @override
  String systemPreferredTheme() => 'Tema do Sistema';

  @override
  String defaultTheme() => 'Tema Padrão';

  @override
  String darkMode() => 'Tema Escuro';

  @override
  String close() => 'Fechar';

  @override
  String back() => 'Voltar';

  @override
  String of() => 'de';

  @override
  String chooseTheme() => 'Escolher Tema';

  @override
  String language() => 'Idioma';

  @override
  String chooseLanguage() => 'Escolher idioma';

  @override
  String anime() => 'Anime';

  @override
  String manga() => 'Mangá';

  @override
  String chapters() => 'Capítulos';

  @override
  String volumes() => 'Volumes';

  @override
  String chapter() => 'Capítulo';

  @override
  String volume() => 'Volume';

  @override
  String page() => 'Página';

  @override
  String noPagesFound() => 'Nenhum página válida encontrada.';

  @override
  String vol() => 'Vol.';

  @override
  String ch() => 'Cap.';

  @override
  String mangaReaderDirection() => 'Direção do leitor';

  @override
  String mangaReaderSwipeDirection() => 'Deslizar para';

  @override
  String horizontal() => 'Horizontal';

  @override
  String vertical() => 'Vertical';

  @override
  String leftToRight() => 'Esquerda para Direita';

  @override
  String rightToLeft() => 'Direita para Esquerda';

  @override
  String mangaReaderMode() => 'Modo de leitura';

  @override
  String list() => 'Lista';

  @override
  String previous() => 'Anterior';

  @override
  String next() => 'Próximo';

  @override
  String skipIntro() => 'Pular Intro';

  @override
  String skipIntroDuration() => 'Duração de Pular Intro';

  @override
  String seekDuration() => 'Duração de Pular';

  @override
  String seconds() => 'Segundos';

  @override
  String autoPlay() => 'Reproduzir automaticamente';

  @override
  String autoPlayDetail() =>
      'Inicia a reprodução dos vídeos de forma automática';

  @override
  String autoNext() => 'Continuar Automaticamente';

  @override
  String autoNextDetail() =>
      'Inicia a reprodução do próximo vídeo automaticamente após o término do atual';

  @override
  String speed() => 'Velocidade';

  @override
  String doubleTapToSwitchChapter() => 'Toque Duplo para Trocar de Capítulo';

  @override
  String doubleTapToSwitchChapterDetail() =>
      'Avança ou retorna um capítulo ao clicar duas vezes.';

  @override
  String tapAgainToSwitchPreviousChapter() =>
      'Toque novamente para voltar ao capítulo anterior';

  @override
  String tapAgainToSwitchNextChapter() =>
      'Toque novamente para avançar ao próximo capítulo';

  @override
  String selectSource() => 'Selecionar Fonte';

  @override
  String sources() => 'Fontes';

  @override
  String refetch() => 'Atualizar';

  @override
  String anilist() => 'AniList';

  @override
  String authenticating() => 'Autenticando';

  @override
  String successfullyAuthenticated() => 'Autenticado com Sucesso!';

  @override
  String autoAnimeFullscreen() => 'Tela Cheia Automática';

  @override
  String autoAnimeFullscreenDetail() =>
      'Entra no modo de Tela Cheia automaticamente ao assistir anime';

  @override
  String autoMangaFullscreen() => 'Tela Cheia Automática';

  @override
  String autoMangaFullscreenDetail() =>
      'Entra no modo de Tela Cheia automaticamente ao ler mangá';

  @override
  String authenticationFailed() => 'Erro na Autenticação!';

  @override
  String connections() => 'Conexões';

  @override
  String logIn() => 'Entrar';

  @override
  String view() => 'Ver';

  @override
  String logOut() => 'Sair';

  @override
  String nothingWasFoundHere() => 'Nada encontrado aqui.';

  @override
  String progress() => 'Progresso';

  @override
  String finishedOf(final int progress, final int? total) =>
      '$progress de ${total ?? '?'} concluído';

  @override
  String startedOn() => 'Iniciado em';

  @override
  String completedOn() => 'Concluído em';

  @override
  String edit() => 'Editar';

  @override
  String vols() => 'vols';

  @override
  String editing() => 'Editando';

  @override
  String save() => 'Salvar';

  @override
  String status() => 'Status';

  @override
  String noOfEpisodes() => 'Qtd de episódios';

  @override
  String noOfChapters() => 'Qtd de capítulos';

  @override
  String noOfVolumes() => 'Qtd de volumes';

  @override
  String score() => 'Nota';

  @override
  String repeat() => 'Repetir';

  @override
  String characters() => 'Personagens';

  @override
  String play() => 'Reproduzir';

  @override
  String computedAs() => 'Computado como';

  @override
  String notThis() => 'Não é esse?';

  @override
  String selectAnAnime() => 'Selecione um anime!';

  @override
  String read() => 'Ler';

  @override
  String animeSyncPercent() => 'Sincronizar como Assistido após completar (%)';

  @override
  String extensions() => 'Extensões';

  @override
  String install() => 'Instalar';

  @override
  String uninstall() => 'Desinstalar';

  @override
  String installing() => 'Instalando';

  @override
  String uninstalling() => 'Desinstalando';

  @override
  String installed() => 'Instalado';

  @override
  String by() => 'Por';

  @override
  String cancel() => 'Cancelar';

  @override
  String version() => 'Versão';

  @override
  String topAnimes() => 'Top Animes';

  @override
  String recentlyUpdated() => 'Atualizado recentemente';

  @override
  String recommendedBy(final String by) => 'Recomendado por $by';

  @override
  String seasonalAnimes() => 'Animes da Temporada';

  @override
  String selectAPluginToGetResults() =>
      'Selecione um plugin para obter resultados';

  @override
  String initializing() => 'Inicializando';

  @override
  String downloadingVersion(
    final String version,
    final String downloaded,
    final String total,
    final String percent,
  ) =>
      'Baixando $version ($downloaded / $total - $percent)';

  @override
  String unpackingVersion(final String version) => 'Descompactando $version';

  @override
  String restartingApp() => 'Reinicializando o app';

  @override
  String checkingForUpdates() => 'Procurando atualizações';

  @override
  String updatingToVersion(final String version) => 'Atualizando para $version';

  @override
  String failedToUpdate(final String err) => 'Erro ao atualizar: $err';

  @override
  String startingApp() => 'Aquecendo os motores';

  @override
  String myAnimeList() => 'MyAnimeList';

  @override
  String episodesWatched() => 'Episódios assistidos';

  @override
  String chaptersRead() => 'Capítulos lidos';

  @override
  String volumesCompleted() => 'Volumes concluídos';

  @override
  String nsfw() => 'NSFW';
}
