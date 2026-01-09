export interface A2UIMessage {
  createSurface?: CreateSurfaceMessage;
  updateComponents?: UpdateComponentsMessage;
  updateDataModel?: UpdateDataModelMessage;
  deleteSurface?: DeleteSurfaceMessage;
}

export interface CreateSurfaceMessage {
  surfaceId: string;
  catalogId?: string;
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

// Component-specific property interfaces
export interface ColumnProps {
  children: ChildList;
  alignment?: string;
  distribution?: string;
}

export interface RowProps {
  children: ChildList;
  alignment?: string;
  distribution?: string;
}

export interface TextProps {
  text: DynamicString;
  alignment?: string;
  usageHint?: string;
}

export interface TextFieldProps {
  label?: DynamicString;
  text?: DynamicString;
  textFieldType?: string;
}

export interface ButtonProps {
  child: string;
  action?: ActionDefinition;
  primary?: boolean;
}

export interface ImageProps {
  url: DynamicString;
  alt?: DynamicString;
  width?: number;
  height?: number;
}

export interface IconProps {
  name: DynamicString;
  size?: number;
}

export interface DividerProps {
  axis?: string;
}

export interface CardProps {
  child: string;
  header?: string;
  footer?: string;
}

export interface ListProps {
  children: ChildList;
}

export interface CheckboxProps {
  label: DynamicString;
  value: DynamicValue;
}

export interface ModalProps {
  entryPointChild: string;
  contentChild: string;
}

export interface TabsProps {
  tabItems: Array<{
    title: DynamicString;
    child: string;
  }>;
}

// Union type for all component definitions
export type ComponentDefinition =
  | { Column: ColumnProps }
  | { Row: RowProps }
  | { Text: TextProps }
  | { TextField: TextFieldProps }
  | { Button: ButtonProps }
  | { Image: ImageProps }
  | { Icon: IconProps }
  | { Divider: DividerProps }
  | { Card: CardProps }
  | { List: ListProps }
  | { Checkbox: CheckboxProps }
  | { Modal: ModalProps }
  | { Tabs: TabsProps };

// Main Component interface
// Supports both formats:
// 1. Simple string: "component": "Column"
// 2. Nested object: "component": { "Column": {...} }
export interface Component {
  id: string;
  weight?: number;
  component: string | ComponentDefinition;

  // Legacy properties for simple string format (backward compatibility)
  children?: ChildList;
  alignment?: string;
  distribution?: string;
  text?: DynamicString;
  label?: DynamicString;
  value?: DynamicValue;
  textFieldType?: string;
  child?: string;
  action?: ActionDefinition;
  url?: DynamicString;
  name?: DynamicString;
  contentChild?: string;
  header?: string;
  footer?: string;
  usageHint?: string;
  primary?: boolean;
  alt?: DynamicString;
  width?: number;
  height?: number;
  size?: number;
  axis?: string;
  entryPointChild?: string;
  tabItems?: Array<{
    title: DynamicString;
    child: string;
  }>;
}

// ChildList can be in multiple formats:
// 1. Simple array: ["child1", "child2"]
// 2. Wrapped array: { "explicitList": ["child1", "child2"] }
// 3. Template object: { "template": { componentId: "...", dataBinding: "..." } }
export type ChildList =
  | string[]
  | { explicitList: string[] }
  | { template: TemplateDefinition };

export interface TemplateDefinition {
  componentId: string;
  dataBinding: DynamicValue | string;
}

export type DynamicValue = DynamicString | DynamicNumber | DynamicBoolean | DynamicStringList;

export interface DynamicString {
  literalString?: string;
  path?: string;
}

export interface DynamicNumber {
  literalNumber?: number;
  path?: string;
}

export interface DynamicBoolean {
  literalBoolean?: boolean;
  path?: string;
}

export interface DynamicStringList {
  literalStringList?: string[];
  path?: string;
}

export interface ActionDefinition {
  name: string;
  context?: Record<string, DynamicValue | undefined>;
}

export interface UserAction {
  action: string;
  surfaceId: string;
  context?: Record<string, any>;
}

export interface DataModel {
  [key: string]: any;
}
