//
//  SBTest.m
//  Stubbilino
//
//  Created by Robb on 2/3/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import "SBTest.h"

@implementation SBTest

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
