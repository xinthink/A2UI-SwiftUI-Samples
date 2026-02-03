import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { ClientAction } from './types/a2ui';
import contactForm from './payloads/contact-form.json';
import userProfile from './payloads/user-profile.json';
import todoList from './payloads/todo-list.json';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Sample A2UI payloads loaded from JSON files
// Type as any[] to bypass strict typing - we validate at runtime
const samplePayloads: Record<string, any[]> = {
  contactForm,
  userProfile,
  todoList
};

// API Routes
app.get('/api/form', (req, res) => {
  console.log('Sending contact form A2UI payload');
  res.setHeader('Content-Type', 'application/x-ndjson');
  const ndjson = samplePayloads.contactForm.map(msg => JSON.stringify(msg)).join('\n');
  res.send(ndjson);
});

app.get('/api/profile', (req, res) => {
  console.log('Sending user profile A2UI payload');
  res.setHeader('Content-Type', 'application/x-ndjson');
  const ndjson = samplePayloads.userProfile.map(msg => JSON.stringify(msg)).join('\n');
  res.send(ndjson);
});

app.get('/api/todos', (req, res) => {
  console.log('Sending todo list A2UI payload');
  res.setHeader('Content-Type', 'application/x-ndjson');
  const ndjson = samplePayloads.todoList.map(msg => JSON.stringify(msg)).join('\n');
  res.send(ndjson);
});

// Endpoint to receive user actions
app.post('/api/action', (req, res) => {
  const clientAction: ClientAction = req.body;

  // Handle v0.9 action format
  if (clientAction.version === 'v0.9' && clientAction.action) {
    const { surfaceId, event } = clientAction.action;
    console.log('Received user action:', JSON.stringify(clientAction, null, 2));

    // Echo back the action with a success response
    res.json({
      version: 'v0.9',
      success: true,
      message: `Action "${event.name}" received for surface "${surfaceId}"`,
      receivedContext: event.context
    });
  } else {
    // Handle legacy format for backward compatibility
    console.log('Received legacy action:', JSON.stringify(req.body, null, 2));
    res.json({
      success: true,
      message: 'Action received (legacy format)',
      receivedData: req.body
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  console.log(`A2UI Mock Server running on http://localhost:${PORT}`);
  console.log('');
  console.log('Available endpoints:');
  console.log('  GET  /api/form    - Contact form example');
  console.log('  GET  /api/profile - User profile example');
  console.log('  GET  /api/todos    - Todo list example');
  console.log('  POST /api/action  - Receive user actions');
  console.log('  GET  /health      - Health check');
});
