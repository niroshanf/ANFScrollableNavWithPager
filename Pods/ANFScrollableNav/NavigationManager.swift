//
//  NavigationManager.swift
//  ANFScrollableNav
//
//  Created by Anthony Niroshan Fernandez on 17/12/2019.
//  Copyright © 2019 Anthony Niroshan Fernandez. All rights reserved.
//

import Foundation
import UIKit

public enum IndicatorDirection {
    case forward
    case backward
    case undefined
}

public enum MenuPosition {
    case Top
    case Center
    case Bottom
}

public protocol NavigationManagerDelegate: AnyObject {
    func menuItemClicked(selectedIndex: Int, manager: NavigationManager)
}

public protocol NavigationManagerUIDelegate: AnyObject {
    
    func selectedMenu(menuItem: String, manager: NavigationManager) -> NSAttributedString
    func unselectedMenu(menuItem: String, manager: NavigationManager) -> NSAttributedString
    func contentInsets() -> UIEdgeInsets
    func interItemSpacing() -> CGFloat
    func indicatorView(selectedIndex: Int) -> UIView
    func indicatorHeight() -> CGFloat
    func menuHeight() -> CGFloat
}

public class NavigationManager: Equatable {
    
    private weak var container: UIView!
    
    private var navCtr: NavViewController!
    private var menuOrientation: UISemanticContentAttribute = .forceLeftToRight
    private var name: String!
    
    private weak var delegate: NavigationManagerDelegate!
    private weak var UIDelegate: NavigationManagerUIDelegate?
    
    

    public init(name: String, items: [String], delegate: NavigationManagerDelegate, UIDelegate: NavigationManagerUIDelegate? = nil, container: UIView, orientation: UISemanticContentAttribute, standaloneNavigation: Bool) {
        
        self.name = name
        self.delegate = delegate
        self.UIDelegate = UIDelegate
        self.menuOrientation = orientation
        self.container = container
        
        self.navCtr = NavViewController(items: items, delegate: self, container: container, orientation: orientation, standaloneNavigation: standaloneNavigation)
    }
    
    public static func ==(lhs: NavigationManager, rhs: NavigationManager) -> Bool {
        return lhs.name == rhs.name
    
    }
    
    public func addNavigation(positionOnContainer: MenuPosition, constant: CGFloat = 0.0) {

        self.container.addSubview(self.navCtr.view)
        
        self.navCtr.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.navCtr.view.leftAnchor.constraint(equalTo: self.container.leftAnchor, constant: 0.0).isActive = true
        self.navCtr.view.rightAnchor.constraint(equalTo: self.container.rightAnchor, constant: 0.0).isActive = true
        
        switch positionOnContainer {
            case .Center:
                self.navCtr.view.centerYAnchor.constraint(equalTo: self.container.centerYAnchor, constant: constant).isActive = true
            case .Bottom:
                self.navCtr.view.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: constant).isActive = true
            case .Top:
                self.navCtr.view.topAnchor.constraint(equalTo: self.container.topAnchor, constant: constant).isActive = true
        } 
    }
    
    public func menuWidth() -> CGFloat {
        self.navCtr.navScroll.btnContainer.frame.width
    }
    
    public func getMenuItemFrame(atIndex: Int) -> CGRect {
        self.navCtr.getMenuItemFrame(atIndex: atIndex)
    }
    
    public func adjustIndicator(offset: CGPoint, pagerWidth: CGFloat, direction: IndicatorDirection) {
        self.navCtr.navScroll.adjustIndicator(offset: offset, pagerWidth: pagerWidth, direction: direction)
    }
    
    public func setSelectedMenuIndex(forPage index: Int) {
        self.navCtr.navScroll.currentMenuTag = index + 1
        self.navCtr.navScroll.clickedMenuTag = index + 1
        self.navCtr.navScroll.highlightSelectedMenu()
    }
    
    public func getIndicatorView() -> UIView {
        self.navCtr.navScroll.getIndicatorView()
    }
    
    public func moveToMenu(index: Int) {
        self.navCtr.navScroll.moveToIndex(index: index)
    }
    
    public func changeMenuColor(selected: UIColor, unselected: UIColor) {
        self.navCtr.changeMenuColor(selected: selected, unselected: unselected)
    }
}

extension NavigationManager: NavViewControllerDelegate {
    
    func menuItemClicked(selectedIndex: Int) {
        self.delegate?.menuItemClicked(selectedIndex: selectedIndex, manager: self)
    }
    
    func selectedMenu(menuItem: String) ->  NSAttributedString {
        self.UIDelegate?.selectedMenu(menuItem: menuItem, manager: self) ?? NSAttributedString(string: menuItem)
    }
    
    func unselectedMenu(menuItem: String) ->  NSAttributedString {
        self.UIDelegate?.unselectedMenu(menuItem: menuItem, manager: self) ?? NSAttributedString(string: menuItem)
    }
    
    func contentInsets() -> UIEdgeInsets {
        self.UIDelegate?.contentInsets() ?? UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func interItemSpacing() -> CGFloat {
        self.UIDelegate?.interItemSpacing() ?? CGFloat(0.0)
    }
    
    func indicatorView(selectedIndex: Int) -> UIView {
        self.UIDelegate?.indicatorView(selectedIndex: selectedIndex) ?? UIView()
    }
    
    func indicatorHeight() -> CGFloat {
        self.UIDelegate?.indicatorHeight() ?? 2.0
    }
    
    func menuHeight() -> CGFloat {
        self.UIDelegate?.menuHeight() ?? 24.0
    }
}
