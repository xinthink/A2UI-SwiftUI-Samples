import Foundation

// MARK: - A2UI Message Types

struct A2UIMessage: Codable {
    let createSurface: CreateSurfaceMessage?
    let updateComponents: UpdateComponentsMessage?
    let updateDataModel: UpdateDataModelMessage?
    let deleteSurface: DeleteSurfaceMessage?
}

struct CreateSurfaceMessage: Codable {
    let surfaceId: String
    let catalogId: String?
}

struct UpdateComponentsMessage: Codable {
    let surfaceId: String
    let components: [Component]
}

struct UpdateDataModelMessage: Codable {
    let surfaceId: String
    let path: String?
    let value: AnyCodable?
}

struct DeleteSurfaceMessage: Codable {
    let surfaceId: String
}

// MARK: - Component Model

struct Component: Codable, Identifiable {
    let id: String
    let component: String
    let weight: Double?
    let children: ChildList?
    let text: DynamicString?
    let label: DynamicString?
    let value: DynamicValue?
    let variant: String?
    let action: Action?
    let url: DynamicString?
    let name: DynamicString?
    let alignment: String?
    let distribution: String?
    let child: String?
    let contentChild: String?
    let header: String?
    let footer: String?
}

struct ChildList: Codable {
    let explicitList: [String]?
    let template: Template?

    struct Template: Codable {
        let componentId: String
        let dataBinding: DynamicValue
    }
}

// MARK: - Dynamic Values

enum DynamicValue: Codable {
    case string(DynamicString)
    case number(DynamicNumber)
    case boolean(DynamicBoolean)
    case stringList(DynamicStringList)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(DynamicString.self) {
            self = .string(string)
        } else if let number = try? container.decode(DynamicNumber.self) {
            self = .number(number)
        } else if let bool = try? container.decode(DynamicBoolean.self) {
            self = .boolean(bool)
        } else if let list = try? container.decode(DynamicStringList.self) {
            self = .stringList(list)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid DynamicValue")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .stringList(let value):
            try container.encode(value)
        }
    }
}

struct DynamicString: Codable {
    let literalString: String?
    let path: String?
}

struct DynamicNumber: Codable {
    let literalNumber: Double?
    let path: String?
}

struct DynamicBoolean: Codable {
    let literalBoolean: Bool?
    let path: String?
}

struct DynamicStringList: Codable {
    let literalStringList: [String]?
    let path: String?
}

// MARK: - Action

struct Action: Codable {
    let name: String
    let context: [String: DynamicValue]?
}

// MARK: - User Action

struct UserAction: Codable {
    let action: String
    let surfaceId: String
    let context: [String: AnyCodable]?
}

// MARK: - Surface State

class SurfaceState: ObservableObject {
    @Published var components: [String: Component] = [:]
    @Published var dataModel: [String: Any] = [:]
    let surfaceId: String

    init(surfaceId: String) {
        self.surfaceId = surfaceId
    }
}

// MARK: - AnyCodable for flexible JSON values

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}