# ANFScrollableNav

[![CI Status](https://img.shields.io/travis/anthony-fernandez/ANFScrollableNav.svg?style=flat)](https://travis-ci.org/anthony-fernandez/ANFScrollableNav)
[![Version](https://img.shields.io/cocoapods/v/ANFScrollableNav.svg?style=flat)](https://cocoapods.org/pods/ANFScrollableNav)
[![License](https://img.shields.io/cocoapods/l/ANFScrollableNav.svg?style=flat)](https://cocoapods.org/pods/ANFScrollableNav)
[![Platform](https://img.shields.io/cocoapods/p/ANFScrollableNav.svg?style=flat)](https://cocoapods.org/pods/ANFScrollableNav)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## How To Get Started

- [Download ANFScrollableNav](https://github.com/niroshanf/ANFScrollableNav/archive/refs/heads/main.zip) and try out the included example apps

## Usage

`NavigationManager` create the menu object. View controller should have a container view to hold the menu.

```objective-c
import ANFScrollableNav

var navigation: NavigationManager!
let menuItems = ["Home", "World", "Politics", "Business", "Sports", "Variety", "Programs", "Entertainment", "Style", "Videos"]

navigation = NavigationManager(name: "Nav", items: menuItems, delegate: self, UIDelegate: self, container: navContainer, orientation: .forceLeftToRight, standaloneNavigation: true)
navigation.addNavigation(positionOnContainer: .Bottom, constant: -10.0)
```

#### Parameters

`Name` - Unique name for the navigation. Useful if you have more than one menu objects in a same view controller
`items` - menu items
`delegate` - View controller responsible for handling all the menu events
`UIDelegate` - View controller responsible for handling all the menu UI
`container` - View that will embed the menu
`orientation` - LTR or RTL
`standaloneNavigation ` - ANFScrollableNav can work as a stand-alone menu or can be integrated with [ANFPager](https://github.com/niroshanf/ANFPager) Pod

#### Event Delegate

`NavigationManagerDelegate` will handle all the events

```objective-c
func menuItemClicked(selectedIndex: Int, manager: NavigationManager) {
        print("menu clicked = \(selectedIndex)")
}
```

#### UI Delegate

`NavigationManagerUIDelegate` will handle all the events

```objective-c

//Handle the design of the selected menu item
func selectedMenu(menuItem: String, manager: NavigationManager) -> NSAttributedString {}

//Handle the design of the unselected menu items
func unselectedMenu(menuItem: String, manager: NavigationManager) -> NSAttributedString {}

//Padding between each menu item
func interItemSpacing() -> CGFloat { }
    
//Padding of the menu to its container view
func contentInsets() -> UIEdgeInsets {}

/*
Can provide any custom view a the menu indicator. Refer to the example code for the implementation
*/
func indicatorView(selectedIndex: Int) -> UIView { }


func indicatorHeight() -> CGFloat {}

//Menu item height    
func menuHeight() -> CGFloat {}
```


## Installation

ANFScrollableNav is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ANFScrollableNav'
```

## Author

Anthony Niroshan De Croos Fernandez, niroshanf@gmail.com

## License

ANFScrollableNav is available under the MIT license. See the LICENSE file for more info.
