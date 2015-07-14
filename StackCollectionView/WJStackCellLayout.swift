//
//  WJStackCellLayout.swift
//  StackCollectionView
//
//  Created by Daniel Johns on 2015-07-03.
//  Copyright (c) 2015 Daniel Johns. All rights reserved.
//

import UIKit

protocol WJCollectionViewDelegateStackLayout: NSObjectProtocol {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, collapsedHeightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat
}

let WJStackCellLayoutHeader = "WJStackCellLayoutHeader"

class WJStackCellLayout: UICollectionViewLayout {
    var columnCount = 1 {
        didSet {
            if columnCount != oldValue {
                self.invalidateLayout()
            }
        }
    }
    var sectionSpacing: CGFloat = 10.0
    var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    var headerHeight: CGFloat = 400
    weak var delegate: WJCollectionViewDelegateStackLayout? {
        get {
            return self.collectionView?.delegate as? WJCollectionViewDelegateStackLayout
        }
    }
    
    private var _itemAttributes:[[UICollectionViewLayoutAttributes]] = []
    private var _columnHeights:[CGFloat] = []
    private var _headerAttributes = UICollectionViewLayoutAttributes()
    
    func expandedItemInSection(section:Int) -> Int {
        if let collectionView = collectionView {
            return collectionView.numberOfItemsInSection(section) - 1
        }
        
        return 0
    }

    override func collectionViewContentSize() -> CGSize {
        let height = self._columnHeights.reduce(CGFloat.min, combine: { max($0, $1) })
        let width = self.collectionView?.bounds.size.width ?? CGFloat(0)
        return CGSize(width:width , height: height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        self.calculateLayout()
        var attributes = self._itemAttributes.flatMap({ $0 })
        attributes.insert(self._headerAttributes, atIndex: 0)
        return attributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        self.calculateLayout()
        
        if indexPath.section >= self._itemAttributes.count { return nil }
        let attributes = self._itemAttributes[indexPath.section]
        
        if indexPath.item >= attributes.count { return nil }
        return attributes[indexPath.row]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self._headerAttributes
    }
    
    private func calculateLayout() {
        if self.collectionView == nil { return }
        let collectionView = self.collectionView!
        
        if self.delegate == nil { return }
        let delegate = self.delegate!
        
        NSLog("Calculating")
        
        self._itemAttributes.removeAll(keepCapacity: true)
        self._headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: WJStackCellLayoutHeader, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        self._headerAttributes.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: self.headerHeight)
        self._columnHeights = [CGFloat](count: self.columnCount, repeatedValue: self.headerHeight + self.sectionInset.top)
        
        let numberOfSections = collectionView.numberOfSections()
        let width = collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right
        let itemWidth = floor((width - (CGFloat(self.columnCount - 1) * 10)) / CGFloat(self.columnCount))
        
        var top:CGFloat = 0
        for var section = 0; section < numberOfSections; section++ {
            self._itemAttributes.append([])
            
            let expandedItem = self.expandedItemInSection(section)
            let numberOfItems = collectionView.numberOfItemsInSection(section)
            let columnIndex = self.shortestColumn()
            for var item = 0; item < numberOfItems; item++ {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let itemHeight = delegate.collectionView(collectionView, layout: self, heightForItemAtIndexPath: indexPath)
                let xOffset = self.sectionInset.left + (itemWidth+10) * CGFloat(columnIndex)
                let yOffset = self._columnHeights[columnIndex]
                
                let verticalAdjustment: CGFloat
                if expandedItem == item {
                    verticalAdjustment = itemHeight
                } else {
                    verticalAdjustment = delegate.collectionView(collectionView, layout: self, collapsedHeightForItemAtIndexPath: indexPath)
                }
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                let horizontalAdjustment = 2*CGFloat(0)
                attributes.frame = CGRect(x: xOffset-horizontalAdjustment*0.5, y: yOffset, width: itemWidth+horizontalAdjustment, height: itemHeight)
                attributes.zIndex = item
                
                self._itemAttributes[section].append(attributes)
                self._columnHeights[columnIndex] += verticalAdjustment
            }
            self._columnHeights[columnIndex] += self.sectionInset.bottom
        }
    }
    
    private func shortestColumn() -> Int {
        var shortestIndex = 0
        var shortestHeight = CGFloat.max
        for (index, height) in enumerate(self._columnHeights) {
            if height < shortestHeight {
                shortestHeight = height
                shortestIndex = index
            }
        }
        
        return shortestIndex
    }
}
