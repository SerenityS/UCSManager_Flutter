import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:get_storage/get_storage.dart';
import 'package:requests/requests.dart';

class PIUApi {
  final _pref = GetStorage();

  final String apiUrl = 'http://www.piugame.com/piu.ucs/ucs.share/ucs.share.ajax.php';
  final String myUcsUrl = 'http://www.piugame.com/piu.ucs/ucs.my_ucs/ucs.my_upload.php';

  Future _saveUCSDataPref(songTitleList, stepArtistList, ucsNoList) async {
    List<String> songTitleStringList = songTitleList.cast<String>();
    List<String> stepArtistStringList = stepArtistList.cast<String>();
    List<String> ucsNoStringList = ucsNoList.cast<String>();

    await _pref.write('songTitleList', songTitleStringList);
    await _pref.write('stepArtistList', stepArtistStringList);
    await _pref.write('ucsNoList', ucsNoStringList);
  }

  Future<String> addUCS(ucsNo) async {
    var response = await Requests.get(
      apiUrl,
      queryParameters: <String, String>{
        'ucs_id': ucsNo,
        'work_type': 'AddtoUCSSLOT',
      },
    );
    return response.content();
  }

  Future<String> buildUCS() async {
    var ucsNoList = _pref.read('ucsNoList');
    if (ucsNoList.length != 0) {
      var response = await Requests.get(
        apiUrl,
        queryParameters: <String, String>{
          'work_type': 'MakeUCSPack',
        },
      );
      return response.content();
    }
    return 'You Can\'t Build when You Don\'t have Any UCS.';
  }

  Future<int> getUCSData() async {
    var songTitle;
    var stepArtist;
    var ucsNo;

    var songTitleList = [];
    var stepArtistList = [];
    var ucsNoList = [];

    var response = await Requests.get(myUcsUrl);
    dom.Document document = parser.parse(response.content());
    var s = document.getElementsByClassName('my_list');

    for (var i = 0;
        i < s[1].getElementsByClassName('my_list_title').length;
        i++) {
      songTitle = s[1]
          .getElementsByClassName('my_list_title')[i]
          .innerHtml
          .replaceAll('<br>', '');
      stepArtist = s[1]
          .getElementsByClassName('my_list_rating')[i]
          .innerHtml
          .replaceAll('<br>', '');
      ucsNo = s[1]
          .getElementsByClassName('ucs_slot_delete')[i]
          .attributes['data-ucs_no']
          .toString();
      songTitleList.insert(i, songTitle);
      stepArtistList.insert(i, stepArtist);
      ucsNoList.insert(i, ucsNo);
    }
    await _saveUCSDataPref(songTitleList, stepArtistList, ucsNoList);
    return s[1].getElementsByClassName('my_list_title').length;
  }

  Future<String> removeUCS(index) async {
    var ucsNoList = _pref.read('ucsNoList');
    var response = await Requests.get(
      apiUrl,
      queryParameters: <String, String>{
        'data_no': ucsNoList[index],
        'work_type': 'RemovetoUCSSLOT2',
      },
    );
    return response.content();
  }

  Future removeAllUCS() async {
    var ucsNoList = _pref.read('ucsNoList');
    if (ucsNoList.length != 0) {
      for (var i = 0; i < ucsNoList.length; i++) {
        await Requests.get(
          apiUrl,
          queryParameters: <String, String>{
            'data_no': ucsNoList[i],
            'work_type': 'RemovetoUCSSLOT2',
          },
        );
      }
    } else {
      return false;
    }
  }
}
