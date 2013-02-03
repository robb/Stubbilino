//
//  StubbilinoSpecs.m
//  Specs
//
//  Created by Robb on 2/2/13.
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
});

describe(@"Stubbing methods", ^{
    __block SBTest<SBStub> *stubbedObject;

    beforeEach(^{
        stubbedObject = [Stubbilino stubObject:[[SBTest alloc] init]];
    });

    it(@"can stub methods", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect(stubbedObject.string).to.equal(@"Stubbed");
    });

    it(@"can access method arguments", ^{
        [stubbedObject stubMethod:@selector(identity:)
                        withBlock:^(id self, NSString *string){
                            return [[string substringFromIndex:4] capitalizedString];
                        }];

        expect([stubbedObject identity:@"Not stubbed"]).to.equal(@"Stubbed");
    });

    it(@"can remove stubbed methods", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        [stubbedObject removeStub:@selector(string)];

        expect(stubbedObject.string).to.equal(@"Not stubbed");
    });

    it(@"does not affect other objects", ^{
        SBTest *otherObject = [[SBTest alloc] init];

        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect(otherObject.string).toNot.equal(@"Stubbed");
    });

    it(@"does not affect other methods", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"Stubbed"; }];

        expect([stubbedObject identity:@"Not stubbed"]).to.equal(@"Not stubbed");
    });
});

SpecEnd