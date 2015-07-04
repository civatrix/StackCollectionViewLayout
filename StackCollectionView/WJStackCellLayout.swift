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
    
    private var itemAttributes:[[UICollectionViewLayoutAttributes]] = []
    
    override func collectionViewContentSize() -> CGSize {
        return self.collectionView?.bounds.size ?? CGSizeZero
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        return self.itemAttributes.flatMap({ $0 })
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if indexPath.section >= self.itemAttributes.count { return nil }
        let attributes = self.itemAttributes[indexPath.section]
        
        if indexPath.item >= attributes.count { return nil }
        return attributes[indexPath.row]
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        if self.collectionView == nil { return }
        let collectionView = self.collectionView!
        
        if self.delegate == nil { return }
        let delegate = self.delegate!
        
        self.itemAttributes.removeAll(keepCapacity: true)
        
        let numberOfSections = collectionView.numberOfSections()
        let width = collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right
        
        var top:CGFloat = 0
        for var section = 0; section < numberOfSections; section++ {
            self.itemAttributes.append([])
            
            top += self.sectionInset.top
            let expandedItem = delegate.collectionView(collectionView, layout: self, expandedItemInSection: section)
            
            let numberOfItems = collectionView.numberOfItemsInSection(section)
            for var item = 0; item < numberOfItems; item++ {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                
                let itemHeight:CGFloat
                if expandedItem == item {
                    itemHeight = delegate.collectionView(collectionView, layout: self, heightForItemAtIndexPath: indexPath)
                } else {
                    itemHeight = delegate.collectionView(collectionView, layout: self, collapsedHeightForItemAtIndexPath: indexPath)
                }
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = CGRect(x: self.sectionInset.left, y: top, width: width, height: itemHeight)
                top += itemHeight
                
                self.itemAttributes[section].append(attributes)
            }
        }
    }
}
