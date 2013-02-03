//
//  StubbilinoSpecs.m
//  Specs
//
//  Created by Robert Böhnke on 2/2/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import "Stubbilino.h"

#import "SBTest.h"

SpecBegin(Stubbilino)

describe(@"Stubbilino", ^{
    it(@"Returns a stubbed object", ^{
        id<SBStub> stub = [Stubbilino stubObject:[[NSObject alloc] init]];

        expect(stub).toNot.beNil();
    });
});

describe(@"A stubbed object", ^{
    __block SBTest *originalObject;
    __block SBTest<SBStub> *stubbedObject;

    beforeEach(^{
        originalObject = [[SBTest alloc] init];
        stubbedObject = [Stubbilino stubObject:originalObject];
    });

    it(@"is identical to the original object", ^{
        expect(stubbedObject).to.beIdenticalTo(originalObject);
    });

    it(@"has a stub class as its class", ^{
        expect(stubbedObject.class).toNot.equal(SBTest.class);
    });

    it(@"stays a subclass of its original class", ^{
        expect(stubbedObject).to.beKindOf(SBTest.class);
    });

    it(@"cannot be stubbed twice", ^{
        Class stubbedClass = stubbedObject.class;

        SBTest<SBStub> *doubleStubbed = [Stubbilino stubObject:stubbedObject];

        expect(doubleStubbed.class).to.beIdenticalTo(stubbedClass);
    });

    it(@"can be unstubbed", ^{
        SBTest *formerStub = [Stubbilino unstubObject:stubbedObject];

        expect(formerStub.class).to.equal(SBTest.class);
    });
});

describe(@"Method stubs", ^{
    __block SBTest<SBStub> *stubbedObject;

    beforeEach(^{
        stubbedObject = [Stubbilino stubObject:[[SBTest alloc] init]];
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
        SBTest *otherObject = [[SBTest alloc] init];

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
        SBTest<SBStub> *otherObject = [Stubbilino stubObject:[[SBTest alloc] init]];

        [otherObject stubMethod:@selector(string)
                      withBlock:^{ return @"Other object"; }];

        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect(otherObject.string).to.equal(@"Other object");
        expect(stubbedObject.string).to.equal(@"Stubbed");
    });
});

SpecEnd