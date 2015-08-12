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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, verticalOffsetForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, expandedItemInSection section: Int) -> Int
}

let WJStackCellLayoutHeader = "WJStackCellLayoutHeader"
let WJStackCellLayoutSectionMask = "WJStackCellLayoutMask"

class WJStackCellLayout: UICollectionViewLayout {
    var columnCount = 1 {
        didSet {
            if columnCount != oldValue {
                self.invalidateLayout()
            }
        }
    }
    var sectionSpacing: CGFloat = 10.0 {
        didSet {
            if sectionSpacing != oldValue {
                self.invalidateLayout()
            }
        }
    }
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5){
        didSet {
            if !UIEdgeInsetsEqualToEdgeInsets(contentInset, oldValue) {
                self.invalidateLayout()
            }
        }
    }
    var itemWidth: CGFloat {
        get {
            return _itemWidth
        }
        set {
            if (_itemWidth != newValue) && (self.columnCount > 1) {
                _itemWidth = newValue
                self.invalidateLayout()
            }
        }
    }
    private var _itemWidth: CGFloat = 310
    var headerHeight: CGFloat = 400{
        didSet {
            if headerHeight != oldValue {
                self.invalidateLayout()
            }
        }
    }
    weak var delegate: WJCollectionViewDelegateStackLayout? {
        get {
            return self.collectionView?.delegate as? WJCollectionViewDelegateStackLayout
        }
    }
    
    private var itemAttributes:[[UICollectionViewLayoutAttributes]] = []
    private var columnHeights:[CGFloat] = []
    private var sectionColumns:[Int:Int] = [:]
    private var headerAttributes = UICollectionViewLayoutAttributes()
    private var maskAttributes:[UICollectionViewLayoutAttributes] = []

    override func collectionViewContentSize() -> CGSize {
        let height = self.columnHeights.reduce(CGFloat.min, combine: { max($0, $1) })
        let width = self.collectionView?.bounds.size.width ?? CGFloat(0)
        return CGSize(width:width , height: height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes = self.itemAttributes.flatMap({ $0 })
        attributes.insert(self.headerAttributes, atIndex: 0)
        attributes.splice(self.maskAttributes, atIndex: 0)
        return attributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if indexPath.section >= self.itemAttributes.count { return nil }
        let attributes = self.itemAttributes[indexPath.section]
        
        if indexPath.item >= attributes.count { return nil }
        return attributes[indexPath.row]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if elementKind == WJStackCellLayoutSectionMask {
            return self.maskAttributes[indexPath.section]
        } else {
            return self.headerAttributes
        }
    }
    
    override func prepareLayout() {
        if self.collectionView == nil { return }
        let collectionView = self.collectionView!
        
        if self.delegate == nil { return }
        let delegate = self.delegate!
        
        var xOffsets = [CGFloat](count: self.columnCount, repeatedValue: 0)
        let spacing = self.sectionSpacing
        let width = collectionView.bounds.size.width - self.contentInset.left - self.contentInset.right
        let halfWidth = width / 2.0
        let itemWidth = self.itemWidth
        if self.columnCount == 1 {
            xOffsets[0] = 0
            self._itemWidth = width
        } else if self.columnCount % 2 == 0 {
            let midColumn = self.columnCount / 2
            
            //calculate offsets for columns right of center
            for var column = midColumn; column < self.columnCount; column++ {
                let adjustedColumn = CGFloat(column - midColumn)
                xOffsets[column] = halfWidth + (spacing * (adjustedColumn + 0.5)) + (itemWidth * adjustedColumn)
            }
            
            //calculate offsets for columns left of center
            for var column = midColumn - 1; column >= 0; column-- {
                let adjustedColumn = CGFloat(midColumn - column - 1)
                xOffsets[column] = halfWidth - (spacing * (adjustedColumn + 0.5)) - (itemWidth * (adjustedColumn + 1))
            }
        } else {
            let midColumn = (self.columnCount-1) / 2
            let halfItemWidth = itemWidth / 2.0
            
            xOffsets[midColumn] = halfWidth - halfItemWidth
            
            //calculate offsets for columns right of center
            for var column = midColumn + 1; column < self.columnCount; column++ {
                let adjustedColumn = CGFloat(column - midColumn)
                xOffsets[column] = halfWidth + halfItemWidth + (spacing * adjustedColumn) + (itemWidth * (adjustedColumn - 1))
            }
            
            //calculate offsets for columns left of center
            for var column = midColumn - 1; column >= 0; column-- {
                let adjustedColumn = CGFloat(midColumn - column)
                xOffsets[column] = halfWidth - halfItemWidth - (spacing * adjustedColumn) - (itemWidth * adjustedColumn)
            }
        }
        
        //offset all offsets by content inset
        xOffsets = xOffsets.map { $0 + self.contentInset.left }
        
        self.itemAttributes.removeAll(keepCapacity: true)
        self.maskAttributes.removeAll(keepCapacity: true)
        self.headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: WJStackCellLayoutHeader, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        self.headerAttributes.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: self.headerHeight)
        self.columnHeights = [CGFloat](count: self.columnCount, repeatedValue: self.headerHeight + self.contentInset.top)
        
        var top:CGFloat = 0
        let numberOfSections = collectionView.numberOfSections()
        for var section = 0; section < numberOfSections; section++ {
            self.itemAttributes.append([])
            
            let numberOfItems = collectionView.numberOfItemsInSection(section)
            let expandedItem = delegate.collectionView(collectionView, layout: self, expandedItemInSection: section)
            
            let columnIndex = self.columnForSection(section)
            let xOffset = xOffsets[columnIndex]
            
            var sectionBottom:CGFloat = 0
            for var item = 0; item < numberOfItems; item++ {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let itemHeight = delegate.collectionView(collectionView, layout: self, heightForItemAtIndexPath: indexPath)
                let yOffset = self.columnHeights[columnIndex]
                
                let verticalAdjustment: CGFloat
                if expandedItem == item {
                    verticalAdjustment = itemHeight
                } else {
                    verticalAdjustment = delegate.collectionView(collectionView, layout: self, verticalOffsetForItemAtIndexPath: indexPath)
                }
                
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                attributes.zIndex = (section*10)+item
                
                sectionBottom = max(yOffset+itemHeight, sectionBottom)
                
                self.itemAttributes[section].append(attributes)
                self.columnHeights[columnIndex] += verticalAdjustment
            }
            var maskAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: WJStackCellLayoutSectionMask, withIndexPath: NSIndexPath(forItem: 0, inSection: section))
            let yOffset = self.columnHeights[columnIndex]
            maskAttribute.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: sectionBottom - yOffset)
            maskAttribute.zIndex = (section*10)+numberOfItems
            self.maskAttributes.append(maskAttribute)
            self.columnHeights[columnIndex] += self.contentInset.bottom
        }
    }
    
    private func shortestColumn() -> Int {
        var shortestIndex = 0
        var shortestHeight = CGFloat.max
        for (index, height) in enumerate(self.columnHeights) {
            if height < shortestHeight {
                shortestHeight = height
                shortestIndex = index
            }
        }

        return shortestIndex
    }

    private func columnForSection(section: Int) -> Int {
        if let column = self.sectionColumns[section] where column != -1{
            return column
        } else {
            let column = self.shortestColumn()
            self.sectionColumns[section] = column
            return column
        }
    }
    
    func resetColumns() {
        self.sectionColumns.removeAll(keepCapacity: false)
    }
}
