//
//  NavScrollView.swift
//  ANFScrollableNav
//
//  Created by Anthony Niroshan Fernandez on 17/12/2019.
//  Copyright © 2019 Anthony Niroshan Fernandez. All rights reserved.
//

import UIKit

protocol NavScrollViewDelegate: AnyObject {
    func layoutSubviewsDone(contentSize: CGSize)
    func menuItemClicked(selectedIndex: Int)
    
    
    //UI
    func selectedMenu(menuItem: String) -> NSAttributedString
    func unselectedMenu(menuItem: String) -> NSAttributedString
    func contentInsets() -> UIEdgeInsets
    func interItemSpacing() -> CGFloat
    func indicatorView(selectedIndex: Int) -> UIView
    func indicatorHeight() -> CGFloat
    func menuHeight() -> CGFloat
}

class NavScrollView: UIScrollView {
    
    internal var indicatorViewLeftConst: NSLayoutConstraint!
    internal var indicatorViewWidthConst: NSLayoutConstraint!
    private var contentOrientation: UISemanticContentAttribute!
    
    internal var btnContainer: UIView!
    
    internal var currentMenuTag: Int = 1
    internal var clickedMenuTag: Int = 1
    
    private weak var navDelegate: NavScrollViewDelegate!
    
    internal var finalContentSize: CGSize?
    
    internal var itemCount: Int = 0
    
    internal var menuItems: [String]!
    
    private var indicatorView: UIView!
    private var indicatorContainer: UIView!
    
    private var standaloneNavigation: Bool!

    init(items: [String], orientation: UISemanticContentAttribute, delegate: NavScrollViewDelegate, standaloneNavigation: Bool) {
        super.init(frame: CGRect.zero)
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        self.contentOrientation = orientation
        self.itemCount = items.count
        self.navDelegate = delegate
        self.menuItems = items
        self.standaloneNavigation = standaloneNavigation
        
        if self.contentOrientation == .forceRightToLeft {
            self.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        let mainContainer: UIView = UIView()
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainContainer)
        
        mainContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        mainContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        mainContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        mainContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        mainContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        self.btnContainer = self.addButtonContainer()
        mainContainer.addSubview(self.btnContainer)
        
        self.btnContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 0).isActive = true
        self.btnContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 0).isActive = true
        self.btnContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: 0).isActive = true
        
        self.addIndicatorContainer()
        mainContainer.addSubview(self.indicatorContainer)
        
        indicatorContainer.topAnchor.constraint(equalTo: self.btnContainer.bottomAnchor, constant: 0).isActive = true
        indicatorContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 0).isActive = true
        indicatorContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: 0).isActive = true
        indicatorContainer.heightAnchor.constraint(equalToConstant: self.navDelegate.indicatorHeight()).isActive = true
        indicatorContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: 0).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.finalContentSize?.width != self.contentSize.width {
            
            self.finalContentSize = self.contentSize
            self.navDelegate?.layoutSubviewsDone(contentSize: self.contentSize)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func click(sender: UIButton) {

        self.clickedMenuTag = sender.tag
        self.highlightSelectedMenu()
        
        if self.standaloneNavigation {
            
            let selectedMenuItemFrame = self.getMenuItemFrame(atIndex: self.clickedMenuTag)
            
            //Move the main scrollview to display prv / next menu items
            let indicatorMaxOriginX: CGFloat = self.frame.width / 2 - selectedMenuItemFrame.width / 2
            var offsetX: CGFloat = selectedMenuItemFrame.minX - indicatorMaxOriginX
            
            if self.contentSize.width <= self.frame.width {
                offsetX = 0
            }
            else {
                
                if offsetX < 0 { offsetX = 0 }
                
                if offsetX > self.contentSize.width - self.frame.width {
                    offsetX = self.contentSize.width - self.frame.width
                }
            }
            
            self.moveIndicator(x: selectedMenuItemFrame.minX)
            self.setIndicatorWidth(width: selectedMenuItemFrame.width)
            self.currentMenuTag = sender.tag
        
            UIView.animate(withDuration: 0.3, animations: {
                
                self.contentOffset = CGPoint(x: offsetX, y: 0)
                self.layoutIfNeeded()
                
            }, completion: { complete in
                
                if complete {
                    self.navDelegate?.menuItemClicked(selectedIndex: sender.tag - 1)
                }
            })
        }
        else {
            self.navDelegate?.menuItemClicked(selectedIndex: sender.tag - 1)
        }
    }

    func moveToIndex(index: Int) {

        self.clickedMenuTag = index + 1
        self.highlightSelectedMenu()
    }
    
    internal func highlightSelectedMenu() {
        
        for obj in self.btnContainer.subviews {
            if let btn = obj as? UIButton {
                
                if btn.tag == self.clickedMenuTag {
                    let menuTxt = self.navDelegate.selectedMenu(menuItem: self.menuItems[btn.tag - 1])
                    btn.setAttributedTitle(menuTxt, for: .normal)
                }
                else {
                    let menuTxt = self.navDelegate.unselectedMenu(menuItem: self.menuItems[btn.tag - 1])
                    btn.setAttributedTitle(menuTxt, for: .normal)
                }
            }
        }
    }
    
    internal func moveIndicator(x: CGFloat) {
        self.indicatorViewLeftConst.constant = x
    }
    
    internal func setIndicatorWidth(width: CGFloat) {
        self.indicatorViewWidthConst.constant = width
    }
    
    internal func addButtonContainer() -> UIView {
        
        let btnContainer = UIView()
        btnContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingPadding: CGFloat = self.navDelegate.contentInsets().left
        let trailingPadding: CGFloat = self.navDelegate.contentInsets().right
        let bottomPadding: CGFloat = self.navDelegate.contentInsets().bottom
        let topPadding: CGFloat = 0
        let interItemPadding: CGFloat = self.navDelegate.interItemSpacing()
        
        var prvMenuBtn: UIButton?
        for (i, txt) in self.menuItems.enumerated() {
            
            let menuBtn: UIButton = UIButton()
            menuBtn.backgroundColor = UIColor.clear
            menuBtn.tag = i + 1
            menuBtn.translatesAutoresizingMaskIntoConstraints = false
            
            if self.contentOrientation == .forceRightToLeft {
                menuBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
            let menuTxt = self.clickedMenuTag == (i+1) ? self.navDelegate.selectedMenu(menuItem: txt):  self.navDelegate.unselectedMenu(menuItem: txt)
            
            menuBtn.setAttributedTitle(menuTxt, for: .normal)
            menuBtn.addTarget(self, action: #selector(click(sender:)), for: .touchUpInside)
            btnContainer.addSubview(menuBtn)

            if i == 0 {
                menuBtn.leadingAnchor.constraint(equalTo: btnContainer.leadingAnchor, constant: leadingPadding).isActive = true
            }
            
            if let prvBtn = prvMenuBtn {
                menuBtn.leadingAnchor.constraint(equalTo: prvBtn.trailingAnchor, constant: interItemPadding).isActive = true
            }
            
            menuBtn.topAnchor.constraint(equalTo: btnContainer.topAnchor, constant: topPadding).isActive = true
            menuBtn.bottomAnchor.constraint(equalTo: btnContainer.bottomAnchor, constant: -bottomPadding).isActive = true
            menuBtn.heightAnchor.constraint(equalToConstant: self.navDelegate.menuHeight()).isActive = true
            
            prvMenuBtn = menuBtn
        }
        
        if let prvBtn = prvMenuBtn {
            prvBtn.trailingAnchor.constraint(equalTo: btnContainer.trailingAnchor, constant: -trailingPadding).isActive = true
        }
        
        return btnContainer
    }
    
    internal func addIndicatorContainer() {
        
        self.indicatorContainer = UIView()
        self.indicatorContainer.semanticContentAttribute = self.contentOrientation
        self.indicatorContainer.backgroundColor = UIColor.clear
        self.indicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        
        self.indicatorView = self.navDelegate.indicatorView(selectedIndex: 0)
        self.indicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.indicatorContainer.addSubview(self.indicatorView)
        
        self.indicatorView.topAnchor.constraint(equalTo: self.indicatorContainer.topAnchor, constant: 0).isActive = true
        self.indicatorView.bottomAnchor.constraint(equalTo: self.indicatorContainer.bottomAnchor, constant: 0).isActive = true
        self.indicatorViewLeftConst = self.indicatorView.leftAnchor.constraint(equalTo: self.indicatorContainer.leftAnchor, constant: 0)
        self.indicatorViewLeftConst.isActive = true
        self.indicatorViewWidthConst = self.indicatorView.widthAnchor.constraint(equalToConstant: 2.0)
        self.indicatorViewWidthConst.isActive = true
    }
    
    internal func getIndicatorView() -> UIView {
        return self.indicatorView
    }
    
    internal func getMenuItemFrame(atIndex: Int) -> CGRect {
        if let menuItem = self.btnContainer.viewWithTag(atIndex) {
            return menuItem.frame
        }
        
        return CGRect.zero
    }
    
    internal func adjustIndicator(offset: CGPoint, pagerWidth: CGFloat, direction: IndicatorDirection) {

        let newX: CGFloat = offset.x - pagerWidth
        var minX: CGFloat = 0.0
        var widthDiff: CGFloat = 0.0
        var newWidth: CGFloat = 0.0
        
        let currentSelectedSegmentWidth: CGFloat = self.getMenuItemFrame(atIndex: self.currentMenuTag).width
        let currentSelectedOriginX: CGFloat = self.getMenuItemFrame(atIndex: self.currentMenuTag).origin.x
        var selectedMenuItemFrame: CGRect = CGRect.zero
        
        if direction == .backward {
            
            if self.currentMenuTag == 1 {
                return
            }
                    
            //Move the menu indicator according to the page
            selectedMenuItemFrame = self.currentMenuTag == self.clickedMenuTag ?  self.getMenuItemFrame(atIndex: self.currentMenuTag - 1) : self.getMenuItemFrame(atIndex: self.clickedMenuTag)
            
            if self.contentOrientation == .forceLeftToRight {
                
                //Set the new indicator position
                let diff = self.currentMenuTag == self.clickedMenuTag ? (selectedMenuItemFrame.width + self.navDelegate.interItemSpacing()) : currentSelectedOriginX - selectedMenuItemFrame.origin.x
                minX = currentSelectedOriginX + newX / pagerWidth * diff
                
                //Get the width difference to calculate the new width of the indicator
                widthDiff =  currentSelectedSegmentWidth - selectedMenuItemFrame.width
            }
            else {
                
                //Set the new indicator position
                let diff =  selectedMenuItemFrame.origin.x - currentSelectedOriginX
                minX = currentSelectedOriginX + newX / pagerWidth * diff
                
                //Get the width difference to calculate the new width of the indicator
                widthDiff =  selectedMenuItemFrame.width - currentSelectedSegmentWidth
            }
            
            //fix the indicator width according to the next menu item
            newWidth = currentSelectedSegmentWidth + newX / pagerWidth * widthDiff
        }
        else {
            
            if self.currentMenuTag == self.itemCount {
                return
            }
            
            //Move the menu indicator according to the page
            selectedMenuItemFrame = self.currentMenuTag == self.clickedMenuTag ? self.getMenuItemFrame(atIndex: self.clickedMenuTag + 1) : self.getMenuItemFrame(atIndex: self.clickedMenuTag)
            
            if self.contentOrientation == .forceLeftToRight {
                
                //Set the new indicator position
                let diff = self.currentMenuTag == self.clickedMenuTag ? (self.navDelegate.interItemSpacing() + currentSelectedSegmentWidth) : selectedMenuItemFrame.origin.x - currentSelectedOriginX
                minX = currentSelectedOriginX + newX / pagerWidth * diff
                
                //Get the width difference to calculate the new width of the indicator
                widthDiff = selectedMenuItemFrame.width - currentSelectedSegmentWidth

            }
            else {
                
                //Set the new indicator position
                let diff = currentSelectedOriginX - selectedMenuItemFrame.origin.x
                minX = currentSelectedOriginX + newX / pagerWidth * diff
                
                //Get the width difference to calculate the new width of the indicator
                widthDiff = currentSelectedSegmentWidth - selectedMenuItemFrame.width
            }
            
            //fix the indicator width according to the next menu item
            newWidth = currentSelectedSegmentWidth + newX / pagerWidth * widthDiff
        }
        
        //Move the main scrollview to display prv / next menu items
        let indicatorMaxOriginX: CGFloat = self.frame.width / 2 - selectedMenuItemFrame.width / 2
        var offsetX: CGFloat = selectedMenuItemFrame.minX - indicatorMaxOriginX
        
        if self.contentSize.width <= self.frame.width {
            offsetX = 0
        }
        else {
            
            if offsetX < 0 {
                offsetX = 0
            }
            
            if offsetX > self.contentSize.width - self.frame.width {
                offsetX = self.contentSize.width - self.frame.width
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.contentOffset = CGPoint(x: offsetX, y: 0)
        }
        
        self.moveIndicator(x: minX)
        self.setIndicatorWidth(width: newWidth)
    }
    
    internal func changeMenuColor(selected: UIColor, unselected: UIColor) {
    
        for menu in self.btnContainer.subviews {
            if let btn = menu as? UIButton {
                
                if let btnTitle = btn.attributedTitle(for: .normal) {
                    
                    let tag = btn.tag
                    let mutableTitle = NSMutableAttributedString(attributedString: btnTitle)
                    
                    if self.currentMenuTag == tag {
                        mutableTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: selected, range: NSRange(location: 0, length: mutableTitle.length))
                    }
                    else {
                        mutableTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: unselected, range: NSRange(location: 0, length: mutableTitle.length))
                    }
                    
                    btn.setAttributedTitle(mutableTitle, for: .normal)
                }
            }
        }
    }
}
