//
//  SBTestObject.m
//  Stubbilino
//
//  Created by Robert Böhnke on 2/3/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import "SBTestObject.h"

@implementation SBTestObject

- (NSString *)string
{
    return @"Not stubbed";
}

- (NSString *)identity:(NSString *)string
{
    return string;
}

- (char)sumOf:(char)a and:(char)b
{
    return a + b;
}

@end
