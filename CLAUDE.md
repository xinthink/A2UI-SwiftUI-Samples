# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an A2UI (Agent-to-UI) v0.9 implementation project with:
- **iOS SwiftUI client** demonstrating A2UI protocol rendering
- **Node.js mock server** providing sample A2UI payloads
- **Protocol specification** and documentation

The project showcases how agents can generate rich, interactive UIs using JSON without executing arbitrary code.

### Current Status (January 2026)

✅ **Fully functional end-to-end implementation**
- Contact form example renders and submits correctly
- All A2UI v0.9 protocol messages supported
- Both ChildList formats handled (simple array and wrapped object)
- Data binding with JSON Pointer working
- User actions successfully sent to server

**Recent Fixes:**
- `f68683d` - Support both ChildList formats per A2UI v0.9 spec
- `b381742` - Resolve SwiftUI initialization issues in interactive components

## Architecture

### iOS Client Structure
```
ios-client/
├── A2UIExample.xcworkspace/          # Open this in Xcode
├── A2UIExample.xcodeproj/            # App shell project
├── A2UIExample/                      # Minimal app wrapper
│   ├── A2UIExampleApp.swift          # @main entry point
│   └── ContentView.swift             # Imports A2UIViews
├── A2UIExamplePackage/               # All A2UI implementation
│   ├── Sources/
│   │   ├── A2UICore/                 # Protocol types & messages
│   │   ├── A2UIServices/             # Client & data binding
│   │   └── A2UIViews/                # SwiftUI renderer
│   └── Tests/                        # Swift Testing tests
└── Config/                           # XCConfig build settings
```

### Swift Package Modules
- **A2UICore**: A2UI protocol types, message definitions, component types
- **A2UIServices**: HTTP client, data binding resolver, surface management
- **A2UIViews**: SwiftUI renderer that converts A2UI JSON to native views

## Common Development Commands

### Building and Testing
```bash
# Build for iPhone simulator
xcodebuild -workspace ios-client/A2UIExample.xcworkspace -scheme A2UIExample -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests on simulator
xcodebuild -workspace ios-client/A2UIExample.xcworkspace -scheme A2UIExample -destination 'platform=iOS Simulator,name=iPhone 16' test

# Build Swift Package only
swift build --package-path ios-client/A2UIExamplePackage

# Test Swift Package only
swift test --package-path ios-client/A2UIExamplePackage
```

### Server Operations
```bash
# Start mock server (recommended - uses pre-built dist)
cd mock-server && node dist/server.js

# Rebuild TypeScript and start server
cd mock-server && npm install && npm run build && node dist/server.js

# Test server endpoints
node test-server.js
```

**Note:** The TypeScript build may have type errors, but the pre-built `dist/server.js` works correctly with the JSON payloads.

### Testing Endpoints
```bash
# Health check
curl http://localhost:3000/health

# Get A2UI components
curl http://localhost:3000/api/form
curl http://localhost:3000/api/profile

# Send user action
curl -X POST http://localhost:3000/api/action \
  -H "Content-Type: application/json" \
  -d '{"action":"submitContactForm","surfaceId":"contact_form","context":{"firstName":"John"}}'
```

## Key Implementation Details

### A2UI Protocol Flow
1. **createSurface**: Initialize UI surface with ID
2. **updateComponents**: Send component definitions as JSON
3. **updateDataModel**: Update data bound to components via JSON Pointer
4. **deleteSurface**: Remove surface when done

### Data Binding
Components bind to data using JSON Pointer paths:
```json
{
  "id": "name_field",
  "component": "TextField",
  "value": { "path": "/form/name" }
}
```

### ChildList Format Support
The iOS client supports **both** A2UI v0.9 ChildList formats:

**Simple array format** (Protocol 0.9.md):
```json
{
  "component": "Column",
  "children": ["child1", "child2", "child3"]
}
```

**Wrapped object format** (Components Reference):
```json
{
  "component": "Column",
  "children": {"explicitList": ["child1", "child2", "child3"]}
}
```

The decoder automatically handles both formats, making the client compatible with various server implementations.

### Supported Components
- **Layout**: Column, Row
- **Display**: Text, Image, Icon, Divider
- **Input**: TextField, Button
- **Container**: Card

### SwiftUI Integration Pattern
The renderer follows these patterns:
1. Parse A2UI JSON messages
2. Map to SwiftUI view types
3. Handle data binding with JSON Pointer resolution
4. Send user actions back to server
5. Support dynamic list rendering

## Development Guidelines

### Code Organization
- All A2UI implementation lives in A2UIExamplePackage
- Keep app shell minimal - just imports and launches
- Use Swift 6+ concurrency (async/await, @MainActor)
- Follow Swift Testing framework for tests

### State Management
- Use @Observable for model objects
- Use @Environment for shared services
- Use @State for view-specific state
- No ViewModels - pure SwiftUI patterns

### Adding New Components
1. Define component type in A2UICore
2. Add SwiftUI renderer in A2UIViews
3. Update mock server with examples
4. Add tests in A2UIComponentsTests

### Network Communication
- All HTTP calls use Swift Concurrency
- CORS enabled for development
- JSON encoding/decoding via Codable
- Error handling with meaningful messages

## Testing Strategy
- Unit tests for core types and services
- Integration tests for renderer
- Mock server for end-to-end testing
- Use Swift Testing framework (not XCTest)

## Development Workflow

### Adding New Features
1. **Protocol Changes**: Update A2UICore with new message/component types
2. **Renderer Updates**: Implement SwiftUI views in A2UIViews
3. **Service Layer**: Add HTTP client support in A2UIServices
4. **Testing**: Write Swift Testing tests before implementation
5. **Documentation**: Update mock server examples
6. **App Integration**: Ensure proper module visibility (`public` access)

### IDE Setup
- Open `ios-client/A2UIExample.xcworkspace` (not the .xcodeproj)
- Development happens in `A2UIExamplePackage/Sources/`
- Use Xcode 16+ for buildable folders support
- Files added to filesystem appear automatically

### Code Standards
- Swift 6+ with strict concurrency checking
- Swift Testing framework for all tests
- SwiftUI with @Observable (not @Published)
- JSON Pointer for data binding (`/path/to/value`)
- No ViewModels - pure SwiftUI state management
- Always include accessibility labels

### Server Development
- Mock server runs on http://localhost:3000
- CORS enabled for development
- Test with curl or Postman before UI integration
- Keep JSON payloads A2UI spec compliant

## Important Notes
- **iOS 18+ only** - Use modern SwiftUI APIs
- **Swift Concurrency** - No GCD or completion handlers
- **Swift Testing** - Do not use XCTest
- **@Observable** - Not @Published or ObservableObject
- **Security** - No code execution, only declarative JSON
- **Modularity** - Keep A2UICore, A2UIServices, A2UIViews separate
- **Public API** - Mark types as `public` for cross-module access
- **No CoreData** - Use SwiftData if persistence needed (rarely)
- **Accessibility** - Always provide labels and identifiers
- **Tool Usage** - Always use `describe_ui` for visual validation instead of `screenshot`
