//
//  CommentCell.m
//  botmusic
//
//  Created by Supervisor on 01.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+WebCache_FadeIn.h"
static NSInteger const DELETE_WIDTH=80.0f;
static CGFloat const COMMENT_CELL_HEIGHT=46.0f;
#define COMMET_LABEL_FRAME CGRectMake(70, 25, 239, 10000)

@interface CommentCell()

@property(nonatomic,weak)IBOutlet UIImageView *autorImage;
@property(nonatomic,weak)IBOutlet UILabel *autorNameLabel;
@property(nonatomic,weak)IBOutlet UILabel *commentTimeLabel;
@property(nonatomic,weak)IBOutlet UILabel *commentLabel;

-(IBAction)didTouchUpDeleteButton:(id)sender;

@end

@implementation CommentCell

- (void)awakeFromNib
{
    [self roundAutorAvatar];
    [self.sliderView setSliderViewDelegate:self];
}
-(void)setCanEdit:(BOOL)canEdit
{
    [self.sliderView setOpenWidth:DELETE_WIDTH];
    [self.sliderView setCanOpenRightSide:canEdit];
}

#pragma mark - Info setters

-(void)setCommentInfo:(MFCommentItem*)commentItem
{
    [_commentTimeLabel setHidden:NO];
    
    [_commentLabel setFrame:COMMET_LABEL_FRAME];
    
    _commentLabel.attributedText=[self hightlightMetionsFor:commentItem.comment];
    _autorNameLabel.text=commentItem.user_name;
    _commentTimeLabel.text=[commentItem postTime];
    [_autorImage sd_setImageAndFadeOutWithURL:[NSURL URLWithString:commentItem.autorAvatarUrl] placeholderImage:nil];
    
    [_autorNameLabel sizeToFit];
    [_commentLabel sizeToFit];
    
    CGRect frame=_commentTimeLabel.frame;
    frame.origin.x=_autorNameLabel.frame.origin.x+_autorNameLabel.frame.size.width+5;
    [_commentTimeLabel setFrame:frame];
    [_commentTimeLabel sizeToFit];
}
-(void)setProposalInfo:(MFFollowItem*)followItem
{
    [_commentTimeLabel setHidden:YES];
    
    [_commentLabel setFrame:COMMET_LABEL_FRAME];
    
    _commentLabel.text=[NSString stringWithFormat:@"@%@",followItem.username];
    _autorNameLabel.text=followItem.name;
    [_autorImage sd_setImageAndFadeOutWithURL:[NSURL URLWithString:followItem.picture] placeholderImage:nil];
    
    [_autorNameLabel sizeToFit];
    [_commentLabel sizeToFit];
}

#pragma mark - SSSliderViewDelegate methods

-(void)willOpenSlider
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didOpenDelete:)])
    {
        [self.delegate didOpenDelete:self];
    }
}
-(void)didCloseSlider
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didCloseDelete:)]){
        [self.delegate didCloseDelete:self];
    }
}

#pragma mark - Calculate cell height

+(CGFloat)heightForComment:(MFCommentItem *)commentItem
{
    CommentCell *cell=[[[NSBundle mainBundle]loadNibNamed:@"CommentCell" owner:nil options:nil]lastObject];
    if ([commentItem.comment isEqual:[NSNull null]]) {
        cell.commentLabel.text = @"";
    }
    else {
        cell.commentLabel.text = commentItem.comment;
    }
    [cell.commentLabel sizeToFit];
    
    return cell.commentLabel.frame.origin.y+CGRectGetHeight(cell.commentLabel.frame)+5;
}


#pragma mark - IBActions

-(IBAction)didTouchUpDeleteButton:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectDelete:)])
    {
        
        [_delegate didSelectDelete:self];
    }
}

#pragma mark - Helpers

-(NSAttributedString*)hightlightMetionsFor:(NSString*)comment
{
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc]initWithString:comment];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[comment length])];
    
    NSError *error;
    NSRegularExpression *regExp=[[NSRegularExpression alloc]initWithPattern:@"@[a-zA-Z0-9_]+" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if(!error)
    {
        NSArray *matches=[regExp matchesInString:comment options:0 range:NSMakeRange(0, [comment length])];
        
        for(NSTextCheckingResult *match in matches)
        {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:202.0f/255 green:31.0f/255 blue:89.0f/255 alpha:1.0] range:[match range]];
        }
    }
    
    return attributedString;
}
-(void)roundAutorAvatar
{
    _autorImage.layer.cornerRadius = _autorImage.frame.size.width / 2;
    [_autorImage setClipsToBounds:YES];
    
}

@end
