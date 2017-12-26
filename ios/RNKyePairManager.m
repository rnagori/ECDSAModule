
#import "RNKyePairManager.h"
#import "KeyPairManager.h"
@import LocalAuthentication;

@implementation RNKyePairManager

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()
RCT_EXPORT_METHOD(getMnemonicsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSDictionary* obj = [self getMnemonics];
    resolve(obj);
}
RCT_EXPORT_METHOD(getTransactionFromData:(NSDictionary*)data Resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [self getTransactionFromData:data];
    resolve(@"");
}
RCT_EXPORT_METHOD(getRawTxnfromData:(NSDictionary*)data Resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([self getTransactionFromData:data]);
}
RCT_EXPORT_METHOD(sendTxnfromData:(NSString*)tx Resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([self sendTxnfromData:tx]);
}

-(NSMutableDictionary*)getMnemonics {
    KeyPairManager *obj = [[KeyPairManager alloc] init];
    return [obj generateSeed];
}
-(NSString *)getTransactionFromData:(NSDictionary*)data{
    KeyPairManager *obj = [[KeyPairManager alloc] init];
    NSString* tx = [obj getRawTxnfromData:data];
    // NSString *hash = [obj sendTxnfromData:tx];
    return tx;
}
-(NSString *)sendTxnfromData:(NSString*)tx{
    KeyPairManager *obj = [[KeyPairManager alloc] init];
    return [obj sendTxnfromData:tx];
}
@end


