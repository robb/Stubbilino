//
//  SBStub.h
//  Stubbilino
//
//  Created by Robb on 2/2/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBStub <NSObject>

- (void)stubMethod:(SEL)method withBlock:(id)block;
- (void)removeStub:(SEL)method;

@end
