//
//  GGMessage.m
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 06.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGMessage.h"

@implementation GGMessage
@synthesize GGNumber, GGMessageBody;

- (id)initWithNumber:(NSString *) numberString andMessageBody:(NSString *)messageString{
    if ((self = [super init])) {
        GGNumber = numberString;
        GGMessageBody = messageString;
    }    
    return self;
}

@end
