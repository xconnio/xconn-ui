import "package:wick_ui/constants.dart";
import "package:xconn/exports.dart";

Serializer _getSerializer(String? serializerString) {
  switch (serializerString) {
    case jsonSerializer:
      return JSONSerializer();
    case cborSerializer:
      return CBORSerializer();
    case msgPackSerializer:
      return MsgPackSerializer();

    default:
      throw Exception("invalid serializer $serializerString");
  }
}

Future<Session> connect(
  String url,
  String realm,
  String serializerStr, {
  String? authid,
  String? authrole,
  String? ticket,
  String? secret,
  String? privateKey,
}) async {
  var serializer = _getSerializer(serializerStr);
  Client client;

  if (ticket != null) {
    client = Client(serializer: serializer, authenticator: TicketAuthenticator(ticket, authid ?? ""));
  } else if (secret != null) {
    client = Client(serializer: serializer, authenticator: WAMPCRAAuthenticator(secret, authid ?? "", {}));
  } else if (privateKey != null) {
    client = Client(serializer: serializer, authenticator: CryptoSignAuthenticator(authid ?? "", privateKey));
  } else {
    client = Client(serializer: serializer);
  }

  return client.connect(url, realm);
}

Server startRouter(String host, int port, List<String> realms) {
  var r = Router();
  realms.forEach(r.addRealm);
  return Server(r);
}
