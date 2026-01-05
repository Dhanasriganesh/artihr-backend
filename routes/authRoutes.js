import express from 'express'
import { body } from 'express-validator'
import { login, signup } from '../controllers/authController.js'

const router = express.Router()

// POST /api/auth/login
router.post(
  '/login',
  [
    body('identifier').notEmpty().withMessage('Identifier is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  async (req, res, next) => {
    // Simple validation error handling here (could be moved to middleware)
    try {
      await login(req, res)
    } catch (err) {
      next(err)
    }
  },
)

// POST /api/auth/signup
router.post(
  '/signup',
  [
    body('name').notEmpty().withMessage('Name is required'),
    body('userId').notEmpty().withMessage('User ID is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  ],
  async (req, res, next) => {
    try {
      await signup(req, res)
    } catch (err) {
      next(err)
    }
  },
)

export default router






