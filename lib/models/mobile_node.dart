import 'dart:typed_data';

class MobileNode {
  double latitude = 0.0;
  double longitude = 0.0;
  double altitude = 0.0;
  double speed = 0.0;
  double heading = 0.0;
  double accelerometerX = 0.0;
  double accelerometerY = 0.0;
  double accelerometerZ = 0.0;
  double gyroscopeX = 0.0;
  double gyroscopeY = 0.0;
  double gyroscopeZ = 0.0;
  double magnetometerX = 0.0;
  double magnetometerY = 0.0;
  double magnetometerZ = 0.0;
  int battery = 0;
  int millis = 0;

  MobileNode();

  Uint8List toBytes() {
    final buffer = ByteData(14 * 8 + 1 + 4);
    int offset = 0;
    buffer.setFloat64(offset, latitude, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, longitude, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, altitude, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, speed, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, heading, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, accelerometerX, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, accelerometerY, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, accelerometerZ, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, gyroscopeX, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, gyroscopeY, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, gyroscopeZ, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, magnetometerX, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, magnetometerY, Endian.little);
    offset += 8;
    buffer.setFloat64(offset, magnetometerZ, Endian.little);
    offset += 8;
    buffer.setInt8(offset, battery);
    offset += 1;
    buffer.setInt32(offset, millis, Endian.little);
    return buffer.buffer.asUint8List(0, buffer.lengthInBytes);
  }
}