import 'package:flutter/cupertino.dart';
import 'package:retroshare/HelperFunction/identity.dart';
import 'package:retroshare/model/http_exception.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:tuple/tuple.dart';

class FriendsIdentity with ChangeNotifier {
  Map<String, Identity> _allIdentity = {};
  List<Identity> _friendsIdsList = [];
  List<Identity> _notContactIds = [];
  List<Identity> _friendsSignedIdsList = [];
  AuthToken _authToken;
  Map<String, Identity> get allIdentity => {..._allIdentity};
  List<Identity> get friendsIdsList => [..._friendsIdsList];
  List<Identity> get notContactIds => [..._notContactIds];
  List<Identity> get friendsSignedIdsList => [..._friendsSignedIdsList];

  setAuthToken(AuthToken authToken) {
    _authToken = authToken;
    notifyListeners();
  }

  Future<void> fetchAndUpdate() async {
    Tuple3<List<Identity>, List<Identity>, List<Identity>> tupleIds =
        await getAllIdentities(_authToken);
    _friendsSignedIdsList = tupleIds.item1;
    _friendsIdsList = tupleIds.item2;
    _notContactIds = tupleIds.item3;

    // ignore: prefer_for_elements_to_map_fromiterable
    _allIdentity = Map.fromIterable(
        [tupleIds.item1, tupleIds.item2, tupleIds.item3]
            .expand((x) => x)
            .toList(),
        key: (id) => id.mId,
        value: (id) => id);

    notifyListeners();
  }

  void setAllIds(Chat chat) {
    if (_allIdentity[chat.interlocutorId] == null) {
      _allIdentity = Map.from(_allIdentity)
        ..[chat.interlocutorId] = Identity(chat.interlocutorId);
    }
    notifyListeners();
  }

  Future<void> toggleContacts(String gxsId, bool type) async {
    try {
      final bool success =
          await RsIdentity.setContact(gxsId, false, _authToken);
      await fetchAndUpdate();
      if (!success) throw HttpException('CHECK CONNECTIVITY');
    } catch (e) {
      rethrow;
    }
  }
}
