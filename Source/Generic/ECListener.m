// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECListener.h"
#import "ECNetworkError.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

ECDefineDebugChannel(ECListenerChannel);

@interface ECListener()

@property (copy, nonatomic) ECListenerConnectionHandler handler;
@property (assign, nonatomic) NSInteger port;
@property (assign, nonatomic) CFSocketRef socket4;
@property (assign, nonatomic) CFSocketRef socket6;

@end

@implementation ECListener

- (id)initWithConnectionHandler:(ECListenerConnectionHandler)handler
{
	if ((self = [super init]) != nil)
	{
		self.handler = handler;

		NSError* error = nil;
		if (![self start:&error])
		{
			ECDebug(ECListenerChannel, @"failed to start listener with error %@", error);
			[self release];
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
	[self stop];

	[_handler release];

	[super dealloc];
}

- (BOOL)start:(NSError**)error
{
	self.socket4 = [self newSocket:error protocol:AF_INET];

	if (self.socket4)
	{
		struct sockaddr_in addr4;
		NSData *addr = [(NSData *)CFSocketCopyAddress(self.socket4) autorelease];
		memcpy(&addr4, [addr bytes], [addr length]);
		self.port = ntohs(addr4.sin_port);

		self.socket6 = [self newSocket:error protocol:AF_INET6];
	}

	return self.socket4 && self.socket6;
}

- (void)stop
{

}

- (void)setupRunLoopForSocket:(CFSocketRef)socket
{
	CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
	CFRelease(source);
}

- (CFSocketRef)newSocket:(NSError**)errorOut protocol:(SInt32)protocol
{
	NSError* error = nil;
	BOOL useIPv4 = protocol == AF_INET;
	CFSocketContext socketCtxt = {0, self, nil, nil, nil};
	CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, protocol, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&acceptConnection, &socketCtxt);
	if(socket) {
		int yes = 1;
		setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

		NSData* address;

		if (useIPv4)
		{
			struct sockaddr_in addr4;
			memset(&addr4, 0, sizeof(addr4));
			addr4.sin_len = sizeof(addr4);
			addr4.sin_family = AF_INET;
			addr4.sin_addr.s_addr = htonl(INADDR_ANY);
			address = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];

		}
		else
		{
			struct sockaddr_in6 addr6;
			memset(&addr6, 0, sizeof(addr6));
			addr6.sin6_len = sizeof(addr6);
			addr6.sin6_family = AF_INET6;
			addr6.sin6_port = htons(self.port);
			memcpy(&(addr6.sin6_addr), &in6addr_any, sizeof(addr6.sin6_addr));
			address = [NSData dataWithBytes:&addr6 length:sizeof(addr6)];
		}

		if (kCFSocketSuccess == CFSocketSetAddress(socket, (CFDataRef)address))
		{
			[self setupRunLoopForSocket:socket];
		}
		else
		{
			error = [NSError errorWithDomain:ECNetworkErrorDomain code:(useIPv4 ? ECNetworkErrorIPv4NotBound : ECNetworkErrorIPv6NotBound) userInfo:nil];
			CFRelease(socket);
			socket = nil;
		}
	}

	else
	{
		error = [NSError errorWithDomain:ECNetworkErrorDomain code:(useIPv4 ? ECNetworkErrorIPv4SocketNotCreated : ECNetworkErrorIPv6SocketNotCreated) userInfo:nil];
	}

	if (errorOut && error)
	{
		*errorOut = error;
	}

	return socket;
}


- (void)acceptConnectionFromAddress:(CFDataRef)address onSocket:(CFSocketNativeHandle)socket
{
	CFReadStreamRef readStream = nil;
	CFWriteStreamRef writeStream = nil;

	CFStreamCreatePairWithSocket(kCFAllocatorDefault, socket, &readStream, &writeStream);
	if(readStream && writeStream)
	{
		CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

		self.handler((NSInputStream*)readStream, (NSOutputStream*)writeStream);
	}
	else
	{
		close(socket);
	}

	if (readStream)
	{
		CFRelease(readStream);
	}

	if (writeStream)
	{
		CFRelease(writeStream);
	}
}

static void acceptConnection(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {

	if (kCFSocketAcceptCallBack == type)
	{
		ECListener *listener = (id)info;
		CFSocketNativeHandle nativeSocket = *(CFSocketNativeHandle *)data;
		[listener acceptConnectionFromAddress:address onSocket:nativeSocket];
	}

	else
	{
		ECDebug(ECListenerChannel, @"unexpected callback type %ld", (long) type);
	}

}

@end
