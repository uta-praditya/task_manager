const express = require('express');
const { v4: uuidv4 } = require('uuid');
const auth = require('../middleware/auth');

const router = express.Router();

// In-memory task storage (replace with database in production)
const tasks = [];

// Get all tasks for user
router.get('/', auth, (req, res) => {
  const userTasks = tasks.filter(task => task.userId === req.userId);
  console.log(`GET /tasks - User: ${req.userId}, Found: ${userTasks.length} tasks`);
  res.json(userTasks);
});

// Get task by ID
router.get('/:id', auth, (req, res) => {
  const task = tasks.find(t => t.id === req.params.id && t.userId === req.userId);
  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }
  res.json(task);
});

// Create task
router.post('/', auth, (req, res) => {
  const { title, description, status = 0, priority = 1, dueDate } = req.body;

  if (!title) {
    return res.status(400).json({ error: 'Title is required' });
  }

  const task = {
    id: uuidv4(),
    userId: req.userId,
    title,
    description,
    status,
    priority,
    dueDate: dueDate ? new Date(dueDate).toISOString() : null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  tasks.push(task);
  console.log(`POST /tasks - Created task for user: ${req.userId}, Total tasks: ${tasks.length}`);
  res.status(201).json(task);
});

// Update task
router.put('/:id', auth, (req, res) => {
  const taskIndex = tasks.findIndex(t => t.id === req.params.id && t.userId === req.userId);
  if (taskIndex === -1) {
    return res.status(404).json({ error: 'Task not found' });
  }

  const { title, description, status, priority, dueDate } = req.body;
  
  tasks[taskIndex] = {
    ...tasks[taskIndex],
    title: title || tasks[taskIndex].title,
    description: description !== undefined ? description : tasks[taskIndex].description,
    status: status !== undefined ? status : tasks[taskIndex].status,
    priority: priority !== undefined ? priority : tasks[taskIndex].priority,
    dueDate: dueDate !== undefined ? (dueDate ? new Date(dueDate).toISOString() : null) : tasks[taskIndex].dueDate,
    updatedAt: new Date().toISOString()
  };

  res.json(tasks[taskIndex]);
});

// Delete task
router.delete('/:id', auth, (req, res) => {
  const taskIndex = tasks.findIndex(t => t.id === req.params.id && t.userId === req.userId);
  if (taskIndex === -1) {
    return res.status(404).json({ error: 'Task not found' });
  }

  tasks.splice(taskIndex, 1);
  res.status(204).send();
});

module.exports = router;