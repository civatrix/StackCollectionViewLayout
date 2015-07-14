//
//  WJDraggableStackCellLayout.swift
//  StackCollectionView
//
//  Created by Daniel Johns on 2015-07-06.
//  Copyright (c) 2015 Daniel Johns. All rights reserved.
//

import UIKit

class WJDraggableStackCellLayout: WJStackCellLayout, UICollectionViewLayout_Warpable {
    var layoutHelper = LSCollectionViewLayoutHelper()
    
    override init() {
        super.init()
        
        self.layoutHelper = LSCollectionViewLayoutHelper(collectionViewLayout: self)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layoutHelper = LSCollectionViewLayoutHelper(collectionViewLayout: self)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        if let attributes = super.layoutAttributesForElementsInRect(rect) {
            return self.layoutHelper.modifiedLayoutAttributesForElements(attributes)
        }
        
        return nil
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if let attributes = super.layoutAttributesForItemAtIndexPath(indexPath) {
            return self.layoutHelper.modifiedLayoutAttributesForElement(attributes)
        }
        
        return nil
    }
}
