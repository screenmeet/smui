//
//  SMWidget.h
//  SMWidget
//
//  Created by Adrian Cayaco on 07/09/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMWidget;

@protocol SMWidgetDelegate <NSObject>

@optional
- (void)streamControllActionPlay:(BOOL)play;
- (void)streamControllActionPause:(BOOL)pause;

@end

@interface SMWidget : UIView

@property (assign, nonatomic, readonly) BOOL isLive;
@property (assign, nonatomic, readonly) BOOL isVisible;
@property (assign, nonatomic, readonly) BOOL isStreaming;

@property (weak, nonatomic) id<SMWidgetDelegate> delegate;

// to refresh UI
- (void)updateUI;

// set different UI
- (void)showDefaultUI;
- (void)showLiveUI;
- (void)showStreamingUI;

- (void)showWidget;
- (void)hideWidget;

@end
