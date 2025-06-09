const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ====== Schemas ======

// User Schema
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});
const User = mongoose.model('User', userSchema);

// Experience Schema
const experienceSchema = new mongoose.Schema({
  companyName: { type: String, required: true },
  role: { type: String, required: true },
  studentName: { type: String, required: true },
  branch: { type: String, required: true },
  year: { type: Number, required: true },
  experience: { type: String, required: true },
  rounds: [String],
  tips: String,
  createdAt: { type: Date, default: Date.now },
  postedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
});
const Experience = mongoose.model('Experience', experienceSchema);

// ====== Middleware for JWT Auth ======

const authenticate = (req, res, next) => {
  const token = req.header('Authorization')?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Access Denied. No token provided.' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(400).json({ error: 'Invalid token' });
  }
};

// ====== Routes ======

// Signup
app.post('/api/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ error: 'User already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ name, email, password: hashedPassword });
    await user.save();

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.status(201).json({ token, user: { id: user._id, name: user.name, email: user.email } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ error: 'Invalid email or password' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ error: 'Invalid email or password' });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user._id, name: user.name, email: user.email } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add Interview Experience (Protected)
app.post('/api/experience', authenticate, async (req, res) => {
  try {
    const experience = new Experience({
      ...req.body,
      postedBy: req.user.id
    });
    await experience.save();
    res.status(201).json(experience);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get all interview experiences (with user info)
app.get('/api/experience', async (req, res) => {
  try {
    const experience = await Experience.find()
      .sort({ createdAt: -1 })
      .populate('postedBy', 'name email');
    res.json(experience);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single Interview Experience (with user info)
app.get('/api/experience/:id', async (req, res) => {
  try {
    const experience = await Experience.findById(req.params.id)
      .populate('postedBy', 'name email');
    if (!experience) return res.status(404).json({ error: 'Not found' });
    res.json(experience);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete Interview Experience (Protected)
app.delete('/api/experience/:id', authenticate, async (req, res) => {
  try {
    const experience = await Experience.findById(req.params.id);
    if (!experience) return res.status(404).json({ error: 'Not found' });

    // Ensure only the creator can delete
    if (experience.postedBy.toString() !== req.user.id) {
      return res.status(403).json({ error: 'Unauthorized to delete this post' });
    }

    await experience.remove();
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ====== DB Connect + Server Start ======

mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected');
    app.listen(process.env.PORT || 5000, () => {
      console.log(`Server running on port ${process.env.PORT || 5000}`);
    });
  })
  .catch(err => console.log(err));
