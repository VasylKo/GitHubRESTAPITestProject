//
//  XMPPCredentials.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 09/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPCredentials : NSObject
- (nonnull instancetype)initWithJid:(nonnull NSString *)jid password:(nonnull NSString *)password;
@property (nonnull, nonatomic, copy, readonly) NSString *jid;
@property (nonnull, nonatomic, copy, readonly) NSString *password;
@end


@protocol XMPPCredentialsProvider <NSObject>
- (nullable XMPPCredentials *)getChatCredentials;
@end