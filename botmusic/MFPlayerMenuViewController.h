//
//  MFPlayerMenuViewController.h
//  botmusic
//
//  Created by Panda Systems on 11/19/15.
//
//

#import <UIKit/UIKit.h>

@class MFPlayerMenuViewController;

@protocol MFPlayerMenuViewControllerDelegate <NSObject>
-(void) playerMenuViewControllerDidSelectDone:(MFPlayerMenuViewController*)controller;
@end

@interface MFPlayerMenuViewController : UIViewController
@property(nonatomic, weak) id<MFPlayerMenuViewControllerDelegate> delegate;
-(void)setCurrentTrackProgress:(CGFloat)progress;
@end
