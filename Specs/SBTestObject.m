//
//  SBTestObject.m
//  Stubbilino
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

#import "SBTestObject.h"

@implementation SBTestObject
{
	NSValue *_value;
}

+ (NSString *)method
{
    return @"Not stubbed";
}

+ (NSString *)methodWithObjectArgument:(NSString *)argument
{
    return @"Not stubbed";
}

+ (char)methodWithPrimitiveArgument:(char)argument
{
    return 0;
}

- (id)initWithValue:(NSValue *)value
{
	self = [self init];
	if (self != nil) {
		_value = value;
	}
	return self;
}

- (NSString *)method
{
    return @"Not stubbed";
}

- (NSString *)methodWithObjectArgument:(NSString *)argument
{
    return @"Not stubbed";
}

- (char)methodWithPrimitiveArgument:(char)argument
{
    return 0;
}

- (BOOL)isEqual:(id)object
{
	if (object == self)
		return YES;
	if (! [object isKindOfClass:[SBTestObject class]])
		return NO;
	if (((typeof(self))object)->_value == _value)
		return YES;
	return [((typeof(self))object)->_value isEqual:_value];
}

- (NSUInteger)hash
{
	return [_value hash];
}

@end
