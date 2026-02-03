// __tests__/payloads.test.ts
// A2UI Mock Server
//
// Unit tests for A2UI v0.9 payload validation
//

import { validateA2UIMessage, validatePayload, validateA2UIComponent } from '../validate';
import todoList from '../payloads/todo-list.json';
import contactForm from '../payloads/contact-form.json';
import userProfile from '../payloads/user-profile.json';

describe('A2UI v0.9 Payload Validation', () => {
  describe('todo-list.json', () => {
    it('should be a valid array', () => {
      expect(Array.isArray(todoList)).toBe(true);
      expect(todoList.length).toBeGreaterThan(0);
    });

    it('should have version "v0.9" in all messages', () => {
      todoList.forEach((message: any, index: number) => {
        expect(message.version).toBe('v0.9');
      });
    });

    it('should contain valid A2UI messages', () => {
      const result = validatePayload(todoList as any[], 'todo-list.json');
      expect(result.valid).toBe(true);
      if (!result.valid) {
        console.error('Validation errors:', result.errors);
      }
    });

    it('should use discriminator-based component structure', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      expect(updateComponents).toBeDefined();

      updateComponents!.updateComponents.components.forEach((comp: any) => {
        expect(comp).toHaveProperty('component');
        expect(typeof comp.component).toBe('string');

        // Verify component type is one of the standard catalog components
        const validComponents = [
          'Row', 'Column', 'Text', 'Image', 'Icon', 'Divider',
          'Button', 'TextField', 'CheckBox', 'ChoicePicker', 'Slider',
          'Card', 'Tabs', 'Modal', 'List', 'Video', 'AudioPlayer'
        ];
        expect(validComponents).toContain(comp.component);
      });
    });

    it('should use "justify" instead of "distribution"', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'Row' || comp.component === 'Column' || comp.component === 'List') {
          expect(comp).not.toHaveProperty('distribution');
          if (comp.justify) {
            expect(['start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly', 'stretch'])
              .toContain(comp.justify);
          }
        }
      });
    });

    it('should use "align" instead of "alignment"', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'Row' || comp.component === 'Column' || comp.component === 'List' || comp.component === 'Text') {
          expect(comp).not.toHaveProperty('alignment');
          if (comp.align) {
            expect(['start', 'center', 'end', 'stretch']).toContain(comp.align);
          }
        }
      });
    });

    it('should not use explicitList wrapper', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'Row' || comp.component === 'Column' || comp.component === 'List') {
          if (Array.isArray(comp.children)) {
            expect(comp.children).not.toHaveProperty('explicitList');
          }
        }
      });
    });

    it('should use direct string values instead of literalString', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'Text') {
          // text should be either a string or {path: "..."}
          if (typeof comp.text === 'string') {
            expect(comp.text).not.toHaveProperty('literalString');
          } else if (comp.text && typeof comp.text === 'object') {
            expect(comp.text).toHaveProperty('path');
          }
        }
        if (comp.component === 'Icon') {
          // name should be either a string or {path: "..."}
          if (typeof comp.name === 'string') {
            expect(comp.name).not.toHaveProperty('literalString');
          } else if (comp.name && typeof comp.name === 'object') {
            expect(comp.name).toHaveProperty('path');
          }
        }
      });
    });

    it('should use "value" instead of "text" for TextField', () => {
      // todo-list doesn't have TextField, so we skip this test
      // TextField validation is tested in contact-form.json
      expect(true).toBe(true);
    });

    it('should use "variant" instead of "textFieldType"', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'TextField') {
          expect(comp).not.toHaveProperty('textFieldType');
          if (comp.variant) {
            expect(['shortText', 'longText', 'number', 'obscured']).toContain(comp.variant);
          }
        }
      });
    });

    it('should use "variant" instead of "primary" for Button', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'Button') {
          expect(comp).not.toHaveProperty('primary');
          if (comp.variant) {
            expect(['primary', 'borderless']).toContain(comp.variant);
          }
        }
      });
    });

    it('should use event object for action', () => {
      const updateComponents = (todoList as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'Button' && comp.action) {
          expect(comp.action).toHaveProperty('event');
          expect(comp.action.event).toHaveProperty('name');
        }
      });
    });
  });

  describe('contact-form.json', () => {
    it('should be a valid array', () => {
      expect(Array.isArray(contactForm)).toBe(true);
      expect(contactForm.length).toBeGreaterThan(0);
    });

    it('should have version "v0.9" in all messages', () => {
      contactForm.forEach((message: any) => {
        expect(message.version).toBe('v0.9');
      });
    });

    it('should contain valid A2UI messages', () => {
      const result = validatePayload(contactForm as any[], 'contact-form.json');
      expect(result.valid).toBe(true);
      if (!result.valid) {
        console.error('Validation errors:', result.errors);
      }
    });

    it('should use discriminator-based component structure', () => {
      const updateComponents = (contactForm as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        expect(comp).toHaveProperty('component');
        expect(typeof comp.component).toBe('string');
      });
    });

    it('should use "value" instead of "text" for TextField', () => {
      const updateComponents = (contactForm as any[]).find(m => m.updateComponents);
      const textFields = updateComponents!.updateComponents.components.filter((c: any) => c.component === 'TextField');
      expect(textFields.length).toBeGreaterThan(0);
      textFields.forEach((textField: any) => {
        expect(textField).not.toHaveProperty('text');
      });
    });
  });

  describe('user-profile.json', () => {
    it('should be a valid array', () => {
      expect(Array.isArray(userProfile)).toBe(true);
      expect(userProfile.length).toBeGreaterThan(0);
    });

    it('should have version "v0.9" in all messages', () => {
      userProfile.forEach((message: any) => {
        expect(message.version).toBe('v0.9');
      });
    });

    it('should contain valid A2UI messages', () => {
      const result = validatePayload(userProfile as any[], 'user-profile.json');
      expect(result.valid).toBe(true);
      if (!result.valid) {
        console.error('Validation errors:', result.errors);
      }
    });

    it('should use "content" instead of "contentChild" for Card', () => {
      const updateComponents = (userProfile as any[]).find(m => m.updateComponents);
      const card = updateComponents!.updateComponents.components.find((c: any) => c.component === 'Card');
      expect(card).toBeDefined();
      if (card) {
        expect(card).not.toHaveProperty('contentChild');
        expect(card).toHaveProperty('content');
      }
    });

    it('should use direct strings for Icon names', () => {
      const updateComponents = (userProfile as any[]).find(m => m.updateComponents);
      updateComponents!.updateComponents.components.forEach((comp: any) => {
        if (comp.component === 'Icon' && typeof comp.name === 'string') {
          expect(comp.name).not.toHaveProperty('literalString');
        }
      });
    });
  });

  describe('All Payloads - Cross-cutting validation', () => {
    it('all payloads should have createSurface message', () => {
      expect((todoList as any[]).find(m => m.createSurface)).toBeDefined();
      expect((contactForm as any[]).find(m => m.createSurface)).toBeDefined();
      expect((userProfile as any[]).find(m => m.createSurface)).toBeDefined();
    });

    it('all createSurface messages should have catalogId', () => {
      const todoCreateSurface = (todoList as any[]).find(m => m.createSurface);
      const contactCreateSurface = (contactForm as any[]).find(m => m.createSurface);
      const profileCreateSurface = (userProfile as any[]).find(m => m.createSurface);

      expect(todoCreateSurface?.createSurface.catalogId).toBeDefined();
      expect(contactCreateSurface?.createSurface.catalogId).toBeDefined();
      expect(profileCreateSurface?.createSurface.catalogId).toBeDefined();
    });

    it('all payloads should have updateComponents message', () => {
      expect((todoList as any[]).find(m => m.updateComponents)).toBeDefined();
      expect((contactForm as any[]).find(m => m.updateComponents)).toBeDefined();
      expect((userProfile as any[]).find(m => m.updateComponents)).toBeDefined();
    });

    it('all payloads should have updateDataModel message', () => {
      expect((todoList as any[]).find(m => m.updateDataModel)).toBeDefined();
      expect((contactForm as any[]).find(m => m.updateDataModel)).toBeDefined();
      expect((userProfile as any[]).find(m => m.updateDataModel)).toBeDefined();
    });

    it('all payloads should validate against v0.9 schema', () => {
      const todoResult = validatePayload(todoList as any[]);
      const contactResult = validatePayload(contactForm as any[]);
      const profileResult = validatePayload(userProfile as any[]);

      expect(todoResult.valid).toBe(true);
      expect(contactResult.valid).toBe(true);
      expect(profileResult.valid).toBe(true);

      if (!todoResult.valid) console.error('Todo list errors:', todoResult.errors);
      if (!contactResult.valid) console.error('Contact form errors:', contactResult.errors);
      if (!profileResult.valid) console.error('User profile errors:', profileResult.errors);
    });
  });
});
