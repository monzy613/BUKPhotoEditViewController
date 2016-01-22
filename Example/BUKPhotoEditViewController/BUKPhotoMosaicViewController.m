//
//  BUKPhotoMosaicViewController.m
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "BUKPhotoMosaicViewController.h"
#import "LCMosaicImageView.h"
#import "UIColor+hex.h"
#import "UIColor+Theme.h"

#define InsetSquare(padding) UIEdgeInsetsMake(padding, padding, padding, padding)
#define SCREEN_FACTOR [UIScreen mainScreen].bounds.size.width/414.0

@interface BUKPhotoMosaicViewController () <LCMosaicImageViewDelegate>

@property (nonatomic, strong) LCMosaicImageView *photoView;
@property (nonatomic, strong) UIImage *lastMosaicImage;

@property (nonatomic, strong) UIButton *undoButton;
@property (nonatomic, strong) UIButton *redoButton;
@property (nonatomic, strong) UIButton *strokeSmallButton;
@property (nonatomic, strong) UIButton *strokeMediumButton;
@property (nonatomic, strong) UIButton *strokeLargeButton;

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *bottomMaskView;

@property (nonatomic, strong) UILabel *strokeLabel;
@property (nonatomic, strong) UILabel *undoLabel;
@property (nonatomic, strong) UILabel *redoLabel;

@property (nonatomic, strong) UIButton *lastSelectedButton;

@end

@implementation BUKPhotoMosaicViewController

static const CGFloat kButtonToBottomPadding = 112.0f;
static const CGFloat kLabelToBottomPadding = 55.0f;
static const CGFloat kButtonBaseWidth = 40.0f;
static const CGFloat kBottomButtonLeftPadding = 43.0f;
static const CGFloat kDoneButtonHeight = 47.0f;
static const CGFloat kLabelBaseWidth = 60.0f;
static const CGFloat kDefaultFontSize = 14.0f;
static const CGFloat kStrokeButtonBasedWidth = 18.0f;

#pragma mark - initializer -

- (instancetype)initWithPhoto:(UIImage *)photo
{
    self = [super init];
    if (self) {
        [self setupViewsWithPhoto:photo];
        [self layoutFrame];
        
        self.lastSelectedButton = self.strokeMediumButton;
        [self.lastSelectedButton setImage:[UIImage imageNamed:@"qingquan_mosaic_fill"] forState:UIControlStateNormal];
        self.photoView.strokeScale = self.lastSelectedButton.tag;
    }
    return self;
}

#pragma mark - lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - event response -

- (void)undo:(id)sender
{
    if (!self.lastMosaicImage) {
        self.lastMosaicImage = self.photoView.image;
        [self.photoView reset];
    }
}

- (void)redo:(id)sender
{
    if (self.lastMosaicImage) {
        self.photoView.image = self.lastMosaicImage;
        self.lastMosaicImage = nil;
    }
}

- (void)strokeTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.photoView.strokeScale = button.tag;
    if ([self.lastSelectedButton isEqual:button]) {
        return;
    } else {
        [button setImage:[UIImage imageNamed:@"qingquan_mosaic_fill"] forState:UIControlStateNormal];
        [self.lastSelectedButton setImage:[UIImage imageNamed:@"qingquan_mosaic_empty"] forState:UIControlStateNormal];
        self.lastSelectedButton = button;
    }
}

- (void)cancel:(id)sender
{
    [self.delegate photoMosaicViewControllerDidCancelEditingPhoto:self];
}

- (void)confirm:(id)sender
{
    [self.delegate photoMosaicViewController:self didFinishEditingPhoto:self.photoView.image];
}

#pragma mark - delegate -

- (void)imageViewDidMosaicImage:(LCMosaicImageView *)imageView
{
    self.lastMosaicImage = nil;
}

#pragma mark - private -

- (void)setupViewsWithPhoto:(UIImage *)photo
{
    self.navigationItem.title = @"马赛克";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.bottomMaskView];
    [self.view addSubview:self.undoButton];
    [self.view addSubview:self.redoButton];
    [self.view addSubview:self.confirmButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.strokeSmallButton];
    [self.view addSubview:self.strokeMediumButton];
    [self.view addSubview:self.strokeLargeButton];
    [self.view addSubview:self.strokeLabel];
    [self.view addSubview:self.undoLabel];
    [self.view addSubview:self.redoLabel];
    
    self.photoView = [[LCMosaicImageView alloc] initWithImage:photo];
    self.photoView.mosaicEnabled = YES;
    self.photoView.mosaicLevel = LCMosaicLevelHigh;
    self.photoView.strokeScale = LCStrokeScaleLarge;
    self.photoView.delegate = self;
    self.photoView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.photoView];
}

- (void)layoutFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    self.bottomMaskView.frame = CGRectMake(0, screenSize.height - kBottomButtonLeftPadding * SCREEN_FACTOR, screenSize.width, kBottomButtonLeftPadding);
    
    self.strokeSmallButton.frame = CGRectMake(screenSize.width / 8.0f - (kStrokeButtonBasedWidth * scale) / 2, screenSize.height - (kStrokeButtonBasedWidth * scale) / 2 - kButtonToBottomPadding, kStrokeButtonBasedWidth * scale, kStrokeButtonBasedWidth * scale);
    self.strokeMediumButton.frame = CGRectMake(2 * screenSize.width / 8.0f - (kStrokeButtonBasedWidth * 1.25 * scale) / 2, screenSize.height - (kStrokeButtonBasedWidth * 1.25 * scale) / 2 - kButtonToBottomPadding, kStrokeButtonBasedWidth * 1.25 * scale, kStrokeButtonBasedWidth * 1.25 * scale);
    self.strokeLargeButton.frame = CGRectMake(3 * screenSize.width / 8.0f - (kStrokeButtonBasedWidth * 1.5 * scale) / 2, screenSize.height - (kStrokeButtonBasedWidth * 1.5 * scale) / 2 - kButtonToBottomPadding, kStrokeButtonBasedWidth * 1.5 * scale, kStrokeButtonBasedWidth * 1.5 * scale);
    
    self.undoButton.frame = CGRectMake(5 * screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    self.redoButton.frame = CGRectMake(7 * screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    self.cancelButton.frame = CGRectMake(kBottomButtonLeftPadding * SCREEN_FACTOR, screenSize.height - kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR);
    self.confirmButton.frame = CGRectMake(screenSize.width - (kBottomButtonLeftPadding + kDoneButtonHeight) * SCREEN_FACTOR, screenSize.height - kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR);
    
    self.strokeLabel.frame = CGRectMake(2 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.undoLabel.frame = CGRectMake(5 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.redoLabel.frame = CGRectMake(7 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    
    self.photoView.frame = CGRectMake(0, 0, screenSize.width,self.strokeLargeButton.frame.origin.y - 64 - 50);
    self.photoView.clipsToBounds = YES;
    self.photoView.center = [self imageCenter];
}

- (CGPoint)imageCenter
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat y = screenSize.height / 2 - ((kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding + 96) / 2;
    return CGPointMake(screenSize.width / 2, y);
}

#pragma mark - getter & setter -

- (UIButton *)redoButton
{
    if (!_redoButton) {
        _redoButton = [[UIButton alloc] init];
        [_redoButton setImage:[UIImage imageNamed:@"qingquan_mosaic_redo"] forState:UIControlStateNormal];
        _redoButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_redoButton addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _redoButton;
}

- (UIButton *)undoButton
{
    if (!_undoButton) {
        _undoButton = [[UIButton alloc] init];
        [_undoButton setImage:[UIImage imageNamed:@"qingquan_mosaic_undo"] forState:UIControlStateNormal];
        _undoButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _undoButton;
}

- (UIButton *)strokeSmallButton
{
    if (!_strokeSmallButton) {
        _strokeSmallButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_strokeSmallButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [_strokeSmallButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_strokeSmallButton setImage:[UIImage imageNamed:@"qingquan_mosaic_empty"] forState:UIControlStateNormal];
        _strokeSmallButton.tag = LCStrokeScaleSmall;
        _strokeSmallButton.contentEdgeInsets = InsetSquare(10);
        _strokeSmallButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_strokeSmallButton addTarget:self action:@selector(strokeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _strokeSmallButton;
}

- (UIButton *)strokeMediumButton
{
    if (!_strokeMediumButton) {
        _strokeMediumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_strokeMediumButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [_strokeMediumButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_strokeMediumButton setImage:[UIImage imageNamed:@"qingquan_mosaic_empty"] forState:UIControlStateNormal];
        _strokeMediumButton.contentEdgeInsets = InsetSquare(10);
        _strokeMediumButton.tag = LCStrokeScaleMedium;
        _strokeMediumButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_strokeMediumButton addTarget:self action:@selector(strokeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _strokeMediumButton;
}

- (UIButton *)strokeLargeButton
{
    if (!_strokeLargeButton) {
        _strokeLargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_strokeLargeButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [_strokeLargeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_strokeLargeButton setImage:[UIImage imageNamed:@"qingquan_mosaic_empty"] forState:UIControlStateNormal];
        _strokeLargeButton.contentEdgeInsets = InsetSquare(10);
        _strokeLargeButton.tag = LCStrokeScaleLarge;
        _strokeLargeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_strokeLargeButton addTarget:self action:@selector(strokeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _strokeLargeButton;
}

- (UILabel *)strokeLabel
{
    if (!_strokeLabel) {
        _strokeLabel = [[UILabel alloc] init];
        _strokeLabel.text = @"画笔设置";
        _strokeLabel.textColor = [UIColor whiteColor];
        _strokeLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _strokeLabel.textAlignment = NSTextAlignmentCenter;
        _strokeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _strokeLabel;
}

- (UILabel *)undoLabel
{
    if (!_undoLabel) {
        _undoLabel = [[UILabel alloc] init];
        _undoLabel.text = @"撤销";
        _undoLabel.textColor = [UIColor whiteColor];
        _undoLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _undoLabel.textAlignment = NSTextAlignmentCenter;
        _undoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _undoLabel;
}

- (UILabel *)redoLabel
{
    if (!_redoLabel) {
        _redoLabel = [[UILabel alloc] init];
        _redoLabel.text = @"还原";
        _redoLabel.textColor = [UIColor whiteColor];
        _redoLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _redoLabel.textAlignment = NSTextAlignmentCenter;
        _redoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _redoLabel;
}


- (UIButton *)confirmButton {
	if(_confirmButton == nil) {
		_confirmButton = [[UIButton alloc] init];
        [_confirmButton setImage:[UIImage imageNamed:@"photo_edit_done"] forState:UIControlStateNormal];
        _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _confirmButton;
}

- (UIButton *)cancelButton {
	if(_cancelButton == nil) {
		_cancelButton = [[UIButton alloc] init];
        [_cancelButton setImage:[UIImage imageNamed:@"qingquan_edit_cancel"] forState:UIControlStateNormal];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _cancelButton;
}

- (UIView *)bottomMaskView {
	if(_bottomMaskView == nil) {
        _bottomMaskView = [[UIView alloc] init];
        _bottomMaskView.backgroundColor = [UIColor pev_darkGrayColor];
	}
	return _bottomMaskView;
}

@end
