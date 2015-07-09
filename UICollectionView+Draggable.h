//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import <UIKit/UIKit.h>
#import "UICollectionViewDataSource_Draggable.h"

@interface UICollectionView (Draggable)

NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) UIEdgeInsets scrollingEdgeInsets;
@property (nonatomic, assign) CGFloat scrollingSpeed;
NS_ASSUME_NONNULL_END

@end
