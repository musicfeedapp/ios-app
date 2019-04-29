//
//  MFProfilePartViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/12/16.
//
//

#import "MFProfilePartViewController.h"

@interface MFProfilePartViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelTrailing;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
 
@end

@implementation MFProfilePartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setObjectsFromCache];
    [self downloadObjects];
    self.flowLayout.itemSize = [self itemSize];
    [self.titleButton setTitle:self.title forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) applyClosedState{
    _isOpenedState = NO;
    _countLabelTrailing.constant = 14;
    _moreButton.alpha = 0.0;
    _collectionView.alpha = 0.0;
}

- (void) applyOpenedState{
    _isOpenedState = YES;
    _countLabelTrailing.constant = 35;
    _moreButton.alpha = 1.0;
    _collectionView.alpha = 1.0;
}

- (IBAction)titleTapped:(id)sender {
    [self.delegate profilePartViewControllerDidTapAtHeader:self];
}

- (IBAction)moreTapped:(id)sender {
    [self.delegate profilePartViewControllerDidTapAtMore:self];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.objects.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate profilePartViewController:self didSelectItem:self.objects[indexPath.row]];
}
- (void)reloadData{
    [self downloadObjects];
}

- (void)setObjectsFromCache{
    //must be overridden
}

- (void)downloadObjects{
    //must be overridden
}

- (CGSize)itemSize{
    //must be overridden
    return (CGSize){0,0};
}

- (UICollectionViewCell*)cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    //must be overridden
    return nil;
}

@end
