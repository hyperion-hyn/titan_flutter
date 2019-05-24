#import "TitanPlugin.h"
#import <titan_plugin/titan_plugin-Swift.h>

@implementation TitanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTitanPlugin registerWithRegistrar:registrar];
}
@end
