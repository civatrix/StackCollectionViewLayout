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
    
    var cells = [cellInfo(color: UIColor.redColor(), text: "Cell 1"), cellInfo(color: UIColor.blueColor(), text: "Cell 2"), cellInfo(color: UIColor.greenColor(), text: "Cell 3"), cellInfo(color: UIColor.orangeColor(), text: "Cell 4")]
    var expandedCell = [0,0,0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.collectionView?.draggable = true
        self.collectionView?.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
}

extension ViewController: WJCollectionViewDelegateStackLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, collapsedHeightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, expandedItemInSection section: Int) -> Int {
        return self.expandedCell[section]
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.expandedCell[indexPath.section] != indexPath.item {
            //update to expand selected cell
            self.expandedCell[indexPath.section] = indexPath.item
            
            collectionView.performBatchUpdates(nil, completion: nil)
            return
        } else {
            //expanded cell selected, perform navigation
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! WJStackedCollectionViewCell
        let info = self.cells[indexPath.item]
        cell.label.text = info.text
        cell.contentView.backgroundColor = info.color
        
        return cell
    }
}

extension ViewController: UICollectionViewDataSource_Draggable {
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        let fromIndex = fromIndexPath.item
        let toIndex = toIndexPath.item
        let movingObject = self.cells[fromIndex];
        
        self.cells.removeAtIndex(fromIndex)
        self.cells.insert(movingObject, atIndex: toIndex)
        
        NSLog("Moving %ld to %ld", fromIndexPath.item, toIndexPath.item)
        
        self.expandedCell[toIndexPath.section] = toIndexPath.item
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath: NSIndexPath) -> Bool {
        //items must stay in the same section
        return indexPath.section == toIndexPath.section
    }
}
