**Swift简介**

**初识Swift**

**Swift 与 OC的区别**

|        | Swift                                  | OC                       |
| ------ | -------------------------------------- | ------------------------ |
| 初始化 | ClassName()                            | [[ClassName alloc] init] |
| 类方法 | UIColor.red                            | [UIColor redColor]       |
| 格式   | 每一行代码结束无分号；同一行用分号隔开 | 每一行代码用分号隔开     |

**变量与常量**

let

- 没有默认值
- 常量

var

- 默认值为nil
- 变量

Swift的自动推导：常量或者变量的类型，会根据=号右侧的结果推导出来。按住option + 单击变量，即可知道

虽然不进行类型检查，但是在不同类型数据之间，不能进行运算

```swift
let a = 10 
let b = 12.5 
print(a + b) //报错 
print(a + Int(b)) //可以 
print(Double(a) + b) //可以  
```

Swift没有基本的数据类型（如int，float，double这些）， 都是Struct结构体

- 指定一个类型

​                let x:Double = 10.0              

**struct 和 class区别**

|          | struct                                                       | class                                                        |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 内存     | 栈                                                           | 堆                                                           |
| 初始化   | 1. 可以在构造函数中，初始化属性2. 有默认的构造函数           | 1. 不可在初始化构造属性，初始化完成后，对属性赋值2. 需要初始化属性时，需要自定义构造函数 |
| 访问属性 | 对let和var能够在编译时，发现问题                             | 对let和var不存在检查的问题，因为是浅拷贝                     |
| 继承     | 否                                                           | 是                                                           |
| 拷贝     | 值拷贝                                                       | 需要指定拷贝类型，深浅                                       |
| 优点     | 1. 安全，没有引用计数2. 不会导致内存泄露3. 速度更快4. 线程安全 |                                                              |
| 缺点     | 1. 对OC不友好，struct不是继承自NSObject2. 不能继承3. 不能被序列化成NSData，也就是不能用NSUserDefaults |                                                              |

- 内存的分配和释放（malloc和free)是耗时操作，栈不需要考虑这些
- 访问时间：访问堆的具体单元，需要两次访问，先拿到指针，再根据指针拿到数据

**可选项 Option(?) 和 解包（！）**

定义：是一个常量或者变量，可以为nil

- none 没有值
- some 某一类值

​                // 写法1 let x : Optional = 10 // 写法2 let y : Int? = 20              

下面的代码会报错

​                print(x + y)  //报错，可选项的值可能为nil，不能运算 print(x! + y!) //输出30              

加入！之后，实现了强行解包 

​                let x : Optional = 10 let y : Int? = nil print(x! + y!)   //崩溃              

**分支与三目运算符**

- **不支持**非零即真的写法

​                if(self){} //这种写法不被支持              

- nil保护写法

​                print( (x ?? 0) + (y ?? 0)) // 如果x有值，就用值，无值就用0              

- if let 和 var的连用语法

- - if let 会解包，判断为非空的情况下才取出值
  - if let 在判断分支内部不修改值，if var 在判断分支内部修改值

​                func demo2(){    let oName : String? = "小小"    let oAge : Int? = 18 //    if oName != nil && oAge != nil{ //        print(oName! + String(oAge!))     //   }    if let name = oName,        let age = oAge {         print(name + String(age))          } else {                   }          if var name = oName,        let age = oAge {        name = "哈哈"         print(name + String(age))          } else {                   } }              

**guard 关键字**

guard expression中，如果expression = true，那么执行guard后边的语句

​                guard expression else { //expression = false //statements //必须包含的语句:return, break, continue or throw. } // expression = true,执行下面的语句  let oName : String?="小小" guard let name = oName else {    // 如果name为空，则执行else中的语句    print("name为空")   } print name              

**Switch语句**

- case的类型，支持任一类型
- 可以合并case在同一行里

​                case "10","9":    print("xx")              

- 不需要使用break，但如果没有内容，必须写break占位

**for语句**

几种不同的写法

​                // 1. for i in 0..<5{    // 两个..    //[0,1,2,3,4] } // 2. for i in 0...5{     // 三个.    //[0,1,2,3,4,5]     } // 3.逆序 for i in (0..<10).reversed(){    //[9,8,7,6,5,4,3,2,1,0] }              

**字符串**

- 初始化

​                var temp = String() var temp2 = "a string"              

- 拼接（变量字符串）

​                var str1 = "123" var str2 = str1 + "456"              

- 获取每个字符的值 **.characters**

​                for character in "Dog!?".characters{    print(character) }              

- 字符串长度 **characters.count**

​                let str = "hello world 你好" print(str.lengthOfBytes(using:.utf8)) //计算字节数 //输出18 ，每个汉字UTF83个字节 print(str.characters.count) //返回字符个数              

**数组**

与OC的数组不同，可变不可变由let 和 var决定

- **初始化**

​                Array<Element>  //泛型 var array = Array<String>() var array2 = [Int]() //简写，创建空数组 Array(repeating:0 count:10) //创建一个10个元素为0的数组 [1,2] var shopplingList : [String] = ["egg","milk"] var shopplingList2 = ["egg","milk"]              

-   **数组相加**

元素类型相同的数组A和数组B可以相加

- **常用属性和方法**

- - count
  - append添加元素，或者使用 += ["1","2"]，添加数组元素，相当于数组相加
  - insert at 插入元素
  - array[2...4] = ["新2","新3"]，将位置2和位置3上的元素，替换为"新2","新3"，注意这里2...4，意思同for循环一样，是[2,4)区间
  - remove 删除元素 removeLast
  - 遍历 for 和 enmurate

​                for(index,value) in array.enmurated(){    //index索引    //value值 }              

**集合**

- 无序
- 不重复元素，集合中的元素必须有确定的hashValue
- 初始化

​                var letters = Set<String>() var favorite:Set<String> = ["Rock","Hip pop"] //根据数组字面值得到集合 var favorite:Set = ["Rock","Hip pop"]              

- 常用属性和方法

- - 添加元素

​                favorite.insert("Jazz")              

- - 删除 remove, removeAll

​                favorite.remove("Rock") //移除成功,返回Rock，删除失败，返回没有值              

- - 遍历

​                for item in favorite.sourted(){    print(item) }              

- - 交集 intersection
  - 并集 union
  - 差集 subtracting
  - 在一个集合，但不在另外一个集合，去掉相同值 symmetricDifference

​                let oddD: Set = [1,3,5,7,9] let evenD: Set = [2,4,6,8,10] let singleDPrim : Set = [2,3,5,7] print(oddD.union(evenD).sorted()) print(oddD.intersection(singleDPrim).sorted()) print(oddD.subtracting(singleDPrim).sorted()) print(oddD.symmetricDifference(singleDPrim).sorted())              

- - 集合的相等，通过 ==
  - A 包含于 B，A中的元素也是B中的元素  

​                A.isSubSet(of:B) B.isSuperSet(of:B)              

- - A 与 B没有交集

​                A.isDisjoint(with:B) // 如果有交集，返回false，没有交集，返回true              

**字典**

**初始化**

​                var dict1 = [Int : String]() var dict2:[Int : String] = [1:"one",2:"two"] //字面量创建 var dict3 = [1:"one",2:"two"]              

**访问与修改**

​                //访问 let someV = dict2[2] // 修改 var oldVar = dict2.updateValue("too", forKey: 2) dict2[1] = "one新值"               

**移除**

​                var removeV = dict2.revemoveValue(forKey:2) dict3[1] = nil              

**遍历**

​                for(key,value) in dict2{   print("key:\(key)====") }              

**字典转数组**

​                let dictKeys = [Int](dict2.keys) let dictValues = [String](dict2.values)              

**函数与闭包**

**函数**

​                func funcName(parameter: Type) -> BackValueType{   return backValue }              

无返回值

​                func demo(){} func demo2()->(){} func demo3()->Void{}              

参数的匿名及省略

​                // 使用匿名str1,str2 func returnName(str1 name:String,str2 age:Int) -> String{   return (name) } returnName(str1: "小明", str2: 12) // 用下划线修饰参数 func returnName2(_ name:String,_ age:Int) -> String{   return (name) } // 调用时省略参数名 returnName2("小宏", 13)              

函数的参数默认值

​                func returnName3(name:String = "空白",age:Int = 12) -> String{   return (name) } // 无参数传入，此时name被默认设置为空白,age为12 returnName3() // 缺省任一参数时，自动会寻找默认值              

**闭包**

**基本知识**

{形参列表 -> 返回值类型 in 实现代码}

​                let blk = {   print("this is a block") } blk() let blk2 = {   (x : String) -> () in print(x) } blk2("String")              

**尾随闭包**

如果函数的最后一个参数是一个闭包，可以把这个闭包写在外面

​                func myFunc(strP:String,closuereP:(String)-> Void) -> Void {   closuereP(strP) } // 普通调用 myFunc(strP: "hello", closuereP: {   (string) in print(string) }) // 尾随闭包,闭包在函数的右括号)的外面 myFunc(strP: "hello 2") { (string) in   print(string) }              

**逃逸闭包**

当闭包作为参数，传入另一个函数中时，而且在函数返回以后，才被执行。此时，闭包逃逸了函数的作用域

@escaping 允许逃逸出函数

​                // 在ViewDidLoad中调用 override func viewDidLoad() {     super.viewDidLoad()     // Do any additional setup after loading the view.     showYouTest {       print("我是闭包")     }   }     func showYouTest(testBlock: @escaping () -> Void) {     //做一个延迟操作     DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {       //3秒之后调用闭包       testBlock()     }     print("我是函数") }               

这种情况，在涉及到异步操作时经常用到，特别是当网络请求后要进行请求成功后的回调时，闭包就要逃逸掉，这时就要在闭包形参钱加上@escaping关键字。类似于需要保活这个block

​                //输出 我是函数 // 3s后 我是闭包               

**枚举**

**定义**

​                enum SomeEnumeration{   case north   case south   case east   case west } //多个成员值，要写在同一行 enum Plant{   case mercury,eatch,mars }              

- 没有默认值，没有整型值
- 值的类型，就是定义的枚举名
- 支持整型、浮点型、字符串型、布尔型

**赋值**

​                var head = SomeEnumeration.east head = .north              

**关联值**

可以在枚举值中，设置关联的值，

​                enum Trade {    case Buy(stock:String,amount:Int)    case Sell(stock:String,amount:Int) } let trade = Trade.Buy(stock: "003100", amount: 100) switch trade { case .Buy(let stock,let amount):        print("stock:\(stock),amount:\(amount)")     case .Sell(let stock,let amount):    print("stock:\(stock),amount:\(amount)") default:    () }              

如果设置了关联值，那么直接判断是否相等是错误的！！！

​                enum Country {    case China(city: String)    case Japan(city: String)    case Singapore } //下面是错误的判断 let sig = Country.Singapore if sig == Country.Singapore {    //... } //正确的如下 let sig = Country.Singapore if case Country.Singapore = sig {    //... } //需要连着关联值一起判断 let gz = Country.Cina(city: "GuangZhou") if case Country.Cina(city: "GuangZhou") = gz {    //... }              

**默认值（原始值）**

指定了枚举的类型，需要设置枚举的原始值

​                enum Movement:Int {    case left = 0,right,top,bottom } //left = 0,right = 1,top = 2,bottom = 3 enum Area: String {    case DG = "dongguan"    case GZ = "guangzhou"    case SZ = "shenzhen" }              

- 字符串的默认值是枚举本身
- 访问枚举变量的原始值

​                let area = Area.DG.rawValue              

**递归枚举**

递归枚举是将枚举的另一个实例作为一个或多个枚举case的关联值。在枚举case 前面添加关键字

indirect来指明该枚举case是递归的，这就告诉了编译器插入必要的间接层。

​                // 写法一： enum ArithmeticExpression {    case number(Int)    indirect case addition(ArithmeticExpression, ArithmeticExpression)    indirect case multiplication(ArithmeticExpression, ArithmeticExpression) } // 写法二： indirect enum ArithmeticExpression {    case number(Int)    case addition(ArithmeticExpression, ArithmeticExpression)    case multiplication(ArithmeticExpression, ArithmeticExpression) } let five = ArithmeticExpression.number(5) let four = ArithmeticExpression.number(4) let sum = ArithmeticExpression.addition(five, four) let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))              

用于处理具有递归结构的数据方法

​                func evaluate(_ expression: ArithmeticExpression) -> Int {    switch expression {    case let .number(value):        return value    case let .addition(left, right):        return evaluate(left) + evaluate(right)    case let .multiplication(left, right):        return evaluate(left) * evaluate(right)    } } print(evaluate(product)) // Prints "18"              

**类和结构体**

区别参考上面 struct和class区别

**属性（实例属性）**

- 不再有实例变量
- 懒加载属性

​                class newClass {   lazy var name = "小明" //懒加载，延迟加载属性 }              

**存储属性**

**计算属性**

​                  var lastName = "小小"   var firstName = "苏"     // 计算属性   var name:String{     get{       return firstName + lastName     }   }              

**只读属性，只有get没有set**

**属性观察器**

​                class newClass {   // 观察属性   var examplePro:Int = 10{     willSet(newTotal){       // 在属性更改之前做的操作       print("新值是\(newTotal)")     }     didSet{       // 在属性更改之后做的操作       // 旧值通过oldValue获取       print("新值-旧值\(examplePro - oldValue)")     }   } } let count = newClass() count.examplePro = 12 //新值是12 //新值-旧值2              

**类型属性**

- 在C或者OC中，静态常量或者变量，作为全局静态变量定义
- 类型属性，作为类型定义的一部分，写在类型定义的最外层花括号内，作用域也就是类型支持的方位
- 用static修饰

​                struct SomeStructure {    static var storedTypeProperty = "Some value."    static var computedTypeProperty: Int {        return 1    } }              

- 使用class，支持子类对父类的重写

​                class SomeClass {    static var storedTypeProperty = "Some value."    static var computedTypeProperty: Int {        return 27    }    // 下面的属性支持子类对父类的复写    class var overrideableComputedTypeProperty: Int {        return 107    } }              

- 调用

​                print(SomeStructure.storedTypeProperty) print(SomeEnum.computedTypeProperty) print(SomeClass.computedTypeProperty)              

**方法**

实例方法 

- 不需要显式的写self，swift内部默认了使用当前实例的属性和方法
- 使用self，主要是消除方法参数和实例属性的歧义，比如参数名为X，而属性名也是X

类方法

- 需要用class声明，是 类方法

​                class SomeClass {    class func someTypeMethod() {        // 在这里实现类型方法    } } SomeClass.someTypeMethod()              

**下标**

定义下标，定义下标的行为，比如返回什么，或者做什么操作

​                struct TimeOfNum{   let num : Int   // 定义一个下标   subscript(index:Int)->Int{     return num * index   } }              

调用

​                let TimeOfFive = TimeOfNum(num: 5) print(TimeOfFive[3])              

重载

​                subscript(index:Int, index2:Int) ->Int{     return num * index + index2; } print(TimeOfFive[3,4])              

**继承**

- 只有类可以继承，Struct和Enum都不能继承
- 可以重写父类的方法，属性、下标
- 使用override修饰需要覆写的方法
- 使用final修饰不可被继承的方法，如果在类之前修饰final，那么整个类都不能被继承

**构造函数**

- 系统自动生成一个构造器init，通过重载来判断用哪个构造器
- 子类不实现自己的指定构造器，则使用父类的无参构造
- 子类中创建了指定构造器，将不再使用父类的任一构造器。但是，子类的构造器中，必须调用父类的某个构造器super.init()

**类型转换**

- is 检查对象是否属于某个类
- as？ 或者 as！对父类型对象转成子类型对象

​                let d:Double = 12.3 let i = Int(d) let dd = d as?Int //转成Int print(dd)  // 输出nil              

**扩展**

​                extension OriginClassName{    // 添加新方法，计算属性等 } extension Int{   // 修改计算属性   var squared: Int {     return self * self;   } }              

- 不能添加已经存在的方法，不能添加存储属性

**泛型**

打印泛型数据，支持不同的数据类型

T 代表任意类型

​                func printElementFromArray<T>(a:[T]){    for elememt in a {    	print(a)   } }               

结构体泛型

​                struct GenericArr<T> {   var items = [T]() //创建数组   mutating func push(item:T){     items.append(item)   } }              

- mutating修饰方法，这个方法会修改self

**协议**

先看个例子

​                protocol People {   var name:String{get set}   var race:String{get set}   func sayHi() } // 遵循协议，就需要实现方法和变量 struct Man:People{   var name:String = "Lee"   var race:String = "Asia"   func sayHi() {     print("hi i am \(name)")   } } class Human:People{   var name: String = "Hele"     var race: String = "Africa"     func sayHi() {       } }              

- 协议可以互相继承，继承的类或者结构体，需要实现继承链上所有的变量和方法
- 如果在变量后面，声明了get 和 set方法，那么需要实现对应的方法
- 协议扩展（extension）实现了协议里的方法，那么实例也能执行这个方法

​                protocol iOSGenius{   func point() } struct iOSPub : iOSGenius{   func point() {     print("ios pub")   } } class iOSDev : iOSGenius{   func point() {     print("ios dev")   } } extension iOSGenius{   func point(){     print("ios genius")   } } let dev = iOSDev() // 如果iOSDev实现了point方法 dev.point() //输出 ios dev // 如果iOS Dev没实现point方法，则输出ios genius              

**视频完**