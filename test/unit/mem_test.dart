
import 'package:flutter_test/flutter_test.dart';
import 'package:titan/env.dart';
import 'package:titan/src/data/cache/memory_cache.dart';

void main() {
  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);

  test('MemoryCache get/set', () async {
    var toBeSave = '111';
    var expected = '111';
    MemoryCache.instance.setMemoryMap("test_key_1", toBeSave);
    var result = MemoryCache.instance.getMemoryMap('test_key_1');
    expect(expected, result);

    MemoryCache.instance.setMemoryMap('test_key_1', '222');
    result = MemoryCache.instance.getMemoryMap('test_key_1');
    expect(result, '222');
  });
}
