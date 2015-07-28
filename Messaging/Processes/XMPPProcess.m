//
//  XMPPProcess.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPProcess.h"
#import "XMPPLogging.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;


@interface XMPPProcess ()
@end

@implementation XMPPProcess

- (instancetype)initWithStream:(XMPPStream *)stream queue:(dispatch_queue_t)completionQueue {
    self = [super init];
    if (self) {
        self.xmppStream =stream;
        self.completionQueue = completionQueue;
    }
    return  self;
}

- (void)dealloc {
    XMPPLogWarn(@"dealloc: %@", [self description]);
}

- (void)executeWithCompletion:(XMPPProcesseCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    dispatch_async([[self class] defaultProcessingQueue], ^{
        XMPPLogInfo(@"Start process:  %@", [self description]);
        [self run];
    });
    
}

- (void)run {
    [self complete:nil error:nil];
}

- (void)complete:(id)result error:(NSError *)error {
    XMPPProcesseCompletionBlock completionBlock = self.completionBlock ?: ^(id r, NSError *e) {};
    dispatch_queue_t completionQueue = self.completionQueue ?: dispatch_get_main_queue();
    XMPPLogInfo(@"Finish process:  %@", [self description]);
    dispatch_async(completionQueue, ^{
        completionBlock(result, error);
    });
}


+ (void)initialize {
    if (self == [XMPPProcess class]) {
        [self setDefaultProcessingQueue:dispatch_get_main_queue()];
    }
}

static dispatch_queue_t __ooXMPPDefaultProcessingQueue =  NULL;

+ (void)setDefaultProcessingQueue:(dispatch_queue_t)queue {
    if (queue) {
        __ooXMPPDefaultProcessingQueue = queue;
    }
}

+ (dispatch_queue_t)defaultProcessingQueue {
    return __ooXMPPDefaultProcessingQueue;
}


@end
