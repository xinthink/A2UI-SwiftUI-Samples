// A2UI v0.9 Protocol Type Definitions
// Based on https://a2ui.org/specification/v0_9/

// ============================================================================
// MESSAGE TYPES
// ============================================================================

export interface A2UIMessage {
  version: string;
  createSurface?: CreateSurfaceMessage;
  updateComponents?: UpdateComponentsMessage;
  updateDataModel?: UpdateDataModelMessage;
  deleteSurface?: DeleteSurfaceMessage;
}

export interface CreateSurfaceMessage {
  surfaceId: string;
  catalogId: string;
  theme?: Record<string, any>;
  sendDataModel?: boolean;
}

export interface UpdateComponentsMessage {
  surfaceId: string;
  components: Component[];
}

export interface UpdateDataModelMessage {
  surfaceId: string;
  path?: string;
  value?: any;
}

export interface DeleteSurfaceMessage {
  surfaceId: string;
}

// ============================================================================
// COMPONENT TYPES
// ============================================================================

// Base component properties
interface ComponentBase {
  id: string;
  weight?: number;
  accessibility?: AccessibilityAttributes;
}

// Discriminator-based component type union
export type Component =
  // Layout Components
  | (ComponentBase & { component: "Row" } & RowProps)
  | (ComponentBase & { component: "Column" } & ColumnProps)
  | (ComponentBase & { component: "List" } & ListProps)
  // Display Components
  | (ComponentBase & { component: "Text" } & TextProps)
  | (ComponentBase & { component: "Image" } & ImageProps)
  | (ComponentBase & { component: "Icon" } & IconProps)
  | (ComponentBase & { component: "Video" } & VideoProps)
  | (ComponentBase & { component: "AudioPlayer" } & AudioPlayerProps)
  | (ComponentBase & { component: "Divider" } & DividerProps)
  // Interactive Components
  | (ComponentBase & { component: "Button" } & ButtonProps)
  | (ComponentBase & { component: "TextField" } & TextFieldProps)
  | (ComponentBase & { component: "CheckBox" } & CheckBoxProps)
  | (ComponentBase & { component: "ChoicePicker" } & ChoicePickerProps)
  | (ComponentBase & { component: "Slider" } & SliderProps)
  // Container Components
  | (ComponentBase & { component: "Card" } & CardProps)
  | (ComponentBase & { component: "Tabs" } & TabsProps)
  | (ComponentBase & { component: "Modal" } & ModalProps);

// ============================================================================
// COMPONENT PROPERTIES
// ============================================================================

// Layout Components
export interface RowProps {
  children: string[] | TemplateDefinition;
  justify?: "start" | "center" | "end" | "spaceBetween" | "spaceAround" | "spaceEvenly" | "stretch";
  align?: "start" | "center" | "end" | "stretch";
}

export interface ColumnProps {
  children: string[] | TemplateDefinition;
  justify?: "start" | "center" | "end" | "spaceBetween" | "spaceAround" | "spaceEvenly" | "stretch";
  align?: "start" | "center" | "end" | "stretch";
}

export interface ListProps {
  children: string[] | TemplateDefinition;
  direction?: "vertical" | "horizontal";
  align?: "start" | "center" | "end" | "stretch";
}

// Display Components
export interface TextProps {
  text: DynamicString;
  align?: "start" | "center" | "end";
  variant?: "h1" | "h2" | "h3" | "h4" | "h5" | "caption" | "body";
}

export interface ImageProps {
  url: DynamicString;
  fit?: "contain" | "cover" | "fill" | "none" | "scale-down";
  variant?: "icon" | "avatar" | "smallFeature" | "mediumFeature" | "largeFeature" | "header";
}

export interface IconProps {
  name: DynamicString;
}

export interface VideoProps {
  url: DynamicString;
}

export interface AudioPlayerProps {
  url: DynamicString;
  description?: DynamicString;
}

export interface DividerProps {
  axis?: "horizontal" | "vertical";
}

// Interactive Components
export interface ButtonProps {
  child: string;
  action: ActionDefinition;
  variant?: "primary" | "borderless";
  enabled?: DynamicBoolean;
  checks?: CheckRule[];
}

export interface TextFieldProps {
  label: DynamicString;
  value?: DynamicString;
  variant?: "shortText" | "longText" | "number" | "obscured";
  enabled?: DynamicBoolean;
  checks?: CheckRule[];
}

export interface CheckBoxProps {
  label: DynamicString;
  value: DynamicBoolean;
  enabled?: DynamicBoolean;
  checks?: CheckRule[];
}

export interface ChoicePickerProps {
  label: DynamicString;
  value?: DynamicStringList;
  variant?: "multipleSelection" | "mutuallyExclusive";
  options: ChoiceOption[];
  enabled?: DynamicBoolean;
  checks?: CheckRule[];
}

export interface ChoiceOption {
  label: DynamicString;
  value: string;
}

export interface SliderProps {
  value: DynamicNumber;
  min?: number;
  max?: number;
  step?: number;
  enabled?: DynamicBoolean;
}

// Container Components
export interface CardProps {
  content: string;
}

export interface TabsProps {
  tabs: TabItem[];
}

export interface TabItem {
  title: DynamicString;
  child: string;
}

export interface ModalProps {
  trigger: string;
  content: string;
}

// ============================================================================
// COMMON TYPES
// ============================================================================

export interface AccessibilityAttributes {
  label?: DynamicString;
  description?: DynamicString;
}

// Template definition for dynamic children
export interface TemplateDefinition {
  componentId: string;
  path: string;
}

// Dynamic value types
export type DynamicString = string | { path: string };
export type DynamicNumber = number | { path: string };
export type DynamicBoolean = boolean | { path: string } | LogicExpression;
export type DynamicStringList = string[] | { path: string };
export type DynamicValue = DynamicString | DynamicNumber | DynamicBoolean | DynamicStringList;

// Logic expression for conditional logic
export type LogicExpression =
  | { and: LogicExpression[] }
  | { or: LogicExpression[] }
  | { not: LogicExpression }
  | FunctionCall
  | { true: true }
  | { false: false };

// Function call
export interface FunctionCall {
  call: string;
  args?: Record<string, DynamicValue | object>;
  returnType?: "string" | "number" | "boolean" | "array" | "object" | "any" | "void";
}

// Check rule for validation
export type CheckRule = LogicExpression & { message: string };

// Action definition
export interface ActionDefinition {
  event: {
    name: string;
    context?: Record<string, DynamicValue>;
  } | {
    functionCall: FunctionCall;
  };
}

// ============================================================================
// CLIENT TO SERVER TYPES
// ============================================================================

export interface ClientAction {
  version: string;
  action: {
    surfaceId: string;
    event: {
      name: string;
      context?: Record<string, any>;
    };
  };
}

export interface ClientError {
  version: string;
  error: {
    code: "VALIDATION_FAILED";
    surfaceId: string;
    path: string;
    message: string;
  };
}
