// validate.ts
// A2UI Mock Server
//
// A2UI v0.9 payload validation utilities
//

/**
 * Validation result interface
 */
export interface ValidationResult {
  valid: boolean;
  errors?: string[];
}

/**
 * Checks if a value is a valid v0.9 component (discriminator-based)
 */
function isValidV09Component(obj: any): boolean {
  if (!obj || typeof obj !== 'object') return false;

  // Must have 'component' discriminator
  if (typeof obj.component !== 'string') return false;

  // Must have 'id' property
  if (!obj.id || typeof obj.id !== 'string') return false;

  return true;
}

/**
 * Checks if a value uses v0.9 DynamicString format (string or {path: string})
 */
function isValidV09DynamicString(obj: any): boolean {
  if (typeof obj === 'string') return true;
  if (obj && typeof obj === 'object' && typeof obj.path === 'string') return true;
  return false;
}

/**
 * Checks if a value is using a deprecated v0.8 property
 */
function hasDeprecatedProperties(obj: any, deprecatedProps: string[]): boolean {
  if (!obj || typeof obj !== 'object') return false;
  return deprecatedProps.some(prop => prop in obj);
}

/**
 * Validates an A2UI message against v0.9 requirements
 */
export function validateA2UIMessage(message: any): ValidationResult {
  const errors: string[] = [];

  if (!message || typeof message !== 'object') {
    return { valid: false, errors: ['Message must be an object'] };
  }

  // Check for version field
  if (message.version !== 'v0.9') {
    errors.push('Missing or invalid "version" field (must be "v0.9")');
  }

  // Check message type
  if (!message.createSurface && !message.updateComponents && !message.updateDataModel && !message.deleteSurface) {
    errors.push('Message must contain one of: createSurface, updateComponents, updateDataModel, deleteSurface');
  }

  // Validate createSurface message
  if (message.createSurface) {
    const surface = message.createSurface;
    if (!surface.surfaceId || typeof surface.surfaceId !== 'string') {
      errors.push('createSurface must have a valid surfaceId');
    }
    if (!surface.catalogId || typeof surface.catalogId !== 'string') {
      errors.push('createSurface must have a valid catalogId');
    }
  }

  // Validate updateComponents message
  if (message.updateComponents) {
    const update = message.updateComponents;
    if (!update.surfaceId || typeof update.surfaceId !== 'string') {
      errors.push('updateComponents must have a valid surfaceId');
    }
    if (!Array.isArray(update.components)) {
      errors.push('updateComponents must have a components array');
    } else {
      update.components.forEach((comp: any, idx: number) => {
        if (!isValidV09Component(comp)) {
          errors.push(`Component at index ${idx}: Invalid v0.9 component structure (missing "component" discriminator or "id")`);
        } else {
          // Check for deprecated properties
          if (comp.component === 'Row' || comp.component === 'Column' || comp.component === 'List') {
            if (comp.distribution !== undefined) {
              errors.push(`Component ${comp.id}: "distribution" is deprecated, use "justify"`);
            }
            if (comp.alignment !== undefined) {
              errors.push(`Component ${comp.id}: "alignment" is deprecated, use "align"`);
            }
          }
          if (comp.component === 'Text') {
            if (comp.alignment !== undefined) {
              errors.push(`Component ${comp.id}: "alignment" is deprecated, use "align"`);
            }
            if (comp.usageHint !== undefined) {
              errors.push(`Component ${comp.id}: "usageHint" is deprecated, use "variant"`);
            }
          }
          if (comp.component === 'TextField') {
            if (comp.text !== undefined) {
              errors.push(`Component ${comp.id}: "text" is deprecated, use "value"`);
            }
            if (comp.textFieldType !== undefined) {
              errors.push(`Component ${comp.id}: "textFieldType" is deprecated, use "variant"`);
            }
          }
          if (comp.component === 'Button') {
            if (comp.primary !== undefined) {
              errors.push(`Component ${comp.id}: "primary" is deprecated, use "variant"`);
            }
          }
          if (comp.component === 'Card' || comp.component === 'Modal') {
            if (comp.contentChild !== undefined) {
              errors.push(`Component ${comp.id}: "contentChild" is deprecated, use "content"`);
            }
          }
          if (comp.component === 'Modal') {
            if (comp.entryPointChild !== undefined) {
              errors.push(`Component ${comp.id}: "entryPointChild" is deprecated, use "trigger"`);
            }
          }
          if (comp.component === 'Tabs') {
            if (comp.tabItems !== undefined) {
              errors.push(`Component ${comp.id}: "tabItems" is deprecated, use "tabs"`);
            }
          }
        }
      });
    }
  }

  // Validate updateDataModel message
  if (message.updateDataModel) {
    const update = message.updateDataModel;
    if (!update.surfaceId || typeof update.surfaceId !== 'string') {
      errors.push('updateDataModel must have a valid surfaceId');
    }
  }

  return {
    valid: errors.length === 0,
    errors: errors.length > 0 ? errors : undefined
  };
}

/**
 * Validates a component against v0.9 requirements
 */
export function validateA2UIComponent(component: any): ValidationResult {
  const errors: string[] = [];

  if (!isValidV09Component(component)) {
    return { valid: false, errors: ['Invalid v0.9 component structure'] };
  }

  return { valid: true };
}

/**
 * Validates an array of A2UI messages
 */
export function validateA2UIMessages(messages: any[]): ValidationResult {
  const errorsByIndex = new Map<number, string[]>();

  messages.forEach((message, index) => {
    const result = validateA2UIMessage(message);
    if (!result.valid && result.errors) {
      errorsByIndex.set(index, result.errors);
    }
  });

  return {
    valid: errorsByIndex.size === 0,
    errors: Array.from(errorsByIndex.entries()).flatMap(([idx, errs]) =>
      errs.map(err => `Message ${idx}: ${err}`)
    )
  };
}

/**
 * Validates a payload file against v0.9 requirements
 */
export function validatePayload(payload: any[], payloadName?: string): ValidationResult {
  const result = validateA2UIMessages(payload);

  if (result.valid) {
    return {
      valid: true,
      errors: undefined
    };
  }

  return {
    valid: false,
    errors: result.errors
  };
}
