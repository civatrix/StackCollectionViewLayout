//
//  ViewController.swift
//  StackCollectionView
//
//  Created by Daniel Johns on 2015-07-03.
//  Copyright (c) 2015 Daniel Johns. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    struct cellInfo {
        let color: UIColor
        let text: String
    }
    var colors = [cellInfo(color: UIColor.redColor(), text: "Cell 1"), cellInfo(color: UIColor.blueColor(), text: "Cell 2"), cellInfo(color: UIColor.greenColor(), text: "Cell 3"), cellInfo(color: UIColor.orangeColor(), text: "Cell 4"), cellInfo(color: UIColor.purpleColor(), text: "Cell 5"), cellInfo(color: UIColor.cyanColor(), text: "Cell 6"), cellInfo(color: UIColor.lightGrayColor(), text: "Cell 7")]
    
    var cells:[[cellInfo]] = []
    var expandedCell:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cells = [self.colors, self.colors, self.colors, self.colors]
        for cell in self.cells {
            //Start with bottom cell expanded
            self.expandedCell.append(cell.count-1)
        }
        
        self.collectionView?.registerNib(UINib(nibName: "WJHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: WJStackCellLayoutHeader, withReuseIdentifier: "Header")
        self.collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: WJStackCellLayoutSectionMask, withReuseIdentifier: "Mask")
    }
    
    override func viewWillLayoutSubviews() {
        self.updateColumnWidthForSize(self.view.bounds.size)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.updateColumnWidthForSize(size)
        //have to invalidate the first time for header size update
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        coordinator.animateAlongsideTransition({ (_) -> Void in
            //invalidate the second time to animate column position changes
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }, completion: { (_) -> Void in
        })
    }
    
    func updateColumnWidthForSize(size: CGSize) {
        let numberOfColumns:Int
        let itemWidth:CGFloat
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            numberOfColumns = 1
            itemWidth = 0
        } else {
            numberOfColumns = 2
            itemWidth = 320
        }
        
        let layout = self.collectionView?.collectionViewLayout as? WJStackCellLayout
        layout?.columnCount = numberOfColumns
        layout?.itemWidth = itemWidth
    }
}

extension ViewController: WJCollectionViewDelegateStackLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item == 3 {
            return 200
        } else {
            return 100
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, verticalOffsetForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.expandedCell[indexPath.section] != indexPath.item {
            self.expandedCell[indexPath.section] = indexPath.item
            collectionView.performBatchUpdates(nil, completion: nil)
        } else {
            //expanded cell selected, perform navigation
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, expandedItemInSection section: Int) -> Int {
        return self.expandedCell[section]
    }
}

extension ViewController: UICollectionViewDataSource {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.cells.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cells[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! WJStackedCollectionViewCell
        let info = self.cells[indexPath.section][indexPath.item]
        cell.label.text = info.text
        cell.contentView.backgroundColor = info.color
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == WJStackCellLayoutSectionMask {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Mask", forIndexPath: indexPath) as! UICollectionReusableView
            cell.backgroundColor = collectionView.backgroundColor
            return cell
        } else {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! UICollectionReusableView
        }
    }
}
