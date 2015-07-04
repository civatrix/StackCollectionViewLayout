//
//  ViewController.swift
//  StackCollectionView
//
//  Created by Daniel Johns on 2015-07-03.
//  Copyright (c) 2015 Daniel Johns. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    let colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.orangeColor()]
    var expandedCell = [0,0,0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

extension ViewController: WJCollectionViewDelegateStackLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, collapsedHeightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: WJStackCellLayout, expandedItemInSection section: Int) -> Int {
        return self.expandedCell[section]
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.expandedCell[indexPath.section] = indexPath.item
        
        collectionView.performBatchUpdates(nil, completion: nil)
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
        cell.label.text = "Cell \(indexPath.item)"
        cell.contentView.backgroundColor = colors[indexPath.item]
        
        return cell
    }
}
