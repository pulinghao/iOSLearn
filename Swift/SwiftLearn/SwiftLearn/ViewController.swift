//
//  ViewController.swift
//  SwiftLearn
//
//  Created by pulinghao on 2023/1/5.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let list = ["测试","测试2"
    ]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = list[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = SecondViewController()
            self.present(vc, animated: true)
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initUI()
        
    }

    func initUI() {
        let screenSize = UIScreen.main.bounds.size
        let tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        tableView.register(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
    
    

}

