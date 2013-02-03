//
//  Stubbilino.h
//  Stubbilino
//
//  Created by Robb on 2/2/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBStub.h"

@interface Stubbilino : NSObject

+ (id<SBStub>)stubObject:(NSObject *)object;

@end
