//
//  ViewController.swift
//  ChatApp
//
//  Created by 吳政緯 on 2017/6/14.
//  Copyright © 2017年 吳政緯. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class ViewController: UIViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let user = Auth.auth().currentUser else {
            // 尚未登入，前往登入、註冊介面
            self.showAuthViewController()
            return
        }
        
        
        // 驗證token是否還有效
        user.getToken {[unowned self] (_, error) in
            if let error = error {
                // 顯示錯誤訊息，並前往登入、註冊介面
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: 3, completion: {
                    self.showAuthViewController()
                })
                return
            }
            
            // token 驗證成功前往聊天室列表
            self.showRoomListViewController()
        }
    }
    
    func showAuthViewController() {
        navigationController?.setViewControllers([AuthViewController()], animated: false)
    }
    
    func showRoomListViewController() {
        navigationController?.setViewControllers([RoomListViewController()], animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
     

}

