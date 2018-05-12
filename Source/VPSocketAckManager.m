//
//  SocketAckManager.m
//  VPSocketIO
//
//  Created by Vasily Popov on 9/20/17.
//  Copyright © 2017 Vasily Popov. All rights reserved.
//

#import "VPSocketAckManager.h"
#import "VPSocketAck.h"

@interface VPSocketAckManager()
{
    NSMutableSet<VPSocketAck*>*acks;
    dispatch_semaphore_t ackSemaphore;
}

@end

@implementation VPSocketAckManager

-(instancetype)init
{
    self = [super init];
    if(self) {
        acks = [NSMutableSet set];
        ackSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}
-(void)addAck:(int)ack callback:(VPScoketAckArrayCallback)callback
{
    [acks addObject:[[VPSocketAck alloc] initWithAck:ack andCallBack:callback]];
}
-(void)executeAck:(int)ack withItems:(NSArray*)items onQueue:(dispatch_queue_t)queue
{
    VPSocketAck *socketAck = [self removeAckWithId:ack];
    dispatch_async(queue, ^
                   {
                       @autoreleasepool
                       {
                           if(socketAck && socketAck.callback) {
                               socketAck.callback(items);
                               [socketAck removeCallback];
                           }
                       }
                   });
    
}
-(void)timeoutAck:(int)ack onQueue:(dispatch_queue_t)queue
{
    VPSocketAck *socketAck = [self removeAckWithId:ack];
    if(socketAck.callback){
        dispatch_async(queue, ^
                       {
                           @autoreleasepool
                           {
                               socketAck.callback(@[@"NO ACK"]);
                           }
                       });
    }
}

-(VPSocketAck*)removeAckWithId:(int)ack {
    
    VPSocketAck *socketAck = nil;
    for (VPSocketAck *vpack in acks) {
        if(vpack.ack == ack) {
            socketAck = vpack;
        }
    }
    if(socketAck){
        [acks removeObject:socketAck];
    }
    return socketAck;
}

@end

