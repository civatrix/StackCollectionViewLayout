//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import <UIKit/UIKit.h>

@interface LSCollectionViewHelper : NSObject <UIGestureRecognizerDelegate>

NS_ASSUME_NONNULL_BEGIN
- (id)initWithCollectionView:(UICollectionView *)collectionView;

@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) UIGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, readonly) UIGestureRecognizer *panPressGestureRecognizer;
@property (nonatomic, assign) UIEdgeInsets scrollingEdgeInsets;
@property (nonatomic, assign) CGFloat scrollingSpeed;
@property (nonatomic, assign) BOOL enabled;
NS_ASSUME_NONNULL_END

@end
