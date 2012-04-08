//
//  GGContact.m
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 05.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGContact.h"

@implementation GGContact
@synthesize GGNumber, NickName, FirstName, LastName, GroupId;

- (id) initWithGGNumber:(NSString *)number nickName:(NSString *)nickname firstName:(NSString *)firstname lastName:(NSString *)lastname andGroupId:(NSString *)groupId{
    if ((self = [super init])) {
        GGNumber = number;
        NickName = nickname;
        FirstName = firstname;
        LastName = lastname;
        GroupId = groupId;
    }    
    return self;
}

@end
