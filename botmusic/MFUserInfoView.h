//
//  MFUserInfoView.h
//  botmusic
//
//  Created by navakdzmitry on 1/26/15.
//
//

#import <UIKit/UIKit.h>

@protocol MFUserInfoViewDelegate <NSObject>

- (void)didTapFollowButton;
- (void)didTapProfilePicture;

@end

@interface MFUserInfoView : UIView

@property (nonatomic, weak) id <MFUserInfoViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView* profileBackground;
@property (nonatomic, weak) IBOutlet UIImageView* profilePicture;

- (void)setProfileImage:(NSURL*)imageUrl;
- (void)animateBigUserView:(BOOL)bigger;
- (void)animateSmallUserView:(BOOL)bigger;

- (void)setHeaderTitle:(NSString*)title;
- (void)showCheckmark:(BOOL)show;
- (void)animate:(CGFloat)phase;

@end
