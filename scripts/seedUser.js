import dotenv from 'dotenv'
import bcrypt from 'bcryptjs'
import connectDB from '../config/database.js'
import User from '../models/User.js'

dotenv.config()

const run = async () => {
  try {
    await connectDB()

    const plainPassword = 'Test@1234'

    const existing = await User.findOne({ empId: 'E123' })
    if (existing) {
      console.log('✅ Test user already exists with empId E123')
      process.exit(0)
    }

    const hashedPassword = await bcrypt.hash(plainPassword, 10)

    const user = await User.create({
      empId: 'E123',
      clientId: 'C456',
      email: 'test@exmp.com',
      name: 'Test Ur',
      role: 'employee',
      password: hashedPassword,
      isActive: true,
    })

    console.log('✅ Test user created:')
    console.log({
      empId: user.empId,
      clientId: user.clientId,
      email: user.email,
      role: user.role,
      loginPassword: plainPassword,
    })

    process.exit(0)
  } catch (err) {
    console.error('❌ Error seeding user:', err)
    process.exit(1)
  }
}

run()





