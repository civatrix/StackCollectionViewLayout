//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "LSCollectionViewLayoutHelper.h"

@interface LSCollectionViewLayoutHelper ()

@end

@implementation LSCollectionViewLayoutHelper

- (id)initWithCollectionViewLayout:(UICollectionViewLayout<UICollectionViewLayout_Warpable>*)collectionViewLayout
{
    self = [super init];
    if (self) {
        _collectionViewLayout = collectionViewLayout;
    }
    return self;
}

- (NSArray *)modifiedLayoutAttributesForElements:(NSArray *)elements {
    NSMutableArray *modifiedElements = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *element in elements) {
        [modifiedElements addObject:[self modifiedLayoutAttributesForElement:element]];
    }
    
    return modifiedElements;
}

- (UICollectionViewLayoutAttributes *)modifiedLayoutAttributesForElement:(UICollectionViewLayoutAttributes *)attributes{
    UICollectionView *collectionView = self.collectionViewLayout.collectionView;
    NSIndexPath *fromIndexPath = self.fromIndexPath;
    NSIndexPath *toIndexPath = self.toIndexPath;
    NSIndexPath *hideIndexPath = self.hideIndexPath;
    NSIndexPath *indexPathToRemove;
    
    if (toIndexPath == nil) {
        if (hideIndexPath == nil || attributes.representedElementCategory != UICollectionElementCategoryCell) {
            //No changes needed
            return attributes;
        }
        if ([attributes.indexPath isEqual:hideIndexPath]) {
            attributes.hidden = YES;
        }
        return attributes;
    }
    
    if (fromIndexPath.section != toIndexPath.section) {
        indexPathToRemove = [NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:fromIndexPath.section] - 1 inSection:fromIndexPath.section];
    }
    
    if(attributes.representedElementCategory != UICollectionElementCategoryCell) {
        //no changes needed
        return attributes;
    }
    
    if([attributes.indexPath isEqual:indexPathToRemove]) {
        // Remove item in source section and insert item in target section
        attributes.indexPath = [NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section] inSection:toIndexPath.section];
        if (attributes.indexPath.item != 0) {
            attributes.center = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:attributes.indexPath].center;
        }
    }
    NSIndexPath *indexPath = attributes.indexPath;
    if ([indexPath isEqual:hideIndexPath]) {
        attributes.hidden = YES;
    }
    
    if([indexPath isEqual:toIndexPath]) {
        // Item's new location
        attributes.indexPath = fromIndexPath;
    } else if(fromIndexPath.section != toIndexPath.section) {
        if(indexPath.section == fromIndexPath.section && indexPath.item >= fromIndexPath.item) {
            // Change indexes in source section
            attributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
        } else if(indexPath.section == toIndexPath.section && indexPath.item >= toIndexPath.item) {
            // Change indexes in destination section
            attributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
        }
    } else if(indexPath.section == fromIndexPath.section) {
        if(indexPath.item <= fromIndexPath.item && indexPath.item > toIndexPath.item) {
            // Item moved back
            attributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
        } else if(indexPath.item >= fromIndexPath.item && indexPath.item < toIndexPath.item) {
            // Item moved forward
            attributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
        }
    }
    
    return attributes;
}

@end
