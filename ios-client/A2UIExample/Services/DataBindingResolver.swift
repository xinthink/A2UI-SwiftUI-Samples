import Foundation

class DataBindingResolver {
    static func resolveString(_ dynamicString: DynamicString?, dataModel: [String: Any]) -> String {
        if let literal = dynamicString?.literalString {
            return literal
        }

        if let path = dynamicString?.path {
            return resolvePath(path, dataModel) as? String ?? ""
        }

        return ""
    }

    static func resolveValue(_ dynamicValue: DynamicValue?, dataModel: [String: Any]) -> Any? {
        guard let dynamicValue = dynamicValue else { return nil }

        switch dynamicValue {
        case .string(let string):
            return resolveString(string, dataModel: dataModel)
        case .number(let number):
            if let literal = number.literalNumber {
                return literal
            }
            if let path = number.path {
                return resolvePath(path, dataModel)
            }
        case .boolean(let bool):
            if let literal = bool.literalBoolean {
                return literal
            }
            if let path = bool.path {
                return resolvePath(path, dataModel) as? Bool
            }
        case .stringList(let list):
            if let literal = list.literalStringList {
                return literal
            }
            if let path = list.path {
                return resolvePath(path, dataModel) as? [String]
            }
        }

        return nil
    }

    private static func resolvePath(_ path: String, _ dataModel: [String: Any]) -> Any? {
        // Simple JSON Pointer implementation
        var current: Any = dataModel
        let parts = path.split(separator: "/").filter { !$0.isEmpty }

        for part in parts {
            if let dict = current as? [String: Any] {
                current = dict[String(part)] ?? NSNull()
            } else if let array = current as? [Any], let index = Int(part), index < array.count {
                current = array[index]
            } else {
                return nil
            }
        }

        return current is NSNull ? nil : current
    }
}