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
#define MODULE_NAME_TRANSACTION  @"transaction"
#define FUNC_GEN_MNEMONIC  @"generateMnemonic"
#define FUNC_GEN_RSA  @"generateKeypairRSA"
#define FUNC_GEN_ECDSA  @"generateKeypairECDSA"
#define FUNC_ENC_AES  @"encryptAES"
#define FUNC_DEC_AES  @"decryptAES"
#define FUNC_ENC_DATA  @"encryptData"
#define FUNC_DEC_DATA  @"decryptData"
#define FUNC_ENTRPY_TO_MNEMONIC @"entropyToMnemonic"
#define FUNC_RAW_TXN  @"getSignedTransaction"
#define FUNC_SEND_TXN  @"sendSignedTransaction"
#define FUNC_SIGN_TXN  @"signTransaction"
#define FUNC_GET_NONCE  @"getNonce"

@interface KeyPairManager (){
    JSContext *jsContext;
    JSValue* jsSDK;
    JSValue* jsCrypto;
    JSValue* jsTx;
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
    jsTx = [jsSDK objectForKeyedSubscript:MODULE_NAME_TRANSACTION];
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

- (NSString *)getRawTxnfromData:(NSDictionary*)data {
    JSValue *value = [jsTx objectForKeyedSubscript:FUNC_RAW_TXN];
    NSArray *paras= [NSArray arrayWithObjects:data[@"from"],data[@"to"],data[@"data"],data[@"node"],data[@"key"], nil];
    NSString *tx =  [value callWithArguments:paras].toString;
    return tx;
}
-(void)getNoncefrom:(NSString*)act andNode:(NSString*)node{
    JSValue *value = [jsTx objectForKeyedSubscript:FUNC_GET_NONCE];
    NSArray *paras= [NSArray arrayWithObjects:act,node, nil];
    JSValue *nonce =  [value callWithArguments:paras];
    NSLog(@"%@",nonce);
    
}
- (NSString *)getSignedTx:(NSDictionary*)tx withKey:(NSString*)key{
    JSValue *value = [jsTx objectForKeyedSubscript:FUNC_SIGN_TXN];
    NSArray *paras= [NSArray arrayWithObjects:tx,key, nil];
    JSValue *signedTx =  [value callWithArguments:paras];
    return signedTx;
    
}
- (NSData *)dataFromHexString:(NSString *)string
{
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

-(NSString *)sendTxnfromData:(NSString*)tx{
    JSValue *value = [jsTx objectForKeyedSubscript:FUNC_SEND_TXN];
    NSArray *paras= [NSArray arrayWithObjects:tx, nil];
    NSString *txHash =  [value callWithArguments:paras].toString;
    return txHash;
}
@end

