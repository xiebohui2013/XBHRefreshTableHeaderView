//
//  XBHRefreshTableHeaderView.m
//  TablePullToRefresh
//
//  Created by xiebohui on 13-9-10.
//  Copyright (c) 2013年 xiebohui. All rights reserved.
//

#import "XBHRefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>

#define FLIP_ANIMATION_DURATION 0.18f
#define XBHRefreshTableHeaderView_LastUpdate @"XBHRefreshTableHeaderView_LastUpdate"

@interface XBHRefreshTableHeaderView()

@property (nonatomic) XBHPullRefreshState state;
@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation XBHRefreshTableHeaderView

@synthesize delegate = _delegate;
@synthesize textColor = _textColor;
@synthesize backgroundColor = _backgroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor whiteColor];
        
        self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 30, frame.size.width, 20)];
        self.lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0];
        self.lastUpdatedLabel.textColor = [UIColor blackColor];
        self.lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        self.lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lastUpdatedLabel];
        
        self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 48, frame.size.width, 20)];
        self.stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.stateLabel.font = [UIFont systemFontOfSize:13.0];
        self.stateLabel.textColor = [UIColor blackColor];
        self.stateLabel.backgroundColor = [UIColor clearColor];
        self.stateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.stateLabel];
        
        self.arrow = [[UIImageView alloc] initWithFrame:CGRectMake(25, frame.size.height - 65, 30, 55)];
        self.arrow.image = [self imagesNamedFromCustomBundle:@"blackArrow.png"];
        [self addSubview:self.arrow];
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.frame = CGRectMake(25, frame.size.height - 38, 20, 20);
        self.activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:self.activityIndicatorView];
        
        self.state = XBHPullRefreshStateNormal;
    }
    return self;
}

- (void)refreshLastUpdatedDate {
    if ([self.delegate respondsToSelector:@selector(xbhRefreshTableHeaderDataSourceLastUpdated:)]) {
        NSDate *date = [self.delegate xbhRefreshTableHeaderDataSourceLastUpdated:self];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh24:mm:ss";
        self.lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新时间:%@",[dateFormatter stringFromDate:date]];
        [[NSUserDefaults standardUserDefaults] setValue:self.lastUpdatedLabel.text forKey:XBHRefreshTableHeaderView_LastUpdate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        self.lastUpdatedLabel.text = nil;
    }
}

- (void)xbhRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.state == XBHPullRefreshStateLoading) {
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
    }
    else if(scrollView.isDragging) {
        BOOL isLoading = NO;
        if ([self.delegate respondsToSelector:@selector(xbhRefreshTableHeaderDataSourceIsLoading:)]) {
            isLoading = [self.delegate xbhRefreshTableHeaderDataSourceIsLoading:self];
        }
        if (!isLoading && self.state == XBHPullRefreshStatePulling && scrollView.contentOffset.y > -65.0 && scrollView.contentOffset.y < 0) {
            self.state = XBHPullRefreshStateNormal;
        }
        else if(!isLoading && self.state == XBHPullRefreshStateNormal && scrollView.contentOffset.y <= -65.0) {
            self.state = XBHPullRefreshStatePulling;
        }
        
        if (scrollView.contentInset.top > 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
    }

}

- (void)xbhRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    BOOL isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(xbhRefreshTableHeaderDataSourceIsLoading:)]) {
        isLoading = [self.delegate xbhRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    if (!isLoading && scrollView.contentOffset.y <= - 65.0) {
        if ([self.delegate respondsToSelector:@selector(xbhRefreshTableHeaderDidTriggerRefresh:)]) {
            [self.delegate xbhRefreshTableHeaderDidTriggerRefresh:self];
        }
        [UIView animateWithDuration:0.3 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        } completion:nil];
    }
}

- (void)xbhRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentInset = UIEdgeInsetsZero;
    } completion:nil];
    self.state = XBHPullRefreshStateNormal;
}

#pragma mark -
#pragma mark Setters

- (void)setState:(XBHPullRefreshState)aState {
    __weak typeof(self) weakSelf = self;
    switch (aState) {
        case XBHPullRefreshStatePulling: {
            self.stateLabel.text = @"松开即可刷新...";
            [UIView animateWithDuration:FLIP_ANIMATION_DURATION animations:^{
                weakSelf.arrow.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:nil];
        }
            break;
        case XBHPullRefreshStateNormal:
            if (self.state == XBHPullRefreshStatePulling) {
                [UIView animateWithDuration:FLIP_ANIMATION_DURATION animations:^{
                    weakSelf.arrow.transform = CGAffineTransformIdentity;
                } completion:nil];
            }
            self.stateLabel.text = @"下拉可以刷新...";
            [self.activityIndicatorView stopAnimating];
            self.arrow.hidden = NO;
            self.arrow.transform = CGAffineTransformIdentity;
            [self refreshLastUpdatedDate];
            break;
        case XBHPullRefreshStateLoading:
            self.stateLabel.text = @"加载中...";
            self.arrow.hidden = YES;
            [self.activityIndicatorView startAnimating];
            break;
        default:
            break;
    }
    self.state = aState;
}

- (void)setTextColor:(UIColor *)textColor {
    self.stateLabel.textColor = textColor;
    self.lastUpdatedLabel.textColor = textColor;
    [self setNeedsDisplay];
    _textColor = textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

#pragma mark -

- (UIImage *)imagesNamedFromCustomBundle:(NSString *)name {
    NSString *customBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Arrow.bundle/images"];
    return [UIImage imageNamed:[customBundlePath stringByAppendingPathComponent:name]];
}

@end
