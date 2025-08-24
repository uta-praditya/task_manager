# Task Manager REST API

A minimal REST API backend for the Task Manager Flutter app.

## Setup

1. Install dependencies:
```bash
cd backend
npm install
```

2. Start the server:
```bash
npm run dev  # Development with nodemon
npm start    # Production
```

The API will run on `http://localhost:3000`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Tasks (Protected)
- `GET /api/tasks` - Get all user tasks
- `GET /api/tasks/:id` - Get specific task
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task

### Health Check
- `GET /api/health` - API status

## Request/Response Examples

### Register/Login
```json
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}

Response:
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

### Create Task
```json
POST /api/tasks
Authorization: Bearer jwt_token_here
{
  "title": "Complete project",
  "description": "Finish the task manager app",
  "status": 0,
  "priority": 2,
  "dueDate": "2024-01-15T10:00:00Z"
}
```

## Task Status & Priority
- **Status**: 0 = To Do, 1 = In Progress, 2 = Done
- **Priority**: 0 = Low, 1 = Medium, 2 = High