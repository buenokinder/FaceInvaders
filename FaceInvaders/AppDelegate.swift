

import UIKit
import CoreData

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
	fileprivate var friendsAPI: FriendsAPI!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		
		self.friendsAPI = FriendsAPI.sharedInstance

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                             sourceApplication: String?,
                             annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
	
	
	func sharedInstance() -> AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}
	
	lazy var datastoreCoordinator: DatastoreCoordinator = {
		return DatastoreCoordinator()
	}()
	
	lazy var contextManager: ContextManager = {
		return ContextManager()
	}()
	
	
	
	
    func applicationWillResignActive(_ application: UIApplication) {
  
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
}
