String stripHtmlTags(final String text) =>
    text.replaceAll(RegExp('<[^>]+>'), '');
