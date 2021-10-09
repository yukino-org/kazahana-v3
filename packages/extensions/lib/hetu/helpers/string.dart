String sliceString(final String str, final int start, final int end) =>
    str.substring(start, end == -1 ? null : end);
