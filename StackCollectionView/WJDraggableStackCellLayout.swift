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
    private var _draggingItem = false
    private var _draggingSection = -1
//    private var _draggingItem:NSIndexPath? = nil
    
    override func expandedItemInSection(section: Int) -> Int {
        if self._draggingItem && self._draggingSection == section {
            return -1
        }
        
//        if let draggingItem = self._draggingItem where draggingItem.section == section {
//            return draggingItem.item
//        }
        
        return super.expandedItemInSection(section)
    }
    
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

extension WJDraggableStackCellLayout: LSCollectionViewDraggableDelegate {
    func willStartDraggingItemAtIndexPath(indexPath: NSIndexPath) {
        self._draggingItem = true
        self._draggingSection = indexPath.section
//        self._draggingItem = indexPath
    }
    
    func willEndDraggingItemAtIndexPath(indexPath: NSIndexPath) {
        self._draggingItem = false
        self._draggingSection = -1
//        self._draggingItem = nil
    }
    
//    func willMoveDraggingItemToIndexPath(indexPath: NSIndexPath) {
//        self._draggingItem = indexPath
//    }
}
