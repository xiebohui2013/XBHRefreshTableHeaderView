//
//  XBHRefreshTableHeaderView.h
//  TablePullToRefresh
//
//  Created by xiebohui on 13-9-10.
//  Copyright (c) 2013年 xiebohui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XBHPullRefreshState){
    XBHPullRefreshStatePulling = 0,
    XBHPullRefreshStateNormal,
    XBHPullRefreshStateLoading
};

@protocol XBHRefreshTableHeaderDelegate;

@interface XBHRefreshTableHeaderView : UIView

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, assign) id<XBHRefreshTableHeaderDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)xbhRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)xbhRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)xbhRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol XBHRefreshTableHeaderDelegate <NSObject>

- (void)xbhRefreshTableHeaderDidTriggerRefresh:(XBHRefreshTableHeaderView *)headerView;
- (BOOL)xbhRefreshTableHeaderDataSourceIsLoading:(XBHRefreshTableHeaderView *)headerView;

@optional
- (NSDate *)xbhRefreshTableHeaderDataSourceLastUpdated:(XBHRefreshTableHeaderView *)headerView;

@end