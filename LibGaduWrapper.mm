//
//  LibGaduWrapper.m
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 04.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LibGaduWrapper.hh"

@implementation LibGaduWrapper

@synthesize ggGroups, ggContacts, lastMessage, lastStatus;


- (id)init{
    if ((self = [super init])) {
        ggNumber = nil;
        ggPassword = nil;
        ggStatusDescription = nil;
        ggStatus = 0;
        gg_debug_level = 0;
        ggGroups = [[NSMutableDictionary alloc] init];
        ggContacts = [[NSArray alloc] init];
        isLoggedIn = NO;
    }    
    return self;
}

- (BOOL) loginWithNumber:(NSString *) numberString password:(NSString *) passwordString andStatus:(int)status withDescription:(NSString *)statusDescription{
    ggNumber = numberString;
    ggPassword = passwordString;
    ggStatusDescription = statusDescription;
    ggStatus = status;
    struct gg_login_params loginParameters;
    memset(&loginParameters, 0, sizeof(loginParameters));
    loginParameters.uin = [ggNumber intValue];
    loginParameters.password = (char *)[ggPassword UTF8String];
    loginParameters.status = ggStatus;
    loginParameters.status_descr = (char *)[ggStatusDescription UTF8String];
    loginParameters.encoding = GG_ENCODING_UTF8;
    loginParameters.protocol_features = GG_FEATURE_DND_FFC | GG_FEATURE_IMAGE_DESCR;
    if (!(session = gg_login(&loginParameters))) {
        NSLog(@"Nie udało się połączyć: %s\n", strerror(errno));
        gg_free_session(session);
        isLoggedIn = NO;
        return NO;
    }
    [NSThread detachNewThreadSelector:@selector(checkEvent) toTarget:self withObject:nil];
    gg_notify(session, NULL, 0);
    [self getList];
    
    NSLog(@"Połączono z numerem %i", [ggNumber intValue]);
    isLoggedIn = YES;
    
    return YES;
}

- (void) logoff{
    NSLog(@"Wylogowuję się");
    if (ggStatusDescription) {
        /*
        if ([self setStatus:GG_STATUS_NOT_AVAIL_DESCR withDescription:ggStatusDescription]) {
            return;
            NSLog(@"Wylogowuję się - nie poszło");
        }*/
    }
    isLoggedIn = NO;
    gg_logoff(session);
    gg_free_session(session);
}

- (BOOL) setStatus:(int) status{
    ggStatus = status;
    
        gg_change_status(session, ggStatus);
    return YES;
}

- (BOOL) setStatusDescription:(NSString *) statusDescription{
    ggStatusDescription = statusDescription;
    [self setStatus:ggStatus];
    return YES;
}

- (BOOL) sendMessage:(NSString *)message toNumber:(int)recieverNumber{
    if (gg_send_message(session, GG_CLASS_MSG, recieverNumber, (unsigned char *)[message UTF8String]) == -1) {
		printf("Połączenie przerwane: %s\n", strerror(errno));
		gg_free_session(session);
		return NO;
	}
	while (0) {
		if (!(e = gg_watch_fd(session))) {
			printf("Połączenie przerwane: %s\n", strerror(errno));
			gg_logoff(session);
			gg_free_session(session);
            //isLoggedIn = NO;
			return NO;
		}
		if (e->type == GG_EVENT_ACK) {
			printf("Wysłano.\n");
			gg_free_event(e);
			break;
		}
		gg_free_event(e);
	}
    return YES;
}

- (void)ping{
    gg_ping(session);
}

- (BOOL) getList{
    return gg_userlist100_request(session, GG_USERLIST100_GET, 0, GG_USERLIST100_FORMAT_TYPE_GG100, NULL);
}

- (void) checkEvent{
    while (1) {
        event = gg_watch_fd(session);
        if (event) {
            switch (event->type) {
                case GG_EVENT_NONE:
                    NSLog(@"Nic ciekawego");
                    break;
                case GG_EVENT_MSG:
                    NSLog(@"Wiadomość!");
                    [self parseMessage:event->event.msg];
                    break;
                case GG_EVENT_USERLIST100_REPLY:
                    NSLog(@"Lista kontaktów!");
                    [self parseContactList:event->event.userlist100_reply];
                    break;
                case GG_EVENT_NOTIFY60:
                    NSLog(@"Statusy dla wszystkich kontaktów");
                    [self parseEventNotify:event->event.notify60];
                    break;
                case GG_EVENT_STATUS60:
                    NSLog(@"Zmiana statusu");
                    [self parseEventStatus:event->event.status60];
                    break;
                default:
                    NSLog(@"Zupa! %i", event->type);
                    break;
            }
            gg_event_free(event);
        }
    }    
}

- (void) parseMessage:(gg_event_msg) message{
    NSLog(@"%i - %s", message.sender, message.message);
    GGMessage *ggMessage = [[GGMessage alloc] initWithNumber:[NSString stringWithFormat:@"%i", message.sender]
                                            andMessageBody:[NSString stringWithUTF8String:(const char*)message.message]];
    lastMessage = ggMessage;
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"MessageNotification" 
     object:nil];
}

- (void) parseContactList:(gg_event_userlist100_reply) userlist{
    NSString *userlistXMLString = [NSString stringWithCString:userlist.reply encoding:NSUTF8StringEncoding];
    RXMLElement *rxml = [RXMLElement elementFromXMLString:userlistXMLString];
    
    ggGroups = nil;
    ggContacts = nil;
    
    ggGroups = [[NSMutableDictionary alloc] init];
    ggContacts = [[NSArray alloc] init];
    
    [rxml iterate:@"Groups.Group" with: ^(RXMLElement *group) {
        [ggGroups addEntriesFromDictionary:
         [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [group child:@"Name"]] 
                                     forKey:[NSString stringWithFormat:@"%@", [group child:@"Id"]]]];
    }];
    [rxml iterate:@"Contacts.Contact" with: ^(RXMLElement *group) {
        GGContact *contact = [[GGContact alloc] initWithGGNumber:[NSString stringWithFormat:@"%@", [group child:@"GGNumber"]]
                                                        nickName:[NSString stringWithFormat:@"%@", [group child:@"NickName"]]
                                                       firstName:[NSString stringWithFormat:@"%@", [group child:@"FirstName"]] 
                                                        lastName:[NSString stringWithFormat:@"%@", [group child:@"LastName"]]
                                                      andGroupId:[NSString stringWithFormat:@"%@", [[group child:@"Groups"] child:@"GroupId"]]];
        ggContacts = [ggContacts arrayByAddingObject:contact];
    }];
    uin_t cContacts[[ggContacts count]];
    int i = 0;
    for (GGContact *contact in ggContacts) cContacts[i++] = [[contact GGNumber] intValue];
    gg_notify(session, cContacts, (int)[ggContacts count]);
    
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"ContactListNotification"
     object:nil];
}

- (void) parseEventNotify:(gg_event_notify60 *)notify{
    int i=0;
    while (1) {
        if (!notify[i].uin) break;
        
        NSString *description = @"";
        if (notify[i].descr) {
            description = [NSString stringWithCString:notify[i].descr encoding:NSUTF8StringEncoding]; 
        }
        GGStatus *status = [[GGStatus alloc] initWithNumber:[NSString stringWithFormat:@"%i", notify[i].uin] 
                                                  andStatus:notify[i].status
                                            withDescription:description];
        lastStatus = status;
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"StatusNotification" 
         object:status];        
        i++;
    }
    
    
}

- (void) parseEventStatus:(gg_event_status60)notify{
    NSString *description = @"";
    if (notify.descr) {
        description = [NSString stringWithCString:notify.descr encoding:NSUTF8StringEncoding]; 
    }
    GGStatus *status = [[GGStatus alloc] initWithNumber:[NSString stringWithFormat:@"%i", notify.uin] 
                                              andStatus:notify.status 
                                        withDescription:description];
    
    lastStatus = status;
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"StatusNotification" 
     object:status];
}

@end