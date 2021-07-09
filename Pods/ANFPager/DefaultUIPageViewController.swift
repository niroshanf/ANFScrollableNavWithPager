//
//  DefaultUIPageViewController.swift
//  ANFPager
//
//  Created by Anthony Niroshan Fernandez on 11/01/2020.
//

import UIKit

public enum PageDirection {
    case forward
    case backward
    case undefined
}

protocol DefaultUIPageViewControllerDelegate {
    func viewControllerAtIndex(index: Int) -> UIViewController?
    func willTransitionToIndex(index: Int)
    func didTransitionToIndex(index: Int)
    func pageviewDidScroll(offset: CGPoint, direction: PageDirection)
    func pageviewWillBeginDragging()
    func pageviewDidEndDecelerating()
}

class DefaultUIPageViewController: UIViewController {

    private var pageViewController: UIPageViewController!
    private var pagesScrollView: UIScrollView!
    internal var pagerOrientation: UISemanticContentAttribute = .forceLeftToRight
    
    private var pages: [UIViewController?]?
    
    private var currentIndex: Int = 0
    private var transitionIndex: Int = 0
    private var noOfOPages: Int = 0
    
    internal var paginDelegate: DefaultUIPageViewControllerDelegate?

    
    init(firstViewController: UIViewController, pages: Int, orientation: UISemanticContentAttribute) {
        super.init(nibName: nil, bundle: nil)
        
        self.pageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.noOfOPages = pages
        self.pagerOrientation = orientation
        
        self.pages = [UIViewController?](repeating: nil, count: pages)
        
        self.pageViewController.view.semanticContentAttribute = orientation
        
        for subView in self.pageViewController.view.subviews {
            if subView is UIScrollView {
                self.pagesScrollView = subView as? UIScrollView
                self.pagesScrollView.delegate = self
                self.pagesScrollView.panGestureRecognizer.maximumNumberOfTouches = 1
            }
        }
        
        self.pageViewController.willMove(toParent: self)
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.pageViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        self.pageViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        self.pageViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
        self.pageViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        
        self.pages?[0] = firstViewController

        self.pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func moveToPage(index: Int) {
        
        guard let pagesArr = self.pages else {
            return
        }
        
        var animateDirection: UIPageViewController.NavigationDirection = .forward
        
        if self.pagerOrientation == .forceLeftToRight {
            animateDirection = self.currentIndex <= index ? .forward : .reverse
        }
        else {
            animateDirection = self.currentIndex >= index ? .forward : .reverse
        }
        
        var viewController: UIViewController?
        
        if let vc = pagesArr[index] {
            viewController = vc
        }
        else {
            if index < self.noOfOPages {
                if let vc = self.paginDelegate?.viewControllerAtIndex(index: index) {
                    self.pages![index] = vc
                    viewController = vc
                }
            }
        }
        
        if let vc = viewController {
            
            self.pageViewController.delegate?.pageViewController?(self.pageViewController, willTransitionTo: [vc])
            
            self.pageViewController.setViewControllers([vc], direction: animateDirection, animated: true, completion:{ completed in
                
                //Have to call didFinishAnimating method manually since setViewControllers wont call it
                if completed {
                    self.pageViewController.delegate?.pageViewController?(self.pageViewController, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed)
                }
            })
            self.currentIndex = index
        }
    }
    
    //Public methods
    public func getCurrentPageIndex() -> Int {
        return self.currentIndex
    }
    
    public func getCurrentPage() -> UIViewController? {
        
        guard let pagesArr = self.pages else {
            return nil
        }
        
        guard let vc = pagesArr[self.currentIndex] else {
            return nil
        }
        
        return vc
    }
    
    public func getAllPages() -> [UIViewController?]? {
        return self.pages
    }
    
}

extension DefaultUIPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let pagesArr = self.pages else {
            return nil
        }
        
        if let idx = pagesArr.firstIndex(of: viewController) {
            
            let nextIdx: Int = idx + 1
            
            guard nextIdx < pagesArr.count else {
                return nil
            }
            
            if let vc = pagesArr[nextIdx] {
                return vc
            }
            else {
                
                if nextIdx < self.noOfOPages {
                    if let vc = self.paginDelegate?.viewControllerAtIndex(index: nextIdx) {
                        self.pages![nextIdx] = vc
                        return vc
                    }
                }
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let pagesArr = self.pages else {
            return nil
        }
        
        if let idx = pagesArr.firstIndex(of: viewController) {
            
            let prvIdx: Int = idx - 1
            
            guard prvIdx >= 0 else {
                return nil
            }
            
            if idx > 0, let vc = pagesArr[prvIdx] {
                return vc
            }
            else {
                
                if prvIdx > 0 {
                    if let vc = self.paginDelegate?.viewControllerAtIndex(index: prvIdx) {
                        self.pages![prvIdx] = vc
                        return vc
                    }
                }
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let pagesArr = self.pages else {
            return
        }
        
        if let vc = pendingViewControllers.first, let idx = pagesArr.firstIndex(of: vc) {
            self.transitionIndex = idx
            self.paginDelegate?.willTransitionToIndex(index: self.transitionIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            self.currentIndex = self.transitionIndex
            self.paginDelegate?.didTransitionToIndex(index: self.currentIndex)
        }
    }
}

extension DefaultUIPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGPoint = scrollView.contentOffset
        
        var direction: PageDirection = .undefined
        
        if offset.x == scrollView.frame.width {
            return
        }
        
        if offset.x < scrollView.frame.width {
            direction =  self.pagerOrientation == .forceLeftToRight ? .backward : .forward
        }
        else {
            direction = self.pagerOrientation == .forceLeftToRight ? .forward : .backward
        }
        
        self.paginDelegate?.pageviewDidScroll(offset: offset, direction: direction)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.paginDelegate?.pageviewWillBeginDragging()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.paginDelegate?.pageviewDidEndDecelerating()
    }
}
