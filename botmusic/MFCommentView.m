//
//  MFCommentView.m
//  botmusic
//
//  Created by Supervisor on 22.09.14.
//
//

#import "MFCommentView.h"
#import <UIColor+Expanded.h>
#import "MFCommentItem+Behavior.h"
#import "MFActivityItem+Behavior.h"
#import "MFUserInfo+Behavior.h"
#import "UIImageView+WebCache_FadeIn.h"

#define COMMENT_LABEL_FRAME CGRectMake(35, 30, 260, 10000)

@interface MFCommentView()

@property (nonatomic, strong) MFCommentItem *commentItem;
@property (nonatomic, strong) MFActivityItem *activityItem;

@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *autorImage;
@property (nonatomic, weak) IBOutlet UILabel *autorNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentIconLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UITextView *commentTextView;
@property (nonatomic,strong) NSDictionary* initialPostDictionary;
@property (nonatomic, readonly) BOOL isComment;

@end

@implementation MFCommentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [self roundAutorAvatar];
    [_separatorView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
    UITapGestureRecognizer *avatarTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserProfile)];
    [_autorImage addGestureRecognizer:avatarTapRecognizer];
    
    UITapGestureRecognizer *usernameTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserProfile)];
    [_autorNameLabel addGestureRecognizer:usernameTapRecognizer];
}

- (BOOL)isComment {
    return _commentItem != nil;
}

- (void)setSeparatorViewHidden:(BOOL)hidden {
    self.separatorView.hidden = hidden;
}

#pragma mark - Info setters

- (void)setCommentInfo:(MFCommentItem *)commentItem {
    _commentItem = commentItem;
    
    [_commentTimeLabel setHidden:NO];
    
    [_commentLabel setFrame:[self commentLabelFrame]];
    
    _commentLabel.attributedText=[self hightlightMetionsFor:commentItem.comment];
    if ([commentItem.user_name isEqual:[NSNull null]]) {
        commentItem.user_name = @"";
    }
    _autorNameLabel.text=commentItem.user_name;
    _commentTimeLabel.text=[commentItem postTime];
    
    [_autorImage sd_setImageWithURL:[NSURL URLWithString:commentItem.autorAvatarUrl] placeholderImage:[UIImage imageNamed:@"NoImage"]];
    
    [_autorNameLabel sizeToFit];
    [_commentLabel sizeToFit];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, _commentLabel.frame.origin.y + _commentLabel.frame.size.height);
    
    CGRect authorFrame=_autorNameLabel.frame;
    authorFrame.size.height = 20.0f;
    [_autorNameLabel setFrame:authorFrame];
    
    CGRect iconFrame=_commentIconLabel.frame;
    iconFrame.origin.x = _autorNameLabel.frame.origin.x + _autorNameLabel.frame.size.width + 5;
    [_commentIconLabel setFrame:iconFrame];
    
    CGRect frame=_commentTimeLabel.frame;
    frame.origin.x=_commentIconLabel.frame.origin.x + _commentIconLabel.frame.size.width;
    [_commentTimeLabel setFrame:frame];
//    [_commentTimeLabel sizeToFit];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnText:)];
    [tap setNumberOfTapsRequired:1];
    [_commentLabel addGestureRecognizer:tap];
    
    [self setFrame:rect];
    [_backgroundView setFrame:rect];
}

- (void)setActivityInfo:(MFActivityItem *)activityItem {
    _activityItem = activityItem;
    
    [_commentTimeLabel setHidden:NO];
    
    [_commentLabel setFrame:[self commentLabelFrame]];
    
    if (activityItem.type == IRActivityTypeComment) {
        _commentLabel.attributedText = [self hightlightMetionsFor:activityItem.comment];
    } else {
        _commentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    _autorNameLabel.text = activityItem.userName;
    _commentTimeLabel.text = _activityItem.postTime;
    
    [self setActivityIcon];
    
    [_autorImage sd_setImageWithURL:[NSURL URLWithString:activityItem.userAvatarUrl] placeholderImage:[UIImage imageNamed:@"NoImage"]];
    
    [_autorNameLabel sizeToFit];
    [_commentLabel sizeToFit];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, _commentLabel.frame.origin.y + _commentLabel.frame.size.height);
    
    CGRect authorFrame=_autorNameLabel.frame;
    authorFrame.size.height = 20.0f;
    [_autorNameLabel setFrame:authorFrame];
    
    CGRect iconFrame=_commentIconLabel.frame;
    iconFrame.origin.x = _autorNameLabel.frame.origin.x + _autorNameLabel.frame.size.width + 5;
    [_commentIconLabel setFrame:iconFrame];
    
    CGRect frame=_commentTimeLabel.frame;
    frame.origin.x=_commentIconLabel.frame.origin.x + _commentIconLabel.frame.size.width;
    [_commentTimeLabel setFrame:frame];
    //    [_commentTimeLabel sizeToFit];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnText:)];
    [tap setNumberOfTapsRequired:1];
    [_commentLabel addGestureRecognizer:tap];
    
    [self setFrame:rect];
    [_backgroundView setFrame:rect];
}

- (void)setInitialPostDateInfo:(NSDictionary *)dictionary{
    
    _activityItem = nil;
    self.initialPostDictionary = dictionary;
    [_commentTimeLabel setHidden:NO];
    
    [_commentLabel setFrame:[self commentLabelFrame]];
    
    _commentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    
    _autorNameLabel.text = dictionary[@"userName"];
    _commentTimeLabel.text = dictionary[@"postDate"];
    
    self.commentIconLabel.text = [NSString stringWithUTF8String:"\uF170"];
    self.commentIconLabel.textColor = [UIColor colorWithRGBHex:kLightColor];
    if (dictionary[@"userAvatarUrl"]) {
        [_autorImage sd_setImageWithURL:[NSURL URLWithString:dictionary[@"userAvatarUrl"]] placeholderImage:[UIImage imageNamed:@"NoImage"]];
    }
    
    [_autorNameLabel sizeToFit];
    [_commentLabel sizeToFit];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, _commentLabel.frame.origin.y + _commentLabel.frame.size.height);
    
    CGRect authorFrame=_autorNameLabel.frame;
    authorFrame.size.height = 20.0f;
    [_autorNameLabel setFrame:authorFrame];
    
    CGRect iconFrame=_commentIconLabel.frame;
    iconFrame.origin.x = _autorNameLabel.frame.origin.x + _autorNameLabel.frame.size.width + 5;
    [_commentIconLabel setFrame:iconFrame];
    
    CGRect frame=_commentTimeLabel.frame;
    frame.origin.x=_commentIconLabel.frame.origin.x + _commentIconLabel.frame.size.width;
    [_commentTimeLabel setFrame:frame];
    //    [_commentTimeLabel sizeToFit];
    
    [self setFrame:rect];
    [_backgroundView setFrame:rect];
}


- (void)setActivityIcon {
    switch (self.activityItem.type) {
        case IRActivityTypeComment:
            self.commentIconLabel.text = [NSString stringWithUTF8String:"\uF150"];
            self.commentIconLabel.textColor = [UIColor colorWithRGBHex:kLightColor];
            break;
        case IRActivityTypeUserLike:
            self.commentIconLabel.text = [NSString stringWithUTF8String:"\uF140"];
            self.commentIconLabel.textColor = [UIColor colorWithRGBHex:kBrandPinkColor];
            break;
        case IRActivityTypePlaylist:
            self.commentIconLabel.text = [NSString stringWithUTF8String:"\uF170"];
            self.commentIconLabel.textColor = [UIColor colorWithRGBHex:kLightColor];
            break;
        default:
            break;
    }
}

- (void)setProposalInfo:(MFFollowItem *)followItem {
    [_commentTimeLabel setHidden:YES];
    
    [_commentLabel setFrame:[self commentLabelFrame]];
    
    _commentLabel.text=[NSString stringWithFormat:@"@%@",followItem.username];
    _autorNameLabel.text=followItem.name;
    [_autorImage sd_setImageWithURL:[NSURL URLWithString:followItem.picture] placeholderImage:[UIImage imageNamed:@"NoImage"]];
    
    [_autorNameLabel sizeToFit];
    [_commentLabel sizeToFit];
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, _commentLabel.frame.origin.y + _commentLabel.frame.size.height);
    
    [self setFrame:rect];
    [_backgroundView setFrame:rect];
}

#pragma mark - Calculate cell height

+ (CGFloat)heightForComment:(MFCommentItem *)commentItem {
    MFCommentView *cell=[[[NSBundle mainBundle]loadNibNamed:@"MFCommentView" owner:nil options:nil]lastObject];
    if ([commentItem.comment isEqual:[NSNull null]]) {
        commentItem.comment = @"";
    }
    cell.commentLabel.attributedText = [MFCommentView attributedTextFor:commentItem.comment];
    [cell.commentLabel sizeToFit];
    
    return cell.commentLabel.frame.origin.y+CGRectGetHeight(cell.commentLabel.frame)+5;
}

+ (CGFloat)heightForActivity:(MFActivityItem *)activityItem {
    if (activityItem.type == IRActivityTypeComment) {
        MFCommentView *cell = [[[NSBundle mainBundle]loadNibNamed:@"MFCommentView" owner:nil options:nil] lastObject];
        cell.commentLabel.attributedText = [MFCommentView attributedTextFor:activityItem.comment];
        [cell.commentLabel sizeToFit];
        
        return cell.commentLabel.frame.origin.y + CGRectGetHeight(cell.commentLabel.frame) + 5;
    } else {
        return 40.0f;
    }
}

#pragma mark - Helpers

- (NSAttributedString*)hightlightMetionsFor:(NSString*)comment {
    if ([comment isEqual:[NSNull null]]) {
        comment = @"";
    }
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc]initWithString:comment];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRGBHex:kDarkColor] range:NSMakeRange(0,[comment length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f] range:NSMakeRange(0,[comment length])];
    
    NSError *error;
    NSRegularExpression *regExp=[[NSRegularExpression alloc]initWithPattern:@"@[a-zA-Z0-9_]+" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *urlRegExp=[[NSRegularExpression alloc]initWithPattern:@"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&amp;=]*)?" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if(!error)
    {
        NSArray *matches = [regExp matchesInString:comment options:0 range:NSMakeRange(0, [comment length])];
        
        for(NSTextCheckingResult *match in matches)
        {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:202.0f/255 green:31.0f/255 blue:89.0f/255 alpha:1.0] range:[match range]];
        }
        matches = [urlRegExp matchesInString:comment options:0 range:NSMakeRange(0, [comment length])];
        for(NSTextCheckingResult *match in matches)
        {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:86.0f/255 green:113.0f/255 blue:230.0f/255 alpha:1.0] range:[match range]];
        }
    }
    
    return attributedString;
}

+ (NSAttributedString*)attributedTextFor:(NSString*)comment {
    if ([comment isEqual:[NSNull null]]) {
        comment = @"";
    }
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc]initWithString:comment];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRGBHex:kDarkColor] range:NSMakeRange(0,[comment length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f] range:NSMakeRange(0,[comment length])];
    
    /*
    NSError *error;
    NSRegularExpression *regExp=[[NSRegularExpression alloc]initWithPattern:@"@[a-zA-Z0-9_]+" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *urlRegExp=[[NSRegularExpression alloc]initWithPattern:@"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&amp;=]*)?" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if(!error)
    {
        NSArray *matches = [regExp matchesInString:comment options:0 range:NSMakeRange(0, [comment length])];
        
        for(NSTextCheckingResult *match in matches)
        {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:202.0f/255 green:31.0f/255 blue:89.0f/255 alpha:1.0] range:[match range]];
        }
        matches = [urlRegExp matchesInString:comment options:0 range:NSMakeRange(0, [comment length])];
        for(NSTextCheckingResult *match in matches)
        {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:86.0f/255 green:113.0f/255 blue:230.0f/255 alpha:1.0] range:[match range]];
        }
    }
    */
    
    return attributedString;
}

- (void)roundAutorAvatar {
    _autorImage.layer.cornerRadius = _autorImage.frame.size.width / 2;
    [_autorImage setClipsToBounds:YES];
}

#pragma mark - Taps

- (void)didTapOnText:(UITapGestureRecognizer *)recognizer {
    UILabel *gestureRecipient = (UILabel*)recognizer.view;
    UITextView *textRegionClone = [[UITextView alloc] initWithFrame:gestureRecipient.frame];
    
    // tweak the text view's content area to get the same rendering (placement and wrapping)
    textRegionClone.textContainerInset = UIEdgeInsetsMake(0.0, -5.0, 0.0, -5.0);
    // copy the label's text properties
    textRegionClone.attributedText = gestureRecipient.attributedText;
    textRegionClone.text = gestureRecipient.text;
    textRegionClone.font = gestureRecipient.font;
    [textRegionClone setNeedsDisplay];
    CGPoint loc = [recognizer locationInView:gestureRecipient];
    UITextPosition *charR = [textRegionClone closestPositionToPoint:loc];
    
    id<UITextInputTokenizer> tokenizer = textRegionClone.tokenizer;
    UITextRange *searchRange = [tokenizer rangeEnclosingPosition:charR withGranularity:UITextGranularityCharacter inDirection:UITextStorageDirectionBackward];
    NSString *commaEnclosedText = @"";
    
    if (searchRange != nil) {
        NSString *tapChar = [textRegionClone textInRange:searchRange];
        
        if ([tapChar isEqualToString:@" "]) { // tapped right on a ","
            // move the end of the range to immediately before the ","
            searchRange = [textRegionClone textRangeFromPosition:searchRange.start toPosition:[textRegionClone positionFromPosition:searchRange.end offset:-1]];
        }
        
        UITextPosition *docStart = textRegionClone.beginningOfDocument;
        
        // search back to find the leading comma or the beginning of the text
        do {
            searchRange = [textRegionClone textRangeFromPosition:[textRegionClone positionFromPosition:searchRange.start offset:-1] toPosition:searchRange.end];
            commaEnclosedText = [textRegionClone textInRange:searchRange];
        }
        while (([searchRange.start isEqual:docStart] == NO) && (([commaEnclosedText characterAtIndex:0] != ' ') && ([commaEnclosedText characterAtIndex:0] != '\n')));
        
        // now search forward to the trailing comma or the end of the text
        UITextPosition *docEnd = textRegionClone.endOfDocument;
        
        while (([searchRange.end isEqual:docEnd] == NO) && (([commaEnclosedText characterAtIndex:commaEnclosedText.length - 1] != ' ') && ([commaEnclosedText characterAtIndex:commaEnclosedText.length - 1] != '\n') && ([commaEnclosedText characterAtIndex:commaEnclosedText.length - 1] != ','))) {
            searchRange = [textRegionClone textRangeFromPosition:searchRange.start toPosition:[textRegionClone positionFromPosition:searchRange.end offset:1]];
            commaEnclosedText = [textRegionClone textInRange:searchRange];
        }
        
        commaEnclosedText = [[commaEnclosedText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    NSError *error;
    NSRegularExpression *urlRegExp=[[NSRegularExpression alloc]initWithPattern:@"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&amp;=]*)?" options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        NSArray *matches = [urlRegExp matchesInString:commaEnclosedText options:0 range:NSMakeRange(0, [commaEnclosedText length])];
        if (matches.count > 0) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:commaEnclosedText]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:commaEnclosedText]];
            }
        }
    }
}

#pragma mark - Tap Events

- (void)openUserProfile {
    if (_delegate && [_delegate respondsToSelector:@selector(shouldOpenUserProfileWithUserInfo:)]) {
        MFUserInfo *userInfo;
        if (self.isComment) {
            userInfo = [dataManager getUserInfoInContextbyExtID:_commentItem.userExtId];
            userInfo.username = _commentItem.user_name;
            userInfo.facebookID = _commentItem.autorFacebookId;
            userInfo.extId = _commentItem.userExtId;
        } else {
            if (_activityItem) {
                userInfo = [dataManager getUserInfoInContextbyExtID:_activityItem.userExtId];
                userInfo.username = _activityItem.userName;
                userInfo.facebookID = _activityItem.userFacebookId;
                userInfo.extId = _activityItem.userExtId;
            } else {
                userInfo = [dataManager getUserInfoInContextbyExtID:self.initialPostDictionary[@"userId"]];
                userInfo.extId = self.initialPostDictionary[@"userId"];
            }
        }
        [_delegate shouldOpenUserProfileWithUserInfo:userInfo];
    }
}

-(CGRect)commentLabelFrame{
    return CGRectMake(35, 30, [UIScreen mainScreen].bounds.size.width - 60.0f , 10000);
}
@end
