import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import User from '../models/User.js'

// Helper to generate JWT
const generateToken = (userId) => {
  const expiresIn = process.env.JWT_EXPIRE || '7d'
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn,
  })
}

// POST /api/auth/login
// Body: { identifier, password }
// identifier can be empId or clientId or email (we'll try in that order)
export const login = async (req, res) => {
  try {
    const { identifier, password } = req.body

    if (!identifier || !password) {
      return res.status(400).json({ message: 'Identifier and password are required' })
    }

    // Try to find user by empId, then clientId, then email
    let user =
      (await User.findOne({ empId: identifier })) ||
      (await User.findOne({ clientId: identifier })) ||
      (await User.findOne({ email: identifier.toLowerCase() }))

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' })
    }

    if (!user.isActive) {
      return res.status(403).json({ message: 'User is inactive' })
    }

    // Compare password
    const isMatch = await bcrypt.compare(password, user.password)
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' })
    }

    const token = generateToken(user._id)

    return res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        empId: user.empId,
        clientId: user.clientId,
        role: user.role,
      },
    })
  } catch (error) {
    console.error('Login error:', error)
    return res.status(500).json({ message: 'Server error' })
  }
}






