// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

class WebNavigation {
  static updateCurrentWebPathQueryParm(Map<String, dynamic> newQueryParm) {
    Uri currentUri = Uri.parse(window.location.href);
    Map<String, dynamic> query = {
      ...currentUri.queryParameters,
    };
    for (String key in newQueryParm.keys) {
      if (query.containsKey(key)) {
        query.remove(key);
      }
    }
    query.addAll(newQueryParm);
    Uri newUri = Uri(
      scheme: currentUri.scheme,
      userInfo: currentUri.userInfo,
      host: currentUri.host,
      path: currentUri.path,
      queryParameters: query,
      port: currentUri.port,
      fragment: currentUri.fragment,
    );
    window.history.pushState(null, "", newUri.toString());
  }

  static updateCurrentWebPath(String path,
      {Map<String, dynamic>? newQueryParm}) {
    Uri currentUri = Uri.parse(window.location.href);
    Uri newUri = Uri(
      scheme: currentUri.scheme,
      userInfo: currentUri.userInfo,
      host: currentUri.host,
      path: path,
      queryParameters: newQueryParm,
      port: currentUri.port,
      fragment: currentUri.fragment,
    );
    window.history.pushState(null, "", newUri.toString());
  }

  static back() {
    window.history.back();
  }

  static refresh() {
    window.location.reload();
  }

  static forward() {
    window.history.forward();
  }
}
