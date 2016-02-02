//
//  XMPPProcess.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//


@import Foundation;

/**
 *  General process callback
 *
 *  @param result process result
 *  @param error    error
 */
typedef void(^XMPPProcesseCompletionBlock)(id __nullable result, NSError * __nullable error);

/**
 *  Abstract xmpp process
 */
@interface XMPPProcess : NSObject


/**
 *  Starts the process
 *
 *  @param completionBlock completion handler
 */
- (void)executeWithCompletion:(nullable XMPPProcesseCompletionBlock)completionBlock;


- (nullable instancetype)init NS_UNAVAILABLE;

@end


FOUNDATION_EXPORT NSString * __nonnull const kXMPPErrorDomain;