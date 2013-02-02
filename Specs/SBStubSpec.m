//
//  SBStubSpec.m
//  Stubbilino
//
//  Created by Robb on 2/2/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

#import "Stubbilino.h"

#import "SBStub.h"

SpecBegin(SBStub)

describe(@"SBStub", ^{
    __block id originalObject;
    __block id<SBStub> stubbedObject;

    beforeAll(^{
        originalObject = [[NSObject alloc] init];
        stubbedObject = [Stubbilino stubObject:originalObject];
    });

    it(@"is identical to the stubbed object", ^{
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
});

SpecEnd