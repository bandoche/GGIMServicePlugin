//
//  GGServicePlugin.m
//  Gadu-GaduServicePlugin
//
//  Created by Paweł Ksieniewicz on 26.12.2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GGServicePlugin.h"

@implementation GGServicePlugin

- (id) initWithServiceApplication:(id<IMServiceApplication>)serviceApplication 
{
    if ((self = [super init])) {
        _application = (id)[serviceApplication retain];
        gadu = [[LibGaduWrapper alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(requestGroupList) 
                                                     name:@"ContactListNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recievedMessage) 
                                                     name:@"MessageNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logout) 
                                                     name:@"LogoutNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusChanged) 
                                                     name:@"StatusNotification"
                                                   object:nil];
        [gadu retain];
        }
    return self;
}

#pragma mark -
#pragma mark IMServicePlugIn Delegate


#pragma mark -
#pragma mark IMServicePlugIn

- (oneway void) login{
    NSString *nrGG = [_accountSettings objectForKey:IMAccountSettingLoginHandle];
    NSString *passwordGG = [_accountSettings objectForKey:IMAccountSettingPassword];
    if ([gadu loginWithNumber:nrGG 
                     password:passwordGG 
                    andStatus:GG_STATUS_AVAIL
              withDescription:nil]) {
        [_application plugInDidLogIn];
        pingTimer = [NSTimer scheduledTimerWithTimeInterval:30. target:self selector:@selector(ping) userInfo:nil repeats:YES];
        [self requestGroupList];
    }
    else{
        [_application plugInDidLogOutWithError:nil reconnect:NO];
    }
    NSLog(@"login");
}
- (void) recievedMessage{
    GGMessage *message = [gadu lastMessage];
    NSAttributedString *wiadomosc = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:[message GGMessageBody]]];
    [_application plugInDidReceiveMessage:[IMServicePlugInMessage servicePlugInMessageWithContent:wiadomosc] fromHandle:[message GGNumber]];    
}

- (void) ping{
    [gadu ping];
}

- (oneway void) logout{
    [gadu logoff];
    [_application plugInDidLogOutWithError:nil reconnect:NO];
    [pingTimer invalidate];
}
- (oneway void) updateAccountSettings:(NSDictionary *)accountSettings{
    [_accountSettings release];
    _accountSettings = [accountSettings retain];
}

#pragma mark -
#pragma mark IMServiceApplicationGroupListSupport

- (oneway void) updateSessionProperties:(NSDictionary *)properties {
    IMSessionAvailability availability = [[properties objectForKey:IMSessionPropertyAvailability] intValue];
    //NSString *awayMessage = [properties objectForKey:IMSessionPropertyStatusMessage];
    if (availability == IMSessionAvailabilityAvailable) {
        [gadu setStatus:GG_STATUS_AVAIL];
    } else if (availability == IMSessionAvailabilityAway) {
        [gadu setStatus:GG_STATUS_BUSY];
    }
}


- (oneway void) requestGroupList
{
    NSArray *groups = [[NSArray alloc] init];
    for (NSString *groupKey in [gadu ggGroups]) {
        NSString *groupName = [[gadu ggGroups] objectForKey:groupKey];
        
        if ([[groupName substringToIndex:1] isEqualToString:@"["]) continue;
        
        NSArray *handles = [[NSArray alloc] init];

        for (GGContact *contact in [gadu ggContacts]) 
            if ([[contact GroupId] isEqualToString:groupKey]) 
                handles = [handles arrayByAddingObject:[contact GGNumber]];
        
        NSNumber *permissions = [[NSNumber alloc] initWithInt:IMGroupListCanReorderGroup | IMGroupListCanReorderMembers];    
        NSDictionary *group = [[NSDictionary alloc] initWithObjectsAndKeys: 
                               groupName, IMGroupListNameKey,
                               handles, IMGroupListHandlesKey, 
                               permissions, IMGroupListPermissionsKey,
                               nil];
        groups = [groups arrayByAddingObject:group];
    }
    [_application plugInDidUpdateGroupList:groups error:nil];
      
    for (GGContact *contact in [gadu ggContacts]){        
        NSMutableDictionary *handleProperties = [[NSMutableDictionary alloc] init];
        [handleProperties setObject:[NSNumber numberWithInt:IMHandleAvailabilityOffline] forKey:IMHandlePropertyAvailability];
        [handleProperties setObject:[contact NickName] forKey:IMHandlePropertyAlias];
        [handleProperties setObject:[contact FirstName] forKey:IMHandlePropertyFirstName];
        [handleProperties setObject:[contact LastName] forKey:IMHandlePropertyLastName];
        [handleProperties setObject:[NSArray arrayWithObject:IMHandleCapabilityOfflineMessaging] forKey:IMHandlePropertyCapabilities];
        [handleProperties setObject:[contact GGNumber] forKey:IMHandlePropertyPictureIdentifier];
        [_application plugInDidUpdateProperties:handleProperties ofHandle:[contact GGNumber]];
        [handleProperties release];        
    }
   }

- (void) statusChanged{
    GGStatus *newStatus = [gadu lastStatus];
    NSMutableDictionary *handleProperties = [[NSMutableDictionary alloc] init];
    int maskedStatus = [newStatus status] & GG_STATUS_MASK;
    [handleProperties setObject:[NSNumber numberWithInt:IMHandleAvailabilityAvailable] forKey:IMHandlePropertyAvailability];
    [handleProperties setObject:[NSArray arrayWithObject:IMHandleCapabilityMessaging] forKey:IMHandlePropertyCapabilities];
    switch (maskedStatus) {
        case GG_STATUS_AVAIL:
        case GG_STATUS_AVAIL_DESCR:
            [handleProperties setObject:[NSNumber numberWithInt:IMHandleAvailabilityAvailable] forKey:IMHandlePropertyAvailability];
            [handleProperties setObject:[NSArray arrayWithObject:IMHandleCapabilityMessaging] forKey:IMHandlePropertyCapabilities];
            break;
        case GG_STATUS_BUSY:
        case GG_STATUS_BUSY_DESCR:
            [handleProperties setObject:[NSNumber numberWithInt:IMHandleAvailabilityAway] forKey:IMHandlePropertyAvailability];
            [handleProperties setObject:[NSArray arrayWithObject:IMHandleCapabilityMessaging] forKey:IMHandlePropertyCapabilities];
            break;
        case GG_STATUS_INVISIBLE:
        case GG_STATUS_INVISIBLE_DESCR:
        case GG_STATUS_NOT_AVAIL:
        case GG_STATUS_NOT_AVAIL_DESCR:
            [handleProperties setObject:[NSNumber numberWithInt:IMHandleAvailabilityOffline] forKey:IMHandlePropertyAvailability];
            [handleProperties setObject:[NSArray arrayWithObject:IMHandleCapabilityOfflineMessaging] forKey:IMHandlePropertyCapabilities];
            break;
        default:
            [handleProperties release];
            return;
            break;
    }
    [handleProperties setObject:[newStatus GGStatusDescription] forKey:IMHandlePropertyStatusMessage];
    [_application plugInDidUpdateProperties:handleProperties ofHandle:[[gadu lastStatus] GGNumber]];
    [handleProperties release];  
}

#pragma mark -
#pragma mark IMServicePlugInInstantMessagingSupport

- (oneway void) userDidStartTypingToHandle:(NSString *)handle
{
    // No way to represent this on IRC
}


- (oneway void) userDidStopTypingToHandle:(NSString *)handle
{
    // No way to represent this on IRC
}

- (oneway void) sendMessage:(IMServicePlugInMessage *)message toHandle:(NSString *)handle
{
    if ([gadu sendMessage:[[message content] string] toNumber:[handle intValue]]){
        [_application plugInDidSendMessage:message toHandle:handle error:nil];
    }
}

- (oneway void) requestPictureForHandle:(NSString *)handle withIdentifier:(NSString *)identifier{
    NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://avatars.gg.pl/%@", handle]]];
    if (avatarData) {
        NSMutableDictionary *consoleProperties = [[NSMutableDictionary alloc] init];
        [consoleProperties setObject:avatarData forKey:IMHandlePropertyPictureData];
        [consoleProperties setObject:identifier forKey:IMHandlePropertyPictureIdentifier];
         [_application plugInDidUpdateProperties:consoleProperties ofHandle:handle];
         [consoleProperties release];
    }

}

- (void) dealloc
{
    [super dealloc];
}

@end
