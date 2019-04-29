//
//  MFNewCommentTableViewCell.m
//  botmusic
//
//  Created by Panda Systems on 11/10/15.
//
//

#import "MFNewCommentTableViewCell.h"

@implementation MFNewCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.tappableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped)]];
    self.commentField.tintColor = [UIColor whiteColor];
    [self.bubbleView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) avatarTapped{
    [self.delegate didTappedAvatarAtCell:self];
}

- (void) longPressed{
    UIMenuController* menu = [UIMenuController sharedMenuController];
    //CGRect frame = [self.superview convertRect:self.bubbleView.frame fromView:self];
    [menu setTargetRect:self.bubbleView.frame inView:self];
    [menu setMenuVisible:YES];
    menu.menuItems = @[[[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(editComment:)]];
    [self becomeFirstResponder];
    [menu update];

}

- (BOOL)canBecomeFirstResponder{
    if (self.commentField.editable) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (
            action == @selector(copy:) ||
            (action == @selector(delete:) && _isMyComment) ||
            (action == @selector(editComment:) && _isMyComment)
            );
}

- (void)copy:(id)sender{
    [UIPasteboard generalPasteboard].string = self.commentField.text;
}

- (void)delete:(id)sender{
    [self.delegate didSelectDeleteComment:self];
}

- (void)editComment:(id)sender{
    [self.delegate didSelectEditComment:self];
}
@end
