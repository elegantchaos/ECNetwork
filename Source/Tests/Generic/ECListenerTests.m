// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECListener.h"
#import <SenTestingKit/SenTestingKit.h>
#import <ECUnitTests/ECUnitTests.h>

@interface ECListenerTests : ECTestCase

@end

@implementation ECListenerTests

- (void)testCreation
{
	__block BOOL connected = NO;
	ECListener* listener = [[ECListener alloc] initWithConnectionHandler:^(NSInputStream *inputStream, NSOutputStream *outputStream) {
		connected = YES;
		[self timeToExitRunLoop];
	}];

	ECTestAssertTrue(listener.port > 0);

	// fake a network connection - it'll be enough to cause the listener to call its callback
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%ld/", (long) listener.port]]];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
	}];

	[self runUntilTimeToExit];
	
	ECTestAssertTrue(connected);
}

@end
