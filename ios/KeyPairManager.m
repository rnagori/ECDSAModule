//
//  KeyPairManager.m
//  RNKyePairManager
//
//  Created by rails on 12/12/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "KeyPairManager.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define JS_FILE_NAME @"bundle"
#define JS_FILE_EXTENSION @"js"
#define JS_CALLBACK  @"response"
#define BUNDLE_NAME @"sdk";
#define MODULE_NAME_CRYPTO  @"crypto"
#define FUNC_GEN_MNEMONIC  @"generateMnemonic"
#define FUNC_GEN_RSA  @"generateKeypairRSA"
#define FUNC_GEN_ECDSA  @"generateKeypairECDSA"
#define FUNC_ENC_AES  @"encryptAES"
#define FUNC_DEC_AES  @"decryptAES"
#define FUNC_ENC_DATA  @"encryptData"
#define FUNC_DEC_DATA  @"decryptData"

@interface KeyPairManager (){
    JSContext *jsContext;
    JSValue* jsSDK;
    JSValue* jsCrypto;
}
@end

@implementation KeyPairManager
-(id)init {
    self = [super init];
    jsContext = [[JSContext alloc] init];
    [self initJsContext];
    
    return self;
}
-(void)initJsContext  {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:JS_FILE_NAME ofType:JS_FILE_EXTENSION];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:0 error:nil];
    [jsContext evaluateScript:content];
    jsSDK = [jsContext objectForKeyedSubscript:@"sdk"];
    jsCrypto = [jsSDK objectForKeyedSubscript:MODULE_NAME_CRYPTO];
}
@end

