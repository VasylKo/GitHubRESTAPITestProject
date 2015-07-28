//
//  XMPPLogFormatter.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPLogFormatter.h"
#import "XMPPLogging.h"

@interface XMPPLogFormatter ()
@end

@implementation XMPPLogFormatter
- (id)init {
    if((self = [super init]))
    {
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    
    NSString *logMsg = logMessage->logMsg;
    
    if (logMessage->logFlag == XMPP_LOG_FLAG_TRACE) {
        return [NSString stringWithFormat:@"   XMPP | TRC %@",logMsg];
    }
    
    NSString *logFlag;
    switch (logMessage->logFlag)
    {
        case XMPP_LOG_FLAG_ERROR : logFlag = @"ERR"; break;
        case XMPP_LOG_FLAG_WARN  : logFlag = @"WRN"; break;
        case XMPP_LOG_FLAG_INFO  : logFlag = @"INF"; break;
        case XMPP_LOG_FLAG_VERBOSE : logFlag = @"VBS"; break;
        case XMPP_LOG_FLAG_SEND: logFlag = @"-->"; break;
        case XMPP_LOG_FLAG_RECV_POST: logFlag = @"<--"; break;
        case XMPP_LOG_FLAG_RECV_PRE: logFlag = @"<-<"; break;
        default             : logFlag = @"  "; break;
    }
    
    return [NSString stringWithFormat:@"   XMPP | %@  %s:%d> %@",logFlag,  logMessage->function,logMessage->lineNumber,logMsg];
}
@end
