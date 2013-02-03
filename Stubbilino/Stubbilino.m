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

+ (id)methodStubForObject:(id)object selector:(SEL)selector;
+ (void)setMethodStub:(id)block forObject:(id)object selector:(SEL)selector;

@end

@implementation Stubbilino

+ (id<SBStub>)stubObject:(NSObject *)object
{
    if ([self.stubbedClasses containsObject:object.class]) {
        return (id<SBStub>)object;
    }

    void (^stubMethodWithBlock)(id, SEL, id) = ^(__unsafe_unretained NSObject *self, SEL selector, id block) {
        [Stubbilino setMethodStub:block forObject:self selector:selector];

        Method stubbedMethod = class_getInstanceMethod(object.class, selector);
        IMP oldImplementation = method_getImplementation(stubbedMethod);

        id (^invokeStub)(id, void **) = ^id(__unsafe_unretained NSObject *self, void **args) {
            id (^block)() = [Stubbilino methodStubForObject:self selector:selector];

            if (block) {
                return block(args);
            } else {
                return oldImplementation(self, selector, args);
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
        [Stubbilino setMethodStub:nil forObject:self selector:selector];
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

+ (id)methodStubForObject:(id)object selector:(SEL)selector
{
    NSMutableDictionary *associatedBlocks = objc_getAssociatedObject(object, SBAssociatedBlocks);

    return [associatedBlocks valueForKey:NSStringFromSelector(selector)];
}

+ (void)setMethodStub:(id)block forObject:(id)object selector:(SEL)selector
{
    NSMutableDictionary *associatedBlocks = objc_getAssociatedObject(self, SBAssociatedBlocks);
    if (!associatedBlocks) {
        associatedBlocks = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(object, SBAssociatedBlocks, associatedBlocks, OBJC_ASSOCIATION_RETAIN);
    }

    [associatedBlocks setValue:block forKey:NSStringFromSelector(selector)];

    if (associatedBlocks.count == 0) {
        objc_setAssociatedObject(object, SBAssociatedBlocks, nil, OBJC_ASSOCIATION_RETAIN);
    }
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
