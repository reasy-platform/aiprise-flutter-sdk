Map<String, String?> getSearchParams(String url) {
  // Get the part after `?`
  final searchParamsString = url.split('?')[1];
  // Split individual params
  final searchParamsList = searchParamsString.split('&');
  // Create a map to store the result
  // Split each param into key and value and add to the map
  final result = <String, String?>{};
  for (var searchParam in searchParamsList) {
    final splitParam = searchParam.split('=');
    result[splitParam[0]] = splitParam.length > 1 ? splitParam[1] : null;
  }
  return result;
}
