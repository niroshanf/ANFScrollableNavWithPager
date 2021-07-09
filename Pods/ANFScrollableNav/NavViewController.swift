//
//  NavViewController.swift
//  ANFScrollableNav
//
//  Created by Anthony Niroshan Fernandez on 18/12/2019.
//  Copyright © 2019 Anthony Niroshan Fernandez. All rights reserved.
//

import UIKit

protocol NavViewControllerDelegate: AnyObject {
    func menuItemClicked(selectedIndex: Int)
    func selectedMenu(menuItem: String) -> NSAttributedString
    func unselectedMenu(menuItem: String) -> NSAttributedString
    
    //UI
    func contentInsets() -> UIEdgeInsets
    func interItemSpacing() -> CGFloat
    func indicatorView(selectedIndex: Int) -> UIView
    func indicatorHeight() -> CGFloat
    func menuHeight() -> CGFloat
}

class NavViewController: UIViewController {

    internal var navScroll: NavScrollView!
    private var items: [String] = [String]()
    private var contentOrientation: UISemanticContentAttribute!
    
    private weak var NavViewDelegate: NavViewControllerDelegate!
    
    public init(items: [String], delegate: NavViewControllerDelegate, container: UIView, orientation: UISemanticContentAttribute, standaloneNavigation: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        self.items = items
        self.contentOrientation = orientation
        self.NavViewDelegate = delegate
        
        self.navScroll = NavScrollView(items: items, orientation: orientation, delegate: self, standaloneNavigation: standaloneNavigation)
        self.navScroll.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.navScroll)

        self.navScroll.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        self.navScroll.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        self.navScroll.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        self.navScroll.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.navScroll.btnContainer.layoutIfNeeded()

        for btn in self.navScroll.btnContainer.subviews {

            if self.navScroll.currentMenuTag == btn.tag {
                
                //Keep the menu item center if the menu item was previously in the center on orientation changed
                let indicatorMaxOriginX: CGFloat = self.navScroll.frame.width / 2 - btn.frame.width / 2
                var offsetX: CGFloat = btn.frame.minX - indicatorMaxOriginX
                
                if self.navScroll.contentSize.width <= self.navScroll.frame.width {
                    offsetX = 0
                }
                else {
                    
                    if offsetX < 0 {
                        offsetX = 0
                    }
                    
                    if offsetX > self.navScroll.contentSize.width - self.navScroll.frame.width {
                        offsetX = self.navScroll.contentSize.width - self.navScroll.frame.width
                    }
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.navScroll.contentOffset = CGPoint(x: offsetX, y: 0)
                }

                //Keep the indicater in the saqme place when orientation changed
                self.navScroll.indicatorViewWidthConst.constant = btn.frame.width
                self.navScroll.indicatorViewLeftConst.constant = btn.frame.origin.x
                
                return
            }
        }
    }
    
    internal func getMenuItemFrame(atIndex: Int) -> CGRect {
        if let menuItem = self.navScroll.btnContainer.viewWithTag(atIndex) {
            return menuItem.frame
        }
        
        return CGRect.zero
    }
    
    internal func changeMenuColor(selected: UIColor, unselected: UIColor) {
        self.navScroll.changeMenuColor(selected: selected, unselected: unselected)
    }
}

extension NavViewController: NavScrollViewDelegate {
    
    func layoutSubviewsDone(contentSize: CGSize) {
        
//        if self.contentOrientation == .forceRightToLeft {
//            let lastFrame = contentSize.width - self.view.frame.width
//            self.navScroll.setContentOffset(CGPoint(x: lastFrame, y: 0.0), animated: false)
//        }
    }
    
    func menuItemClicked(selectedIndex: Int) {
        self.NavViewDelegate.menuItemClicked(selectedIndex: selectedIndex)
    }
    
    func selectedMenu(menuItem: String) -> NSAttributedString {
        self.NavViewDelegate.selectedMenu(menuItem: menuItem)
    }
    
    func unselectedMenu(menuItem: String) -> NSAttributedString {
        self.NavViewDelegate.unselectedMenu(menuItem: menuItem)
    }
    
    func contentInsets() -> UIEdgeInsets {
        self.NavViewDelegate.contentInsets()
    }
    
    func interItemSpacing() -> CGFloat {
        self.NavViewDelegate.interItemSpacing()
    }
    
    func indicatorView(selectedIndex: Int) -> UIView {
        self.NavViewDelegate.indicatorView(selectedIndex: selectedIndex)
    }
    
    func indicatorHeight() -> CGFloat {
        self.NavViewDelegate.indicatorHeight()
    }
    
    func menuHeight() -> CGFloat {
        self.NavViewDelegate.menuHeight()
    }
}
