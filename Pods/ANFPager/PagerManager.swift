//
//  PagerManager.swift
//  ANFPager
//
//  Created by Anthony Niroshan Fernandez on 11/01/2020.
//

import Foundation
import UIKit

public enum transition {
    case scroll
    case pageCurl
    case stack
}

public protocol PagerManagerDelegate {
    func viewControllerAtIndex(index: Int) -> UIViewController?
    func willTransitionToIndex(index: Int)
    func didTransitionToIndex(index: Int)
    func pageviewDidScroll(offset: CGPoint, direction: PageDirection)
    func pageviewWillBeginDragging()
    func pageviewDidEndDecelerating()
}

public class PagerManager {
    
    private var container: UIView!
    private var pageViewController: DefaultUIPageViewController!
    private var containerViewController: UIViewController!
    private var noOfOPages: Int = 0
    
    public var pagerDelegate: PagerManagerDelegate!

    public init<T: UIViewController & PagerManagerDelegate>(container: UIView, pages: Int, delegate: T) {
        self.container = container
        self.containerViewController = delegate
        self.pagerDelegate = delegate
        self.noOfOPages = pages
    }
    
    public func createPageViewController(orientation: UISemanticContentAttribute, transitionType: transition) {
        
        switch transitionType {
            
            case .scroll, .pageCurl:
                
                guard let firstVC = self.pagerDelegate.viewControllerAtIndex(index: 0) else {
                    fatalError("viewControllerAtIndex didn't return a valid UIViewController")
                }
                
                self.pageViewController = DefaultUIPageViewController(firstViewController: firstVC, pages: self.noOfOPages, orientation: orientation)
                self.pageViewController.paginDelegate = self

                self.pageViewController.willMove(toParent: self.containerViewController)
                self.containerViewController.addChild(self.pageViewController)
                self.container.addSubview(self.pageViewController.view)
                
                self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
                
                self.pageViewController.view.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 0.0).isActive = true
                self.pageViewController.view.leftAnchor.constraint(equalTo: self.container.leftAnchor, constant: 0.0).isActive = true
                self.pageViewController.view.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: 0.0).isActive = true
                self.pageViewController.view.rightAnchor.constraint(equalTo: self.container.rightAnchor, constant: 0.0).isActive = true

            case .stack:
                    ()
        }
    }
    
    public func moveToPage(index: Int) {
        self.pageViewController.moveToPage(index: index)
    }
    
    public func getCurrentPageIndex() -> Int {
        return self.pageViewController.getCurrentPageIndex()
    }
    
    public func getCurrentPage() -> UIViewController? {
        return self.pageViewController.getCurrentPage()
    }
    
    public func getAllPages() -> [UIViewController?]? {
        return self.pageViewController.getAllPages()
    }
}



extension PagerManager: DefaultUIPageViewControllerDelegate {
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        return self.pagerDelegate.viewControllerAtIndex(index: index)
    }
    
    func willTransitionToIndex(index: Int) {
        self.pagerDelegate.willTransitionToIndex(index: index)
    }
    
    func didTransitionToIndex(index: Int) {
        self.pagerDelegate.didTransitionToIndex(index: index)
    }
    
    func pageviewDidScroll(offset: CGPoint, direction: PageDirection) {
        self.pagerDelegate.pageviewDidScroll(offset: offset, direction: direction)
    }
    
    func pageviewWillBeginDragging() {
        self.pagerDelegate?.pageviewWillBeginDragging()
    }
    
    func pageviewDidEndDecelerating() {
        self.pagerDelegate?.pageviewDidEndDecelerating()
    }
}
