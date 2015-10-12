//
//  XMPPConversation.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 12/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPConversation : NSObject

@property (readonly, copy, nonnull ) NSArray *participants;
@property (nonatomic, readonly, nonnull) NSDate *lastActivityDate;
@property (nonatomic, readonly, copy, nonnull) NSString *name;
@property (nonatomic, readonly, strong, nullable) NSURL *imageURL;
@property (nonatomic, readonly, copy, nonnull) NSString *roomId;
@property (nonatomic, readonly, assign) BOOL isMultiUser;
@end
