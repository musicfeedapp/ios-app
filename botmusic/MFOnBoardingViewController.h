//
//  MFOnBoardingViewController.h
//  botmusic
//
//  Created by Panda Systems on 8/24/15.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MFOnBoardingViewControllerPresentationModeFull,
    MFOnBoardingViewControllerPresentationModeConnectingServices,
    MFOnBoardingViewControllerPresentationModeSelectingGenres,
    MFOnBoardingViewControllerPresentationModeFollow,
} MFOnBoardingViewControllerPresentationMode;

@interface MFOnBoardingViewController : AbstractViewController
@property (nonatomic) MFOnBoardingViewControllerPresentationMode presentationMode;
@property (nonatomic) BOOL isShownFromBottom;
@end
