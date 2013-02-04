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

describe(@"Stubbilino", ^{
    it(@"Returns a stubbed object", ^{
        id<SBStub> stub = [Stubbilino stubObject:[[NSObject alloc] init]];

        expect(stub).toNot.beNil();
    });
});

describe(@"A stubbed object", ^{
    __block SBTestObject *originalObject;
    __block SBTestObject<SBStub> *stubbedObject;

    beforeEach(^{
        originalObject = [[SBTestObject alloc] init];
        stubbedObject = [Stubbilino stubObject:originalObject];
    });

    it(@"is identical to the original object", ^{
        expect(stubbedObject).to.beIdenticalTo(originalObject);
    });

    it(@"has a stub class as its class", ^{
        expect(stubbedObject.class).toNot.equal(SBTestObject.class);
    });

    it(@"stays a subclass of its original class", ^{
        expect(stubbedObject).to.beKindOf(SBTestObject.class);
    });

    it(@"cannot be stubbed twice", ^{
        Class stubbedClass = stubbedObject.class;

        SBTestObject<SBStub> *doubleStubbed = [Stubbilino stubObject:stubbedObject];

        expect(doubleStubbed.class).to.beIdenticalTo(stubbedClass);
    });

    it(@"can be unstubbed", ^{
        SBTestObject *formerStub = [Stubbilino unstubObject:stubbedObject];

        expect(formerStub.class).to.equal(SBTestObject.class);
    });
});

describe(@"Instance method stubs", ^{
    __block SBTestObject<SBStub> *stubbedObject;

    beforeEach(^{
        stubbedObject = [Stubbilino stubObject:[[SBTestObject alloc] init]];
    });

    it(@"raise an exception if the stubbed object does not respond to the selector", ^{
        expect(^{
            [stubbedObject stubMethod:@selector(notImplemented)
                            withBlock:^{ return @"Stubbed"; }];
        }).to.raise(NSInvalidArgumentException);
    });

    it(@"invoke the stub block", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect(stubbedObject.string).to.equal(@"Stubbed");
    });

    it(@"can access object arguments", ^{
        [stubbedObject stubMethod:@selector(identity:)
                        withBlock:^(id self, NSString *string){
                            return [[string substringFromIndex:4] capitalizedString];
                        }];

        expect([stubbedObject identity:@"Not stubbed"]).to.equal(@"Stubbed");
    });

    it(@"can access primitive arguments", ^{
        [stubbedObject stubMethod:@selector(sumOf:and:)
                        withBlock:^(id self, char a, char b){
                            return a + b + 1;
                        }];

        expect([stubbedObject sumOf:2 and:2]).to.equal(5);
    });

    it(@"can be removed individually", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        [stubbedObject removeStub:@selector(string)];

        expect(stubbedObject.string).to.equal(@"Not stubbed");
    });

    it(@"can be removed by unstubbing the object", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        [Stubbilino unstubObject:stubbedObject];

        expect(stubbedObject.string).to.equal(@"Not stubbed");
    });

    it(@"do not affect other objects", ^{
        SBTestObject *otherObject = [[SBTestObject alloc] init];

        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect(otherObject.string).toNot.equal(@"Stubbed");
    });

    it(@"do not affect other methods", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect([stubbedObject identity:@"Not stubbed"]).to.equal(@"Not stubbed");
    });

    it(@"do not affect other stubs", ^{
        SBTestObject<SBStub> *otherObject = [Stubbilino stubObject:[[SBTestObject alloc] init]];

        [otherObject stubMethod:@selector(string)
                      withBlock:^{ return @"Other object"; }];

        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect(otherObject.string).to.equal(@"Other object");
        expect(stubbedObject.string).to.equal(@"Stubbed");
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

    it(@"raise an exception if the stubbed class does not respond to the selector", ^{
        expect(^{
            [stubbedClass stubMethod:@selector(notImplemented)
                           withBlock:^{ return @"Stubbed"; }];
        }).to.raise(NSInvalidArgumentException);
    });

    it(@"invoke the stub block", ^{
        [stubbedClass stubMethod:@selector(classMethod)
                       withBlock:^{ return @"Stubbed"; }];

        expect(SBTestObject.classMethod).to.equal(@"Stubbed");
    });

    it(@"can be removed individually", ^{
        [stubbedClass stubMethod:@selector(classMethod)
                        withBlock:^{ return @"Stubbed"; }];

        [stubbedClass removeStub:@selector(classMethod)];

        expect(SBTestObject.classMethod).to.equal(@"Not stubbed");
    });

    it(@"can be removed by unstubbing the class", ^{
        [stubbedClass stubMethod:@selector(classMethod)
                        withBlock:^{ return @"Stubbed"; }];

        [Stubbilino unstubClass:stubbedClass];

        expect(SBTestObject.classMethod).to.equal(@"Not stubbed");
    });
});

SpecEnd