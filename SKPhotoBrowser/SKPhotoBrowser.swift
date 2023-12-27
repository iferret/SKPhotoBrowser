//
//  SKPhotoBrowser.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

public let SKPHOTO_LOADING_DID_END_NOTIFICATION = "photoLoadingDidEndNotification"

// MARK: - SKPhotoBrowser
/// SKPhotoBrowser
open class SKPhotoBrowser: UIViewController {
    /// Int
    open var currentPageIndex: Int = 0
    /// Int
    open var initPageIndex: Int = 0
    /// UIActivityItemProvider
    open var activityItemProvider: Optional<UIActivityItemProvider> = .none
    /// [SKPhotoProtocol]
    open var photos: [SKPhotoProtocol] = []
    /// Double
    open var autoHideControllsfadeOutDelay: Double = 4.0
    /// Bool
    open var shouldAutoHideControlls: Bool = true
    
    /// UIBarButtonItem
    public var toolActionButton: Optional<UIBarButtonItem> { toolbar.toolActionButton }
    /// Optional<UIBarButtonItem>
    public var toolDownloadButton: Optional<UIBarButtonItem> { toolbar.toolDownloadButton }
    
    /// SKPagingScrollView
    internal lazy var pagingScrollView: SKPagingScrollView = SKPagingScrollView(frame: self.view.frame, browser: self)
    
    // appearance
    fileprivate let bgColor: UIColor = SKPhotoBrowserOptions.backgroundColor
    // SKAnimator
    internal let animator: SKAnimator = .init()
    
    // SKActionView
    fileprivate var actionView: SKActionView!
    /// SKPaginationView
    fileprivate(set) var paginationView: SKPaginationView!
    /// SKToolbar
    internal var toolbar: SKToolbar!

    /// Optional<UIPanGestureRecognizer>
    fileprivate var panGesture: Optional<UIPanGestureRecognizer> = .none
    
    /// Bool
    fileprivate var isEndAnimationByToolBar: Bool = true
    
    /// Bool
    fileprivate var isViewActive: Bool = false
    
    /// Bool
    fileprivate var isPerformingLayout: Bool = false
    
    /// CGFloat
    fileprivate var firstX: CGFloat = 0.0
    
    /// CGFloat
    fileprivate var firstY: CGFloat = 0.0
    
    /// Timer
    fileprivate var controlVisibilityTimer: Optional<Timer> = .none
    // delegate
    open weak var delegate: Optional<SKPhotoBrowserDelegate> = .none
    
    // statusbar initial state
    private var statusbarHidden: Bool = UIApplication.shared.isStatusBarHidden
    
    // strings
    open var cancelTitle = "Cancel"
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// 构建
    /// - Parameters:
    ///   - nibNameOrNil: String
    ///   - nibBundleOrNil: Bundle
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    /// 构建
    /// - Parameter photos: [SKPhotoProtocol]
    public convenience init(photos: [SKPhotoProtocol]) {
        self.init(photos: photos, initialPageIndex: 0)
    }
    
    /// 构建
    /// - Parameters:
    ///   - originImage: UIImage
    ///   - photos: [SKPhotoProtocol]
    ///   - animatedFromView: UIView
    @available(*, deprecated)
    public convenience init(originImage: UIImage, photos: [SKPhotoProtocol], animatedFromView: UIView) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.photos.forEach { $0.checkCache() }
        animator.senderOriginImage = originImage
        animator.senderViewForAnimation = animatedFromView
    }
    
    /// 构建
    /// - Parameters:
    ///   - photos: [SKPhotoProtocol]
    ///   - initialPageIndex: Int
    public convenience init(photos: [SKPhotoProtocol], initialPageIndex: Int) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        //self.photos.forEach { $0.checkCache() }
        self.currentPageIndex = min(initialPageIndex, photos.count - 1)
        self.initPageIndex = self.currentPageIndex
        animator.senderOriginImage = photos[currentPageIndex].underlyingImage
        animator.senderViewForAnimation = photos[currentPageIndex] as? UIView
    }
    
    /// setup
    internal func setup() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        let name: Notification.Name = .init(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSKPhotoLoadingDidEndNotification(_:)), name: name, object: nil)
    }
    
    // MARK: - override
    
    /// viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configurePagingScrollView()
        configureGestureControl()
        configureActionView()
        configurePaginationView()
        configureToolbar()
        
        animator.willPresent(self)
    }
    
    /// viewWillAppear
    /// - Parameter animated: Bool
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadData()
        var i = 0
        for photo: SKPhotoProtocol in photos {
            photo.index = i
            i += 1
        }
    }
    
    /// viewWillLayoutSubviews
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        isPerformingLayout = true
        // where did start
        delegate?.browser?(self, didShowPhotoAtIndex: currentPageIndex)
        // toolbar
        toolbar.frame = frameForToolbarAtOrientation()
        // action
        actionView.updateFrame(frame: view.frame)
        // paging
        switch SKCaptionOptions.captionLocation {
        case .basic:  paginationView.updateFrame(frame: view.frame)
        case .bottom: paginationView.frame = frameForPaginationAtOrientation()
        }
        pagingScrollView.updateFrame(view.bounds, currentPageIndex: currentPageIndex)
        
        isPerformingLayout = false
    }
    
    /// viewDidAppear
    /// - Parameter animated: Bool
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
    }
    
    /// Bool
    open override var prefersStatusBarHidden: Bool {
        return SKPhotoBrowserOptions.displayStatusbar == false
    }
    
    // MARK: - Notification
    
    /// handleSKPhotoLoadingDidEndNotification
    /// - Parameter notification: Notification
    @objc open func handleSKPhotoLoadingDidEndNotification(_ notification: Notification) {
        guard let photo = notification.object as? SKPhotoProtocol else { return }
        // dispatch main
        DispatchQueue.main.async {[weak self] in
            guard let this = self,
                  let page = this.pagingScrollView.pageDisplayingAtPhoto(photo),
                  let photo = page.photo
            else { return }
            if photo.underlyingImage != nil {
                page.displayImage(complete: true)
                this.loadAdjacentPhotosIfNecessary(photo)
            } else {
                page.displayImageFailure()
            }
        }
    }
    
    /// loadAdjacentPhotosIfNecessary
    /// - Parameter photo: SKPhotoProtocol
    open func loadAdjacentPhotosIfNecessary(_ photo: SKPhotoProtocol) {
        pagingScrollView.loadAdjacentPhotosIfNecessary(photo, currentPageIndex: currentPageIndex)
    }
    
    // MARK: - initialize / setup
    
    /// reloadData
    open func reloadData() {
        performLayout()
        view.setNeedsLayout()
    }
    
    /// performLayout
    open func performLayout() {
        isPerformingLayout = true
        // reset local cache
        pagingScrollView.reload()
        pagingScrollView.updateContentOffset(currentPageIndex)
        pagingScrollView.tilePages()
        // didShowPhotoAtIndex
        delegate?.browser?(self, didShowPhotoAtIndex: currentPageIndex)
        // isPerformingLayout
        isPerformingLayout = false
    }
    
    /// prepareForClosePhotoBrowser
    open func prepareForClosePhotoBrowser() {
        cancelControlHiding()
        if let panGesture = panGesture {
            view.removeGestureRecognizer(panGesture)
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    /// dismissPhotoBrowser
    /// - Parameters:
    ///   - animated: Bool
    ///   - completion: Optional<() -> Void>
    open func dismissPhotoBrowser(animated: Bool, completion: Optional<() -> Void> = .none) {
        prepareForClosePhotoBrowser()
        if !animated {
            modalTransitionStyle = .crossDissolve
        }
        dismiss(animated: !animated) {
            completion?()
            self.delegate?.browser?(self, didDismissAtPageIndex: self.currentPageIndex)
        }
    }
    
    /// determineAndClose
    open func determineAndClose() {
        delegate?.browser?(self, willDismissAtPageIndex: currentPageIndex)
        animator.willDismiss(self)
    }
    
    /// popupShare
    /// - Parameter includeCaption: Bool
    open func popupShare(includeCaption: Bool = true) {
        let photo = photos[currentPageIndex]
        guard let underlyingImage = photo.underlyingImage else { return }
        var activityItems: [AnyObject] = [underlyingImage]
        if photo.caption != nil && includeCaption {
            if let shareExtraCaption = SKPhotoBrowserOptions.shareExtraCaption {
                let caption = photo.caption ?? "" + shareExtraCaption
                activityItems.append(caption as AnyObject)
            } else {
                activityItems.append(photo.caption as AnyObject)
            }
        }
        
        if let activityItemProvider = activityItemProvider {
            activityItems.append(activityItemProvider.item as AnyObject)
        }
        
        let controller: UIActivityViewController = .init(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { (activity, success, items, error) in
            self.hideControlsAfterDelay()
        }
        if SKMesurement.isPhone {
            present(controller, animated: true, completion: nil)
        } else {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.barButtonItem = toolbar.toolActionButton
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - Public Function For Customizing Buttons

extension SKPhotoBrowser {
    
    /// updateCloseButton
    /// - Parameters:
    ///   - image: UIImage
    ///   - size: CGSize
    public func updateCloseButton(_ image: UIImage, size: Optional<CGSize> = .none) {
        actionView.updateCloseButton(image: image, size: size)
    }
    
    /// updateDeleteButton
    /// - Parameters:
    ///   - image: UIImage
    ///   - size:  Optional<CGSize>
    public func updateDeleteButton(_ image: UIImage, size: Optional<CGSize> = .none) {
        actionView.updateDeleteButton(image: image, size: size)
    }
    
    /// hiddenActionButton
    /// - Parameter hidden: Bool
    public func hiddenActionButton(_ hidden: Bool) {
        toolbar?.hideActionButton(hidden)
    }
    
    /// hideDownloadButton
    /// - Parameter hidden: Bool
    public func hideDownloadButton(_ hidden: Bool) {
        toolbar.hideDownloadButton(hidden)
    }
}

// MARK: - Public Function For Browser Control

extension SKPhotoBrowser {
    
    /// initializePageIndex
    /// - Parameter index: Int
    public func initializePageIndex(_ index: Int) {
        let i = min(index, photos.count - 1)
        currentPageIndex = i
        
        if isViewLoaded {
            jumpToPageAtIndex(index)
            if !isViewActive {
                pagingScrollView.tilePages()
            }
            paginationView.update(currentPageIndex)
        }
        self.initPageIndex = currentPageIndex
    }
    
    /// jumpToPageAtIndex
    /// - Parameter index: Int
    public func jumpToPageAtIndex(_ index: Int) {
        if index < photos.count {
            if !isEndAnimationByToolBar { return }
            isEndAnimationByToolBar = false
            let pageFrame = frameForPageAtIndex(index)
            pagingScrollView.jumpToPageAtIndex(pageFrame)
        }
        hideControlsAfterDelay()
    }
    
    /// photoAtIndex
    /// - Parameter index: Int
    /// - Returns: SKPhotoProtocol
    public func photoAtIndex(_ index: Int) -> SKPhotoProtocol {
        return photos[index]
    }
    
    /// gotoPreviousPage
    @objc public func gotoPreviousPage() {
        jumpToPageAtIndex(currentPageIndex - 1)
    }
    
    /// gotoNextPage
    @objc public func gotoNextPage() {
        jumpToPageAtIndex(currentPageIndex + 1)
    }
    
    /// cancelControlHiding
    public func cancelControlHiding() {
        if controlVisibilityTimer != nil {
            controlVisibilityTimer?.invalidate()
            controlVisibilityTimer = nil
        }
    }
    
    /// hideControlsAfterDelay
    public func hideControlsAfterDelay() {
        // Hide controlls only if it is configured to hide automatically
        guard shouldAutoHideControlls else { return }
        // reset
        cancelControlHiding()
        // start
        controlVisibilityTimer = Timer.scheduledTimer(timeInterval: autoHideControllsfadeOutDelay, 
                                                      target: self,
                                                      selector: #selector(SKPhotoBrowser.hideControls(_:)),
                                                      userInfo: nil,
                                                      repeats: false)
    }
    
    /// hideControls
    public func hideControls() {
        setControlsHidden(true, animated: true, permanent: false)
    }
    
    /// hideControls
    /// - Parameter timer: Timer
    @objc public func hideControls(_ timer: Timer) {
        hideControls()
        delegate?.browser?(self, controlsVisibilityToggled: true)
    }
    
    /// toggleControls
    public func toggleControls() {
        let hidden = !areControlsHidden()
        setControlsHidden(hidden, animated: true, permanent: false)
        delegate?.browser?(self, controlsVisibilityToggled: areControlsHidden())
    }
    
    /// areControlsHidden
    /// - Returns: Bool
    public func areControlsHidden() -> Bool {
        return paginationView.alpha == 0.0
    }
    
    /// getCurrentPageIndex
    /// - Returns: Int
    public func getCurrentPageIndex() -> Int {
        return currentPageIndex
    }
    
    /// addPhotos
    /// - Parameter photos: [SKPhotoProtocol]
    public func addPhotos(photos: [SKPhotoProtocol]) {
        self.photos.append(contentsOf: photos)
        self.reloadData()
    }
    
    /// insertPhotos
    /// - Parameters:
    ///   - photos: [SKPhotoProtocol]
    ///   - index: Int
    public func insertPhotos(photos: [SKPhotoProtocol], at index: Int) {
        self.photos.insert(contentsOf: photos, at: index)
        self.reloadData()
    }
}

// MARK: - Internal Function

extension SKPhotoBrowser {
    
    /// showButtons
    internal func showButtons() {
        actionView.animate(hidden: false)
    }
    
    /// pageDisplayedAtIndex
    /// - Parameter index: Int
    /// - Returns: SKZoomingScrollView
    internal func pageDisplayedAtIndex(_ index: Int) -> SKZoomingScrollView? {
        return pagingScrollView.pageDisplayedAtIndex(index)
    }
    
    /// getImageFromView
    /// - Parameter sender: UIView
    /// - Returns: UIImage
    internal func getImageFromView(_ sender: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

// MARK: - Internal Function For Frame Calc

extension SKPhotoBrowser {
    
    /// frameForToolbarAtOrientation
    /// - Returns: CGRect
    internal func frameForToolbarAtOrientation() -> CGRect {
        let offset: CGFloat = {
            if #available(iOS 11.0, *) {
                return view.safeAreaInsets.bottom - 5.0
            } else {
                return 15.0
            }
        }()
        return view.bounds.divided(atDistance: 44, from: .maxYEdge).slice.offsetBy(dx: 0, dy: -offset)
    }
    
    /// frameForToolbarHideAtOrientation
    /// - Returns: CGRect
    internal func frameForToolbarHideAtOrientation() -> CGRect {
        return view.bounds.divided(atDistance: 44, from: .maxYEdge).slice.offsetBy(dx: 0, dy: 44)
    }
    
    /// frameForPaginationAtOrientation
    /// - Returns: CGRect
    internal func frameForPaginationAtOrientation() -> CGRect {
        let offset = UIDevice.current.orientation.isLandscape ? 35 : 44
        return CGRect(x: 0, y: self.view.bounds.size.height - CGFloat(offset), width: self.view.bounds.size.width, height: CGFloat(offset))
    }
    
    /// frameForPageAtIndex
    /// - Parameter index: Int
    /// - Returns: CGRect
    internal func frameForPageAtIndex(_ index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
}

// MARK: - Internal Function For Button Pressed, UIGesture Control

extension SKPhotoBrowser {
    
    /// panGestureRecognized
    /// - Parameter sender: UIPanGestureRecognizer
    @objc internal func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        guard let zoomingScrollView: SKZoomingScrollView = pagingScrollView.pageDisplayedAtIndex(currentPageIndex) else {
            return
        }
        
        animator.backgroundView.isHidden = true
        let viewHeight: CGFloat = zoomingScrollView.frame.size.height
        let viewHalfHeight: CGFloat = viewHeight/2
        var translatedPoint: CGPoint = sender.translation(in: self.view)
        
        // gesture began
        if sender.state == .began {
            firstX = zoomingScrollView.center.x
            firstY = zoomingScrollView.center.y
            
            hideControls()
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        zoomingScrollView.center = translatedPoint
        
        let minOffset: CGFloat = viewHalfHeight / 4
        let offset: CGFloat = 1 - (zoomingScrollView.center.y > viewHalfHeight
                                   ? zoomingScrollView.center.y - viewHalfHeight
                                   : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight
        
        view.backgroundColor = bgColor.withAlphaComponent(max(0.7, offset))
        
        // gesture end
        if sender.state == .ended {
            
            if zoomingScrollView.center.y > viewHalfHeight + minOffset
                || zoomingScrollView.center.y < viewHalfHeight - minOffset {
                
                determineAndClose()
                
            } else {
                // Continue Showing View
                setNeedsStatusBarAppearanceUpdate()
                view.backgroundColor = bgColor
                
                let velocityY: CGFloat = CGFloat(0.35) * sender.velocity(in: self.view).y
                let finalX: CGFloat = firstX
                let finalY: CGFloat = viewHalfHeight
                
                let animationDuration: Double = Double(abs(velocityY) * 0.0002 + 0.2)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIView.AnimationCurve.easeIn)
                zoomingScrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()
            }
        }
    }
    
    /// actionButtonPressed
    /// - Parameter ignoreAndShare: Bool
    @objc internal func actionButtonPressed(ignoreAndShare: Bool) {
        delegate?.browser?(self, willShowActionSheetAtIndex: currentPageIndex)
        guard photos.count > 0 else { return }
        if let titles = SKPhotoBrowserOptions.actionButtonTitles {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheetController.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
            for idx in titles.indices {
                actionSheetController.addAction(UIAlertAction(title: titles[idx], style: .default, handler: {[unowned self] (_) -> Void in
                    self.delegate?.browser?(self, didDismissActionSheetWithButtonIndex: idx, photoIndex: self.currentPageIndex)
                }))
            }
            if SKMesurement.isPhone {
                present(actionSheetController, animated: true, completion: nil)
            } else {
                actionSheetController.modalPresentationStyle = .popover
                if let popoverController = actionSheetController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.barButtonItem = toolbar.toolActionButton
                }
                present(actionSheetController, animated: true, completion: { () -> Void in
                    
                })
            }
        } else {
            popupShare()
        }
    }
    
    /// deleteImage
    internal func deleteImage() {
        defer { reloadData() }
        if photos.count > 1 {
            pagingScrollView.deleteImage()
            photos.remove(at: currentPageIndex)
            if currentPageIndex != 0 {
                gotoPreviousPage()
            }
            paginationView.update(currentPageIndex)
        } else if photos.count == 1 {
            dismissPhotoBrowser(animated: true)
        }
    }
}

// MARK: - Private Function
extension SKPhotoBrowser {
    
    /// configureAppearance
    private func configureAppearance() {
        view.backgroundColor = bgColor
        view.clipsToBounds = true
        view.isOpaque = false
        if #available(iOS 11.0, *) {
            view.accessibilityIgnoresInvertColors = true
        }
    }
    
    /// configurePagingScrollView
    private func configurePagingScrollView() {
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
    }
    
    /// configureGestureControl
    private func configureGestureControl() {
        guard !SKPhotoBrowserOptions.disableVerticalSwipe else { return }
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SKPhotoBrowser.panGestureRecognized(_:)))
        panGesture?.minimumNumberOfTouches = 1
        panGesture?.maximumNumberOfTouches = 1
        if let panGesture = panGesture {
            view.addGestureRecognizer(panGesture)
        }
    }
    
    /// configureActionView
    private func configureActionView() {
        actionView = SKActionView(frame: view.frame, browser: self)
        view.addSubview(actionView)
    }
    
    /// configurePaginationView
    private func configurePaginationView() {
        paginationView = SKPaginationView(frame: view.frame, browser: self)
        view.addSubview(paginationView)
    }
    
    /// configureToolbar
    private func configureToolbar() {
        toolbar = SKToolbar(frame: frameForToolbarAtOrientation(), browser: self)
        view.addSubview(toolbar)
    }
    
    /// setControlsHidden
    /// - Parameters:
    ///   - hidden: Bool
    ///   - animated: Bool
    ///   - permanent: Bool
    private func setControlsHidden(_ hidden: Bool, animated: Bool, permanent: Bool) {
        // timer update
        cancelControlHiding()
        // scroll animation
        pagingScrollView.setControlsHidden(hidden: hidden)
        // paging animation
        paginationView.setControlsHidden(hidden: hidden)
        // action view animation
        actionView.animate(hidden: hidden)
        if !hidden && !permanent {
            hideControlsAfterDelay()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - UIScrollView Delegate

extension SKPhotoBrowser: UIScrollViewDelegate {
    
    /// scrollViewDidScroll
    /// - Parameter scrollView: UIScrollView
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isViewActive else { return }
        guard !isPerformingLayout else { return }
        
        // tile page
        pagingScrollView.tilePages()
        
        // Calculate current page
        let previousCurrentPage = currentPageIndex
        let visibleBounds = pagingScrollView.bounds
        currentPageIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), photos.count - 1)
        
        if currentPageIndex != previousCurrentPage {
            delegate?.browser?(self, didShowPhotoAtIndex: currentPageIndex)
            paginationView.update(currentPageIndex)
        }
    }
    
    /// scrollViewDidEndDecelerating
    /// - Parameter scrollView: UIScrollView
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hideControlsAfterDelay()
        // didScrollToIndex
        delegate?.browser?(self, didScrollToIndex: Int(pagingScrollView.contentOffset.x / pagingScrollView.frame.size.width))
    }
    
    /// scrollViewDidEndScrollingAnimation
    /// - Parameter scrollView: UIScrollView
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isEndAnimationByToolBar = true
    }
}
