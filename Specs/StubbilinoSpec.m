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

#import "SBTestObject.h"

SpecBegin(Stubbilino)

describe(@"A stub", ^{
    __block SBTestObject *originalObject;
    __block SBTestObject<SBStub> *stubbedObject;

    beforeEach(^{
        originalObject = [[SBTestObject alloc] init];
        stubbedObject = [Stubbilino stubObject:originalObject];
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

    it(@"cannot be stubbed twice", ^{
        Class stubbedClass = stubbedObject.class;

        SBTestObject<SBStub> *doubleStubbed = [Stubbilino stubObject:stubbedObject];

        expect(doubleStubbed.class).to.beIdenticalTo(stubbedClass);
    });
});

describe(@"Removing stubs", ^{
    __block id<SBStub> stub1;
    __block id<SBStub> stub2;

    beforeEach(^{
        stub1 = [Stubbilino stubObject:[[NSObject alloc] init]];
        stub2 = [Stubbilino stubObject:[[NSObject alloc] init]];
    });

    describe(@"individually", ^{
        it(@"should restore the original class", ^{
            [Stubbilino unstubObject:stub1];

            expect(stub1.class).to.beIdenticalTo(NSObject.class);
            expect(stub2.class).toNot.beIdenticalTo(NSObject.class);
        });
    });

    describe(@"all at once", ^{
        it(@"should restore the original class of all stubs", ^{
            [Stubbilino removeAllStubs];

            expect(stub1.class).to.beIdenticalTo(NSObject.class);
            expect(stub2.class).to.beIdenticalTo(NSObject.class);
        });
    });
});

describe(@"Instance method stubs", ^{
    __block SBTestObject<SBStub> *stubbedObject;

    beforeEach(^{
        stubbedObject = [Stubbilino stubObject:[[SBTestObject alloc] init]];
    });

    it(@"should raise an exception if the stubbed object does not respond to the selector", ^{
        expect(^{
            [stubbedObject stubMethod:@selector(notImplemented)
                            withBlock:^{ return @"Stubbed"; }];
        }).to.raise(NSInvalidArgumentException);
    });

    it(@"should invoke the stub block", ^{
        [stubbedObject stubMethod:@selector(instanceMethod)
                        withBlock:^{ return @"Stubbed"; }];

        expect(stubbedObject.instanceMethod).to.equal(@"Stubbed");
    });

    it(@"should access object arguments", ^{
        [stubbedObject stubMethod:@selector(instanceMethodWithObjectArgument:)
                        withBlock:^(id self, NSString *string){
                            return [[string substringFromIndex:4] capitalizedString];
                        }];

        expect([stubbedObject instanceMethodWithObjectArgument:@"Not stubbed"]).to.equal(@"Stubbed");
    });

    it(@"should access primitive arguments", ^{
        [stubbedObject stubMethod:@selector(instanceMethodWithPrimitiveArgument:)
                        withBlock:^(id self, char arg){
                            return arg + 1;
                        }];

        expect([stubbedObject instanceMethodWithPrimitiveArgument:2]).to.equal(3);
    });

    describe(@"when removed individually", ^{
        it(@"should not be invoked", ^{
            [stubbedObject stubMethod:@selector(instanceMethod)
                            withBlock:^{ return @"Stubbed"; }];

            [stubbedObject removeStub:@selector(instanceMethod)];

            expect(stubbedObject.instanceMethod).to.equal(@"Not stubbed");
        });
    });

    describe(@"when the object is unstubbed", ^{
        it(@"should not be invoked", ^{
            [stubbedObject stubMethod:@selector(instanceMethod)
                            withBlock:^{ return @"Stubbed"; }];

            [Stubbilino unstubObject:stubbedObject];

            expect(stubbedObject.instanceMethod).to.equal(@"Not stubbed");
        });
    });

    it(@"should not affect other objects", ^{
        SBTestObject *otherObject = [[SBTestObject alloc] init];

        [stubbedObject stubMethod:@selector(instanceMethod)
                        withBlock:^{ return @"Stubbed"; }];

        expect(otherObject.instanceMethod).toNot.equal(@"Stubbed");
    });

    it(@"should not affect other methods", ^{
        [stubbedObject stubMethod:@selector(instanceMethod)
                        withBlock:^{ return @"Stubbed"; }];

        expect([stubbedObject instanceMethodWithObjectArgument:@"Not stubbed"]).to.equal(@"Not stubbed");
    });

    it(@"should not affect other stubs", ^{
        SBTestObject<SBStub> *otherObject = [Stubbilino stubObject:[[SBTestObject alloc] init]];

        [otherObject stubMethod:@selector(instanceMethod)
                      withBlock:^{ return @"Other object"; }];

        [stubbedObject stubMethod:@selector(instanceMethod)
                        withBlock:^{ return @"Stubbed"; }];

        expect(otherObject.instanceMethod).to.equal(@"Other object");
        expect(stubbedObject.instanceMethod).to.equal(@"Stubbed");
    });
});

describe(@"Class method stubs", ^{
    __block Class<SBClassStub> stubbedClass;

    beforeEach(^{
        stubbedClass = [Stubbilino stubClass:SBTestObject.class];
    });

    afterEach(^{
        [Stubbilino unstubClass:SBTestObject.class];
    });

    it(@"should raise an exception if the stubbed class does not respond to the selector", ^{
        expect(^{
            [stubbedClass stubMethod:@selector(notImplemented)
                           withBlock:^{ return @"Stubbed"; }];
        }).to.raise(NSInvalidArgumentException);
    });

    it(@"should invoke the stub block", ^{
        [stubbedClass stubMethod:@selector(classMethod)
                       withBlock:^{ return @"Stubbed"; }];

        expect(SBTestObject.classMethod).to.equal(@"Stubbed");
    });

    it(@"should access object arguments", ^{
        [stubbedClass stubMethod:@selector(classMethodWithObjectArgument:)
                       withBlock:^(id self, NSString *string){
                           return [[string substringFromIndex:4] capitalizedString];
                       }];

        expect([SBTestObject classMethodWithObjectArgument:@"Not stubbed"]).to.equal(@"Stubbed");
    });

    it(@"should access primitive arguments", ^{
        [stubbedClass stubMethod:@selector(classMethodWithPrimitiveArgument:)
                       withBlock:^(id self, char arg){
                           return arg + 1;
                       }];

        expect([SBTestObject classMethodWithPrimitiveArgument:2]).to.equal(3);
    });

    describe(@"when removed individually", ^{
        it(@"should not be invoked", ^{
            [stubbedClass stubMethod:@selector(classMethod)
                           withBlock:^{ return @"Stubbed"; }];

            [stubbedClass removeStub:@selector(classMethod)];

            expect(SBTestObject.classMethod).to.equal(@"Not stubbed");
        });
    });

    describe(@"when the class is unstubbed", ^{
        it(@"should not be invoked", ^{
            [stubbedClass stubMethod:@selector(classMethod)
                           withBlock:^{ return @"Stubbed"; }];

            [Stubbilino unstubClass:stubbedClass];

            expect(SBTestObject.classMethod).to.equal(@"Not stubbed");
        });
    });

    it(@"should not affect other classes", ^{
        Class otherClass = [NSObject class];

        [stubbedClass stubMethod:@selector(description)
                       withBlock:^{ return @"Stubbed"; }];

        expect([otherClass description]).toNot.equal(@"Stubbed");
    });

    it(@"should not affect other methods", ^{
        [stubbedClass stubMethod:@selector(classMethod)
                       withBlock:^{ return @"Stubbed"; }];

        expect([SBTestObject classMethodWithObjectArgument:@"Not stubbed"]).to.equal(@"Not stubbed");
    });

    it(@"should not affect other stubs", ^{
        Class<SBClassStub> otherClass = [Stubbilino stubClass:NSObject.class];

        [otherClass stubMethod:@selector(description)
                      withBlock:^{ return @"Other object"; }];

        [stubbedClass stubMethod:@selector(description)
                       withBlock:^{ return @"Stubbed"; }];

        expect(NSObject.description).to.equal(@"Other object");
        expect(SBTestObject.description).to.equal(@"Stubbed");

        [Stubbilino unstubClass:otherClass];
    });
});

SpecEnd