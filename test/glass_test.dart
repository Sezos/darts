import 'package:darts/utils/glass.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the iOS major version', () {
    expect(GlassCapability.majorVersionOf('Version 26.0.1 (Build 23A341)'), 26);
    expect(GlassCapability.majorVersionOf('Version 18.5 (Build 22F76)'), 18);
    expect(GlassCapability.majorVersionOf('unknown'), isNull);
  });

  test('tests never use native glass unless forced', () {
    expect(GlassCapability.supported, isFalse);
    GlassCapability.debugOverride = true;
    addTearDown(() => GlassCapability.debugOverride = null);
    expect(GlassCapability.supported, isTrue);
  });
}
