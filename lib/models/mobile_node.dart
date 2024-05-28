import 'dart:typed_data';

class MobileNode {
  double latitude = 0.0;
  double longitude = 0.0;
  double altitude = 0.0;
  double speed = 0.0;
  double accelerometerX = 0.0;
  double accelerometerY = 0.0;
  double accelerometerZ = 0.0;
  double gyroscopeX = 0.0;
  double gyroscopeY = 0.0;
  double gyroscopeZ = 0.0;
  double magnetometerX = 0.0;
  double magnetometerY = 0.0;
  double magnetometerZ = 0.0;
  int millis = 0;

  MobileNode();

  Uint8List toBytes() {
    final buffer = ByteData(16 * 8 + 4); // 16 doubles (8 bytes each) + 1 int (4 bytes)
    int offset = 0;
    buffer.setFloat64(offset, latitude, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, longitude, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, altitude, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, speed, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, accelerometerX, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, accelerometerY, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, accelerometerZ, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, gyroscopeX, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, gyroscopeY, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, gyroscopeZ, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, magnetometerX, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, magnetometerY, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, magnetometerZ, Endian.big);
    offset += 8;
    buffer.setInt32(offset, millis, Endian.big);
    return buffer.buffer.asUint8List(0, buffer.lengthInBytes);
  }
}