//
//  TableViewCell.m
//  botmusic
//
//  Created by Dzmitry Navak on 31/01/15.
//
//

#import "UIImage+GPUBlur.h"
#import <float.h>
#import "GPUImage.h"


@implementation UIImage (GPUBlur)


- (UIImage *)gpuBlurApplyLightEffect
{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground){

        GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 1.7;
        UIImage *result = [blurFilter imageByFilteringImage:self];

        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -0.15;
        result = [brightnessFilter imageByFilteringImage:result];

        GPUImageContrastFilter* contrastFilter = [[GPUImageContrastFilter alloc] init];
        contrastFilter.contrast = 1.65;
        result = [contrastFilter imageByFilteringImage:result];

        return result;

    }
    else return nil;
}

- (UIImage *)gpuBlurApplyProfileEffect
{
    //return nil;
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground){
        
        GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 8;
        UIImage *result = [blurFilter imageByFilteringImage:self];
        
        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -0.4;
        result = [brightnessFilter imageByFilteringImage:result];
        
//        GPUImageContrastFilter* contrastFilter = [[GPUImageContrastFilter alloc] init];
//        contrastFilter.contrast = 1.65;
//        result = [contrastFilter imageByFilteringImage:result];
        
        return result;
        
    }
    else return nil;
}

- (UIImage *)gpuBlurApplyDarkEffect
{
    //return nil;
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground){

        GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 6;
        UIImage *result = [blurFilter imageByFilteringImage:self];
        
        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -0.3;
        result = [brightnessFilter imageByFilteringImage:result];
        
        return result;
    }
    else return nil;
}

- (UIImage *)gpuBlurApplyDarkerEffect
{
    //return nil;
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground){
        
        GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 8;
        UIImage *result = [blurFilter imageByFilteringImage:self];
        
        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -0.4;
        result = [brightnessFilter imageByFilteringImage:result];
        
        return result;
    }
    else return nil;
}
@end
