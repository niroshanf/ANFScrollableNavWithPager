//
//  ViewController.swift
//  ANFScrollableNavWithPager
//
//  Created by Anthony Niroshan Fernandez on 08/07/2021.
//

import UIKit
import ANFScrollableNav
import ANFPager

class ViewController: UIViewController {
    
    @IBOutlet weak var topNavigationContainer: UIView!
    @IBOutlet weak var detailContainer: UIView!
    
    var pager: PagerManager!
    var navigation: NavigationManager!

    var colors = [UIColor.red, UIColor.green, UIColor.yellow, UIColor.orange, UIColor.gray, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.darkGray, UIColor.magenta, UIColor.purple]
    
    
    let menuItems = ["Home", "World", "Politics", "Business", "Sports", "Variety", "Programs", "Entertainment", "Style", "Videos"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation = NavigationManager(name: "Nav", items: self.menuItems, delegate: self, UIDelegate: self, container: self.topNavigationContainer, orientation: .forceLeftToRight, standaloneNavigation: false)
        self.navigation.addNavigation(positionOnContainer: .Bottom, constant: -10.0)
        
        self.pager = PagerManager(container: self.detailContainer, pages: self.menuItems.count, delegate: self)
        self.pager.createPageViewController(orientation: .forceLeftToRight, transitionType: .scroll)
        
        let currentViewController = getCurrentViewController()
        if let sectionHomeViewController = currentViewController as? SectionHomeViewController {
            sectionHomeViewController.view.backgroundColor = self.colors[0]
        }
    }
    
    func getCurrentViewController() -> UIViewController? {

        let visibleViewController = self.pager.getCurrentPage()
        return visibleViewController

    }
}

extension ViewController: NavigationManagerDelegate {
    
    func menuItemClicked(selectedIndex: Int, manager: NavigationManager) {
        
        self.pager.moveToPage(index: selectedIndex)

    }
}



extension ViewController: NavigationManagerUIDelegate {
    
    func selectedMenu(menuItem: String, manager: NavigationManager) -> NSAttributedString {
    
        let color: UIColor = UIColor(named: "SelectedMenu")!
        let font = UIFont.boldSystemFont(ofSize: 16)
        return NSMutableAttributedString(string: menuItem, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color])
    }
    
    func unselectedMenu(menuItem: String, manager: NavigationManager) -> NSAttributedString {
        let color: UIColor = UIColor(named: "UnselectedMenu")!
        let font = UIFont.boldSystemFont(ofSize: 16)
        return NSMutableAttributedString(string: menuItem, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color])
    }
    
    func interItemSpacing() -> CGFloat {
        return 24.0
    }
    
    func contentInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 24, bottom: 5, right: 24)
    }
    
    func indicatorView(selectedIndex: Int) -> UIView {
        let v = MenuIndicatorRoundedEdge()
        v.backgroundColor = UIColor.clear
        v.indicatorColor = colors[selectedIndex]

        return v
    }
    
    func indicatorHeight() -> CGFloat {
        return 4.0
    }
    
    func menuHeight() -> CGFloat {
        return 50.0
    }
}

extension ViewController: PagerManagerDelegate {
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        let vc = storyBoard.instantiateViewController(withIdentifier: "SectionHome") as! SectionHomeViewController
        return vc
    }
    
    func willTransitionToIndex(index: Int) {}
    
    func didTransitionToIndex(index: Int) {
        
        self.navigation.setSelectedMenuIndex(forPage: index)
        
        //Change the indicator color
        if let indicator = self.navigation.getIndicatorView() as? MenuIndicatorRoundedEdge {
            indicator.setIndicatorColor(color: self.colors[index])
        }
        
        let currentViewController = getCurrentViewController()
        if let sectionHomeViewController = currentViewController as? SectionHomeViewController {
            sectionHomeViewController.view.backgroundColor = self.colors[index]
        }
    }
    
    func pageviewDidScroll(offset: CGPoint, direction: PageDirection) {

        let scrollViewWidth: CGFloat = self.detailContainer.frame.width
        self.navigation.adjustIndicator(offset: offset, pagerWidth: scrollViewWidth, direction: direction == .forward ? .forward : .backward)
    }
    
    func pageviewWillBeginDragging() {
        print("Will begin draging")
    }
    
    func pageviewDidEndDecelerating() {
        print("pageviewDidEndDecelerating")
    }
}

