//
//  XMPPProcess.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//


#import "XMPPProcess+Private.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;

@interface XMPPProcess ()
@property (nonatomic, strong, readwrite, nonnull) XMPPStream *xmppStream;
@property (nonatomic, copy, readwrite, nullable) XMPPProcesseCompletionBlock completionBlock;
@property (nonatomic, strong, readwrite, nullable) dispatch_queue_t completionQueue;
@property (nonatomic, strong, readwrite, nonnull) dispatch_semaphore_t semaphore;
@end

@implementation XMPPProcess

- (instancetype)init {
    return  nil;
}

- (instancetype)initWithStream:(XMPPStream *)stream queue:(dispatch_queue_t)completionQueue {
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(0);
        self.xmppStream = stream;
        [self.xmppStream addDelegate:self delegateQueue:[[self class] defaultProcessingQueue]];
        self.completionQueue = completionQueue;
    }
    return  self;
}

- (void)dealloc {
    [self.xmppStream removeDelegate:self];
    XMPPLogVerbose(@"Dealloc process: %@", [self description]);
}

- (void)executeWithCompletion:(XMPPProcesseCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    dispatch_async([[self class] defaultProcessingQueue], ^{
        XMPPLogInfo(@"Starting process:  %@", [self description]);
        [self run];
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    });
    
}

- (void)run {
    //Default implementation call success with no result
    [self complete:nil error:nil];
}

- (void)complete:(id)result error:(NSError *)error {
    XMPPLogInfo(@"Finishing process:  %@ (%@, %@)", [self description], result, error);
    dispatch_semaphore_signal(self.semaphore);
    XMPPProcesseCompletionBlock completionBlock = self.completionBlock ?: ^(id r, NSError *e) {};
    dispatch_queue_t completionQueue = self.completionQueue ?: dispatch_get_main_queue();
    
    dispatch_async(completionQueue, ^{
        completionBlock(result, error);
    });
}



+ (void)initialize {
    if (self == [XMPPProcess class]) {
        [self setDefaultProcessingQueue:dispatch_queue_create("com.bekitzur.xmpp.process", DISPATCH_QUEUE_CONCURRENT)];
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
