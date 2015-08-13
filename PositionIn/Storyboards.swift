//
// Autogenerated by Natalie - Storyboard Generator Script.
// http://blog.krzyzanowskim.com
//

import UIKit

//MARK: - Storyboards
struct Storyboards {

    struct Main {

        static let identifier = "Main"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> SidebarViewController! {
            return self.storyboard.instantiateInitialViewController() as! SidebarViewController
        }

        static func instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewControllerWithIdentifier(identifier) as! UIViewController
        }

        static func instantiateMainMenuViewController() -> MainMenuViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("MainMenuViewController") as! MainMenuViewController
        }

        static func instantiateCommunityListViewController() -> CommunityListViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("CommunityListViewController") as! CommunityListViewController
        }

        static func instantiateSearchViewController() -> SearchViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        }

        static func instantiateBrowseMapViewController() -> BrowseMapViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("BrowseMapViewController") as! BrowseMapViewController
        }

        static func instantiateBrowseListViewController() -> BrowseListViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("BrowseListViewController") as! BrowseListViewController
        }

        static func instantiateMapViewController() -> BrowseViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("MapViewController") as! BrowseViewController
        }
    }

    struct Login {

        static let identifier = "Login"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> LoginViewController! {
            return self.storyboard.instantiateInitialViewController() as! LoginViewController
        }

        static func instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewControllerWithIdentifier(identifier) as! UIViewController
        }

        static func instantiateLoginViewController() -> LoginViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        }

        static func instantiateRegisterViewController() -> RegisterViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
        }

        static func instantiateRecoverPasswordViewController() -> RecoverPasswordViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("RecoverPasswordViewController") as! RecoverPasswordViewController
        }
    }

    struct NewItems {

        static let identifier = "NewItems"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewControllerWithIdentifier(identifier) as! UIViewController
        }

        static func instantiateAddProductViewController() -> AddProductViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("AddProductViewController") as! AddProductViewController
        }

        static func instantiateAddPostViewController() -> AddPostViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("AddPostViewController") as! AddPostViewController
        }

        static func instantiateAddCommunityViewController() -> AddCommunityViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("AddCommunityViewController") as! AddCommunityViewController
        }

        static func instantiateAddPromotionViewController() -> AddPromotionViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("AddPromotionViewController") as! AddPromotionViewController
        }

        static func instantiateAddEventViewController() -> AddEventViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("AddEventViewController") as! AddEventViewController
        }
    }
}

//MARK: - ReusableKind
enum ReusableKind: String, Printable {
    case TableViewCell = "tableViewCell"
    case CollectionViewCell = "collectionViewCell"

    var description: String { return self.rawValue }
}

//MARK: - SegueKind
enum SegueKind: String, Printable {    
    case Relationship = "relationship" 
    case Show = "show"                 
    case Presentation = "presentation" 
    case Embed = "embed"               
    case Unwind = "unwind"             

    var description: String { return self.rawValue } 
}

//MARK: - SegueProtocol
public protocol IdentifiableProtocol: Equatable {
    var identifier: String? { get }
}

public protocol SegueProtocol: IdentifiableProtocol {
}

public func ==<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {
   return lhs.identifier == rhs.identifier
}

public func ~=<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {
   return lhs.identifier == rhs.identifier
}

public func ==<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {
   return lhs.identifier == rhs
}

public func ~=<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {
   return lhs.identifier == rhs
}

//MARK: - ReusableViewProtocol
public protocol ReusableViewProtocol: IdentifiableProtocol {
    var viewType: UIView.Type? {get}
}

public func ==<T: ReusableViewProtocol, U: ReusableViewProtocol>(lhs: T, rhs: U) -> Bool {
   return lhs.identifier == rhs.identifier
}

//MARK: - Protocol Implementation
extension UIStoryboardSegue: SegueProtocol {
}

extension UICollectionReusableView: ReusableViewProtocol {
    public var viewType: UIView.Type? { return self.dynamicType}
    public var identifier: String? { return self.reuseIdentifier}
}

extension UITableViewCell: ReusableViewProtocol {
    public var viewType: UIView.Type? { return self.dynamicType}
    public var identifier: String? { return self.reuseIdentifier}
}

//MARK: - UIViewController extension
extension UIViewController {
    func performSegue<T: SegueProtocol>(segue: T, sender: AnyObject?) {
       performSegueWithIdentifier(segue.identifier, sender: sender)
    }

    func performSegue<T: SegueProtocol>(segue: T) {
       performSegue(segue, sender: nil)
    }
}

//MARK: - UICollectionView

extension UICollectionView {

    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UICollectionViewCell? {
        if let identifier = reusable.identifier {
            return dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: forIndexPath) as? UICollectionViewCell
        }
        return nil
    }

    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {
        if let type = reusable.viewType, identifier = reusable.identifier {
            registerClass(type, forCellWithReuseIdentifier: identifier)
        }
    }

    func dequeueReusableSupplementaryViewOfKind<T: ReusableViewProtocol>(elementKind: String, withReusable reusable: T, forIndexPath: NSIndexPath!) -> UICollectionReusableView? {
        if let identifier = reusable.identifier {
            return dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: identifier, forIndexPath: forIndexPath) as? UICollectionReusableView
        }
        return nil
    }

    func registerReusable<T: ReusableViewProtocol>(reusable: T, forSupplementaryViewOfKind elementKind: String) {
        if let type = reusable.viewType, identifier = reusable.identifier {
            registerClass(type, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
        }
    }
}
//MARK: - UITableView

extension UITableView {

    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UITableViewCell? {
        if let identifier = reusable.identifier {
            return dequeueReusableCellWithIdentifier(identifier, forIndexPath: forIndexPath) as? UITableViewCell
        }
        return nil
    }

    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {
        if let type = reusable.viewType, identifier = reusable.identifier {
            registerClass(type, forCellReuseIdentifier: identifier)
        }
    }

    func dequeueReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) -> UITableViewHeaderFooterView? {
        if let identifier = reusable.identifier {
            return dequeueReusableHeaderFooterViewWithIdentifier(identifier) as? UITableViewHeaderFooterView
        }
        return nil
    }

    func registerReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) {
        if let type = reusable.viewType, identifier = reusable.identifier {
             registerClass(type, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
}


//MARK: - MainMenuViewController

//MARK: - SidebarViewController
extension UIStoryboardSegue {
    func selection() -> SidebarViewController.Segue? {
        if let identifier = self.identifier {
            return SidebarViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension SidebarViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case DrawerSegue = "DrawerSegue"
        case ShowBrowse = "ShowBrowse"
        case ShowMessagesList = "ShowMessagesList"
        case ShowFilters = "ShowFilters"
        case ShowCommunities = "ShowCommunities"

        var kind: SegueKind? {
            switch (self) {
            case DrawerSegue:
                return SegueKind(rawValue: "custom")
            case ShowBrowse:
                return SegueKind(rawValue: "custom")
            case ShowMessagesList:
                return SegueKind(rawValue: "custom")
            case ShowFilters:
                return SegueKind(rawValue: "presentation")
            case ShowCommunities:
                return SegueKind(rawValue: "custom")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case DrawerSegue:
                return MainMenuViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - MessagesListViewController

//MARK: - FilterViewController

//MARK: - CommunityListViewController

//MARK: - SearchViewController

//MARK: - BrowseMapViewController

//MARK: - BrowseListViewController

//MARK: - ProductDetailsViewController
extension UIStoryboardSegue {
    func selection() -> ProductDetailsViewController.Segue? {
        if let identifier = self.identifier {
            return ProductDetailsViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension ProductDetailsViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case ShowProductInventory = "ShowProductInventory"
        case ShowSellerProfile = "ShowSellerProfile"
        case ShowBuyScreen = "ShowBuyScreen"

        var kind: SegueKind? {
            switch (self) {
            case ShowProductInventory:
                return SegueKind(rawValue: "show")
            case ShowSellerProfile:
                return SegueKind(rawValue: "show")
            case ShowBuyScreen:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case ShowProductInventory:
                return ProductInventoryViewController.self
            case ShowSellerProfile:
                return SellerProfileViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - ProductInventoryViewController
extension UIStoryboardSegue {
    func selection() -> ProductInventoryViewController.Segue? {
        if let identifier = self.identifier {
            return ProductInventoryViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension ProductInventoryViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case ShowProductDetails = "ShowProductDetails"

        var kind: SegueKind? {
            switch (self) {
            case ShowProductDetails:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case ShowProductDetails:
                return ProductDetailsViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - SellerProfileViewController

//MARK: - BrowseViewController
extension UIStoryboardSegue {
    func selection() -> BrowseViewController.Segue? {
        if let identifier = self.identifier {
            return BrowseViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension BrowseViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case ShowProductDetails = "ShowProductDetails"

        var kind: SegueKind? {
            switch (self) {
            case ShowProductDetails:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case ShowProductDetails:
                return ProductDetailsViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - LoginViewController
extension UIStoryboardSegue {
    func selection() -> LoginViewController.Segue? {
        if let identifier = self.identifier {
            return LoginViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension LoginViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case ShowRegister = "ShowRegister"
        case ShowRecoverPassword = "ShowRecoverPassword"

        var kind: SegueKind? {
            switch (self) {
            case ShowRegister:
                return SegueKind(rawValue: "show")
            case ShowRecoverPassword:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case ShowRegister:
                return RegisterViewController.self
            case ShowRecoverPassword:
                return RecoverPasswordViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - RegisterViewController

//MARK: - RecoverPasswordViewController

//MARK: - AddProductViewController

//MARK: - AddPostViewController

//MARK: - AddCommunityViewController

//MARK: - AddPromotionViewController

//MARK: - AddEventViewController
