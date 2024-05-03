import 'package:mqtt_client/mqtt_client.dart';

class Message {
  MqttPublishMessage message = MqttPublishMessage();
  String topic = "";
  String messageString = "";
  String bytes = "";
  DateTime timestamp = DateTime.now().toUtc();

  Message(this.message) {
    topic = message.variableHeader!.topicName;
    messageString = MqttPublishPayload.bytesToStringAsString(message.payload.message);
    bytes = MqttPublishPayload.bytesToString(message.payload.message);
  }

  bool stringContainsUnknownUnicode() {
    for (int i = 0; i < messageString.length; i++) {
      int codeUnit = messageString.codeUnitAt(i);
      if (codeUnit < 0x20 || codeUnit > 0x7E) {
        return true;
      }
    }
    return false;
  }
}