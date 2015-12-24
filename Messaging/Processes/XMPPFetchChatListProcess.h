//
//  XMPPFetchChatList.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

#import "XMPPProcess+Private.h"

@interface XMPPFetchChatListProcess : XMPPProcess
@property (nonatomic, copy) NSString *serviceName;
@end
