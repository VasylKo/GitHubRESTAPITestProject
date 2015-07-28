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

/**
 *  Designated initializer
 *
 *  @param stream          xmpp stream
 *  @param completionQueue completion queue
 *
 *  @return new instance of the process
 */
- (nonnull instancetype)initWithStream:(nonnull XMPPStream *)stream queue:(nullable dispatch_queue_t)completionQueue NS_DESIGNATED_INITIALIZER;

/**
 *  Abstract method. Do actual work
 */
- (void)run;

/**
 *  Finishes process and call completion block. Subclasses MUST call this method
 *
 *  @param result process result
 *  @param error  process error
 */
- (void)complete:(nullable id)result error:(nullable  NSError *)error;

/**
 *  Generates error from xml element
 *
 *  @param element xml element
 *
 *  @return error instance
 */
- (NSError * __nonnull )errorFromElement:(nonnull NSXMLElement *)element;

@end

@interface XMPPProcess (Private)

/**
 *  Processes XMPP stream
 */
@property (nonatomic, strong, readonly, nonnull) XMPPStream *xmppStream;

@end