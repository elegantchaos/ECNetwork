// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

typedef void(^ECListenerConnectionHandler)(NSInputStream* inputStream, NSOutputStream* outputStream);


/**
 Listens for a network connection on a port.

 When one comes in, it executes the handler block.
 */

@interface ECListener : NSObject

@property (readonly, nonatomic) NSInteger port;

- (id)initWithConnectionHandler:(ECListenerConnectionHandler)handler;

@end
