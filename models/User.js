import mongoose from 'mongoose'

const userSchema = new mongoose.Schema(
  {
    empId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    clientId: {
      type: String,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    name: {
      type: String,
      trim: true,
    },
    role: {
      type: String,
      enum: ['admin', 'c-suite', 'hr', 'manager', 'supermanager', 'tl', 'employee', 'client'],
      default: 'employee',
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  },
)

// Ensure indexes
userSchema.index({ empId: 1 }, { unique: true })
userSchema.index({ email: 1 }, { unique: true })

const User = mongoose.model('User', userSchema)

export default User






