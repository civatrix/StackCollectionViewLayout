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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, expandedItemInSection section: Int) -> Int
}

class WJStackCellLayout: UICollectionViewLayout {
    var columnCount = 1
    var sectionSpacing:CGFloat = 10.0
    var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    weak var delegate: WJCollectionViewDelegateStackLayout? {
        get {
            return self.collectionView?.delegate as? WJCollectionViewDelegateStackLayout
        }
    }
    
    private var _itemAttributes:[[UICollectionViewLayoutAttributes]] = []
    private var _contentSize = CGSizeZero
    
    func expandedItemInSection(section:Int) -> Int {
        if let delegate = self.delegate, collectionView = collectionView {
            return delegate.collectionView(collectionView, layout: self, expandedItemInSection: section)
        }
        
        return 0
    }

    override func collectionViewContentSize() -> CGSize {
        return self._contentSize
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        self.calculateLayout()
        return self._itemAttributes.flatMap({ $0 })
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        self.calculateLayout()
        
        if indexPath.section >= self._itemAttributes.count { return nil }
        let attributes = self._itemAttributes[indexPath.section]
        
        if indexPath.item >= attributes.count { return nil }
        return attributes[indexPath.row]
    }
    
    private func calculateLayout() {
        if self.collectionView == nil { return }
        let collectionView = self.collectionView!
        
        if self.delegate == nil { return }
        let delegate = self.delegate!
        
        self._itemAttributes.removeAll(keepCapacity: true)
        
        let numberOfSections = collectionView.numberOfSections()
        let width = collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right
        
        var top:CGFloat = 0
        for var section = 0; section < numberOfSections; section++ {
            self._itemAttributes.append([])
            
            top += self.sectionInset.top
            
            let expandedItem = self.expandedItemInSection(section)
            let numberOfItems = collectionView.numberOfItemsInSection(section)
            for var item = 0; item < numberOfItems; item++ {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let itemHeight = delegate.collectionView(collectionView, layout: self, heightForItemAtIndexPath: indexPath)
                let verticalAdjustment: CGFloat
                if expandedItem == item {
                    verticalAdjustment = itemHeight
                } else {
                    verticalAdjustment = delegate.collectionView(collectionView, layout: self, collapsedHeightForItemAtIndexPath: indexPath)
                }
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                let horizontalAdjustment = CGFloat(0)//4*CGFloat(numberOfItems-item)
                attributes.frame = CGRect(x: self.sectionInset.left-horizontalAdjustment*0.5, y: top, width: width+horizontalAdjustment, height: verticalAdjustment)
                top += verticalAdjustment
                
                self._itemAttributes[section].append(attributes)
            }
        }
        
        self._contentSize = CGSize(width: width, height: top)
    }
}
