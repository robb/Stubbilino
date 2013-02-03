//
//  SBTestObject.h
//  Stubbilino
//
//  Created by Robert Böhnke on 2/3/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBTestObject : NSObject

- (NSString *)string;
- (NSString *)identity:(NSString *)string;
- (char)sumOf:(char)a and:(char)b;

@end
