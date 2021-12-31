import 'package:utilx/utilities/locale.dart';
import './en.dart' as en;

class Sentences extends en.Sentences {
  @override
  Locale get locale => Locale(LanguageCodes.es);

  @override
  String home() => 'Inicio';

  @override
  String search() => 'Buscar';

  @override
  String settings() => 'Ajustes';

  @override
  String episodes() => 'Episodios';

  @override
  String episode() => 'Episódio';

  @override
  String noValidSources() => 'Ninguna fuente válida encontrada.';

  @override
  String prohibitedPage() => 'No deberías de estar aquí.';

  @override
  String selectPlugin() => 'Seleccionar Plugin';

  @override
  String searchInPlugin(final String plugin) => 'Buscar en $plugin';

  @override
  String enterToSearch() => 'Escriba algo para buscar!';

  @override
  String noResultsFound() => 'No se encontró ningún resultado.';

  @override
  String failedToGetResults() => 'No se encontró ningún resultado.';

  @override
  String preferences() => 'Preferencias';

  @override
  String landscapeVideoPlayer() => 'Reproducción de Vídeo Apaisado';

  @override
  String landscapeVideoPlayerDetail() => 'Fuerza el vídeo para que se vea apaisado.';

  @override
  String theme() => 'Tema';

  @override
  String systemPreferredTheme() => 'Tema del Sistema';

  @override
  String defaultTheme() => 'Tema por Defecto';

  @override
  String darkMode() => 'Tema Oscuro';

  @override
  String close() => 'Cerrar';

  @override
  String back() => 'Volver';

  @override
  String of() => 'de';

  @override
  String chooseTheme() => 'Cambiar Tema';

  @override
  String language() => 'Idioma';

  @override
  String chooseLanguage() => 'Cambiar idioma';

  @override
  String anime() => 'Anime';

  @override
  String manga() => 'Manga';

  @override
  String chapters() => 'Capítulos';

  @override
  String volumes() => 'Volúmenes';

  @override
  String chapter() => 'Capítulo';

  @override
  String volume() => 'Volúmen';

  @override
  String page() => 'Página';

  @override
  String noPagesFound() => 'Ninguna página válida encontrada.';

  @override
  String vol() => 'Vol.';

  @override
  String ch() => 'Cap.';

  @override
  String mangaReaderDirection() => 'Dirección del lector';

  @override
  String mangaReaderSwipeDirection() => 'Sentido de deslizamiento del lector';

  @override
  String horizontal() => 'Horizontal';

  @override
  String vertical() => 'Vertical';

  @override
  String leftToRight() => 'De Izquierda a Derecha';

  @override
  String rightToLeft() => 'De Derecha a Izquierda';

  @override
  String mangaReaderMode() => 'Modo de lectura';

  @override
  String list() => 'Lista';

  @override
  String previous() => 'Anterior';

  @override
  String next() => 'Próximo';

  @override
  String skipIntro() => 'Saltar Intro';

  @override
  String skipIntroDuration() => 'Duración del salto de la Intro';

  @override
  String seekDuration() => 'Duración del salto';

  @override
  String seconds() => 'Segundos';

  @override
  String autoPlay() => 'Reproducir automáticamente';

  @override
  String autoPlayDetail() =>
      'Inicia la reproducción de los vídeos de forma automática';

  @override
  String autoNext() => 'Continuar Automáticamente';

  @override
  String autoNextDetail() =>
      'Inicia la reproducción del próximo vídeo automáticamente después de que termine el actual';

  @override
  String speed() => 'Velocidad';

  @override
  String doubleTapToSwitchChapter() => 'Doble Toque para Cambiar de Capítulo';

  @override
  String doubleTapToSwitchChapterDetail() =>
      'Cambia al capítulo anterior o al siguiente sólo cuando se pulsa dos veces';

  @override
  String tapAgainToSwitchPreviousChapter() =>
      'Toca nuevamente para volver al capítulo anterior';

  @override
  String tapAgainToSwitchNextChapter() =>
      'Toca nuevamente para avanzar al próximo capítulo';

  @override
  String selectSource() => 'Seleccionar Fuente';

  @override
  String sources() => 'Fuentes';

  @override
  String refetch() => 'Actualizar';

  @override
  String anilist() => 'AniList';

  @override
  String authenticating() => 'Autenticando';

  @override
  String successfullyAuthenticated() => 'Autenticación Exitosa!';

  @override
  String autoAnimeFullscreen() => 'Pantalla completa automática (anime)';

  @override
  String autoAnimeFullscreenDetail() =>
      'Entra en modo pantalla completa automáticamente al estar viendo anime';

  @override
  String autoMangaFullscreen() => 'Pantalla completa automática (manga)';

  @override
  String autoMangaFullscreenDetail() =>
      'Entra en modo pantalla completa automáticamente al estar leyendo manga';

  @override
  String authenticationFailed() => 'Error en la autenticación!';

  @override
  String connections() => 'Conexiones';

  @override
  String logIn() => 'Entrar';

  @override
  String view() => 'Ver';

  @override
  String logOut() => 'Salir';

  @override
  String nothingWasFoundHere() => 'No se ha encontrado nada aquí.';

  @override
  String progress() => 'Progreso';

  @override
  String finishedOf(final int progress, final int? total) =>
      '$progress de ${total ?? '?'} terminado';

  @override
  String startedOn() => 'Iniciado en';

  @override
  String completedOn() => 'Terminado en';

  @override
  String edit() => 'Editar';

  @override
  String vols() => 'vols';

  @override
  String editing() => 'Editando';

  @override
  String save() => 'Guardar';

  @override
  String status() => 'Estado';

  @override
  String noOfEpisodes() => 'Nº de episodios';

  @override
  String noOfChapters() => 'Nº de capítulos';

  @override
  String noOfVolumes() => 'Nº de volúmenes';

  @override
  String score() => 'Puntuación';

  @override
  String repeat() => 'Repetir';

  @override
  String characters() => 'Personajes';

  @override
  String play() => 'Reproducir';

  @override
  String computedAs() => 'Registrado como';

  @override
  String notThis() => '¿No es?';

  @override
  String selectAnAnime() => 'Seleccione un anime!';

  @override
  String read() => 'Leer';

  @override
  String animeSyncPercent() => 'Marcar como Visto después de Completar (%)';

  @override
  String extensions() => 'Extensiones';

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
  String version() => 'Versión';

  @override
  String topAnimes() => 'Top Animes';

  @override
  String recentlyUpdated() => 'Actualizados recientemente';

  @override
  String recommendedBy(final String by) => 'Recomendado por $by';

  @override
  String seasonalAnimes() => 'Animes de la Temporada';

  @override
  String selectAPluginToGetResults() =>
      'Seleccione un plugin para obtener resultados';

  @override
  String initializing() => 'Inicializando';

  @override
  String downloadingVersion(
    final String version,
    final String downloaded,
    final String total,
    final String percent,
  ) =>
      'Descargando $version ($downloaded / $total - $percent)';

  @override
  String unpackingVersion(final String version) => 'Desempaquetando $version';

  @override
  String restartingApp() => 'Reiniciando la app';

  @override
  String checkingForUpdates() => 'Buscando actualizaciones';

  @override
  String updatingToVersion(final String version) => 'Actualizando para $version';

  @override
  String failedToUpdate(final String err) => 'Error al actualizar: $err';

  @override
  String startingApp() => 'Arrancando motores';

  @override
  String myAnimeList() => 'MyAnimeList';

  @override
  String episodesWatched() => 'Episodios completados';

  @override
  String chaptersRead() => 'Capítulos leídos';

  @override
  String volumesCompleted() => 'Volúmenes acabados';

  @override
  String nsfw() => 'NSFW';

  @override
  String restartAppForChangesToTakeEffect() =>
      'Reinicia la app para que los cambios surtan efecto';

  @override
  String copyError() => 'Error al copiar';

  @override
  String somethingWentWrong() => 'Algo salió mal.';

  @override
  String unknownExtension(final String name) => 'Extensión desconocida: $name';

  @override
  String about() => 'Acerca de';

  @override
  String copyLogsToClipboard() => 'Copiar registros al portapapeles';

  @override
  String copiedLogsToClipboard() => 'Registros copiados al portapapeles';

  @override
  String github() => 'GitHub';

  @override
  String patreon() => 'Patreon';

  @override
  String website() => 'Sitio Web';

  @override
  String wiki() => 'Wiki';

  @override
  String discord() => 'Discord';

  @override
  String developers() => 'Desarrolladores';

  @override
  String reportABug() => 'Informar de un error';

  @override
  String disableAnimations() => 'Desactivar animaciones';

  @override
  String keyboardShortcuts() => 'Atajos de Teclado';

  @override
  String waitingForKeyStrokes() => 'Esperando a que se pulsen teclas...';

  @override
  String playPause() => 'Reanudar/Pausar';

  @override
  String fullscreen() => 'Pantalla completa';

  @override
  String seekBackward() => 'Ir hacia atrás';

  @override
  String seekForward() => 'Ir hacia delante';

  @override
  String goBack() => 'Volver atrás';

  @override
  String previousEpisode() => 'Episodio anterior';

  @override
  String nextEpisode() => 'Episodio siguiente';

  @override
  String ignoreBadHttpSslCertificates() => 'Ignorar los certificados SSL HTTP defectuosos';

  @override
  String copiedErrorToClipboard() => 'Error copiado al portapapeles';
}
