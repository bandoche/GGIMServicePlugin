//
//  GGMessage.h
//  LibGaduWrapper
//
//  Created by Paweł Ksieniewicz on 06.01.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGMessage : NSObject{
    NSString *GGNumber, *GGMessageBody;
}

- (id)initWithNumber:(NSString *) numberString andMessageBody:(NSString *)messageString;

@property (nonatomic, retain) NSString *GGNumber;
@property (nonatomic, retain) NSString *GGMessageBody;

@end
