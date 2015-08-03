//
//  XMPPAuthProcess.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPProcess+Private.h"

@interface XMPPAuthProcess : XMPPProcess

@property (nonatomic, copy) XMPPJID *jid;
@property (nonatomic, copy) NSString *password;

@end