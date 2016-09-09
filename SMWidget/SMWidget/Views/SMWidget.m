//
//  SMWidget.m
//  SMWidget
//
//  Created by Adrian Cayaco on 07/09/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import "SMWidget.h"
#import "SMWidgetItem.h"

#define kDefaultFrame           CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)
#define kDefaultFlipThreshold   0.75

@interface SMWidget ()

@property (strong, nonatomic) UIButton    *interactionButton;
@property (strong, nonatomic) UIView      *widgetItemsContainer;

@property (strong, nonatomic) SMWidgetItem *streamControlItem;
@property (strong, nonatomic) SMWidgetItem *inviteItem;
@property (strong, nonatomic) SMWidgetItem *viewersItem;
@property (strong, nonatomic) SMWidgetItem *stopStreamItem;
@property (strong, nonatomic) SMWidgetItem *viewerCountItem;

@property (strong, nonatomic) NSArray      *widgetItems;

@property (assign, nonatomic) CGFloat offset;
@property (assign, nonatomic) CGFloat itemWidth;

@property (assign, nonatomic) BOOL wasDragged;

@property (assign, nonatomic) BOOL isLive;
@property (assign, nonatomic) BOOL isVisible;
@property (assign, nonatomic) BOOL isStreaming;

@end

@implementation SMWidget

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)dealloc
{
    [self.interactionButton removeTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.interactionButton removeTarget:self action:@selector(interactionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.streamControlItem removeTarget:self action:@selector(streamControlItemWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - Private Methods

- (void)commonInit
{
    // set bounds
    CGRect frame = kDefaultFrame;
    
    if (self.frame.size.height != 0.0f || self.frame.size.width != 0.0f) {
        frame.size     = self.frame.size;
        // set the origin to be right anchored
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width;
    } else {
        self.frame = frame;
    }
    
    self.itemWidth                                   = self.frame.size.width;

    self.widgetItemsContainer                        = [[UIImageView alloc] init];
    self.widgetItemsContainer.frame                  = self.bounds;
    self.widgetItemsContainer.userInteractionEnabled = YES;

    self.interactionButton                           = [[UIButton alloc] initWithFrame:self.bounds];
    
    // set UI
    [self showDefaultUI];
    
    self.alpha  = 0.0f;
    self.hidden = YES;
    
    [self addSubview:self.widgetItemsContainer];
    [self initiateItems];
    [self addSubview:self.interactionButton];
    
    [self addObservers];
    
    self.isStreaming = YES;
}

- (void)dragMoving:(UIControl *)control withEvent:(UIEvent *)event
{
    // set flag to eliminate false positives
    self.wasDragged = YES;
    
    // calculate the position for the touch event and adjust the current center
    // only allow vertical movement
    CGPoint movement = [[[event allTouches] anyObject] locationInView:self.superview];
    
    CGFloat threshold = self.frame.size.height;
    
    if (movement.y > threshold && movement.y < ([UIScreen mainScreen].bounds.size.height - threshold)) {
        self.center = CGPointMake(self.center.x, movement.y);
    }
}

- (void)interactionButtonWasPressed:(UIButton *)button
{
    if (self.wasDragged) {
        // don't trigger since it was a false positive
        // the message came from an event from drag
        // reset flag
        self.wasDragged = NO;
    } else {
        if (self.frame.size.width > self.itemWidth) {
            [self compressWidget];
        } else {
            [self expandWidget];
        }
    }
}

- (void)initiateItems
{
    CGRect frame = self.bounds;
    
    UIEdgeInsets normalIconInset = UIEdgeInsetsMake(15.0f, 10.0f, 15.0f, 10.0f);
    UIEdgeInsets inviteIconInset = UIEdgeInsetsMake(8.0f, 5.0f, 8.0f, 5.0f);
    
    // 1st item
    self.inviteItem = [[SMWidgetItem alloc] initWithFrame:frame];
    
    [self.inviteItem setImage:[UIImage imageNamed:@"smwi_invite"] forState:UIControlStateNormal];
    [self.inviteItem setImageEdgeInsets:inviteIconInset];
    
    frame.origin.x    -= 10.0f;
    frame.origin.y    -= 10.0f;
    frame.size.width  = 30.0f;
    frame.size.height = 30.0f;
    
    self.viewerCountItem = [[SMWidgetItem alloc] initWithFrame:frame];
    
    [self.viewerCountItem setBackgroundImage:[UIImage imageNamed:@"smwi_badge"] forState:UIControlStateNormal];
    [self.viewerCountItem setTitle:@"10" forState:UIControlStateNormal];
    [self.viewerCountItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.viewerCountItem setTitleEdgeInsets:inviteIconInset];
    
//    self.viewerCountItem.backgroundColor = [UIColor lightGrayColor];
//    self.viewerCountItem.titleLabel.backgroundColor = [UIColor yellowColor];
    
    frame = self.inviteItem.frame;
    frame.origin.x += self.itemWidth;
    
    // 2nd item
    self.stopStreamItem = [[SMWidgetItem alloc] initWithFrame:frame];
    
    [self.stopStreamItem setImage:[UIImage imageNamed:@"smwi_stop"] forState:UIControlStateNormal];
    [self.stopStreamItem setImageEdgeInsets:normalIconInset];
    
    frame.origin.x += self.itemWidth;
    
    // 3rd item
    self.streamControlItem = [[SMWidgetItem alloc] initWithFrame:frame];
    
    [self.streamControlItem setImage:[UIImage imageNamed:@"smwi_pause"] forState:UIControlStateNormal];
    [self.streamControlItem setImageEdgeInsets:normalIconInset];
    
    frame.origin.x += self.itemWidth;
    // 4th item
    self.viewersItem = [[SMWidgetItem alloc] initWithFrame:frame];
    
    [self.viewersItem setImage:[UIImage imageNamed:@"smwi_viewers"] forState:UIControlStateNormal];
    [self.viewersItem setImageEdgeInsets:normalIconInset];
    
    self.widgetItems = @[self.inviteItem, self.viewerCountItem, self.stopStreamItem, self.streamControlItem, self.viewersItem];
    
    for (SMWidgetItem *anItem in self.widgetItems) {
        if (anItem == self.viewerCountItem) {
            [self addSubview:anItem];
        } else {
            [self.widgetItemsContainer addSubview:anItem];
        }
    }
}

-(void)roundCornersOnView:(id)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius
{
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView     = view;
        
        roundedView.layer.mask  = nil;
        
        UIBezierPath *maskPath  = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        
        maskLayer.frame         = roundedView.bounds;
        maskLayer.path          = maskPath.CGPath;
        
        roundedView.layer.mask  = maskLayer;
        
    } else {
    }
}

- (void)addObservers
{
    // listener events for the drag
    [self.interactionButton addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.interactionButton addTarget:self action:@selector(interactionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.streamControlItem addTarget:self action:@selector(streamControlItemWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // observers for the NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Delegate Methods

- (void)streamControlItemWasPressed:(UIButton *)button
{
    
#warning Add more checks for streaming states
    if (self.isStreaming) {
        
        if ([self.delegate respondsToSelector:@selector(streamControllActionPause:)]) {
            [self.delegate streamControllActionPause:YES];
        }
        
        self.isStreaming = NO;
        [self.streamControlItem setImage:[UIImage imageNamed:@"smwi_play"] forState:UIControlStateNormal];
        
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(streamControllActionPlay:)]) {
            [self.delegate streamControllActionPlay:YES];
        }
        
        self.isStreaming = YES;
        [self.streamControlItem setImage:[UIImage imageNamed:@"smwi_pause"] forState:UIControlStateNormal];
    }
    
}

#pragma mark - Public Methods

- (void)updateUI
{
    [self showDefaultUI];
}

- (void)showDefaultUI
{
    [self.interactionButton setImage:nil forState:UIControlStateNormal];
    [self.interactionButton setImageEdgeInsets:UIEdgeInsetsMake(12.0f, 8.0f, 12.0f, 8.0f)];
    
    self.widgetItemsContainer.backgroundColor = [UIColor clearColor];
    self.backgroundColor                      = [UIColor whiteColor];
    
    self.widgetItemsContainer.layer.borderWidth = 1.0f;
    self.widgetItemsContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.widgetItemsContainer
}

- (void)showLiveUI
{
    // same as default UI.
    [self showDefaultUI];
}

- (void)showStreamingUI
{
    [self.interactionButton setImage:[UIImage imageNamed:@"smwi_invite"] forState:UIControlStateNormal];
    
    self.backgroundColor        = [UIColor redColor];
}

- (void)showWidget
{
    if (self.hidden) {
        // just to make sure
        self.alpha  = 0.0f;
        self.hidden = NO;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
    
        self.isVisible = YES;
    }
    
    [self updateUI];
}

- (void)hideWidget
{
    if (!self.hidden) {
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            
            self.isVisible = NO;
        }];
    }
}

- (void)expandWidget
{
    [self.interactionButton setImage:[UIImage imageNamed:@"smwi_collapse"] forState:UIControlStateNormal];
    
    CGRect frame = self.frame;
    
    CGFloat offset = self.itemWidth * 4;
    
    frame.origin.x   -= offset;
    frame.size.width += offset;
    
    CGRect interactionButtonFrame = self.interactionButton.frame;
    
    interactionButtonFrame.origin.x = self.itemWidth * 4.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.frame                      = frame;
        self.interactionButton.frame    = interactionButtonFrame;
        self.widgetItemsContainer.frame = self.bounds;
        
        for (NSInteger index; index == 0; index++) {
            
            SMWidgetItem *anItem = self.widgetItems[index];

            CGRect viewFrame     = anItem.frame;

            viewFrame.origin.x   += (self.itemWidth * index);

            anItem.frame         = viewFrame;
            
        }
    }];
    
}

- (void)compressWidget
{
    [self.interactionButton setImage:nil forState:UIControlStateNormal];
    
    CGRect frame = self.frame;
    
    frame.origin.x   = [UIScreen mainScreen].bounds.size.width - self.itemWidth;
    frame.size.width = self.itemWidth;
    
    CGRect interactionButtonFrame = self.interactionButton.frame;
    
    interactionButtonFrame.origin.x = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.frame                      = frame;
        self.interactionButton.frame    = interactionButtonFrame;
        self.widgetItemsContainer.frame = self.bounds;

        
        for (NSInteger index; index == 0; index++) {
            
            SMWidgetItem *anItem = self.widgetItems[index];

            CGRect viewFrame     = anItem.frame;

            viewFrame.origin.x   -= (self.itemWidth * index);

            anItem.frame         = viewFrame;
            
        }
    }];
}

#pragma mark - Orientation Change

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    // Obtaining the current device orientation
    CGPoint center = self.center;
    center.y       = [UIScreen mainScreen].bounds.size.height/2;
    self.center    = center;
}

#pragma mark - Keyboard Notifications

// Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info        = [aNotification userInfo];
    CGSize kbSize             = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect aRect              = [UIScreen mainScreen].bounds;

    CGFloat widgetBottom      = CGRectGetMaxY(self.frame);
    CGFloat widgetBottomSpace = aRect.size.height - widgetBottom;
    
    if (widgetBottom > (aRect.size.height - kbSize.height)) {
        // always set widget position a little higher then keyboard
        self.offset           = kbSize.height - widgetBottomSpace;
        self.center           = CGPointMake(self.center.x, self.center.y - self.offset - self.frame.size.height/2);
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.offset > 0.0f) {
        self.center           = CGPointMake(self.center.x, self.center.y + self.offset + self.frame.size.height/2);
        self.offset           = 0.0f;
    }
}

@end