const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const experienceSchema = new mongoose.Schema({
  companyName: { type: String, required: true },
  role: { type: String, required: true },
  studentName: { type: String, required: true },
  branch: { type: String, required: true },
  year: { type: Number, required: true },
  experience: { type: String, required: true },
  rounds: [String],
  tips: String,
  createdAt: { type: Date, default: Date.now }
});
const Experience = mongoose.model('Experience', experienceSchema);

// 1. Add Interview Experience
app.post('/api/experience', async (req, res) => {
  try {
    const experience = new Experience(req.body);
    await experience.save();
    res.status(201).json(experience);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// 2. Get all interview experiences
app.get('/api/experience', async (req, res) => {
  try {
    const experience = await Experience.find().sort({ createdAt: -1 });
    res.json(experience);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 3. Get single Interview Experience
app.get('/api/experience/:id', async (req, res) => {
  try {
    const experience = await Experience.findById(req.params.id);
    if (!experience) return res.status(404).json({ error: 'Not found' });
    res.json(experience);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 4. Delete Interview Experience
app.delete('/api/experience/:id', async (req, res) => {
  try {
    const experience = await Experience.findByIdAndDelete(req.params.id);
    if (!experience) return res.status(404).json({ error: 'Not found' });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Connect to MongoDB and start the server
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected');
    app.listen(process.env.PORT || 5000, () => {
      console.log(`Server running on port ${process.env.PORT || 5000}`);
    });
  })
  .catch(err => console.log(err));
