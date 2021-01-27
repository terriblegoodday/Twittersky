//
//  AppDelegate.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 27.01.2021.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSToolbarDelegate, NSWindowDelegate, MainWindowDelegate, SignInPresenterDelegate, NewTweetPresenter {

    var userInfo: UserInfo?
    var window: NSWindow!
    var toolbar: NSToolbar!
    var signInPresenter: SignInPresenter?
    var newTweetWindow: NewTweetWindow?
    var currentUser: User? {
        didSet {
            userInfo?.currentUser = currentUser
            userInfo?.user = currentUser
            userInfo?.refresh()
        }
    }
    
    enum Constants {
        enum Toolbar {
            static let newTweet = NSToolbarItem.Identifier("Новый твит")
            static let reloadTweets = NSToolbarItem.Identifier("Обновить")
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let userInfo = UserInfo()
        self.userInfo = userInfo
        let contentView = ContentView(delegate: self, viewModel: userInfo).environment(\.managedObjectContext, persistentContainer.viewContext).environment(\.userInfo, userInfo)
        

        self.toolbar = NSToolbar()
        self.toolbar.delegate = self
        self.toolbar.displayMode = .iconOnly
        
        self.signInPresenter = SignInPresenter()
        self.signInPresenter!.delegate = self
        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 1200),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Twitter"
        window.toolbar = self.toolbar
        self.toolbar.isVisible = true
        
        getDefaultUser()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - NewTweetPresenter
    
    func sendTweet(body: String) {
        let tweet = Tweet(context: NSManagedObjectContext.shared)
        tweet.body = body
        tweet.author = currentUser
        tweet.createdAt = Date()
        NSManagedObjectContext.saveShared()
        self.newTweetWindow?.close()
    }
    
    // MARK: - MainWindowDelegate
    
    func didClickSignInButton() {
        self.signInPresenter?.present()
    }
    
    func logout() {
        currentUser = nil
        removeDefaultUser()
    }
    
    func destroy() {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to destroy your account?"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Destroy")
        let modalResult = alert.runModal()
        
        switch(modalResult) {
        case .alertFirstButtonReturn:
            break
        case .alertSecondButtonReturn:
            NSManagedObjectContext.shared.delete(currentUser!)
            currentUser = nil
        default:
            break
        }
    }
    
    // MARK: - SignInPresenterDelegate
    
    func didSignIn(with user: User) {
        self.currentUser = user
        storeDefaultUser(user)
    }
    
    func getDefaultUser() {
        let defaults = UserDefaults.standard
        if let login = defaults.string(forKey: "currentAccount.login"), let password = defaults.string(forKey: "currentAccount.password") {
            let request: NSFetchRequest<User> = User.fetchRequest()
            let loginPredicate = NSPredicate(format: "login == %@", login)
            let passwordPredicate = NSPredicate(format: "password == %@", password)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [loginPredicate, passwordPredicate])
            if let response = try? NSManagedObjectContext.shared.fetch(request) {
                self.currentUser = response.first
            }
        }
    }
    
    func storeDefaultUser(_ user: User) {
        let login = user.login
        let password = user.password
        let defaults = UserDefaults.standard
        defaults.set(login, forKey: "currentAccount.login")
        defaults.set(password, forKey: "currentAccount.password")
    }
    
    func removeDefaultUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "currentAccount.login")
        defaults.removeObject(forKey: "currentAccount.password")
    }
    
    // MARK: - NSToolbarDelegate
    
    @objc func didClickNewTweetButton(_ sender: NSToolbarItem) {
        if currentUser != nil {
            let window = NewTweetWindow(presenter: self, contentRect: NSRect(x: 0, y: 0, width: 320, height: 320), styleMask: [.titled, .closable, .docModalWindow], backing: .buffered, defer: false)
            window.delegate = self
            self.newTweetWindow = window
            let _ = NSWindowController(window: window)
            NSApp.runModal(for: window)
        } else {
            let alert = NSAlert()
            alert.messageText = "You can't post tweets without authorization"
            alert.runModal()
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }
    
    @objc func didClickReloadButton(_ sender: NSToolbarItem) {
        print ("did click reload button")
        NSManagedObjectContext.saveShared()
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch(itemIdentifier) {
        case Constants.Toolbar.newTweet:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let button = NSButton(image: NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Новый твит")!, target: self, action: #selector(didClickNewTweetButton(_:)))
            button.isBordered = false
            item.view = button
            item.label = "Новый твит"
            item.minSize = CGSize(width: 24, height: 24)
            item.maxSize = CGSize(width: 24, height: 24)
            item.action = #selector(didClickNewTweetButton(_:))
            return item
        case Constants.Toolbar.reloadTweets:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let button = NSButton(image: NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: "Обновить")!, target: self, action: #selector(didClickReloadButton(_:)))
            button.isBordered = false
            item.view = button
            item.label = "Обновить"
            item.minSize = CGSize(width: 24, height: 24)
            item.maxSize = CGSize(width: 24, height: 24)
            item.action = #selector(didClickReloadButton(_:))
            return item
        default:
            return nil
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [Constants.Toolbar.newTweet]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        var allowedIdentifiers = [Constants.Toolbar.newTweet]

        return allowedIdentifiers
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [Constants.Toolbar.newTweet]
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Twittersky")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

