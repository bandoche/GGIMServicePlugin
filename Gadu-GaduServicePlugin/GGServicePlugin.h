//
//  GGServicePlugin.h
//  Gadu-GaduServicePlugin
//
//  Created by Paweł Ksieniewicz on 26.12.2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IMServicePlugIn/IMServicePlugIn.h>
#import "LibGaduWrapper.hh"

@interface GGServicePlugin : NSObject <IMServicePlugIn,IMServicePlugInGroupListSupport,IMServicePlugInInstantMessagingSupport, IMServicePlugInGroupListHandlePictureSupport>{
    id<IMServiceApplication, IMServiceApplicationGroupListSupport, IMServiceApplicationInstantMessagingSupport> _application;
    
    NSDictionary *_accountSettings;
    
    NSTimer *pingTimer;
    LibGaduWrapper *gadu;
}

@end
