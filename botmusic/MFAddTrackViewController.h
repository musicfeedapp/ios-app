//
//  MFAddTrackViewController.h
//  botmusic
//

#import <UIKit/UIKit.h>

@interface MFAddTrackViewController : AbstractViewController
@property (weak, nonatomic) FXBlurView *blurView;
@property (nonatomic) BOOL shouldStartRecognizeImmediatelyAfterViewAppeared;
- (void)startRecognitionImediately;
@end
