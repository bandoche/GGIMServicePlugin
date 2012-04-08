//
//  LibGaduWrapper.h
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 04.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RXMLElement.h"
#import "GGContact.h"
#import "GGStatus.h"
#import "GGMessage.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libgadu.h"

@interface LibGaduWrapper : NSObject{
    struct gg_session *session;
    struct gg_event *e, *event;
    NSMutableDictionary *ggGroups;
    NSArray *ggContacts;
    BOOL isLoggedIn;
    NSString *ggNumber, *ggPassword, *ggStatusDescription;
    GGMessage *lastMessage;
    GGStatus *lastStatus;
    int ggStatus;
}

- (BOOL) loginWithNumber:(NSString *) numberString password:(NSString *) passwordString andStatus:(int)status withDescription:(NSString *)statusDescription;
- (void) logoff;

- (BOOL) setStatus:(int) status;
- (BOOL) setStatusDescription:(NSString *) statusDescription;

- (BOOL) sendMessage:(NSString *)message toNumber:(int)recieverNumber;
- (void) ping;

- (void) checkEvent;

- (BOOL) getList;

//- (void) parseEventNotify:(gg_event_notify60 *)notify;
//- (void) parseEventStatus:(gg_event_status60)notify;

//- (void) parseContactList:(gg_event_userlist100_reply) userlist;
//- (void) parseMessage:(gg_event_msg) message;

@property (nonatomic, retain) NSMutableDictionary *ggGroups;
@property (nonatomic, retain) NSArray *ggContacts;
@property (nonatomic, retain) GGMessage *lastMessage;
@property (nonatomic, retain) GGStatus *lastStatus;

@end
