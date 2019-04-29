//
//  MFPlayerAnimationView.h
//  botmusic
//
//  Created by Panda Systems on 12/16/15.
//
//

#import <UIKit/UIKit.h>

@interface MFPlayerAnimationView : UIView

+(MFPlayerAnimationView*)playerAnimationViewWithFrame:(CGRect)frame color:(UIColor*)color;

-(void)startAnimating;
-(void)stopAnimating;
@property (nonatomic, readonly) BOOL isAnimating;

@end
