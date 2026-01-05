# Employee Portal Backend

Backend API server for the Employee Portal application using Express.js and MongoDB.

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Copy the `.env.example` file to `.env` and update with your MongoDB connection details:

```bash
cp .env.example .env
```

Edit `.env` and update:
- `MONGODB_URI`: Your MongoDB connection string from the server admin
- `JWT_SECRET`: A random secret key for JWT tokens
- `PORT`: Server port (default: 3000)

### 3. Start Development Server

```bash
npm run dev
```

The server will start on `http://localhost:3000`

### 4. Test Connection

Visit `http://localhost:3000/api/health` to verify the server and database connection.

## Project Structure

```
backend/
├── config/
│   └── database.js      # MongoDB connection configuration
├── models/              # Mongoose models (to be created)
├── routes/              # API routes (to be created)
├── controllers/         # Route controllers (to be created)
├── middleware/          # Custom middleware (to be created)
├── utils/               # Utility functions (to be created)
├── server.js            # Main server file
├── package.json
└── .env                 # Environment variables (not in git)
```

## MongoDB Connection

The backend uses Mongoose to connect to MongoDB. Ensure:
1. MongoDB is running on the server
2. Connection string is correct in `.env`
3. Database user has proper permissions
4. Firewall allows connection to MongoDB port

## Next Steps

1. Create Mongoose models for:
   - Employees
   - Departments
   - Users/Authentication
   - Leave requests
   - Attendance
   - etc.

2. Create API routes and controllers

3. Implement authentication and authorization

4. Add validation and error handling

5. Set up production deployment






