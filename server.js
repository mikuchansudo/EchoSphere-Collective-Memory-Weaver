const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://<your-mongo-url>', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('MongoDB connected'))
    .catch(err => console.log('MongoDB connection error:', err));

// Memory Schema
const memorySchema = new mongoose.Schema({
    text: String,
    createdAt: { type: Date, default: Date.now }
});
const Memory = mongoose.model('Memory', memorySchema);

// Routes
app.get('/memories', async (req, res) => {
    try {
        const memories = await Memory.find().sort({ createdAt: -1 });
        res.json(memories);
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

app.post('/memories', async (req, res) => {
    try {
        const memory = new Memory({ text: req.body.text });
        await memory.save();
        res.status(201).json(memory);
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Start Server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});