//
//  SKPagingScrollView.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/18.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import UIKit

/// SKPagingScrollView
class SKPagingScrollView: UIScrollView {
    
    /// Int
    fileprivate let pageIndexTagOffset: Int = 1000
    /// CGFloat
    fileprivate let sideMargin: CGFloat = 10
    /// [SKZoomingScrollView]
    fileprivate var visiblePages: [SKZoomingScrollView] = []
    /// [SKZoomingScrollView]
    fileprivate var recycledPages: [SKZoomingScrollView] = []
    /// SKPhotoBrowser
    fileprivate weak var browser: Optional<SKPhotoBrowser> = .none
    /// Int
    internal var numberOfPhotos: Int {  browser?.photos.count ?? 0 }
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// 构建
    /// - Parameters:
    ///   - frame: CGRect
    ///   - browser: SKPhotoBrowser
    internal convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser

        isPagingEnabled = true
        showsHorizontalScrollIndicator = SKPhotoBrowserOptions.displayPagingHorizontalScrollIndicator
        showsVerticalScrollIndicator = true

        updateFrame(bounds, currentPageIndex: browser.currentIndex)
    }
    
    /// reload
    internal func reload() {
        visiblePages.forEach { $0.removeFromSuperview() }
        visiblePages.removeAll()
        recycledPages.removeAll()
    }
    
    /// loadAdjacentPhotosIfNecessary
    /// - Parameters:
    ///   - photo: SKPhotoProtocol
    ///   - currentPageIndex: Int
    internal func loadAdjacentPhotosIfNecessary(_ photo: SKPhotoProtocol, currentPageIndex: Int) {
        guard let browser = browser, let page = pageDisplayingAtPhoto(photo) else { return }
        let pageIndex = (page.tag - pageIndexTagOffset)
        if currentPageIndex == pageIndex {
            // Previous
            if pageIndex > 0 {
                let previousPhoto = browser.photos[pageIndex - 1]
                if previousPhoto.underlyingImage == nil {
                    previousPhoto.loadUnderlyingImageAndNotify()
                }
            }
            // Next
            if pageIndex < numberOfPhotos - 1 {
                let nextPhoto = browser.photos[pageIndex + 1]
                if nextPhoto.underlyingImage == nil {
                    nextPhoto.loadUnderlyingImageAndNotify()
                }
            }
        }
    }
    
    /// deleteImage
    internal func deleteImage() {
        // index equals 0 because when we slide between photos delete button is hidden and user cannot to touch on delete button. And visible pages number equals 0
        if numberOfPhotos > 0 {
            visiblePages[0].captionView?.removeFromSuperview()
        }
    }
    
    /// jumpToPageAtIndex
    /// - Parameter frame: CGRect
    internal func jumpToPageAtIndex(_ frame: CGRect) {
        let point = CGPoint(x: frame.origin.x - sideMargin, y: 0)
        setContentOffset(point, animated: true)
    }
    
    /// updateFrame
    /// - Parameters:
    ///   - bounds: CGRect
    ///   - currentPageIndex: Int
    internal func updateFrame(_ bounds: CGRect, currentPageIndex: Int) {
        var frame = bounds
        frame.origin.x -= sideMargin
        frame.size.width += (2 * sideMargin)
        
        self.frame = frame
        
        if visiblePages.count > 0 {
            for page in visiblePages {
                let pageIndex = page.tag - pageIndexTagOffset
                page.frame = frameForPageAtIndex(pageIndex)
                page.setMaxMinZoomScalesForCurrentBounds()
                if let captionView = page.captionView {
                    captionView.frame = frameForCaptionView(captionView, index: pageIndex)
                }
            }
        }
        
        updateContentSize()
        updateContentOffset(currentPageIndex)
    }
    
    /// updateContentSize
    internal func updateContentSize() {
        contentSize = CGSize(width: bounds.size.width * CGFloat(numberOfPhotos), height: bounds.size.height)
    }
    
    /// updateContentOffset
    /// - Parameter index: Int
    internal func updateContentOffset(_ index: Int) {
        let pageWidth = bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        contentOffset = CGPoint(x: newOffset, y: 0)
    }
    
    /// tilePages
    internal func tilePages() {
        guard let browser = browser else { return }
        let firstIndex: Int = getFirstIndex()
        let lastIndex: Int = getLastIndex()
        visiblePages.filter { $0.tag - pageIndexTagOffset < firstIndex ||  $0.tag - pageIndexTagOffset > lastIndex }.forEach { page in
            recycledPages.append(page)
            page.prepareForReuse()
            page.removeFromSuperview()
        }
        let visibleSet: Set<SKZoomingScrollView> = Set(visiblePages)
        let visibleSetWithoutRecycled: Set<SKZoomingScrollView> = visibleSet.subtracting(recycledPages)
        visiblePages = Array(visibleSetWithoutRecycled)
        while recycledPages.count > 2 {
            recycledPages.removeFirst()
        }
        for index: Int in firstIndex...lastIndex {
            if visiblePages.filter({ $0.tag - pageIndexTagOffset == index }).count > 0 {
                continue
            }
            let page: SKZoomingScrollView = SKZoomingScrollView(frame: frame, browser: browser)
            page.frame = frameForPageAtIndex(index)
            page.tag = index + pageIndexTagOffset
            let photo = browser.photos[index]
            page.photo = photo
            if let thumbnail = browser.animator.senderOriginImage,
                index == browser.initialIndex,
                photo.underlyingImage == nil {
                page.displayImage(thumbnail)
            }
            
            visiblePages.append(page)
            addSubview(page)
            
            // if exists caption, insert
            if let captionView: SKCaptionView = createCaptionView(index) {
                captionView.frame = frameForCaptionView(captionView, index: index)
                captionView.alpha = browser.areControlsHidden() ? 0 : 1
                addSubview(captionView)
                // ref val for control
                page.captionView = captionView
            }
        }
    }
    
    /// frameForCaptionView
    /// - Parameters:
    ///   - captionView: SKCaptionView
    ///   - index: Int
    /// - Returns: CGRect
    internal func frameForCaptionView(_ captionView: SKCaptionView, index: Int) -> CGRect {
        let pageFrame = frameForPageAtIndex(index)
        let captionSize = captionView.sizeThatFits(CGSize(width: pageFrame.size.width, height: 0))
        let paginationFrame = browser?.paginationView.frame ?? .zero
        let toolbarFrame = browser?.toolbar.frame ?? .zero
        
        var frameSet = CGRect.zero
        switch SKCaptionOptions.captionLocation {
        case .basic:
            frameSet = paginationFrame
        case .bottom:
            frameSet = toolbarFrame
        }
        return CGRect(x: pageFrame.origin.x,
                      y: pageFrame.size.height - captionSize.height - frameSet.height,
                      width: pageFrame.size.width,
                      height: captionSize.height)
    }
    
    /// pageDisplayedAtIndex
    /// - Parameter index: Int
    /// - Returns: SKZoomingScrollView
    internal func pageDisplayedAtIndex(_ index: Int) -> Optional<SKZoomingScrollView> {
        for page in visiblePages where page.tag - pageIndexTagOffset == index {
            return page
        }
        return nil
    }
    
    /// pageDisplayingAtPhoto
    /// - Parameter photo: SKPhotoProtocol
    /// - Returns: SKZoomingScrollView
    internal func pageDisplayingAtPhoto(_ photo: SKPhotoProtocol) -> Optional<SKZoomingScrollView> {
        for page in visiblePages where page.photo === photo {
            return page
        }
        return nil
    }
    
    /// getCaptionViews
    /// - Returns: Set<SKCaptionView>
    internal func getCaptionViews() -> Set<SKCaptionView> {
        var captionViews = Set<SKCaptionView>()
        visiblePages.compactMap { $0.captionView }.forEach { captionViews.insert($0) }
        return captionViews
    }
    
    /// setControlsHidden
    /// - Parameter hidden: Bool
    internal func setControlsHidden(hidden: Bool) {
        let captionViews = getCaptionViews()
        let alpha: CGFloat = hidden ? 0.0 : 1.0
        // animate
        UIView.animate(withDuration: 0.35) {
            captionViews.forEach { $0.alpha = alpha }
        }
    }
}

extension SKPagingScrollView {
    
    /// frameForPageAtIndex
    /// - Parameter index: Int
    /// - Returns: CGRect
    private func frameForPageAtIndex(_ index: Int) -> CGRect {
        var pageFrame = bounds
        pageFrame.size.width -= (2 * sideMargin)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + sideMargin
        return pageFrame
    }
    
    /// createCaptionView
    /// - Parameter index: Int
    /// - Returns: SKCaptionView
    private func createCaptionView(_ index: Int) -> Optional<SKCaptionView> {
        guard let browser = browser else { return .none }
        if let ownCaptionView = browser.delegate?.browser?(browser, captionViewForPhotoAtIndex: index) {
            return ownCaptionView
        }
        let photo = browser.photoAtIndex(index)
        guard photo.caption != nil else { return .none }
        return SKCaptionView(photo: photo)
    }
    
    /// getFirstIndex
    /// - Returns: Int
    private func getFirstIndex() -> Int {
        let firstIndex = Int(floor((bounds.minX + sideMargin * 2) / bounds.width))
        if firstIndex < 0 {
            return 0
        }
        if firstIndex > numberOfPhotos - 1 {
            return numberOfPhotos - 1
        }
        return firstIndex
    }
    
    /// getLastIndex
    /// - Returns: Int
    private func getLastIndex() -> Int {
        let lastIndex  = Int(floor((bounds.maxX - sideMargin * 2 - 1) / bounds.width))
        if lastIndex < 0 {
            return 0
        }
        if lastIndex > numberOfPhotos - 1 {
            return numberOfPhotos - 1
        }
        return lastIndex
    }
}

