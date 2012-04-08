//
//  GGStatus.m
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 06.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGStatus.h"

@implementation GGStatus
@synthesize GGNumber, GGStatusDescription, status;

- (id)initWithNumber:(NSString *) numberString andStatus:(int)_status withDescription:(NSString *)statusDescription{
    if ((self = [super init])) {
        GGNumber = numberString;
        GGStatusDescription = statusDescription;
        status = _status;
    }    
    return self;
}

@end
