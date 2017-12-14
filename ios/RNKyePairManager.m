
#import "RNKyePairManager.h"
#import "KeyPairManager.h"

@implementation RNKyePairManager

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()
RCT_EXPORT_METHOD(getMnemonicsResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    
    resolve([self getMnemonics]);
}
-(NSString*)getMnemonics {
    KeyPairManager *obj = [[KeyPairManager alloc] init];
    return [obj generateMnemonic];
}
@end
  
