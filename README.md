# 🎯 Smart Task Manager - Flutter App

A task management system with **intelligent auto-classification** that automatically categorizes tasks, assigns priorities, extracts entities, and suggests relevant actions.

## 📋 Table of Contents

- [Features](#features)
- [App Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Architecture Decisions](#architecture-decisions)

---

## ✨ Features

### Core Functionality
- ✅ **Auto-Classification**: Automatically categorizes tasks into scheduling, finance, technical, safety, or general
- ✅ **Priority Detection**: Intelligently assigns high, medium, or low priority based on keywords
- ✅ **Entity Extraction**: Extracts dates, people, locations, and action items from task descriptions
- ✅ **Action Suggestions**: Provides context-aware action suggestions based on task category
- ✅ **Audit Trail**: Complete history of all task changes
- ✅ **Flexible Filtering**: Filter by status, category, priority, and search text
- ✅ **Pagination**: Efficient handling of large datasets

### Technical Features
- RESTful API design with proper HTTP methods
- Input validation using Joi
- Comprehensive error handling
- Transaction support for data consistency
- Unit tests for classification logic
- PostgreSQL with Prisma ORM

---

# App Screenshots

## 📱 App Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/184b433f-6e16-41b0-b7a6-ba7383478756" width="250" />
  <img src="https://github.com/user-attachments/assets/f1aac2f7-e563-44a5-994d-bc6656f1f539" width="250" />
  <img src="https://github.com/user-attachments/assets/6a1595a3-51a0-49fa-a18f-e302bdfed4e3" width="250" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/ed8bfed1-f067-4358-adde-9cb84b3f7065" width="250"/>
  <img src="https://github.com/user-attachments/assets/ba087144-0ec1-42f3-b804-14cb578964db" width="250" />
  <img src="https://github.com/user-attachments/assets/4c81c255-1919-4108-a277-56b0a0f5f667" width="250" />
  <img src="https://github.com/user-attachments/assets/0d16c535-a92e-4732-a8f5-aad6153c47a1" width="250" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/7929e03b-253a-4c8a-89a5-64c50dcaec5e" width="250" />
  <img src="https://github.com/user-attachments/assets/e309bc51-bfc8-4224-a18e-b0d471907085" width="250" />
  <img src="https://github.com/user-attachments/assets/8639514b-bda2-46b2-b592-2618055f2e7f" width="250" />
</p>



---

## 🛠️ Tech Stack

- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Validation**: Joi
- **Testing**: Jest
- **Language**: JavaScript (ES6+)

---

## 📁 Project Structure

```
backend/
├── prisma/
│   ├── schema.prisma          # Database schema
│   └── migrations/            # Database migrations
├── src/
│   ├── config/
│   │   └── database.js        # Prisma client configuration
│   ├── controllers/
│   │   └── taskController.js  # Request handlers
│   ├── services/
│   │   ├── classificationService.js  # Auto-classification logic
│   │   └── taskService.js     # Business logic
│   ├── routes/
│   │   └── taskRoutes.js      # API routes
│   ├── middleware/
│   │   ├── errorHandler.js    # Error handling
│   │   └── validator.js       # Request validation
│   ├── utils/
│   │   └── entityExtractor.js # Entity extraction
│   └── app.js                 # Express app setup
├── tests/
│   ├── classification.test.js
│   ├── entityExtraction.test.js
│   └── taskService.test.js
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

---

## 🚀 Installation

### Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v14 or higher)
- npm or yarn

### Step 1: Clone Repository

```bash
git clone <your-repo-url>
cd backend
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Environment Setup

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
DATABASE_URL="postgresql://user:password@localhost:5432/taskmanager?schema=public"
PORT=3000
NODE_ENV=development
```

---

## 🗄️ Database Setup

### Option 1: Local PostgreSQL

1. Create database:
```bash
createdb taskmanager
```

2. Generate Prisma client:
```bash
npm run prisma:generate
```

3. Run migrations:
```bash
npm run prisma:migrate
```

### Option 2: Supabase (Cloud)

1. Create a project at [supabase.com](https://supabase.com)
2. Get your connection string from Settings > Database
3. Update `DATABASE_URL` in `.env`
4. Run migrations:
```bash
npm run prisma:deploy
```

### Database Schema

```sql
-- Tasks Table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'general',
  priority TEXT DEFAULT 'low',
  status TEXT DEFAULT 'pending',
  assigned_to TEXT,
  due_date TIMESTAMP,
  extracted_entities JSONB,
  suggested_actions JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Task History Table
CREATE TABLE task_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  old_value JSONB,
  new_value JSONB,
  changed_by TEXT,
  changed_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🏃 Running the Application

### Development Mode

```bash
npm run dev
```

Server will start on `http://localhost:3000`

### Production Mode

```bash
npm start
```

### Other Commands

```bash
# Run tests
npm test

# Open Prisma Studio (database GUI)
npm run prisma:studio

# Generate Prisma client
npm run prisma:generate
```

---

## 📚 API Documentation

### Base URL
```
http://localhost:3000/api
```

### Endpoints

#### 1. Create Task
**POST** `/api/tasks`

Creates a new task with automatic classification.

**Request Body:**
```json
{
  "title": "Schedule urgent meeting with team today",
  "description": "Discuss Q4 budget allocation",
  "assignedTo": "John Doe",
  "dueDate": "2025-01-15T10:00:00Z"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Task created successfully",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Schedule urgent meeting with team today",
    "description": "Discuss Q4 budget allocation",
    "category": "scheduling",
    "priority": "high",
    "status": "pending",
    "assignedTo": "John Doe",
    "dueDate": "2025-01-15T10:00:00Z",
    "extractedEntities": {
      "dates": ["today"],
      "people": [],
      "locations": [],
      "actions": ["schedule"]
    },
    "suggestedActions": [
      "Block calendar",
      "Send invite",
      "Prepare agenda",
      "Set reminder"
    ],
    "createdAt": "2025-01-15T09:30:00Z",
    "updatedAt": "2025-01-15T09:30:00Z"
  }
}
```

---

#### 2. Get All Tasks
**GET** `/api/tasks`

Retrieves all tasks with optional filters.

**Query Parameters:**
- `status`: Filter by status (pending, in_progress, completed)
- `category`: Filter by category (scheduling, finance, technical, safety, general)
- `priority`: Filter by priority (high, medium, low)
- `search`: Search in title and description
- `limit`: Results per page (default: 50)
- `offset`: Pagination offset (default: 0)
- `sortBy`: Sort field (default: createdAt)
- `sortOrder`: Sort direction (asc/desc, default: desc)

**Example Request:**
```
GET /api/tasks?status=pending&priority=high&limit=10
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "title": "...",
      "category": "scheduling",
      "priority": "high",
      "status": "pending",
      // ... other fields
    }
  ],
  "pagination": {
    "total": 25,
    "limit": 10,
    "offset": 0,
    "hasMore": true
  }
}
```

---

#### 3. Get Task by ID
**GET** `/api/tasks/:id`

Retrieves a single task with its complete history.

**Example Request:**
```
GET /api/tasks/123e4567-e89b-12d3-a456-426614174000
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Schedule urgent meeting",
    // ... all task fields
    "history": [
      {
        "id": "...",
        "action": "created",
        "newValue": { /* task data */ },
        "changedBy": "system",
        "changedAt": "2025-01-15T09:30:00Z"
      }
    ]
  }
}
```

**Response (404):**
```json
{
  "success": false,
  "error": "Task not found"
}
```

---

#### 4. Update Task
**PATCH** `/api/tasks/:id`

Updates an existing task.

**Request Body:**
```json
{
  "status": "completed",
  "priority": "medium",
  "changedBy": "John Doe"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Task updated successfully",
  "data": {
    // Updated task data
  }
}
```

---

#### 5. Delete Task
**DELETE** `/api/tasks/:id`

Deletes a task and its history.

**Response (200):**
```json
{
  "success": true,
  "message": "Task deleted successfully"
}
```

---

#### 6. Preview Classification (Bonus)
**POST** `/api/tasks/classify`

Preview how a task would be classified without creating it.

**Request Body:**
```json
{
  "title": "Fix critical production bug",
  "description": "Server is down and needs immediate attention"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "category": "technical",
    "priority": "high",
    "suggestedActions": [
      "Diagnose issue",
      "Check resources",
      "Assign technician",
      "Document fix"
    ],
    "extractedEntities": {
      "dates": [],
      "people": [],
      "locations": [],
      "actions": ["fix"]
    }
  }
}
```

---

#### 7. Get Statistics (Bonus)
**GET** `/api/tasks/stats`

Get task statistics and counts.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total": 150,
    "byStatus": {
      "pending": 45,
      "in_progress": 30,
      "completed": 75
    },
    "highPriority": 20,
    "byCategory": {
      "scheduling": 40,
      "finance": 35,
      "technical": 30,
      "safety": 25,
      "general": 20
    }
  }
}
```

---

## 🧪 Testing

### Run All Tests

```bash
npm test
```

### Test Coverage

```bash
npm test -- --coverage
```

### Test Files

1. **classification.test.js** - Tests auto-classification logic
2. **entityExtraction.test.js** - Tests entity extraction
3. **taskService.test.js** - Tests service layer structure

### Example Test Output

```
PASS  tests/classification.test.js
  ✓ should classify scheduling task correctly (3ms)
  ✓ should classify finance task correctly (2ms)
  ✓ should determine high priority correctly (1ms)
  ✓ should classify complete task correctly (2ms)

Test Suites: 3 passed, 3 total
Tests:       15 passed, 15 total
```

---

## 🚢 Deployment

### Deploy to Render.com

1. **Create Account**: Sign up at [render.com](https://render.com)

2. **Create Web Service**:
   - Connect your GitHub repository
   - Select "Web Service"
   - Configure:
     - Name: `smart-task-manager`
     - Environment: `Node`
     - Build Command: `npm install && npm run prisma:deploy`
     - Start Command: `npm start`

3. **Add Environment Variables**:
   ```
   DATABASE_URL=<your-postgresql-url>
   NODE_ENV=production
   ```

4. **Deploy**: Click "Create Web Service"

### Deploy Database

**Option 1: Render PostgreSQL**
- Create a PostgreSQL database in Render
- Copy the Internal Database URL
- Use it as `DATABASE_URL`

**Option 2: Supabase**
- Free tier available
- Get connection string from Supabase dashboard
- Better for development and small projects

---

## 🏗️ Architecture Decisions

### Why These Choices?

#### 1. **Prisma ORM**
- Type-safe database access
- Automatic migrations
- Excellent developer experience
- Built-in connection pooling

#### 2. **Service Layer Pattern**
- Separates business logic from HTTP concerns
- Easier to test
- Reusable across different interfaces
- Single responsibility principle

#### 3. **Keyword-Based Classification**
- Simple and fast
- No external dependencies
- Predictable results
- Easy to extend with more keywords

#### 4. **Transaction Support**
- Ensures data consistency
- Task and history are always in sync
- Prevents partial updates

#### 5. **Joi Validation**
- Clear error messages
- Schema reusability
- Comprehensive validation rules

---

## 🔮 Future Improvements

Given more time, I would add:

### Performance
- [ ] Redis caching for frequently accessed tasks
- [ ] Database query optimization and indexing
- [ ] Background job processing for heavy operations

### Features
- [ ] Agent-based reasoning & classification using LangChain and LangGraph
- [ ] Natural language processing for better entity extraction
- [ ] Task dependencies and relationships
- [ ] File attachments support
- [ ] Real-time updates with WebSockets
- [ ] Email notifications
- [ ] Task templates

### Security
- [ ] JWT authentication
- [ ] Role-based access control (RBAC)
- [ ] API rate limiting
- [ ] Input sanitization
- [ ] SQL injection prevention (already handled by Prisma)

### API
- [ ] GraphQL alternative endpoint
- [ ] Swagger/OpenAPI documentation
- [ ] API versioning
- [ ] Batch operations
- [ ] CSV/Excel export

---

## 📝 License

MIT

---

## 👤 Author

Navicon Infraprojects Assessment

---

## 🙏 Acknowledgments

- Built as part of Backend + Flutter Hybrid Developer Assessment
- Classification logic inspired by modern task management systems
- Entity extraction patterns based on NLP best practices
