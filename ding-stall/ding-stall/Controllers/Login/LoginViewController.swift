//
//  LoginViewController.swift
//  ding-stall
//
//  Created by Yunpeng Niu on 23/03/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import DingBase
import FirebaseAuthUI

/**
 The controller for initial login view. However, this controller is only an adapter. The actual
 login view is managed by the Firebase-Auth-UI library.

 - Author: Group 3 @ CS3217
 - Date: March 2018
 */
class LoginViewController: UIViewController {

    /// A flag to show whether the user is new
    var isNewUser = false

    /// Used to handle all logics related to Firebase Auth.
    fileprivate let authorizer = Authorizer()
    /// Used to handle the account of current login user
    private let accountController = AccountController()

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountController.downloadGlobalInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard authorizer.didLogin && !isNewUser else {
            if !isNewUser {
                loadLoginView(animated)
            }
            return
        }

        setUserAccount()
        loadTabBarView(animated)
    }

    private func loadProfileView(_ animated: Bool) {
        let id = Constants.profileControllerId
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: id) else {
            fatalError("Could not find the controller for Profile View")
        }
        navigationController?.pushViewController(tabBarController, animated: animated)
    }

    /// Loads the login view from Firebase Auth UI library.
    /// - Parameter animated: If true, the view was added to the window using an animation.
    private func loadLoginView(_ animated: Bool) {
        if let authUI = FUIAuth.defaultAuthUI() {
            authUI.delegate = self
            present(authUI.authViewController(), animated: animated, completion: nil)
        }
    }

    /// Loads the main tab bar view from storyboard.
    /// - Parameter animated: If true, the view was added to the window using an animation.
    private func loadTabBarView(_ animated: Bool) {
        let id = Constants.tabBarControllerId
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: id) else {
            fatalError("Could not find the controller for main tab bar")
        }
        navigationController?.pushViewController(tabBarController, animated: animated)
    }

    /// Load a form view to let the user fill in stall information
    /// - Parameter animated: If true, the view was added to the window using an animation.
    private func loadStallFormView(_ animated: Bool) {
        let id = Constants.stallFormControllerId
        guard let stallCreationController = storyboard?.instantiateViewController(withIdentifier: id)
            as? StallCreationViewController else {
                fatalError("Could not find the controller for stall detail form")
        }
        stallCreationController.stallId = authorizer.userId
        stallCreationController.loginDelegate = self
        navigationController?.pushViewController(stallCreationController, animated: animated)
    }

    /// Set the current user id.
    private func setUserAccount() {
        guard authorizer.isEmailVerified else {
            handleEmailNotVerifiedError()
            return
        }
        accountController.loginDelegate = self
        accountController.setStallId(authorizer.userId)
    }

    private func handleEmailNotVerifiedError() {
        DialogHelpers.showAlertMessage(in: self, title: "Oops", message: "Email address is not verified."
            + "Please verify it and login again") {
                self.signOut()
                self.authorizer.verifyEmail()
                self.loadLoginView(true)
        }
    }
}

/**
 Extension for `LoginViewController` to act as a delegate for Firebase Auth UI.
 */
extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {

        if isNewUser {
            isNewUser = false
            authorizer.verifyEmail()
            loadStallFormView(true)
        }
    }

    func passwordSignUpViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordSignUpViewController {
        let controller = PasswordSignUpController(authUI: authUI, email: email)
        controller.parentController = self
        return controller
    }
}

extension LoginViewController: LoginDelegate {
    /// Automatically signs user out when user signs in using customer account.
    public func handleWrongAccountType() {
        DialogHelpers.showAlertMessage(in: self, title: "Wrong Account Type",
                                       message: "The account is not registered as a stall account." +
                                                "Try to sign in using another account") {
                                                    self.signOut()
        }
    }

    /// Sign out this account and navigate back to login view
    public func signOut() {
        authorizer.signOut()
        Account.clear()
        navigationController?.popToRootViewController(animated: true)
    }
}

public protocol LoginDelegate: class {
    /// Handles when the login account is not registered for stall
    func handleWrongAccountType()

    /// Sign out the current account
    func signOut()
}
