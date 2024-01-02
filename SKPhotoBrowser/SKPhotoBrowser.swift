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
    open var currentIndex: Int = 0
    /// Int
    open var initialIndex: Int = 0
    /// [SKPhotoProtocol]
    open var photos: [SKPhotoProtocol] {
        didSet { photos.enumerated().forEach { $0.element.index = $0.offset } }
    }
    /// Double
    open var autoHideControllsfadeOutDelay: Double = 4.0
    /// Bool
    open var shouldAutoHideControlls: Bool = true
    
    /// Optional<ActionKind>
    open var actionKind: Optional<ActionKind> {
        get { toolbar.actionKind }
        set { toolbar.actionKind = newValue }
    }
    
    /// Optional<UIBarButtonItem>
    open var leftBarButtonItem: Optional<UIBarButtonItem> { toolbar.leftBarButtonItem }
    /// Optional<UIBarButtonItem>
    open var rightBarButtonItem: Optional<UIBarButtonItem> { toolbar.rightBarButtonItem }
    /// Optional<[UIBarButtonItem]>
    open var barButtonItems: Optional<[UIBarButtonItem]> { toolbar.barButtonItems }
    /// Optional<UIActivityIndicatorView>
    open var loadingView: Optional<UIActivityIndicatorView> { toolbar.loadingView }
    
    /// SKPagingScrollView
    internal lazy var pagingScrollView: SKPagingScrollView = SKPagingScrollView(frame: self.view.frame, browser: self)
    
    // appearance
    fileprivate let bgColor: UIColor = SKPhotoBrowserOptions.backgroundColor
    // SKAnimator
    internal let animator: SKAnimator = .init()
    
    // SKActionView
    fileprivate(set) lazy var actionView: SKActionView = .init(frame: view.frame, browser: self)
    /// SKPaginationView
    fileprivate(set) lazy var paginationView: SKPaginationView = .init(frame: view.frame, browser: self)
    /// SKToolbar
    fileprivate(set) lazy var toolbar: SKToolbar = {
        let _toolbar: SKToolbar = .init(frame: self.frameForToolbarAtOrientation(), browser: self)
        _toolbar.delegate = self
        return _toolbar
    }()
    
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
    /// - Parameters:
    ///   - photos: [SKPhotoProtocol]
    ///   - initialIndex: Int
    public init(photos: [SKPhotoProtocol], initialIndex: Int = 0) {
        // setup index
        photos.enumerated().forEach { $0.element.index = $0.offset }
        self.photos = photos
        //self.photos.forEach { $0.checkCache() }
        self.currentIndex = min(initialIndex, photos.count - 1)
        self.initialIndex = self.currentIndex
        super.init(nibName: .none, bundle: .none)
        animator.senderOriginImage = photos[currentIndex].underlyingImage
        // animator.senderViewForAnimation = photos[currentPageIndex] as? UIView
        
        self.modalPresentationCapturesStatusBarAppearance = true
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        
        // add observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSKPhotoLoadingDidEndNotification(_:)),
                                               name: .init(SKPHOTO_LOADING_DID_END_NOTIFICATION), 
                                               object: nil)
        
    }
    
    /// 构建
    /// - Parameter coder: NSCoder
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    
    /// viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configurePagingScrollView()
        configureGestureControl()
        // add actionView
        view.addSubview(actionView)
        // add paginationView
        view.addSubview(paginationView)
        // add toolbar
        view.addSubview(toolbar)
        
        animator.willPresent(self)
    }
    
    /// viewWillAppear
    /// - Parameter animated: Bool
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        /// reloadData
        reloadData()
    }
    
    /// viewWillLayoutSubviews
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        isPerformingLayout = true
        // where did start
        delegate?.browser?(self, didShowPhotoAtIndex: currentIndex)
        // toolbar
        toolbar.frame = frameForToolbarAtOrientation()
        // action
        actionView.updateFrame(frame: view.frame)
        // paging
        switch SKCaptionOptions.captionLocation {
        case .basic:  paginationView.updateFrame(frame: view.frame)
        case .bottom: paginationView.frame = frameForPaginationAtOrientation()
        }
        pagingScrollView.updateFrame(view.bounds, currentPageIndex: currentIndex)
        
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
            guard let this = self, let page = this.pagingScrollView.pageDisplayingAtPhoto(photo), let photo = page.photo else { return }
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
        pagingScrollView.loadAdjacentPhotosIfNecessary(photo, currentPageIndex: currentIndex)
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
        pagingScrollView.updateContentOffset(currentIndex)
        pagingScrollView.tilePages()
        // didShowPhotoAtIndex
        delegate?.browser?(self, didShowPhotoAtIndex: currentIndex)
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
            self.delegate?.browser?(self, didDismissAtPageIndex: self.currentIndex)
        }
    }
    
    /// determineAndClose
    open func determineAndClose() {
        delegate?.browser?(self, willDismissAtPageIndex: currentIndex)
        animator.willDismiss(self)
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
    
}

// MARK: - Public Function For Browser Control

extension SKPhotoBrowser {
    
    /// initializePageIndex
    /// - Parameter index: Int
    public func initializePageIndex(_ index: Int) {
        let i = min(index, photos.count - 1)
        currentIndex = i
        
        if isViewLoaded {
            jumpToPageAtIndex(index)
            if !isViewActive {
                pagingScrollView.tilePages()
            }
            paginationView.update(currentIndex)
        }
        self.initialIndex = currentIndex
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
        jumpToPageAtIndex(currentIndex - 1)
    }
    
    /// gotoNextPage
    @objc public func gotoNextPage() {
        jumpToPageAtIndex(currentIndex + 1)
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
        return currentIndex
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
        let offset: CGFloat
        if #available(iOS 11.0, *) {
            offset = view.safeAreaInsets.bottom - 5.0
        } else {
            offset = 15.0
        }
        return view.bounds.divided(atDistance: 44.0, from: .maxYEdge).slice.offsetBy(dx: 0.0, dy: -offset)
    }
    
    /// frameForToolbarHideAtOrientation
    /// - Returns: CGRect
    internal func frameForToolbarHideAtOrientation() -> CGRect {
        let height: CGFloat = 44.0
        return view.bounds.divided(atDistance: height, from: .maxYEdge).slice.offsetBy(dx: 0.0, dy: height)
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
        guard let zoomingScrollView: SKZoomingScrollView = pagingScrollView.pageDisplayedAtIndex(currentIndex) else {
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
    
    /// deleteImage
    internal func deleteImage() {
        defer { reloadData() }
        if photos.count > 1 {
            pagingScrollView.deleteImage()
            photos.remove(at: currentIndex)
            if currentIndex != 0 {
                gotoPreviousPage()
            }
            paginationView.update(currentIndex)
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
        let previousCurrentPage = currentIndex
        let visibleBounds = pagingScrollView.bounds
        currentIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), photos.count - 1)
        
        if currentIndex != previousCurrentPage {
            delegate?.browser?(self, didShowPhotoAtIndex: currentIndex)
            paginationView.update(currentIndex)
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

// MARK: - SKToolbarDelegate
extension SKPhotoBrowser: SKToolbarDelegate {
    
    /// shareActionHandler
    /// - Parameters:
    ///   - toolbar: SKToolbar
    ///   - sender: UIBarButtonItem
    internal func toolbar(_ toolbar: SKToolbar, shareActionHandler sender: UIBarButtonItem) {
        delegate?.browser?(self, shareActionHandler: sender)
    }
    
    /// downloadActionHandler
    /// - Parameters:
    ///   - toolbar: SKToolbar
    ///   - sender: UIBarButtonItem
    internal func toolbar(_ toolbar: SKToolbar, downloadActionHandler sender: UIBarButtonItem) {
        delegate?.browser?(self, downloadActionHandler: sender)
    }
    
    
}
