//
//  StubbilinoSpecs.m
//  Specs
//
//  Created by Robb on 2/2/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import "Stubbilino.h"

SpecBegin(Stubbilino)

describe(@"Stubbilino", ^{
    it(@"Returns a stubbed object", ^{
        id<SBStub> stub = [Stubbilino stubObject:[[NSObject alloc] init]];

        expect(stub).toNot.beNil();
    });
});

describe(@"A stubbed object", ^{
    __block id originalObject;
    __block id<SBStub> stubbedObject;

    beforeEach(^{
        originalObject = [[NSObject alloc] init];
        stubbedObject = [Stubbilino stubObject:originalObject];
    });

    it(@"is identical to the original object", ^{
        expect(stubbedObject).to.beIdenticalTo(originalObject);
    });

    it(@"can stub methods", ^{
        [stubbedObject stubMethod:@selector(description)
                        withBlock:^{ return @"stubbed"; }];

        expect(stubbedObject.description).to.equal(@"stubbed");
    });

    it(@"can remove stubbed methods", ^{
        NSString *originalDescription = [originalObject description];

        [stubbedObject stubMethod:@selector(description)
                        withBlock:^{ return @"stubbed"; }];

        [stubbedObject removeStub:@selector(description)];

        expect(stubbedObject.description).to.equal(originalDescription);
    });

    it(@"does not affect other objects", ^{
        id otherObject = [[NSObject alloc] init];

        [stubbedObject stubMethod:@selector(description)
                        withBlock:^{ return @"stubbed"; }];

        expect([otherObject description]).toNot.equal(@"stubbed");
    });
});

SpecEnd