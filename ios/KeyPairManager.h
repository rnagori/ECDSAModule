//
//  KeyPairManager.h
//  RNKyePairManager
//
//  Created by rails on 12/12/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyPairManager : NSObject
- (NSString*)generateMnemonic;
- (NSMutableDictionary *)generateSeed;
@end

