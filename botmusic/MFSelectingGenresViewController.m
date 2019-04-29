//
//  MFSelectingGenresViewController.m
//  botmusic
//
//  Created by Panda Systems on 8/24/15.
//
//

#import "MFSelectingGenresViewController.h"
#import "UIColor+Expanded.h"
#import "MFGenre.h"
#import <objc/runtime.h>

@interface MFSelectingGenresViewController ()
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIView *genresContainerView;
@property (strong, nonatomic) NSMutableArray<MFGenre*>* genresArray;
@property (strong, nonatomic) NSMutableArray<NSString*>* selectedGenresArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@property (strong, nonatomic) NSMutableArray* lines;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *genresContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL genresViewPrepared;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation MFSelectingGenresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.separatorHeightConstraint.constant = 1.0/[UIScreen mainScreen].scale;
    [self.scrollView setContentInset:UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0)];
    [self downloadGenres];
    [self.view layoutIfNeeded];
    self.plusButton.hidden = YES;
    if (self.isSettingsMode) {
        self.textLabel.text = @"";
    }
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.scrollView layoutIfNeeded];
    if (!self.genresViewPrepared) {
        self.genresViewPrepared = YES;
        //[self prepareGenresView];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) prepareGenresView{
    for (UIView* subview in self.genresContainerView.subviews) {
        [subview removeFromSuperview];
    }
    self.lines = [NSMutableArray array];
    int currentLine = 0;
    float currentLineWidth = 0;
    [self.lines addObject:[NSMutableArray array]];
    for (int i = 0; i<self.genresArray.count; i++) {
        NSString* genreString = self.genresArray[i].name;
        UIButton* genreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        objc_setAssociatedObject(genreButton, @"genre", self.genresArray[i], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [genreButton setTitle:genreString forState:UIControlStateNormal];
        [genreButton setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
        if ([self.selectedGenresArray containsObject:self.genresArray[i].ID]) {
            [genreButton setBackgroundColor:[UIColor colorWithRGBHex:0x126EFF]];
            [genreButton setSelected:YES];
        } else {
            [genreButton setBackgroundColor:[UIColor whiteColor]];
        }
        [genreButton sizeToFit];
        [genreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [genreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [genreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [genreButton addTarget:self action:@selector(genreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        genreButton.layer.cornerRadius = genreButton.bounds.size.height/2.0;
        
        if (currentLineWidth+2.0+genreButton.bounds.size.width<self.genresContainerView.bounds.size.width) {
            [self.lines[currentLine] addObject:genreButton];
            currentLineWidth += 2.0 + genreButton.bounds.size.width;
        } else {
            currentLine++;
            [self.lines addObject:[NSMutableArray array]];
            [self.lines[currentLine] addObject:genreButton];
            currentLineWidth = genreButton.bounds.size.width;
        }
    }
    float currentY = 0.0;
    for (NSMutableArray* line in self.lines) {
        float totalWidth = 0;
        for (UIButton* btn in line) {
            totalWidth+=2.0+btn.bounds.size.width;
        }
        totalWidth -=2.0;
        float currentX = (self.genresContainerView.bounds.size.width - totalWidth)/2.0;
        for (UIButton* btn in line) {
            btn.frame = CGRectMake(currentX, currentY, btn.bounds.size.width, btn.bounds.size.height);
            [self.genresContainerView addSubview:btn];
            
            currentX += 2.0 + btn.bounds.size.width;
        }
        currentY +=40.0;
    }
    self.genresContainerHeightConstraint.constant = currentY;

}

- (void) placeGenresFilteredByString:(NSString*)string onView:(UIView*)view{
    if (!string) {
        return;
    }
    [[IRNetworkClient sharedInstance] searchGenresWithKeyword:string SuccessBlock:^(NSArray *array) {
        for (UIView* subview in view.subviews) {
            [subview removeFromSuperview];
        }
        NSMutableArray<MFGenre*>* foundGenresArray = [NSMutableArray array];
        for (NSDictionary* dict in array) {
            MFGenre* genre = [[MFGenre alloc] init];
            genre.name = dict[@"name"];
            genre.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
            [foundGenresArray addObject:genre];
        }

        NSMutableArray* lines = [NSMutableArray array];
        int currentLine = 0;
        float currentLineWidth = 0;
        [lines addObject:[NSMutableArray array]];
        for (int i = 0; i<foundGenresArray.count; i++) {
            NSString* genreString = foundGenresArray[i].name;
            UIButton* genreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            objc_setAssociatedObject(genreButton, @"genre", foundGenresArray[i], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            //NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:genreString];
            [genreButton setTitle:genreString forState:UIControlStateNormal];
            //[genreButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
            [genreButton setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
            if ([self.selectedGenresArray containsObject:foundGenresArray[i].ID]) {
                [genreButton setBackgroundColor:[UIColor colorWithRGBHex:0x126EFF]];
                [genreButton setSelected:YES];
            } else {
                [genreButton setBackgroundColor:[UIColor whiteColor]];
            }
            [genreButton sizeToFit];
            [genreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [genreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [genreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [genreButton addTarget:self action:@selector(genreButtonTappedFromSearch:) forControlEvents:UIControlEventTouchUpInside];
            genreButton.layer.cornerRadius = genreButton.bounds.size.height/2.0;

            if (currentLineWidth+2.0+genreButton.bounds.size.width<view.bounds.size.width) {
                [lines[currentLine] addObject:genreButton];
                currentLineWidth += 2.0 + genreButton.bounds.size.width;
            } else {
                currentLine++;
                [lines addObject:[NSMutableArray array]];
                [lines[currentLine] addObject:genreButton];
                currentLineWidth = genreButton.bounds.size.width;
            }

        }
        float currentY = 0.0;
        for (NSMutableArray* line in lines) {
            float totalWidth = 0;
            for (UIButton* btn in line) {
                totalWidth+=2.0+btn.bounds.size.width;
            }
            totalWidth -=2.0;
            float currentX = (view.bounds.size.width - totalWidth)/2.0;
            for (UIButton* btn in line) {
                btn.frame = CGRectMake(currentX, currentY, btn.bounds.size.width, btn.bounds.size.height);
                [view addSubview:btn];
                
                currentX += 2.0 + btn.bounds.size.width;
            }
            currentY +=40.0;
        }
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.genresSearchDelegate)];

    }];

}

- (void) downloadGenres{
    self.selectedGenresArray = [NSMutableArray array];
    [self.activityIndicator startAnimating];

    if (self.isSettingsMode) {
        self.genresArray = [NSMutableArray array];
        self.selectedGenresArray = [NSMutableArray array];
        [[IRNetworkClient sharedInstance] getUserGenresSuccessBlock:^(NSArray *array) {
            self.genresArray = [NSMutableArray array];
            for (NSDictionary* dict in array) {
                MFGenre* genre = [[MFGenre alloc] init];
                genre.name = dict[@"name"];
                genre.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
                [self.genresArray addObject:genre];
                [self.selectedGenresArray addObject:genre.ID];
            }
            [self prepareGenresView];
            self.plusButton.hidden = NO;
            [self.activityIndicator stopAnimating];
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.genresSearchDelegate)];

        }];
        //[[[UIAlertView alloc] initWithTitle:nil message:@"Server isn't ready for fetching selected genres" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

    } else {

        [[IRNetworkClient sharedInstance] getAllGenresSuccessBlock:^(NSArray *array) {
            self.genresArray = [NSMutableArray array];
            for (NSDictionary* dict in array) {
                MFGenre* genre = [[MFGenre alloc] init];
                genre.name = dict[@"name"];
                genre.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
                [self.genresArray addObject:genre];
            }
            [self prepareGenresView];
            self.plusButton.hidden = NO;
            [self.activityIndicator stopAnimating];
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.genresSearchDelegate)];

        }];
    }
    [self.view layoutIfNeeded];
}

- (IBAction)plusButtonTapped:(id)sender {
    if (self.genresSearchDelegate) {
        [self.genresSearchDelegate startSearch];
    }
}

- (void)genreButtonTapped:(UIButton*)sender{
    MFGenre* genre = objc_getAssociatedObject(sender, @"genre");
    if (![self.selectedGenresArray containsObject:genre.ID]) {
        [sender setSelected:YES];
        [UIView animateWithDuration:0.15 animations:^{
            [sender setBackgroundColor:[UIColor colorWithRGBHex:0x126EFF]];
        }];
        [self.selectedGenresArray addObject:genre.ID];
    } else {
        [sender setSelected:NO];
        [UIView animateWithDuration:0.15 animations:^{
            [sender setBackgroundColor:[UIColor whiteColor]];
        }];
        [self.selectedGenresArray removeObject:genre.ID];
    }
}

- (void)genreButtonTappedFromSearch:(UIButton*)sender{
    MFGenre* genre = objc_getAssociatedObject(sender, @"genre");
    if (![self.selectedGenresArray containsObject:genre.ID]) {
        [sender setSelected:YES];
        [UIView animateWithDuration:0.15 animations:^{
            [sender setBackgroundColor:[UIColor colorWithRGBHex:0x126EFF]];
        }];
        [self.selectedGenresArray addObject:genre.ID];
        if ([self.genresArray containsObject:genre]) {
            [self.genresArray removeObject:genre];
        }
        [self.genresArray insertObject:genre atIndex:0];
    } else {
        [sender setSelected:NO];
        [UIView animateWithDuration:0.15 animations:^{
            [sender setBackgroundColor:[UIColor whiteColor]];
        }];
        [self.selectedGenresArray removeObject:genre.ID];
    }
    //[self refreshButtons];
    [self prepareGenresView];
}

- (void)refreshButtons{
    for (NSMutableArray* line in self.lines) {
        for (UIButton* btn in line) {
            MFGenre* genre = objc_getAssociatedObject(btn, @"genre");
                if ([self.selectedGenresArray containsObject:genre.ID]) {
                    [btn setSelected:YES];
                    [UIView animateWithDuration:0.15 animations:^{
                        [btn setBackgroundColor:[UIColor colorWithRGBHex:0x126EFF]];
                    }];
                } else {
                    [btn setSelected:NO];
                    [UIView animateWithDuration:0.15 animations:^{
                        [btn setBackgroundColor:[UIColor whiteColor]];
                    }];
                }

        }
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.genresSearchDelegate finishSearch];
}

- (void) viewWillDisappear:(BOOL)animated{
    NSMutableArray* ids = [NSMutableArray array];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    for (NSString* genreID in self.selectedGenresArray) {
        [ids addObject:[f numberFromString:genreID]];
    }
    [[IRNetworkClient sharedInstance] postUserGenres:ids SuccessBlock:^(NSArray *array) {

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.genresSearchDelegate)];

    }];
}
@end
