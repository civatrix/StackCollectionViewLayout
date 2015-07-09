//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import <Foundation/Foundation.h>
#import "UICollectionViewLayout_Warpable.h"
#import <UIKit/UIKit.h>

@interface LSCollectionViewLayoutHelper : NSObject

NS_ASSUME_NONNULL_BEGIN
- (id)initWithCollectionViewLayout:(UICollectionViewLayout<UICollectionViewLayout_Warpable>*)collectionViewLayout;

- (NSArray *)modifiedLayoutAttributesForElements:(NSArray *)elements;
- (UICollectionViewLayoutAttributes *)modifiedLayoutAttributesForElement:(UICollectionViewLayoutAttributes *)attributes;

@property (nonatomic, weak, readonly) UICollectionViewLayout<UICollectionViewLayout_Warpable> *collectionViewLayout;
@property (nullable, strong, nonatomic) NSIndexPath *fromIndexPath;
@property (nullable, strong, nonatomic) NSIndexPath *toIndexPath;
@property (nullable, strong, nonatomic) NSIndexPath *hideIndexPath;
NS_ASSUME_NONNULL_END

@end
