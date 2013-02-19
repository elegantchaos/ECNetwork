// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECListener.h"
#import <SenTestingKit/SenTestingKit.h>

@interface ECListenerTests : SenTestCase

@end

@implementation ECListenerTests

- (void)testCreation
{
	ECListener* listener = [[ECListener alloc] initWithConnectionHandler:^(NSInputStream *inputStream, NSOutputStream *outputStream) {

		NSLog(@"connected");
	}];

	STAssertTrue(listener.port > 0, @"should have had a port assigned");

	[listener release];
}

@end
