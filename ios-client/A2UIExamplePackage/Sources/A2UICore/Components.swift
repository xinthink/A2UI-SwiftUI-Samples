// Components.swift
// A2UICore
//
// A2UI v0.9 component definitions
//

import Foundation

// MARK: - Component

/// All component types in the standard catalog (v0.9 discriminator-based)
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

    // v0.9 discriminator-based decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the discriminator first
        let componentType = try container.decode(String.self, forKey: .component)

        // Now decode the properties based on the component type
        switch componentType {
        case "Row":
            self = .row(try RowProperties(from: decoder))
        case "Column":
            self = .column(try ColumnProperties(from: decoder))
        case "Text":
            self = .text(try TextProperties(from: decoder))
        case "Image":
            self = .image(try ImageProperties(from: decoder))
        case "Icon":
            self = .icon(try IconProperties(from: decoder))
        case "Divider":
            self = .divider(try DividerProperties(from: decoder))
        case "Button":
            self = .button(try ButtonProperties(from: decoder))
        case "TextField":
            self = .textField(try TextFieldProperties(from: decoder))
        case "CheckBox":
            self = .checkbox(try CheckboxProperties(from: decoder))
        case "Card":
            self = .card(try CardProperties(from: decoder))
        case "Modal":
            self = .modal(try ModalProperties(from: decoder))
        case "Tabs":
            self = .tabs(try TabsProperties(from: decoder))
        case "List":
            self = .list(try ListProperties(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .component,
                in: container,
                debugDescription: "Unknown component type: \(componentType)"
            )
        }
    }

    // Coding keys for Component enum encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case component
        case id
        case children
        case justify
        case align
        case weight
        case accessibility
        case text
        case variant
        case url
        case fit
        case name
        case axis
        case child
        case action
        case enabled
        case label
        case value
        case content
        case trigger
        case tabs
        case direction
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .row(let properties):
            try container.encode("Row", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.children, forKey: .children)
            try container.encodeIfPresent(properties.justify, forKey: .justify)
            try container.encodeIfPresent(properties.align, forKey: .align)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .column(let properties):
            try container.encode("Column", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.children, forKey: .children)
            try container.encodeIfPresent(properties.justify, forKey: .justify)
            try container.encodeIfPresent(properties.align, forKey: .align)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .text(let properties):
            try container.encode("Text", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.text, forKey: .text)
            try container.encodeIfPresent(properties.align, forKey: .align)
            try container.encodeIfPresent(properties.variant, forKey: .variant)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .image(let properties):
            try container.encode("Image", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.url, forKey: .url)
            try container.encodeIfPresent(properties.fit, forKey: .fit)
            try container.encodeIfPresent(properties.variant, forKey: .variant)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .icon(let properties):
            try container.encode("Icon", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.name, forKey: .name)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .divider(let properties):
            try container.encode("Divider", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encodeIfPresent(properties.axis, forKey: .axis)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .button(let properties):
            try container.encode("Button", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.child, forKey: .child)
            try container.encode(properties.action, forKey: .action)
            try container.encodeIfPresent(properties.variant, forKey: .variant)
            try container.encodeIfPresent(properties.enabled, forKey: .enabled)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .textField(let properties):
            try container.encode("TextField", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.label, forKey: .label)
            try container.encodeIfPresent(properties.value, forKey: .value)
            try container.encodeIfPresent(properties.variant, forKey: .variant)
            try container.encodeIfPresent(properties.enabled, forKey: .enabled)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .checkbox(let properties):
            try container.encode("CheckBox", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.label, forKey: .label)
            try container.encodeIfPresent(properties.value, forKey: .value)
            try container.encodeIfPresent(properties.enabled, forKey: .enabled)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .card(let properties):
            try container.encode("Card", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.content, forKey: .content)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .modal(let properties):
            try container.encode("Modal", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.trigger, forKey: .trigger)
            try container.encode(properties.content, forKey: .content)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .tabs(let properties):
            try container.encode("Tabs", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.tabs, forKey: .tabs)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        case .list(let properties):
            try container.encode("List", forKey: .component)
            try container.encode(properties.id, forKey: .id)
            try container.encode(properties.children, forKey: .children)
            try container.encodeIfPresent(properties.direction, forKey: .direction)
            try container.encodeIfPresent(properties.align, forKey: .align)
            try container.encodeIfPresent(properties.weight, forKey: .weight)
            try container.encodeIfPresent(properties.accessibility, forKey: .accessibility)
        }
    }
}

// MARK: - Layout Components

public struct RowProperties: Codable, Sendable, Equatable {
    public let id: String
    public let children: ChildList
    public let justify: String?
    public let align: String?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, children: ChildList, justify: String? = nil, align: String? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.children = children
        self.justify = justify
        self.align = align
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct ColumnProperties: Codable, Sendable, Equatable {
    public let id: String
    public let children: ChildList
    public let justify: String?
    public let align: String?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, children: ChildList, justify: String? = nil, align: String? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.children = children
        self.justify = justify
        self.align = align
        self.weight = weight
        self.accessibility = accessibility
    }
}

// MARK: - Display Components

public struct TextProperties: Codable, Sendable, Equatable {
    public let id: String
    public let text: DynamicString
    public let align: String?
    public let variant: String?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, text: DynamicString, align: String? = nil, variant: String? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.text = text
        self.align = align
        self.variant = variant
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct ImageProperties: Codable, Sendable, Equatable {
    public let id: String
    public let url: DynamicString
    public let fit: String?
    public let variant: String?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, url: DynamicString, fit: String? = nil, variant: String? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.url = url
        self.fit = fit
        self.variant = variant
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct IconProperties: Codable, Sendable, Equatable {
    public let id: String
    public let name: DynamicString
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, name: DynamicString, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.name = name
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct DividerProperties: Codable, Sendable, Equatable {
    public let id: String
    public let axis: String?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, axis: String? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.axis = axis
        self.weight = weight
        self.accessibility = accessibility
    }
}

// MARK: - Interactive Components

public struct ActionDefinition: Codable, Sendable, Equatable {
    public let event: EventDefinition?

    public init(event: EventDefinition?) {
        self.event = event
    }
}

public struct EventDefinition: Codable, Sendable, Equatable {
    public let name: String
    public let context: [String: DynamicString]?

    public init(name: String, context: [String: DynamicString]? = nil) {
        self.name = name
        self.context = context
    }
}

public struct ButtonProperties: Codable, Sendable, Equatable {
    public let id: String
    public let child: String
    public let variant: String?
    public let action: ActionDefinition
    public let enabled: DynamicBoolean?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, child: String, variant: String? = nil, action: ActionDefinition, enabled: DynamicBoolean? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.child = child
        self.variant = variant
        self.action = action
        self.enabled = enabled
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct TextFieldProperties: Codable, Sendable, Equatable {
    public let id: String
    public let label: DynamicString
    public let value: DynamicString?
    public let variant: String?
    public let enabled: DynamicBoolean?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, label: DynamicString, value: DynamicString? = nil, variant: String? = nil, enabled: DynamicBoolean? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.label = label
        self.value = value
        self.variant = variant
        self.enabled = enabled
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct CheckboxProperties: Codable, Sendable, Equatable {
    public let id: String
    public let label: DynamicString
    public let value: DynamicBoolean?
    public let enabled: DynamicBoolean?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, label: DynamicString, value: DynamicBoolean? = nil, enabled: DynamicBoolean? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.label = label
        self.value = value
        self.enabled = enabled
        self.weight = weight
        self.accessibility = accessibility
    }
}

// MARK: - Container Components

public struct CardProperties: Codable, Sendable, Equatable {
    public let id: String
    public let content: String
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, content: String, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.content = content
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct ModalProperties: Codable, Sendable, Equatable {
    public let id: String
    public let trigger: String
    public let content: String
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, trigger: String, content: String, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.trigger = trigger
        self.content = content
        self.weight = weight
        self.accessibility = accessibility
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
    public let id: String
    public let tabs: [TabItem]
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, tabs: [TabItem], weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.tabs = tabs
        self.weight = weight
        self.accessibility = accessibility
    }
}

public struct ListProperties: Codable, Sendable, Equatable {
    public let id: String
    public let children: ChildList
    public let direction: String?
    public let align: String?
    public let weight: Double?
    public let accessibility: AccessibilityAttributes?

    public init(id: String, children: ChildList, direction: String? = nil, align: String? = nil, weight: Double? = nil, accessibility: AccessibilityAttributes? = nil) {
        self.id = id
        self.children = children
        self.direction = direction
        self.align = align
        self.weight = weight
        self.accessibility = accessibility
    }
}

// MARK: - Accessibility

public struct AccessibilityAttributes: Codable, Sendable, Equatable {
    public let label: DynamicString?
    public let description: DynamicString?

    public init(label: DynamicString? = nil, description: DynamicString? = nil) {
        self.label = label
        self.description = description
    }
}

