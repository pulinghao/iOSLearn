//
//  ViewController.swift
//  MySwiftProject
//
//  Created by pulinghao on 2021/11/25.
//

import UIKit

enum SomeEnumeration{
    case north
    case south
    case east
    case west
}

enum Plant{
    case mercury,eatch,mars
}

enum BarCode{
    case upc(Int,Int,Int,Int) //根据数字识别商品
    case QrCode(String)       //根绝二维码
}

struct Teacher{
    var name:String = ""
    var age:Int = 20
}

class Student {
    var name:String?
    var age:Int = 10
}



class newClass {
    var lastName = "小小"
    var firstName = "苏"
    
    // 计算属性
    var name:String{
        get{
            return firstName + lastName
        }
    }
    
    // 观察属性
    var examplePro:Int = 10{
        willSet(newTotal){
            // 在属性更改之前做的操作
            print("新值是\(newTotal)")
        }
        didSet{
            // 在属性更改之后做的操作
            // 旧值通过oldValue获取
            print("新值-旧值\(examplePro - oldValue)")
        }
    }
    
}


struct SomeStructure {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 1
    }
}
enum SomeEnum {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 6
    }
}
class SomeClass {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 27
    }
    class var overrideableComputedTypeProperty: Int {
        return 107
    }
}

struct TimeOfNum{
    let num : Int
    // 定义一个下标
    subscript(index:Int)->Int{
        return num * index
    }
    
    subscript(index:Int, index2:Int) ->Int{
        return num * index + index2;
    }
}

struct ShoolUniform{
    enum Style:String{
        case Sport = "运动服", Suit = "中山装"
    }
    
    enum Grade:String{
        case One = "一年级", Two = "二年级", Three = "三年级"
    }
    
    let myStyle:Style
    let myGrade:Grade
    func cunstiom(){
        print("我的年级:\(myGrade.rawValue)====我的校服:\(myStyle.rawValue)")
    }
}
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let unifor = ShoolUniform(myStyle: .Suit, myGrade: .Two)
        unifor.cunstiom()
        
        let d:Double = 12.3
        let i = Int(d)
        let dd = d as?Int //转成Int
        print(dd)
        
        
        let TimeOfFive = TimeOfNum(num: 5)
        print(TimeOfFive[3])
        print(TimeOfFive[3,4])
        
        print(SomeStructure.storedTypeProperty)
        print(SomeEnum.computedTypeProperty)
        print(SomeClass.computedTypeProperty)
        
        let classItem = Student()
        classItem.name = "13班"
        
        let count = newClass()
        count.examplePro = 12
        
        
        
        demo()
        demo2(x: 10, y: nil)
        
        var head = SomeEnumeration.east
        head = .west
        
        
        switch head {
        case .north:
            print("N")
        case .south:
            print("S")
        case .east:
            print("E")
        case .west:
            print("W")
        default:
            print("No head")
        }
        
        
        // 创建条形码
        var productBar = BarCode.upc(1, 2, 3, 4)
        productBar = .QrCode("ABCDE")
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

