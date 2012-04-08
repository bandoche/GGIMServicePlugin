//
//  GGContact.h
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 05.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGContact : NSObject{
    NSString *GGNumber, *NickName, *FirstName, *LastName, *GroupId;
}

- (id) initWithGGNumber:(NSString *)number nickName:(NSString *)nickname firstName:(NSString *)firstname lastName:(NSString *)lastname andGroupId:(NSString *)groupId;

@property (nonatomic, retain) NSString *GGNumber;
@property (nonatomic, retain) NSString *NickName;
@property (nonatomic, retain) NSString *FirstName;
@property (nonatomic, retain) NSString *LastName;
@property (nonatomic, retain) NSString *GroupId;

@end