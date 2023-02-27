//
//  SceneDelegate.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var handle: AuthStateDidChangeListenerHandle?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
//        User.uploadMochDataToDatabase()
        
        
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print(user?.uid, user?.isEmailVerified) 
                if let user, user.isEmailVerified {
                    //if user is logged in
                    
                    guard let mainView = mainStoryboard.instantiateViewController(withIdentifier: "MainView") as? UITabBarController else {
                        fatalError("Could not typecast to UITabBarController")
                    }
                    self.window?.rootViewController = mainView
                } else {
                    // if user isn't logged in
                    guard let logInController = mainStoryboard.instantiateViewController(withIdentifier: "LoginView") as? WelcomeViewController else {
                        fatalError("Could not typecast to LoginViewController")
                    }
                    self.window?.rootViewController = logInController
                }
                self.window?.makeKeyAndVisible()
                UIView.transition(with: self.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
                
            }
        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

