//
//  XMPPCredentials.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 09/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPCredentials.h"

@interface XMPPCredentials ()
@property (nonnull, nonatomic, copy, readwrite) NSString *jid;
@property (nonnull, nonatomic, copy, readwrite) NSString *password;
@end

@implementation XMPPCredentials
- (instancetype)initWithJid:(nonnull NSString *)jid password:(nonnull NSString *)password {
    self = [super init];
    if (self) {
        self.jid = jid;
        self.password = password;
    }
    return self;
}
@end
