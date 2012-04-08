//
//  GGStatus.h
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 06.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGStatus : NSObject{
    NSString *GGNumber, *GGStatusDescription;
    int status;
}

- (id)initWithNumber:(NSString *) numberString andStatus:(int)_status withDescription:(NSString *)statusDescription;

@property (nonatomic) int status;
@property (nonatomic, retain) NSString *GGNumber;
@property (nonatomic, retain) NSString *GGStatusDescription;

@end
