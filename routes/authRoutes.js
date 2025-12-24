import express from 'express'
import { body } from 'express-validator'
import { login } from '../controllers/authController.js'

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

export default router




