// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ECNetworkErrorCode)
{
	ECNetworkErrorIPv4NotBound,
	ECNetworkErrorIPv4SocketNotCreated,
	ECNetworkErrorIPv6NotBound,
	ECNetworkErrorIPv6SocketNotCreated,

};

extern NSString *const ECNetworkErrorDomain;
