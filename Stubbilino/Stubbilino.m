//
//  Stubbilino.m
//  Stubbilino
//
//  Created by Robb on 2/2/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import <objc/runtime.h>

#import "Stubbilino.h"

@interface Stubbilino ()

+ (NSString *)nameOfStub:(Class)class;

+ (NSMutableSet *)stubClasses;

@end

static void SBStubMethodWithBlock(__unsafe_unretained id self, SEL cmd, SEL selector, id block) {
    Method method = class_getInstanceMethod([self class], selector);

    class_replaceMethod([self class],
                        selector,
                        imp_implementationWithBlock(block),
                        method_getTypeEncoding(method));
}

static void SBRemoveStub(__unsafe_unretained id self, SEL cmd, SEL selector) {
    Method superMethod = class_getInstanceMethod(class_getSuperclass([self class]), selector);

    class_replaceMethod([self class],
                        selector,
                        method_getImplementation(superMethod),
                        method_getTypeEncoding(superMethod));
}


@implementation Stubbilino

+ (id<SBStub>)stubObject:(NSObject *)object
{
    if ([Stubbilino.stubClasses containsObject:object.class]) {
        return (id<SBStub>)object;
    }

    NSString *name = [Stubbilino nameOfStub:object.class];

    Class stubClass = objc_allocateClassPair(object.class, name.UTF8String, 0);

    class_addMethod(stubClass, @selector(stubMethod:withBlock:), (IMP)&SBStubMethodWithBlock, "v@::@");
    class_addMethod(stubClass, @selector(removeStub:), (IMP)&SBRemoveStub, "v@::");

    object_setClass(object, stubClass);

    [Stubbilino.stubClasses addObject:stubClass];

    return (id<SBStub>)object;
}

+ (id)unstubObject:(NSObject<SBStub> *)object
{
    if (![Stubbilino.stubClasses containsObject:object.class]) {
        return (id<SBStub>)object;
    }

    Class stubClass = object_getClass(object);
    Class originalClass = class_getSuperclass(stubClass);

    object_setClass(object, originalClass);

    [Stubbilino.stubClasses removeObject:stubClass];

    objc_disposeClassPair(stubClass);

    return object;
}

#pragma mark - Private

+ (NSString *)nameOfStub:(Class)class
{
    return [NSString stringWithFormat:@"SBStubOf%@", NSStringFromClass(class)];
}

+ (NSMutableSet *)stubClasses
{
    static NSMutableSet *stubClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stubClasses = [[NSMutableSet alloc] init];
    });
    return stubClasses;
}

@end
