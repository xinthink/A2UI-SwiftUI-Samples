import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { A2UIMessage, UserAction } from './types/a2ui';
import contactForm from './payloads/contact-form.json';
import userProfile from './payloads/user-profile.json';
import todoList from './payloads/todo-list.json';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Sample A2UI payloads loaded from JSON files
const samplePayloads: Record<string, A2UIMessage[]> = {
  contactForm,
  userProfile,
  todoList
};

// API Routes
app.get('/api/form', (req, res) => {
  console.log('Sending contact form A2UI payload');
  res.json(samplePayloads.contactForm);
});

app.get('/api/profile', (req, res) => {
  console.log('Sending user profile A2UI payload');
  res.json(samplePayloads.userProfile);
});

app.get('/api/todos', (req, res) => {
  console.log('Sending todo list A2UI payload');
  res.json(samplePayloads.todoList);
});

// Endpoint to receive user actions
app.post('/api/action', (req, res) => {
  const action: UserAction = req.body;
  console.log('Received user action:', JSON.stringify(action, null, 2));

  // Echo back the action with a success response
  res.json({
    success: true,
    message: `Action "${action.action}" received for surface "${action.surfaceId}"`,
    receivedContext: action.context
  });
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
