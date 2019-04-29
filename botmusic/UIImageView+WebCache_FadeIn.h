//
//  UIImageView+WebCache_FadeIn.h
//  botmusic
//
//  Created by Panda Systems on 1/26/16.
//
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface UIImageView (WebCache_FadeIn)

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url;

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setAvatarWithUrl:(NSURL*)url name:(NSString*)name;
- (void)sd_setAvatarWithUrl:(NSURL*)url name:(NSString*)name cropRoundedImage:(BOOL)cropRoundedImage;
- (void)hideInitialsLabel;
@end
