//
//  MFCommentTableCell.m
//  botmusic
//
//  Created by Supervisor on 22.09.14.
//
//

#import "MFCommentTableCell.h"
#import "MGSwipeButton.h"
#import <UIColor+Expanded.h>

@interface MFCommentTableCell()

@property(nonatomic,strong)MFCommentView *commentView;

@end

@implementation MFCommentTableCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.commentView=[[[NSBundle mainBundle] loadNibNamed:@"MFCommentView" owner:nil options:nil] lastObject];
        [self.commentView setFrame:self.commentView.bounds];
        [self.contentView addSubview:self.commentView];
        
//        MGSwipeButton *button=[MGSwipeButton buttonWithTitle:@"Remove" backgroundColor:[UIColor selectedColor]];
//        [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
//        self.rightButtons = @[button];
//        self.rightSwipeSettings.transition = MGSwipeTransitionStatic;
//        
//        [self setBackgroundColor:[UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:244.0f/255 alpha:1.0f]];
    }
    return self;
}

- (void)setCommentInfo:(MFCommentItem*)commentItem
{
    [self.commentView setCommentInfo:commentItem];
}

- (void)setActivityInfo:(MFActivityItem *)activityItem
{
    [self.commentView setActivityInfo:activityItem];
}

- (void)setInitialPostDateInfo:(NSDictionary *)dictionary
{
    [self.commentView setInitialPostDateInfo:dictionary];
}

- (void)setProposalInfo:(MFFollowItem*)followItem
{
    [self.commentView setProposalInfo:followItem];
}

- (void)setCommentDelegate:(id<MFCommentViewDelegate>)delegate
{
    [self.commentView setDelegate:delegate];
}

- (void)setSeparatorViewHidden:(BOOL)hidden
{
    [self.commentView setSeparatorViewHidden:hidden];
}

+ (CGFloat)heightForComment:(MFCommentItem*)commentItem
{
    return [MFCommentView heightForComment:commentItem];
}

+ (CGFloat)heightForActivity:(MFActivityItem *)activityItem
{
    return [MFCommentView heightForActivity:activityItem];
}

@end
