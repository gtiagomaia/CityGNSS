//
//  ContainerController.swift
//  SNLocation
//
//  Created by Tiago Maia on 12/04/2019.
//  Copyright © 2019 Tiago Maia. All rights reserved.
//

import UIKit



protocol MenuControllerDelegate{
    func handleMenuToggle(forMenuOption menuOption: MenuOption?)
    func selectChangeView(forMenuOption menuOption: MenuOption)
}


class ContainerController: UIViewController {
    
    // MARK: - Properties
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var menuController: MenuController!
    var homeController: HomeController!
    var currentViewController: UIViewController!
    var isMenuExpanded = false
    var isTrueAnimteStatusBar = true       //this setting can be edited here directly, animate if status bar will be hidden //
    var lastMenuOption: MenuOption!
    //overlay when menu is on
    var overlay: UIView!
  
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //call function configureController to set all steps of navigationController
       
        configureHomeController()
    }
    
    
    //set background StatusBar color light (for dark backgrounds) of the iOS (clock, network lenght and other details)
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    //animation od status bar
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .none
    }
    override var prefersStatusBarHidden: Bool{
                        //changed this option, to set up alpha
        return  false // isMenuExpanded   //hide statubar when Menu Is Expanded
    }
    
    // MARK: - Handlers
    
    
    func configureHomeController(){
        
        lastMenuOption = .MAP
        // current = HomeController()
        //to be embedded in a navigation controller
        //let = ...
        homeController = HomeController()
        //call homeController delegate to be have this as delegate
        homeController.delegate = self
        //call UI navigation controller and set that rootViewController
        currentViewController = UINavigationController(rootViewController: homeController)
        //appdelegate.window!.rootViewController = currentViewController /* teste navigation controller */
        //set view controller
         view.addSubview(currentViewController.view)
         addChild(currentViewController)
         currentViewController.didMove(toParent: self);
        
        //configure menu controller
        menuController = MenuController()
        menuController.delegate = self
        
        //overlay
        overlay = UIView(frame: CGRect(x: 0, y: 0, width: currentViewController.view.frame.size.width, height: currentViewController.view.frame.size.height))
    }
    
    
    //function to show the side menu
    func animateshowMenuPanel(shouldExpand: Bool, menuOption: MenuOption?){
        
        if(currentViewController == nil){return}
        
        if shouldExpand { //==true
            // show menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                //set width window of side menu, all width size minus some
                self.currentViewController.view.frame.origin.x = self.currentViewController.view.frame.width - 115
               
            }, completion: nil)
        }else{
            // hide menu
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options:  .curveEaseIn, animations: {
                //set width window = 0 i'll be hided

                self.currentViewController.view.frame.origin.x = 0
            }) { (_) in
                guard let menuOption = menuOption else { return }
                if(menuOption != self.lastMenuOption || menuOption == .SETTINGS){
                    self.selectChangeView(forMenuOption: menuOption)
                }else{
                    //  
                }
            }
        }
        
        //set updates on animation for hidden status bar
        if isTrueAnimteStatusBar{
            animateStatusBar()
        }
    }
    
    //method that invoke each view for each option of the menu
    func didSelectMenuOption(menuOption: MenuOption){
        
        if(currentViewController == nil){return}
        //self.centerController?.view.removeFromSuperview()
        //self.centerController = nil

        switch menuOption{
        case .MAP:
            print("Show Map as home")
            homeController = HomeController()
            homeController.delegate = self
            //homeController.delegate = self
            replaceViewController(forNextViewController: homeController)
            
        case .LOCATIONINFO:
            print("Show location info")
            let locationInfoStoryboard = UIStoryboard(name: "LocationInfo", bundle: nil)
            let controller = locationInfoStoryboard.instantiateViewController(withIdentifier: "LocationIfoStoryboard") as! LocationInfoViewController
            controller.delegate = self
            replaceViewController(forNextViewController: controller)
            //self.present(controller, animated: true, completion: nil)
            
        case .SATELLITELIST:
            print("Show satellite list")
            let SatelliteListStoryboard = UIStoryboard(name: "SatelliteList", bundle: nil)
            let controller = SatelliteListStoryboard.instantiateViewController(withIdentifier: "SatelliteListStoryboard") as! SatelliteListViewController
            controller.delegate = self
            replaceViewController(forNextViewController: controller)
            
        case .NMEADATA:
            print("Show nmeadata")
            let controller = NMEATableViewController()
            controller.delegate = self
            replaceViewController(forNextViewController: controller)
            
        case .SETTINGS:
            print("Show settings")
            let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
           // if(settingsStoryboard == nil){ return }
            
            let controller = settingsStoryboard.instantiateInitialViewController() as! TableViewController
            controller.delegate = homeController.self
            
            self.present(UINavigationController(rootViewController: controller), animated: true)
            
        case .ABOUT:
            print("Show about")
            let controller = AboutController()
            controller.delegate = self
            replaceViewController(forNextViewController: controller)
        }
        
    }
    
    //animation status bar when menu is expanded
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            //self.navigationController?.navigationBar.frame = self.navigationController!.navigationBar.bounds
            
            let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
            if(self.isMenuExpanded){
                UIView.animate(withDuration: 1) {
                    statusBarWindow?.transform = CGAffineTransform(translationX: 0, y: -20)
                    statusBarWindow?.alpha = 0
                }
            }else{
                UIView.animate(withDuration: 1) {
                    statusBarWindow?.transform = CGAffineTransform(translationX: 0, y: 0)
                    statusBarWindow?.alpha = 1
                }
            }
            //updates view if needed
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
        
    }
    
    //shadow for container
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            currentViewController.view.layer.shadowOpacity = 0.8
            currentViewController.view.layer.shadowRadius = 4.0
            showOverlay()
        } else {
            currentViewController.view.layer.shadowOpacity = 0.0
            currentViewController.view.layer.shadowRadius = 0.0
            hideOverlay()
        }
    }
    
    // effect overlay
    func showOverlay(){
      
        overlay.backgroundColor = .black
        overlay.alpha = 0.0
        currentViewController.view.addSubview(overlay)
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.overlay.alpha = 0.175
            self.view.layoutIfNeeded()
        }
        
    }
    func hideOverlay() {
      overlay.removeFromSuperview()
       
    }
}

extension ContainerController: MenuControllerDelegate{
    
    //MARK: - handles
    @objc func handleMenuToggleOverlay(){
       handleMenuToggle(forMenuOption: nil)
    }
    
    func handleMenuToggle(forMenuOption menuOption: MenuOption?) {
        //if side menu isn't expand set menuController
        if !isMenuExpanded {
            
            //if menuController == nil{
                //add menu controller here
                addChild(menuController) //create relationship to manage memory
                view.insertSubview(menuController.view, at: 0)
            
                //menuController.didMove(toParent: self)
            
               
                //print("Did menu controller was added?")
                //view.backgroundColor = .gray
           // }
            
            //on overlay gestures
            //tap
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuToggleOverlay))
            gestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
            overlay.addGestureRecognizer(gestureRecognizer)
            //swipe left
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleMenuToggleOverlay))
            leftSwipe.direction = .left
            overlay.addGestureRecognizer(leftSwipe)

           // print("about isMenuExpanded \(isMenuExpanded)")
        }
        
        //show shadow if menu is expanded
        showShadowForCenterViewController(!isMenuExpanded)
        //if side menu is expanded will be closed
        //else if side isn't expanded will be showed
        isMenuExpanded = !isMenuExpanded
        //call show menu method
        animateshowMenuPanel(shouldExpand: isMenuExpanded, menuOption: menuOption)
        
    }
    
    // MARK: - select and change view
    func selectChangeView(forMenuOption menuOption: MenuOption) {
       
        
        self.didSelectMenuOption(menuOption: menuOption)

        if(menuOption == .LOCATIONINFO){
            menuController.selectRowLocationInfo(menuOption: menuOption)
        }
        if(menuOption != .SETTINGS){
            self.lastMenuOption = menuOption
            print("debug option: \(self.lastMenuOption.description)")
        }
    }
    
    

    // MARK: - transition effect
    
    func setTransitionFromRight(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.linear)
        view.window!.layer.add(transition, forKey: kCATransition)
        //present(dashboardWorkout, animated: false, completion: nil)
    }
   
    
    // MARK: - change ViewController
    
    func replaceViewController(forNextViewController nextViewController:UIViewController){
        

        let newVC = UINavigationController(rootViewController: nextViewController)      // 1
        addChild(newVC)                                                                 // 2
        newVC.view.frame = view.bounds                                                  // 3
        view.addSubview(newVC.view)                                                     // 4
        newVC.didMove(toParent: self)                                                   // 5
        //animation
        setTransitionFromRight()
        currentViewController.willMove(toParent: nil)                                   // 6
        currentViewController.view.removeFromSuperview()                                // 7
        currentViewController.removeFromParent()                                        // 8
        currentViewController = newVC
        
    }
    
}



