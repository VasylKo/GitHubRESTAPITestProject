//
//  XMPPProcess.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

/**
 *  General process callback
 *
 *  @param result process result
 *  @param error    error
 */
typedef void(^XMPPProcesseCompletionBlock)(id result, NSError *error);

@interface XMPPProcess : NSObject

- (instancetype)initWithStream:(XMPPStream *)stream queue:(dispatch_queue_t)completionQueue;

/**
 *  Starts the process
 *
 *  @param completionBlock completion handler
 */
- (void)executeWithCompletion:(XMPPProcesseCompletionBlock)completionBlock;

- (void)run;
- (void)complete:(id)result error:(NSError *)error;

//Private

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, copy) XMPPProcesseCompletionBlock completionBlock;

@end
