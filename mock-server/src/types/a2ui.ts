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

export interface Component {
  id: string;
  component: string;
  weight?: number;
  children?: ChildList;
  text?: DynamicString;
  label?: DynamicString;
  value?: DynamicValue;
  variant?: string;
  action?: Action;
  url?: DynamicString;
  name?: DynamicString;
  alignment?: string;
  distribution?: string;
  child?: string;
  contentChild?: string;
  header?: string;
  footer?: string;
}

export interface ChildList {
  explicitList?: string[];
  template?: {
    componentId: string;
    dataBinding: DynamicValue;
  };
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

export interface Action {
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