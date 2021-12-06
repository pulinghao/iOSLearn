//
//  ViewController.swift
//  MySwiftProject
//
//  Created by pulinghao on 2021/11/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        demo()
        demo2(x: 10, y: nil)
    }
    
    func demo() {
        var x = 10 //
        x = 20
        let y = 20.5
        
        let v = UIView()
        
        let z : Optional = 10
        
        print(x)
        print(y)
        print(v)
        print(z)
    }
    
    func demo2(x:Int?, y:Int?) {
       
        if x != nil && y != nil {
            print(x! + y!)
        } else {
            
        }
        
        print( (x ?? 0) + (y ?? 0))
        
        let name:String? = "小小"
        print((name ?? "") + "你好")
        print(name ?? "" + "你好")
    }

}

