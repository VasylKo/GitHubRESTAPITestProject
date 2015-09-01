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

        static func instantiateProductDetailsViewControllerId() -> ProductDetailsViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("ProductDetailsViewControllerId") as! ProductDetailsViewController
        }

        static func instantiateEventDetailsViewControllerId() -> EventDetailsViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("EventDetailsViewControllerId") as! EventDetailsViewController
        }

        static func instantiatePromotionDetailsViewControllerId() -> PromotionDetailsViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("PromotionDetailsViewControllerId") as! PromotionDetailsViewController
        }

        static func instantiateMapViewController() -> BrowseViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("MapViewController") as! BrowseViewController
        }

        static func instantiateUserProfileViewController() -> UserProfileViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        }

        static func instantiateEditProfileViewController() -> EditProfileViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
        }

        static func instantiateProfileListViewController() -> ProfileListViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("ProfileListViewController") as! ProfileListViewController
        }

        static func instantiateSettingsViewController() -> SettingsViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        }
    }

    struct Login {

        static let identifier = "Login"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UINavigationController! {
            return self.storyboard.instantiateInitialViewController() as! UINavigationController
        }

        static func instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewControllerWithIdentifier(identifier) as! UIViewController
        }

        static func instantiateLoginSignUpViewController() -> LoginSignupViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("LoginSignUpViewController") as! LoginSignupViewController
        }

        static func instantiateRegisterViewController() -> RegisterViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
        }

        static func instantiateRecoverPasswordViewController() -> RecoverPasswordViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("RecoverPasswordViewController") as! RecoverPasswordViewController
        }

        static func instantiateLoginViewController() -> LoginViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        }

        static func instantiateRegisterInfoViewController() -> RegisterInfoViewController! {
            return self.storyboard.instantiateViewControllerWithIdentifier("RegisterInfoViewController") as! RegisterInfoViewController
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
        case ShowSettings = "ShowSettings"
        case ShowMyProfile = "ShowMyProfile"

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
            case ShowSettings:
                return SegueKind(rawValue: "custom")
            case ShowMyProfile:
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

//MARK: - EventDetailsViewController

//MARK: - PromotionDetailsViewController

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
        case ShowEventDetails = "ShowEventDetails"

        var kind: SegueKind? {
            switch (self) {
            case ShowProductDetails:
                return SegueKind(rawValue: "show")
            case ShowEventDetails:
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
            case ShowEventDetails:
                return EventDetailsViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - UserProfileViewController

//MARK: - EditProfileViewController

//MARK: - ProfileListViewController

//MARK: - SettingsViewController

//MARK: - LoginSignupViewController
extension UIStoryboardSegue {
    func selection() -> LoginSignupViewController.Segue? {
        if let identifier = self.identifier {
            return LoginSignupViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension LoginSignupViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case LoginSegueId = "LoginSegueId"

        var kind: SegueKind? {
            switch (self) {
            case LoginSegueId:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case LoginSegueId:
                return LoginViewController.self
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
extension UIStoryboardSegue {
    func selection() -> RegisterViewController.Segue? {
        if let identifier = self.identifier {
            return RegisterViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension RegisterViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case SignUpSegue = "SignUpSegue"

        var kind: SegueKind? {
            switch (self) {
            case SignUpSegue:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case SignUpSegue:
                return RegisterInfoViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - RecoverPasswordViewController

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
        case ForgotPasswordSegueId = "ForgotPasswordSegueId"

        var kind: SegueKind? {
            switch (self) {
            case ForgotPasswordSegueId:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case ForgotPasswordSegueId:
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

//MARK: - RegisterInfoViewController

//MARK: - AddProductViewController
extension UIStoryboardSegue {
    func selection() -> AddProductViewController.Segue? {
        if let identifier = self.identifier {
            return AddProductViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension AddProductViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case Close = "Close"

        var kind: SegueKind? {
            switch (self) {
            case Close:
                return SegueKind(rawValue: "unwind")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - AddPostViewController
extension UIStoryboardSegue {
    func selection() -> AddPostViewController.Segue? {
        if let identifier = self.identifier {
            return AddPostViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension AddPostViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case Close = "Close"

        var kind: SegueKind? {
            switch (self) {
            case Close:
                return SegueKind(rawValue: "unwind")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - AddCommunityViewController
extension UIStoryboardSegue {
    func selection() -> AddCommunityViewController.Segue? {
        if let identifier = self.identifier {
            return AddCommunityViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension AddCommunityViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case Close = "Close"

        var kind: SegueKind? {
            switch (self) {
            case Close:
                return SegueKind(rawValue: "unwind")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - AddPromotionViewController
extension UIStoryboardSegue {
    func selection() -> AddPromotionViewController.Segue? {
        if let identifier = self.identifier {
            return AddPromotionViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension AddPromotionViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case Close = "Close"

        var kind: SegueKind? {
            switch (self) {
            case Close:
                return SegueKind(rawValue: "unwind")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}

//MARK: - AddEventViewController
extension UIStoryboardSegue {
    func selection() -> AddEventViewController.Segue? {
        if let identifier = self.identifier {
            return AddEventViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}

extension AddEventViewController { 

    enum Segue: String, Printable, SegueProtocol {
        case Close = "Close"

        var kind: SegueKind? {
            switch (self) {
            case Close:
                return SegueKind(rawValue: "unwind")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.description } 
        var description: String { return self.rawValue }
    }

}
