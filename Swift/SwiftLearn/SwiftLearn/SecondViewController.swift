//
//  SecondViewController.swift
//  SwiftLearn
//
//  Created by pulinghao on 2023/1/5.
//

import UIKit

protocol secondViewDelegate {
    func hello()
}

class SecondViewController: UIViewController, helloProtocol {
    func hello() {
        print("hello")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.red
        let myView = MyView.init(frame: CGRect(x: 10, y: 10, width: 40, height: 10))
        myView.delegate = self
        self.view.addSubview(myView)
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("SecondViewControll deallop")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
