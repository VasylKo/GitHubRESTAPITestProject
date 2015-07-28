//
//  XMPPProcess+Private.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPProcess.h"
#import "XMPP.h"
#import "XMPPLogging.h"

@interface XMPPProcess ()

- (instancetype)initWithStream:(XMPPStream *)stream queue:(dispatch_queue_t)completionQueue;

- (void)run;
- (void)complete:(id)result error:(NSError *)error;

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, copy) XMPPProcesseCompletionBlock completionBlock;

@end