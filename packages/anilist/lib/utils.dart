String stripHtmlTags(final String text) =>
    text.replaceAll(RegExp('<[^>]+>'), '');

const Map<String, String> htmlEntities = <String, String>{
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&nbsp;': ' ',
  '&copy;': '©',
  '&deg;': '°',
  '&lsquo;': "'",
  '&rsquo;': "'",
  '&sbquo;': ',',
  '&ldquo;': '"',
  '&rdquo;': '"',
  '&trade;': '™',
};

String replaceHtmlEntities(final String text) {
  String output = text;
  for (final MapEntry<String, String> x in htmlEntities.entries) {
    output = output.replaceAll(x.key, x.value);
  }
  return output;
}

String cleanHtml(final String text) => replaceHtmlEntities(stripHtmlTags(text));
