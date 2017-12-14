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
#define FUNC_ENTRPY_TO_MNEMONIC @"entropyToMnemonic"

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
- (void)initJsContext  {
    NSString *path = [[NSBundle mainBundle] pathForResource:JS_FILE_NAME ofType:JS_FILE_EXTENSION];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [jsContext evaluateScript:content];
    jsSDK = [jsContext objectForKeyedSubscript:@"sdk"];
    jsCrypto = [jsSDK objectForKeyedSubscript:MODULE_NAME_CRYPTO];
}

- (NSString *)generateMnemonic {
    JSValue *value = [jsSDK objectForKeyedSubscript:FUNC_GEN_MNEMONIC];
    NSString* mnemonics = [[value callWithArguments:[NSArray array]] toString];
    return mnemonics;
}

- (NSString *)entropyToMnemonicsWithSeed:(NSMutableData *)data {
    JSValue *value = [jsSDK objectForKeyedSubscript:FUNC_GEN_MNEMONIC];
    NSString *mnemonics = [[value callWithArguments:[NSArray arrayWithObject:data]] toString];
    return mnemonics;
}

- (NSMutableDictionary *)generateSeed {
    NSMutableData *data = [NSMutableData dataWithLength:24];
    int result = SecRandomCopyBytes(NULL, 24, data.mutableBytes);
    NSAssert(result == 0, @"Error generating random bytes: %d", errno);
    NSString *mnemonics = [self entropyToMnemonicsWithSeed:data];
    NSMutableDictionary* walletData =  [self generateECDSAFromMnemonic:mnemonics];
    [walletData setObject:mnemonics forKey:@"mnemonic"];
    return walletData;
}

- (NSMutableDictionary *)generateECDSAFromMnemonic:(NSString *)mnemonic {
    JSValue *value = [jsSDK objectForKeyedSubscript:FUNC_GEN_ECDSA];
    NSDictionary* data = [value callWithArguments:[NSArray arrayWithObject:mnemonic]].toDictionary;
    NSMutableDictionary *dic=  [[NSMutableDictionary alloc] initWithDictionary:data];
    return dic;
}

@end

