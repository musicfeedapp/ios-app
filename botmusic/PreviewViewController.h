//
//  PreviewViewController.h
//  botmusic
//
//  Created by Dzionis Brek on 24.02.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"
#import "DDPageControl.h"
#import "MFTrackItem+Behavior.h"

@interface PreviewViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property(nonatomic,strong)MFTrackItem *tutorialTrack;
@property(nonatomic,copy)NSString *friendPicture;
@property(nonatomic,copy)NSString *artistPicture;
@property(nonatomic,copy)NSString *friendUsername;
@property(nonatomic,copy)NSString *artistUsername;

@property(nonatomic,strong)PageViewController* pageVC;
@property(nonatomic,strong) NSArray* pageVCs;

@property(nonatomic,strong)DDPageControl *pageControl;

@end
