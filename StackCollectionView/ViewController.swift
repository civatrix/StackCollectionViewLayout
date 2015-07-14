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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cells = [self.colors, self.colors, self.colors, self.colors];
        
        self.collectionView?.draggable = true
        self.collectionView?.registerNib(UINib(nibName: "WJHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: WJStackCellLayoutHeader, withReuseIdentifier: "Header")
    }
    
    override func viewWillLayoutSubviews() {
        self.updateColumnWidthForSize(self.view.bounds.size)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.updateColumnWidthForSize(size)
    }
    
    func updateColumnWidthForSize(size: CGSize) {
        let numberOfColumns:Int
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            numberOfColumns = 1
        } else {
            if (size.width < size.height) {
                numberOfColumns = 2
            } else {
                numberOfColumns = 3
            }
        }
        
        let layout = self.collectionView!.collectionViewLayout as! WJStackCellLayout
        layout.columnCount = numberOfColumns
    }
    
    func moveItemAtIndexPath(fromIndexPath:NSIndexPath, toIndexPath:NSIndexPath) {
        let fromIndex = fromIndexPath.item
        let toIndex = toIndexPath.item
        let movingObject = self.cells[fromIndexPath.section][fromIndex];
        
        self.cells[fromIndexPath.section].removeAtIndex(fromIndex)
        self.cells[toIndexPath.section].insert(movingObject, atIndex: toIndex)
        
        self.collectionView?.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
    }
}

extension ViewController: WJCollectionViewDelegateStackLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, verticalOffsetForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let numberOfItemsInSection = self.cells[indexPath.section].count
        if numberOfItemsInSection != indexPath.item {
            //update to move selected cell to bottom
            self.moveItemAtIndexPath(indexPath, toIndexPath: NSIndexPath(forItem: numberOfItemsInSection-1, inSection: indexPath.section))
            return
        } else {
            //bottom cell selected, perform navigation
        }
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
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! UICollectionReusableView
    }
}

extension ViewController: UICollectionViewDataSource_Draggable {
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        self.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath: NSIndexPath) -> Bool {
        //items must stay in the same section
        return indexPath.section == toIndexPath.section
    }
}
