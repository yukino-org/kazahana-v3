class PageArguments {
  PageArguments({
    required final this.terms,
    required final this.autoSearch,
  });

  factory PageArguments.fromJson(final Map<String, String> json) =>
      PageArguments(
        terms: json['terms'],
        autoSearch: json['autoSearch'] == 'true',
      );

  String? terms;
  bool? autoSearch;

  Map<String, String> toJson() {
    final Map<String, String> json = <String, String>{};

    if (terms != null) {
      json['terms'] = terms!;
    }

    if (autoSearch != null) {
      json['autoSearch'] = autoSearch.toString();
    }

    return json;
  }
}
