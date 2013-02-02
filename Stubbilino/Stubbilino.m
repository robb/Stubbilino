//
//  Stubbilino.m
//  Stubbilino
//
//  Created by Robb on 2/2/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import <objc/runtime.h>

#import "Stubbilino.h"

static const char *SBAssociatedBlocks = "SBAssociatedBlocks";

static const char *SBTypeEncodingForMethod(const char *returnType, const char *argTypes, ...) NS_REQUIRES_NIL_TERMINATION;

@interface Stubbilino ()

+ (NSMutableSet *)stubbedClasses;

@end

@implementation Stubbilino

+ (id<SBStub>)stubObject:(NSObject *)object
{
    if ([self.stubbedClasses containsObject:object.class]) {
        return (id<SBStub>)object;
    }

    void (^stubMethodWithBlock)(id, SEL, id) = ^(__unsafe_unretained NSObject *self, SEL selector, id block) {
        NSMutableDictionary *associatedBlocks = objc_getAssociatedObject(self, SBAssociatedBlocks);

        if (!associatedBlocks) {
            associatedBlocks = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, SBAssociatedBlocks, associatedBlocks, OBJC_ASSOCIATION_RETAIN);
        }

        associatedBlocks[NSStringFromSelector(selector)] = block;
        Method stubbedMethod = class_getInstanceMethod(object.class, selector);
        IMP oldImplementation = method_getImplementation(stubbedMethod);

        id (^invokeStub)(id) = ^id(__unsafe_unretained NSObject *self) {
            NSDictionary *associatedBlocks = objc_getAssociatedObject(self, SBAssociatedBlocks);

            id (^block)() = associatedBlocks[NSStringFromSelector(selector)];
            if (block) {
                return block();
            } else {
                return oldImplementation(self, selector);
            }
        };

        class_replaceMethod(self.class,
                            selector,
                            imp_implementationWithBlock(invokeStub),
                            method_getTypeEncoding(stubbedMethod));
    };

    class_addMethod(object.class,
                    @selector(stubMethod:withBlock:),
                    imp_implementationWithBlock(stubMethodWithBlock),
                    SBTypeEncodingForMethod(@encode(id), @encode(SEL), @encode(id), nil));

    void (^removeStub)(id, SEL) = ^(__unsafe_unretained NSObject *self, SEL selector) {
        NSMutableDictionary *associatedBlocks = objc_getAssociatedObject(self, SBAssociatedBlocks);

        [associatedBlocks removeObjectForKey:NSStringFromSelector(selector)];
    };

    class_addMethod(object.class,
                    @selector(removeStub:),
                    imp_implementationWithBlock(removeStub),
                    SBTypeEncodingForMethod(@encode(id), @encode(SEL), nil));

    [self.stubbedClasses addObject:object.class];

    return (id<SBStub>)object;
}

#pragma mark - Private

+ (NSMutableSet *)stubbedClasses
{
    static NSMutableSet *stubbedClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stubbedClasses = [NSMutableSet set];
    });
    return stubbedClasses;
}

static const char *SBTypeEncodingForMethod(const char *returnType, const char *argTypes, ...)
{
    NSMutableArray *types = @[
        [NSString stringWithUTF8String:returnType],
        [NSString stringWithUTF8String:@encode(id)], // self
        [NSString stringWithUTF8String:@encode(SEL)], // cmd
    ].mutableCopy;

    va_list arguments;
    va_start(arguments, argTypes);
    const char *arg = argTypes;

    while (arg) {
        [types addObject:[NSString stringWithUTF8String:arg]];

        arg = va_arg(arguments, const char *);
    }

    va_end(arguments);

    return [[types componentsJoinedByString:@""] UTF8String];
}

@end
