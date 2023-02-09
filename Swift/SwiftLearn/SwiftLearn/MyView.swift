//
//  MyView.swift
//  SwiftLearn
//
//  Created by pulinghao on 2023/1/6.
//

import UIKit

protocol helloProtocol {
    func hello()
}

class MyView: UIView {
    var delegate : helloProtocol?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        let lable = UILabel.init()
        lable.text = "你好"
        lable.sizeToFit()
        self.addSubview(lable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MyView dealloc")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.hello()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
