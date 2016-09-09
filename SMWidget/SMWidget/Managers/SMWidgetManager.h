//
//  SMWidgetManager.h
//  SMWidget_Example
//
//  Created by Adrian Cayaco on 07/09/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMWidgetManager : NSObject

+ (SMWidgetManager *)sharedManager;

- (void)initializeSMWidget;

@end
