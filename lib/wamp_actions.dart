import "package:xconn/exports.dart";
import "package:xconn_ui/constants.dart";

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

  // print("serializer $serializerStr");
  // print("serializer $serializer");


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

Future<Registration> register(Session session, String procedure) {
  return session.register(procedure, (Invocation inv) {

    return Result();
  });
}

Future<Result> call(Session session, String procedure, {List? args, Map<String, dynamic>? kwargs}) {
  return session.call(procedure, args: args, kwargs: kwargs);
}

Future<Subscription> subscribe(Session session, String topic) {
  return session.subscribe(topic, (Event event) {});
}

Future<void>? publish(Session session, String topic, {List? args, Map<String, dynamic>? kwargs}) {
  return session.publish(topic, args: args, kwargs: kwargs);
}
