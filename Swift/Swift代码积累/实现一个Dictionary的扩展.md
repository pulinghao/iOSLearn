# 实现一个Dictionary的扩展

实现一个Dictionary的扩展

- 内部有个native的字典，给这个native的字典里添加数据
- 如果没有这个native的字典，则动态创建

参考代码

```swift
public extension Dictionary where Key: StringProtocol {
    /// SwifterSwift: Lowercase all keys in dictionary.
    ///
    ///        var dict = ["tEstKeY": "value"]
    ///        dict.lowercaseAllKeys()
    ///        print(dict) // prints "["testkey": "value"]"
    ///
    mutating func lowercaseAllKeys() {
        // http://stackoverflow.com/questions/33180028/extend-dictionary-where-key-is-of-type-string
        for key in keys {
            if let lowercaseKey = String(describing: key).lowercased() as? Key {
                self[lowercaseKey] = removeValue(forKey: key)
            }
        }
    }
}
```



```swift
public extension Dictionary {
    mutating func asd_safeSetObject(_ value: Value?, forKey key: Key) {
        if let value = value {
            self[key] = value
        }
    }
}
```

实现

```swift
extension Dictionary {
    
    /// 为DX模板添加本地参数，在 nativeContext 这个结构中添加
    /// - Parameters:
    ///   - key: String
    ///   - value: String
    mutating func setNativeParam(_ key: String,_ value: String) {
        var mutParams = [AnyHashable: Any]()
        if let nativeParams = self["nativeContext" as! Key] as? [String: Any] {
            mutParams = nativeParams
        }
        mutParams[key] = value
        self["nativeContext" as! Key] = mutParams as? Value
    }
}
```

