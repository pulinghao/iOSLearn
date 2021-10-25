最近在校园地图的项目中，发现基线RD普遍喜欢使用`JSONModel`这个三方框架，来解析`JSON`数据。于是就研究了一下这个三方框架的用法和内部原理。

# 1. 使用示例

比如说与服务端制定了如下的数据结构协议：

## 下行数据

```json
{
  "name":"Tom",
  "age" :13,
  "family":{
    "father":"Jack",
    "mother":"Hellen"
  },
  "friends":[
    {
      "name":"Leo",
      "age":12
    },
    {
      "name":"Jim",
      "age":13
    }
  ]
}
```

## 常规写法

```objc
@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSDictionary *family;
@property (nonatomic, copy) NSArray *friends;

@end


@implementation Person

- (Person *)convertDictToPersonModel:(NSString *)jsonString{
    NSError *error;
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    id jsonObject;
    if (jsonData) {
        jsonObject  = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingAllowFragments
                                                        error:&error];
    }
    
    NSDictionary *jsonDict = (NSDictionary *)jsonData;
    
    // 转为model
    Person *person = [[Person alloc] init];
    // 按照服务端协议命名
    person.name = [jsonDict objectForKey:@"name"];
    person.age = [[jsonDict objectForKey:@"age"] integerValue];
    person.family = [jsonDict objectForKey:@"family"];   //family是字典结构
    person.friends = [jsonDict objectForKey:@"friends"]; //friends是数组结构
    return person;
}
@end
```

常规写法有以下几点不足：

- 每次都需要自己创建数据模型`Model`，并针对`JSON`中的每个字段提取出来解析
- 部分特殊的字段，需要进一步转化，例如`int`，`float`等
- 复杂的数据结构，例如字典和数组，并没有被解析为数据模型，还需要进一步写解析函数



## 使用JSONModel

```objective-c
// 头文件声明
// Person.h
#import "JSONModel.h"

@protocol Family
@end

@interface Family : JSONModel
@property (nonatomic, copy) NSString *father;
@property (nonatomic, copy) NSString *mother;
@end

@protocol Friend
@end

@interface Friend : JSONModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@end

@interface Person : JSONModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) Family *family;
@property (nonatomic, copy) NSArray<Friend> *friends;  //这里一定要写 protocol，否则会崩溃

@end
  
// 实现
// Person.m
@implementation Person
@end
  
// 调用方
// OtherClass
Person *person = [[Person alloc] initWithDictionary:data error:nil];
```

使用`JSONModel`的优势

- 更少的代码
- 自动类型转换
- 字段可选控制：对于可选字段，设置`<Optional>`属性来实现



# 2. 注意点

- 嵌套的数据结构，即模型A包括模型B时，一定要写模型B的`protocol`，否则无法正常解析模型B

```objective-c
@protocol ModelB   //没有这个会出现字典数据无法正常转化成ModelB对象
@end

@interface ModelB : JSONModel
@end

@interface ModelA : JSONModel
@property (nonatomic, strong) ModelB *modelB;
```

- 数组中的元素也是个对象时，注意修饰符号，不带`*`

```objective-c
@property (nonatomic, copy) NSArray<ModelB> *modelB;  //不写<ModelB>会出现崩溃
```

- 两个注意点：

<font color='red'>**如果没有写<>中的属性，那么会出现崩溃！！！**</font>

<font color='red'>**如果没有写持有对象所属类的`protocol`，那么会出现崩溃！！！**</font>

```shell
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[__NSDictionaryI modelB]: unrecognized selector sent to instance 0x280c2e400'
terminating with uncaught exception of type NSException
```

# 3. 原理

## 1） 属性构造

基本的数据类型，例如`int`，`string`并不需要特殊处理，`JSONModel`通过`KVC`的方式进行赋值：

```objc
if (property.type == nil && property.structName==nil) {
                
    //generic setter
    [self setValue:jsonValue forKey: property.name];

    //skip directly to the next key
    continue;
}
```



## 2）`JSONModel`是如何给嵌套的JSON数据构造Model，并赋值的？

如果是数组，其实就是解决如何解析嵌套JSON的问题。假设我们是这样修饰Model A中的属性modelB的

`@property (nonatomic, copy) NSArray<ModelB> *modelB;`

从`JSONModel`的源码中，可以看到

```objective-c
//get property name
objc_property_t property = properties[i];
const char *propertyName = property_getName(property);
p.name = @(propertyName);

//get property attributes
const char *attrs = property_getAttributes(property);
NSString* propertyAttributes = @(attrs);
```

通过`property_getName()`获取属性名字`modelB`

通过`property_getAttributes()`获取修饰属性的特征`T@"NSArray<ModelB>",C,N,V_modelB。

然后构造了一个字符串的检索`scanner`,从属性中拿到`protocol`对应的那个类

```objc
scanner = [NSScanner scannerWithString: propertyAttributes];
            

//read through the property protocols
while ([scanner scanString:@"<" intoString:NULL]) {

    NSString* protocolName = nil;
		
    // 这一步，把<>中的内容赋值给了protocolName
    [scanner scanUpToString:@">" intoString: &protocolName];

     // 为属性的protocol字段复制，后面便于构造对应的类
    p.protocol = protocolName;
    
    [scanner scanString:@">" intoString:NULL];
}

```

从`protocol`中构造`Class`

```objc
-(id)__transform:(id)value forProperty:(JSONModelClassProperty*)property error:(NSError**)err{
		//if the protocol is actually a JSONModel class
    // 检查是不是JSONModel的子类
    if ([self __isJSONModelSubClass:protocolClass]) {

			// Expecting an array, make sure 'value' is an array
      // 类型是个数组
			if ([property.type isSubclassOfClass:[NSArray class]]) {

			// Expecting an array, make sure 'value' is an array
      // 值如果不是数组
			if(![[value class] isSubclassOfClass:[NSArray class]])
			{
				if(err != nil)
				{
					NSString* mismatch = [NSString stringWithFormat:@"Property '%@' is declared as NSArray<%@>* but the corresponding JSON value is not a JSON Array.", property.name, property.protocol];
					JSONModelError* typeErr = [JSONModelError errorInvalidDataWithTypeMismatch:mismatch];
					*err = [typeErr errorByPrependingKeyPathComponent:property.name];
				}
				return nil;
			}

            if (property.convertsOnDemand) {
                //on demand conversion
                value = [[JSONModelArray alloc] initWithArray:value modelClass:[protocolClass class]]; 
            } else {
                //one shot conversion
								JSONModelError* arrayErr = nil;
								//构造数组，数组里面的每个元素都是protocolClass类型
                value = [[protocolClass class] arrayOfModelsFromDictionaries:value error:&arrayErr];
            }

    }
```

从数组构造model

```objc
// Same as above, but with error reporting
+(NSMutableArray*)arrayOfModelsFromDictionaries:(NSArray*)array error:(NSError**)err
{
    //bail early
    if (isNull(array)) return nil;

    //parse dictionaries to objects
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];

    for (NSDictionary* d in array) {

		JSONModelError* initErr = nil;
    // 重新按照dictionary的方式，继续构造内部的数据
		id obj = [[self alloc] initWithDictionary:d error:&initErr];
		if (obj == nil)
		{
			// Propagate the error, including the array index as the key-path component
			if((err != nil) && (initErr != nil))
			{
				NSString* path = [NSString stringWithFormat:@"[%lu]", (unsigned long)list.count];
				*err = [initErr errorByPrependingKeyPathComponent:path];
			}
			return nil;
		}
        [list addObject: obj];
    }

    return list;
}
```

