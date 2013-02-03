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

    it(@"can stub methods", ^{
        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"stubbed"; }];

        expect(stubbedObject.string).to.equal(@"stubbed");
    });

    it(@"can remove stubbed methods", ^{
        NSString *originalString = originalObject.string;

        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"stubbed"; }];

        [stubbedObject removeStub:@selector(string)];

        expect(stubbedObject.string).to.equal(originalString);
    });

    it(@"does not affect other objects", ^{
        SBTest *otherObject = [[SBTest alloc] init];

        [stubbedObject stubMethod:@selector(string)
                        withBlock:^{ return @"stubbed"; }];

        expect(otherObject.string).toNot.equal(@"stubbed");
    });
});

SpecEnd