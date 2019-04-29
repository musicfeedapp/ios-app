//
//  UIImageView+WebCache_FadeIn.m
//  botmusic
//
//  Created by Panda Systems on 1/26/16.
//
//

#import "UIImageView+WebCache_FadeIn.h"
#import <objc/runtime.h>
#import "UIColor+Expanded.h"

@implementation UIImageView (WebCache_FadeIn)


- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url {
    [self sd_setImageAndFadeOutWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self sd_setImageAndFadeOutWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setImageAndFadeOutWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageAndFadeOutWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageAndFadeOutWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageAndFadeOutWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)sd_setImageAndFadeOutWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock{
    self.alpha = 0.0;
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        if (image && cacheType == SDImageCacheTypeNone) {
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.0;
            }];
        } else {
            self.alpha = 1.0;
        }
        if (completedBlock) {
            completedBlock(image,error,cacheType,imageURL);
        }

    }];
}

- (void)sd_setAvatarWithUrl:(NSURL*)url name:(NSString*)name{
    [self sd_setAvatarWithUrl:url name:name cropRoundedImage:NO];
}

- (void)sd_setAvatarWithUrl:(NSURL*)url name:(NSString*)name cropRoundedImage:(BOOL)cropRoundedImage{
    self.alpha = 0.0;
    [self initialsLabel].hidden = YES;
    UIImage* oldImage = self.image;
    [self sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        if (image) {
            if (cacheType == SDImageCacheTypeNone) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.alpha = 1.0;
                }];
            } else {
                self.alpha = 1.0;
            }
            if (cropRoundedImage) {
                self.clipsToBounds = NO;
                self.image = oldImage;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    UIImage* roundImage = [self makeRoundedImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = roundImage;
                        self.clipsToBounds = NO;
                    });
                });

            } else {
                self.clipsToBounds = YES;
            }
        } else {
            UILabel* initialsLabel = [self initialsLabel];
            if (!initialsLabel) {
                initialsLabel = [[UILabel alloc] init];
                initialsLabel.frame = self.bounds;
                initialsLabel.textAlignment = NSTextAlignmentCenter;
                initialsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:self.bounds.size.width/2.8];
                initialsLabel.textColor = [UIColor darkGrayColor];
                initialsLabel.backgroundColor = [UIColor colorWithRGBHex:0xF0F0F0];
                initialsLabel.layer.cornerRadius = initialsLabel.bounds.size.width/2.0;
                initialsLabel.clipsToBounds = YES;
                [self addSubview:initialsLabel];
                [self setInitialsLabel:initialsLabel];
            }
            initialsLabel.text = [self initialsTextWithName:name];
            self.initialsLabel.hidden = NO;
            self.alpha = 1.0;
        }

    }];
}

- (UILabel*)initialsLabel{
    return objc_getAssociatedObject(self, @"MFInitialsLabel");
}

- (void)setInitialsLabel:(UILabel*)label{
    objc_setAssociatedObject(self, @"MFInitialsLabel", label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)initialsTextWithName:(NSString*)name{
    NSMutableString* initials = [@"" mutableCopy];
    __block int n = 0;
    NSArray* nameComponents = [name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [nameComponents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* component = obj;
        if (component.length) {
            [initials appendString:[[component substringToIndex:1] uppercaseString]];
            n++;
        }
        if (n>1) {
            *stop = YES;
        }
    }];
    return initials;
}

- (CALayer*)cropImageLayer{
    return objc_getAssociatedObject(self, @"MFCropImageLayer");
}

- (void)setCropImageLayer:(CALayer*)layer{
    objc_setAssociatedObject(self, @"MFCropImageLayer", layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIImage *)makeRoundedImage:(UIImage *)image
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (![self cropImageLayer]) {
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = CGRectMake(0, 0, self.bounds.size.width*scale, self.bounds.size.width*scale);
        imageLayer.contentsGravity = @"resizeAspectFill";
        imageLayer.masksToBounds = YES;
        imageLayer.cornerRadius = self.bounds.size.width*scale/2.0;
        [self setCropImageLayer:imageLayer];
    }

    CALayer *imageLayer = [self cropImageLayer];
    imageLayer.contents = (id) image.CGImage;
    UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width*scale, self.bounds.size.width*scale));
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return roundedImage;
}

- (void)hideInitialsLabel{
    [self initialsLabel].hidden = YES;
}

@end
