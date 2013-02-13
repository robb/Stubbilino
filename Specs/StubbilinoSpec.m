//
//  StubbilinoSpecs.m
//  Specs
//
//  Copyright (c) 2013 Robert Böhnke
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import "Stubbilino.h"
#import "Stubbilino+Private.h"

#import "SBTestObject.h"

SpecBegin(Stubbilino)

describe(@"A stub", ^{
    __block SBTestObject *originalObject;
    __block SBTestObject<SBStub> *stubbedObject;

    beforeEach(^{
        originalObject = [[SBTestObject alloc] init];
        stubbedObject = [Stubbilino stubObject:originalObject];
    });

    afterEach(^{
        originalObject = nil;
        stubbedObject = nil;
    });

    it(@"should be identical to the original object", ^{
        expect(stubbedObject).to.beIdenticalTo(originalObject);
    });

    it(@"should have a stub class as its class", ^{
        expect(stubbedObject.class).toNot.equal(SBTestObject.class);
    });

    it(@"should remain a subclass of its original class", ^{
        expect(stubbedObject).to.beKindOf(SBTestObject.class);
    });

    it(@"should not put side effects on other stubbed objects", ^{
        SBTestObject *otherObject = [[SBTestObject alloc] init];
        SBTestObject<SBStub> *stubbedOtherObject = [Stubbilino stubObject:otherObject];
        expect(stubbedOtherObject.class).toNot.equal(SBTestObject.class);

        [Stubbilino unstubObject:stubbedOtherObject];
        expect(stubbedOtherObject.class).to.equal(SBTestObject.class);
    });

    it(@"cannot be stubbed twice", ^{
        Class stubbedClass = stubbedObject.class;

        __weak SBTestObject<SBStub> *doubleStubbed = [Stubbilino stubObject:stubbedObject];

        expect(doubleStubbed.class).to.beIdenticalTo(stubbedClass);
    });
});

describe(@"Deallocating a stub", ^{
    it(@"should dispose of the stub class", ^{
        @autoreleasepool {
            id stub = [Stubbilino stubObject:[[NSObject alloc] init]];

            expect((NSSet *)Stubbilino.stubbedObjects).to.haveCountOf(1);

            stub = nil;
        }

        expect((NSSet *)Stubbilino.stubbedObjects).to.haveCountOf(0);
    });
});

describe(@"Removing stubs", ^{
    __block id<SBStub> stub1;
    __block id<SBStub> stub2;

    beforeEach(^{
        stub1 = [Stubbilino stubObject:[[SBTestObject alloc] init]];
        stub2 = [Stubbilino stubObject:[[SBTestObject alloc] init]];
    });

    describe(@"individually", ^{
        it(@"should restore the original class", ^{
            [Stubbilino unstubObject:stub1];

            expect(stub1.class).to.beIdenticalTo(SBTestObject.class);
            expect(stub2.class).toNot.beIdenticalTo(SBTestObject.class);
        });
    });

    describe(@"all at once", ^{
        it(@"should restore the original class of all stubs", ^{
            [Stubbilino removeAllStubs];

            expect(stub1.class).to.beIdenticalTo(SBTestObject.class);
            expect(stub2.class).to.beIdenticalTo(SBTestObject.class);
        });
    });

    it(@"should have no effect on objects that aren't stubs", ^{
        expect(^{
            [Stubbilino unstubObject:stub1];
            [Stubbilino unstubObject:stub1];
        }).toNot.raise(nil);
    });
});

static NSString * const SBStubSetupBlock = @"SBStubSetupBlock";
static NSString * const SBOtherSetupBlock = @"SBOtherSetupBlock";

static NSString * const SBUnstubBlock = @"SBUnstubBlock";

sharedExamplesFor(@"Method stubs", ^(NSDictionary *data) {
    __block id stub;
    __block id otherStub;

    __block id (^unstub)(id);

    beforeEach(^{
        id<SBStub> (^stubSetup)() = data[SBStubSetupBlock];
        stub = stubSetup();

        id<SBStub> (^otherSetup)() = data[SBOtherSetupBlock];
        otherStub = otherSetup();

        unstub = data[SBUnstubBlock];
    });

    afterEach(^{
        [Stubbilino removeAllStubs];
    });

    it(@"should raise an exception if the stubbed object does not respond to the selector", ^{
        expect(^{
            [stub stubMethod:@selector(notImplemented)
                   withBlock:^{ return @"Stubbed"; }];
        }).to.raise(NSInvalidArgumentException);
    });

    it(@"should invoke the stub block", ^{
        [stub stubMethod:@selector(method)
               withBlock:^{ return @"Stubbed"; }];

        expect([stub method]).to.equal(@"Stubbed");
    });

    it(@"should access object arguments", ^{
        [stub stubMethod:@selector(methodWithObjectArgument:)
               withBlock:^(id obj, NSString *string){
                   return [[string substringFromIndex:4] capitalizedString];
               }];

        expect([stub methodWithObjectArgument:@"Not stubbed"]).to.equal(@"Stubbed");
    });

    it(@"should access primitive arguments", ^{
        [stub stubMethod:@selector(methodWithPrimitiveArgument:)
               withBlock:^(id obj, char arg){
                   return arg + 1;
               }];

        expect([stub methodWithPrimitiveArgument:2]).to.equal(3);
    });

    describe(@"when removed individually", ^{
        it(@"should not be invoked", ^{
            [stub stubMethod:@selector(method)
                   withBlock:^{ return @"Stubbed"; }];

            [stub removeStub:@selector(method)];

            expect([stub method]).to.equal(@"Not stubbed");
        });
    });

    describe(@"when the object is unstubbed", ^{
        it(@"should not be invoked", ^{
            [stub stubMethod:@selector(method)
                   withBlock:^{ return @"Stubbed"; }];

            unstub(stub);

            expect([stub method]).to.equal(@"Not stubbed");
        });
    });

    it(@"should not affect other objects", ^{
        [stub stubMethod:@selector(description)
               withBlock:^{ return @"Stubbed"; }];

        expect([otherStub description]).toNot.equal(@"Stubbed");
    });

    it(@"should not affect other methods", ^{
        [stub stubMethod:@selector(method)
               withBlock:^{ return @"Stubbed"; }];

        expect([stub methodWithObjectArgument:@"Not stubbed"]).to.equal(@"Not stubbed");
    });

    it(@"should not affect other stubs", ^{
        [otherStub stubMethod:@selector(description)
                    withBlock:^{ return @"Other object"; }];

        [stub stubMethod:@selector(description)
               withBlock:^{ return @"Stubbed"; }];
        
        expect([otherStub description]).to.equal(@"Other object");
        expect([stub description]).to.equal(@"Stubbed");
    });
});

describe(@"Instance method stubs", ^{
    itShouldBehaveLike(@"Method stubs", @{
        SBStubSetupBlock:  ^{ return [Stubbilino stubObject:[[SBTestObject alloc] init]]; },
        SBOtherSetupBlock: ^{ return [Stubbilino stubObject:[[SBTestObject alloc] init]]; },
        SBUnstubBlock: ^(id<SBStub> stub) {
            return [Stubbilino unstubObject:stub];
        }
    });
});

describe(@"Class method stubs", ^{
    itShouldBehaveLike(@"Method stubs", @{
        SBStubSetupBlock:  ^{ return [Stubbilino stubClass:SBTestObject.class]; },
        SBOtherSetupBlock: ^{ return [Stubbilino stubClass:NSObject.class]; },

        SBUnstubBlock: ^(Class<SBClassStub> class) {
            return [Stubbilino unstubClass:class];
        }
    });
});

SpecEnd