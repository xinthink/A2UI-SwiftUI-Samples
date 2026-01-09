# A2UI v0.9 Example Project

This project demonstrates the A2UI (Agent-to-UI) v0.9 specification with an iOS SwiftUI client and a mock Node.js server.

## Overview

A2UI is a JSON-based protocol that allows agents to generate rich, interactive user interfaces without executing arbitrary code. This example shows:

- How to create A2UI-compliant JSON payloads
- How to render A2UI components in SwiftUI
- How to handle user interactions and data binding
- HTTP-based communication between client and server

## Project Structure

```
A2UI-Example/
├── ios-client/                     # iOS SwiftUI client
│   ├── A2UIExample.xcworkspace/    # Open this in Xcode
│   ├── A2UIExample.xcodeproj/      # App shell project
│   ├── A2UIExample/                # App wrapper (minimal)
│   ├── A2UIExamplePackage/         # Swift Package with A2UI implementation
│   │   ├── Sources/
│   │   └── Tests/                  # Unit tests
│   └── Config/                     # Build settings & entitlements
├── mock-server/                    # Express-based Node.js server
└── docs/A2UI/                     # Protocol specification docs
```

## Features

### Standard A2UI Components Implemented
- **Layout**: Column, Row
- **Display**: Text, Image, Icon, Divider
- **Input**: TextField, Button
- **Container**: Card

### Sample UIs
1. **Contact Form** - A complete form with validation
2. **User Profile** - A card-based profile display
3. **Todo List** - A dynamic list with actions

## Quick Start

### 1. Start the Mock Server

```bash
# Using the standalone server (no npm dependencies)
node simple-server.js

# Or using the Express-based server
cd mock-server
npm install
node server.js
```

The server will start on http://localhost:3000

### 2. Run the iOS Client

The iOS client uses a modern **workspace + Swift Package** architecture. Open the workspace in Xcode:

```bash
open ios-client/A2UIExample.xcworkspace
```

**Architecture:**
- **App Shell**: `A2UIExample/` contains minimal code (just `@main` and entry views)
- **Implementation**: All A2UI logic is in `A2UIExamplePackage/` as a Swift Package

In Xcode:
1. Select the **A2UIExample** scheme
2. Choose your target device/simulator
3. Build and run (⌘R)

The app will connect to the mock server at `http://localhost:3000` and render A2UI components.

### 3. Test the Endpoints

```bash
# Health check
curl http://localhost:3000/health

# Get contact form UI
curl http://localhost:3000/api/form

# Get user profile UI
curl http://localhost:3000/api/profile

# Send user action
curl -X POST http://localhost:3000/api/action \
  -H "Content-Type: application/json" \
  -d '{"action":"submitContactForm","surfaceId":"contact_form","context":{"firstName":"John"}}'
```

## A2UI Protocol Overview

### Message Types

1. **createSurface**: Initialize a new UI surface
2. **updateComponents**: Send component definitions
3. **updateDataModel**: Update data bound to components
4. **deleteSurface**: Remove a surface

### Example Message Flow

```json
[
  {
    "createSurface": {
      "surfaceId": "contact_form",
      "catalogId": "https://a2ui.dev/specification/0.9/standard_catalog_definition.json"
    }
  },
  {
    "updateComponents": {
      "surfaceId": "contact_form",
      "components": [
        {
          "id": "title",
          "component": "Text",
          "text": { "literalString": "Contact Us" }
        }
      ]
    }
  },
  {
    "updateDataModel": {
      "surfaceId": "contact_form",
      "path": "/form",
      "value": {
        "firstName": "",
        "lastName": ""
      }
    }
  }
]
```

### Data Binding

Components can bind to data using JSON Pointer paths:

```json
{
  "id": "name_field",
  "component": "TextField",
  "label": { "literalString": "Name" },
  "value": { "path": "/form/name" }
}
```

## Implementation Details

### Server Implementation

The mock server provides:
- HTTP endpoints returning static A2UI JSON payloads
- CORS support for cross-origin requests
- POST endpoint to receive user actions
- Sample UIs: Contact Form, User Profile, Todo List

**Options:**
- `simple-server.js` - Standalone server with zero dependencies
- `mock-server/server.js` - Express-based server with more features

### Client Implementation

The iOS client uses a **modern Swift Package architecture**:

**A2UIExamplePackage Module**:
- A2UI protocol implementation

**App Shell** (`A2UIExample/`):
- Minimal wrapper that imports and launches the package
- Entry point and basic navigation
- Asset management

Key Features:
- **JSON Pointer binding**: Components bind to data models via path references
- **Progressive rendering**: Components stream and render incrementally
- **Type-safe**: Swift's type system ensures component validity
- **Platform-native**: Renders native SwiftUI controls
- **Modular**: Clean separation of concerns across packages

## Testing

Run the test script to verify the server:

```bash
node test-server.js
```

This will test all endpoints and verify the JSON structure.

## Architecture Notes

1. **Security**: A2UI uses declarative JSON instead of executable code
2. **Flexibility**: Same protocol works across platforms (iOS, Android, Web)
3. **Progressive Rendering**: Components can be streamed and rendered incrementally
4. **Data Binding**: Dynamic updates without full UI re-renders

## Future Enhancements

- Add more standard components (Slider, Checkbox, Radio buttons)
- Implement dynamic list templating
- Add error handling and validation
- Support custom component catalogs
- Add theming and styling support

## Resources

- [A2UI Specification v0.9](https://github.com/google/A2UI)
- [A2UI Components Reference](A2UI%20Components%20Reference.md)
- [A2UI Theming Guide](A2UI%20Theming%20Guide.md)
- [Renderer Development Guide](Renderer%20Development%20Guide.md)
