// Components.swift
// A2UICore
//
// All standard catalog component definitions
//

import Foundation

// MARK: - Component

/// All component types in the standard catalog
public enum Component: Codable, Sendable, Equatable {
    case row(RowProperties)
    case column(ColumnProperties)
    case text(TextProperties)
    case image(ImageProperties)
    case icon(IconProperties)
    case divider(DividerProperties)
    case button(ButtonProperties)
    case textField(TextFieldProperties)
    case checkbox(CheckboxProperties)
    case card(CardProperties)
    case modal(ModalProperties)
    case tabs(TabsProperties)
    case list(ListProperties)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try each component type in order
        if let properties = try? container.decode(RowProperties.self, forKey: .row) {
            self = .row(properties)
        } else if let properties = try? container.decode(ColumnProperties.self, forKey: .column) {
            self = .column(properties)
        } else if let properties = try? container.decode(TextProperties.self, forKey: .text) {
            self = .text(properties)
        } else if let properties = try? container.decode(ImageProperties.self, forKey: .image) {
            self = .image(properties)
        } else if let properties = try? container.decode(IconProperties.self, forKey: .icon) {
            self = .icon(properties)
        } else if let properties = try? container.decode(DividerProperties.self, forKey: .divider) {
            self = .divider(properties)
        } else if let properties = try? container.decode(ButtonProperties.self, forKey: .button) {
            self = .button(properties)
        } else if let properties = try? container.decode(TextFieldProperties.self, forKey: .textField) {
            self = .textField(properties)
        } else if let properties = try? container.decode(CheckboxProperties.self, forKey: .checkbox) {
            self = .checkbox(properties)
        } else if let properties = try? container.decode(CardProperties.self, forKey: .card) {
            self = .card(properties)
        } else if let properties = try? container.decode(ModalProperties.self, forKey: .modal) {
            self = .modal(properties)
        } else if let properties = try? container.decode(TabsProperties.self, forKey: .tabs) {
            self = .tabs(properties)
        } else if let properties = try? container.decode(ListProperties.self, forKey: .list) {
            self = .list(properties)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .row,
                in: container,
                debugDescription: "Unknown component type"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .row(let properties):
            try container.encode(properties, forKey: .row)
        case .column(let properties):
            try container.encode(properties, forKey: .column)
        case .text(let properties):
            try container.encode(properties, forKey: .text)
        case .image(let properties):
            try container.encode(properties, forKey: .image)
        case .icon(let properties):
            try container.encode(properties, forKey: .icon)
        case .divider(let properties):
            try container.encode(properties, forKey: .divider)
        case .button(let properties):
            try container.encode(properties, forKey: .button)
        case .textField(let properties):
            try container.encode(properties, forKey: .textField)
        case .checkbox(let properties):
            try container.encode(properties, forKey: .checkbox)
        case .card(let properties):
            try container.encode(properties, forKey: .card)
        case .modal(let properties):
            try container.encode(properties, forKey: .modal)
        case .tabs(let properties):
            try container.encode(properties, forKey: .tabs)
        case .list(let properties):
            try container.encode(properties, forKey: .list)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case row = "Row"
        case column = "Column"
        case text = "Text"
        case image = "Image"
        case icon = "Icon"
        case divider = "Divider"
        case button = "Button"
        case textField = "TextField"
        case checkbox = "Checkbox"
        case card = "Card"
        case modal = "Modal"
        case tabs = "Tabs"
        case list = "List"
    }
}

// MARK: - Layout Components

public struct RowProperties: Codable, Sendable, Equatable {
    public let children: ChildList
    public let distribution: String?  // start, center, end, spaceBetween, spaceAround, spaceEvenly
    public let alignment: String?     // start, center, end, stretch

    public init(children: ChildList, distribution: String? = nil, alignment: String? = nil) {
        self.children = children
        self.distribution = distribution
        self.alignment = alignment
    }
}

public struct ColumnProperties: Codable, Sendable, Equatable {
    public let children: ChildList
    public let distribution: String?  // start, center, end, spaceBetween, spaceAround, spaceEvenly
    public let alignment: String?     // start, center, end, stretch

    public init(children: ChildList, distribution: String? = nil, alignment: String? = nil) {
        self.children = children
        self.distribution = distribution
        self.alignment = alignment
    }
}

// MARK: - Display Components

public struct TextProperties: Codable, Sendable, Equatable {
    public let text: DynamicString
    public let alignment: String?     // start, center, end

    public init(text: DynamicString, alignment: String? = nil) {
        self.text = text
        self.alignment = alignment
    }
}

public struct ImageProperties: Codable, Sendable, Equatable {
    public let url: DynamicString

    public init(url: DynamicString) {
        self.url = url
    }
}

public struct IconProperties: Codable, Sendable, Equatable {
    public let name: DynamicString

    public init(name: DynamicString) {
        self.name = name
    }
}

public struct DividerProperties: Codable, Sendable, Equatable {
    public let axis: String?  // horizontal, vertical

    public init(axis: String? = nil) {
        self.axis = axis
    }
}

// MARK: - Interactive Components

public struct ActionDefinition: Codable, Sendable, Equatable {
    public let name: String
    public let context: [String: DynamicString]?  // Action-specific data binding

    public init(name: String, context: [String: DynamicString]? = nil) {
        self.name = name
        self.context = context
    }
}

public struct ButtonProperties: Codable, Sendable, Equatable {
    public let child: String              // ID of child component
    public let primary: Bool?
    public let action: ActionDefinition

    public init(child: String, primary: Bool? = nil, action: ActionDefinition) {
        self.child = child
        self.primary = primary
        self.action = action
    }
}

public struct TextFieldProperties: Codable, Sendable, Equatable {
    public let label: DynamicString
    public let text: DynamicString?       // Data binding path for value
    public let textFieldType: String?     // shortText, longText, date, number, obscured

    public init(label: DynamicString, text: DynamicString? = nil, textFieldType: String? = nil) {
        self.label = label
        self.text = text
        self.textFieldType = textFieldType
    }
}

public struct CheckboxProperties: Codable, Sendable, Equatable {
    public let label: DynamicString
    public let value: DynamicBoolean?     // Data binding path for boolean value

    public init(label: DynamicString, value: DynamicBoolean? = nil) {
        self.label = label
        self.value = value
    }
}

// MARK: - Container Components

public struct CardProperties: Codable, Sendable, Equatable {
    public let child: String

    public init(child: String) {
        self.child = child
    }

    private enum CodingKeys: String, CodingKey {
        case child = "contentChild"
    }
}

public struct ModalProperties: Codable, Sendable, Equatable {
    public let entryPointChild: String
    public let contentChild: String

    public init(entryPointChild: String, contentChild: String) {
        self.entryPointChild = entryPointChild
        self.contentChild = contentChild
    }
}

public struct TabItem: Codable, Sendable, Equatable {
    public let title: DynamicString
    public let child: String

    public init(title: DynamicString, child: String) {
        self.title = title
        self.child = child
    }
}

public struct TabsProperties: Codable, Sendable, Equatable {
    public let tabItems: [TabItem]

    public init(tabItems: [TabItem]) {
        self.tabItems = tabItems
    }
}

public struct ListProperties: Codable, Sendable, Equatable {
    public let children: ChildList

    public init(children: ChildList) {
        self.children = children
    }
}
