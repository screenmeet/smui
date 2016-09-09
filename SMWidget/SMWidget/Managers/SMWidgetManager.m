//
//  SMWidgetManager.m
//  SMWidget_Example
//
//  Created by Adrian Cayaco on 07/09/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import "SMWidgetManager.h"
#import "SMWidget.h"

#define kSMWidgetTag  2002
#define kWidgetHeight 50.0f
#define kWidgetWidth  40.0f

@interface SMWidgetManager ()

@property (strong, nonatomic) SMWidget *smWidget;

@end

@implementation SMWidgetManager

static SMWidgetManager *manager = nil;

@synthesize smWidget = _smWidget;

+ (SMWidgetManager *)sharedManager
{
    @synchronized(self) {
        if (!manager) {
            manager = (SMWidgetManager *)[[self alloc] init];
        }
    }
    return manager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

#pragma mark - Accessors

- (SMWidget *)smWidget
{
    if (!_smWidget) {
        _smWidget     = [[SMWidget alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - kWidgetWidth, ([UIScreen mainScreen].bounds.size.height-kWidgetHeight)/2, kWidgetWidth, kWidgetHeight)];
        _smWidget.tag = kSMWidgetTag;
    }
    return _smWidget;
}

#pragma mark - Private Methods

#pragma mark - Public Methods

- (BOOL)isSMWidgetInitialized
{
    if ([[[UIApplication sharedApplication] delegate].window viewWithTag:kSMWidgetTag]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)initializeSMWidget
{
    if (![self isSMWidgetInitialized]) {
        [[[UIApplication sharedApplication] delegate].window addSubview:self.smWidget];
    }
    
    [[[UIApplication sharedApplication] delegate].window bringSubviewToFront:self.smWidget];
    
    [self.smWidget showWidget];
}

@end
