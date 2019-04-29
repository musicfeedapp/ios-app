//
//  MFWebIntroViewController.m
//  botmusic
//
//  Created by Dzmitry Navak on 19/02/15.
//
//

#import "MFWebIntroViewController.h"
#import <sys/utsname.h>
#import "MenuCreator.h"

typedef NS_ENUM(NSUInteger, MFDeviceType) {
    MFDeviceTypeUnknown,
    MFDeviceTypeIphone4,
    MFDeviceTypeIphone5,
    MFDeviceTypeIphone6
};

@interface MFWebIntroViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webIntro;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation MFWebIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* introName = @"";
    
    switch ([self deviceName]) {
        case MFDeviceTypeIphone4:
            introName = @"phone-4";
            break;
            
        case MFDeviceTypeIphone5:
            introName = @"phone-5";
            break;
            
        case MFDeviceTypeIphone6:
            introName = @"phone-6";
            break;
            
        default:
            introName = @"phone-5";
            break;
    }
    
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:introName withExtension:@"html"];
    
    self.webIntro.delegate = self;
    [self.webIntro loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MFDeviceType)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString* devName = [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
    
    if ([devName isEqualToString:@"iPhone3,1"] ||
        [devName isEqualToString:@"iPhone3,3"] ||
        [devName isEqualToString:@"iPhone4,1"] ) {
        return MFDeviceTypeIphone4;
    }
    else if ([devName isEqualToString:@"iPhone5,1"] ||
             [devName isEqualToString:@"iPhone5,2"] ||
             [devName isEqualToString:@"iPhone5,3"] ||
             [devName isEqualToString:@"iPhone5,4"] ||
             [devName isEqualToString:@"iPhone6,1"] ||
             [devName isEqualToString:@"iPhone6,2"]) {
        return MFDeviceTypeIphone5;
    }
    else if ([devName isEqualToString:@"iPhone7,1"] ||
             [devName isEqualToString:@"iPhone7,2"]) {
        return MFDeviceTypeIphone6;
    }
    return MFDeviceTypeUnknown;
}

- (IBAction)skipButtonTapped:(id)sender {
    
    MFSideMenuContainerViewController *slidingVC = [MenuCreator createMenu:NO];
    
    [self presentViewController:slidingVC
                       animated:YES
                     completion:nil];
}

@end
