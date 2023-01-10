import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class Crawler {
  Future getWebsiteData(String url) async {
    final response = await http.get(Uri.parse(url));
    dom.Document html = dom.Document.html(response.body);

    //   #main > div > div.Root__top-container > div.Root__main-view > div.main-view-container > div.os-host.os-host-foreign.os-theme-spotify.os-host-resize-disabled.main-view-container__scroll-node.os-host-transition.os-host-scrollbar-horizontal-hidden.os-host-overflow.os-host-overflow-y > div.os-padding > div > div > div.main-view-container__scroll-node-child > main > div > section > div.rezqw3Q4OEPB1m4rmwfw > div.contentSpacing > div > div.JUa6JJNj7R_Y3i4P8YUX > div:nth-child(2) > div:nth-child(1) > div > div.gvLrgQXBFVW6m9MscfFA > div > a > div

    // https://open.spotify.com/track/6cr9XbO2yAJgTNa6XNRINF
    // https://open.spotify.com/track/4br0nM6NdvDKMJgLj44foR

    final results = html.querySelector('body > div');
    print('Titles is null == ${results == null}');
    if (results != null) {
      String result = results.innerHtml;
      List<String> titles = result.split('https://open.spotify.com/track/');
      titles.removeAt(0);
      print('Titles length: ${titles.length}');

      for (String title in titles) {
        int startOfString = title.indexOf('>');
        int endOfString = title.indexOf('</a>');
        print(title.substring(startOfString + 1, endOfString));
        print('---------------------------------------------');
      }
    }

    // print('Count: ${titles.length}');
    // for (String title in titles) {
    //   print(title);
    // }
  }
}
