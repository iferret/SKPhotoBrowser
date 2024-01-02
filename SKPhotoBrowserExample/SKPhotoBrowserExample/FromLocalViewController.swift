//
//  ViewController.swift
//  SKPhotoBrowserExample
//
//  Created by suzuki_keishi on 2015/10/06.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class FromLocalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SKPhotoBrowserDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [SKPhotoProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Static setup
        SKPhotoBrowserOptions.displayAction = true
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true

        setupTestData()
        setupCollectionView()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

 // MARK: - UICollectionViewDataSource
extension FromLocalViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exampleCollectionViewCell", for: indexPath) as? ExampleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.exampleImageView.image = UIImage(named: "image\((indexPath as NSIndexPath).row % 10).jpg")
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension FromLocalViewController {
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = SKPhotoBrowser(photos: images, initialIndex: indexPath.row)
        browser.delegate = self

        present(browser, animated: true, completion: {})
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 300)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 200)
        }
    }
}

// MARK: - SKPhotoBrowserDelegate

extension FromLocalViewController {
    
    /// didShowPhotoAtIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    internal func browser(_ browser: SKPhotoBrowser, didShowPhotoAtIndex index: Int) {
        collectionView.visibleCells.forEach({$0.isHidden = false})
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = true
        
        if index % 2 == 0 {
            browser.actionKind = .loading
        } else {
            browser.actionKind = .share
        }
    }
    
    /// willDismissAtPageIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    internal func browser(_ browser: SKPhotoBrowser, willDismissAtPageIndex index: Int) {
        collectionView.visibleCells.forEach({$0.isHidden = false})
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = true
    }
    
    /// willShowActionSheetAtIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - photoIndex: Int
    internal func browser(_ browser: SKPhotoBrowser, willShowActionSheetAtIndex photoIndex: Int) {
        // do some handle if you need
    }
    
    /// didDismissAtPageIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    internal func browser(_ browser: SKPhotoBrowser, didDismissAtPageIndex index: Int) {
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = false
    }
    
    /// didDismissActionSheetWithButtonIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - buttonIndex: Int
    ///   - photoIndex: Int
    internal func browser(_ browser: SKPhotoBrowser, didDismissActionSheetWithButtonIndex buttonIndex: Int, photoIndex: Int) {
        // handle dismissing custom actions
    }
    
    /// removePhotoAtIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    ///   - reload: @escaping (() -> Void)
    internal func browser(_ browser: SKPhotoBrowser, removePhotoAtIndex index: Int, reload: @escaping (() -> Void)) {
        reload()
    }
    
    /// viewForPhotoAtIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    /// - Returns: Optional<UIView>
    internal func browser(_ browser: SKPhotoBrowser, viewForPhotoAtIndex index: Int) -> Optional<UIView> {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    /// captionViewForPhotoAtIndex
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    /// - Returns: Optional<SKCaptionView>
    internal func browser(_ browser: SKPhotoBrowser, captionViewForPhotoAtIndex index: Int) -> Optional<SKCaptionView> {
        return nil
    }
   
}

// MARK: - private

private extension FromLocalViewController {
    func setupTestData() {
        images = createLocalPhotos()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createLocalPhotos() -> [SKPhotoProtocol] {
        return (0..<10).map { (i: Int) -> SKPhotoProtocol in
            let photo = SKPhoto.photoWithImage(UIImage(named: "image\(i%10).jpg")!)
            // photo.caption = caption[i%10]
            return photo
        }
    }
}

class ExampleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var exampleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        exampleImageView.image = nil
//        layer.cornerRadius = 25.0
        layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        exampleImageView.image = nil
    }
}

var caption = ["Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
               ]
