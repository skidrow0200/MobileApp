const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const mongoose = require('mongoose');
const { check, validationResult } = require('express-validator');
require("dotenv").config()

const app = express();
const port = process.env.PORT || 5000;
const JWT_SECRET_KEY = `${process.env.KEY}`;

// Connect to MongoDB
mongoose.connect(`${process.env.MONGODB_CONNECTION}`, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

// Define User schema
const userSchema = new mongoose.Schema({
  email: { type: String, unique: true },
  password: String,
  fullname: String,
  favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Favorite' }],
});

// Define User model
const User = mongoose.model('User', userSchema);

// Define Favorite schema
const favoriteSchema = new mongoose.Schema({
  title: String,
  url: String,
  description: String,
  date_added: { type: Date, default: Date.now },
  id : Number
});

// Define Favorite model
const Favorite = mongoose.model('Favorite', favoriteSchema);

app.use(bodyParser.json());

// Register a new user
app.post(
  '/register',
  [
    check('email').isEmail(),
    check('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long'),
    check('fullname').notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const { email, password, fullname } = req.body;

      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({ errors: [{ msg: 'User already exists' }] });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const user = new User({
        email,
        password: hashedPassword,
        fullname,
        favorites: [],
      });

      await user.save();

      res.json({ success: true });
    } catch (err) {
      res.status(500).json({ errors: [{ msg: 'Internal server error' }] });
    }
  }
);

// Login
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ errors: [{ msg: 'Invalid credentials' }] });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ errors: [{ msg: 'Invalid credentials' }] });
    }

    const token = jwt.sign({ email: user.email }, JWT_SECRET_KEY, { expiresIn: '1d' });

    res.json({ success: true, access_token: token });
  } catch (err) {
    res.status(500).json({ errors: [{ msg: 'Internal server error' }] });
  }
});

// Get the details of a user
app.get('/users/:email', async (req, res) => {
  try {
    const { email } = req.params;

    const decodedToken = jwt.verify(req.headers.authorization.split(' ')[1], JWT_SECRET_KEY);
    if (decodedToken.email !== email) {
      return res.status(401).json({ errors: [{ msg: 'Unauthorized' }] });
    }

    const user = await User.findOne({ email }).populate('favorites');
    if (!user) {
      return res.status(404).json({ errors: [{ msg: 'User not found' }] });
    }

    res.json({ email: user.email, fullname: user.fullname, favorites: user.favorites });
  } catch (err) {
    res.status(500).json({ errors: [{ msg: 'Internal server error' }] });
  }
});

// Add a new favorite
app.post('/users/:email/favorites', async (req, res) => {
  try {
    const { email } = req.params;

    const decodedToken = jwt.verify(req.headers.authorization.split(' ')[1], JWT_SECRET_KEY);
    if (decodedToken.email !== email) {
      return res.status(401).json({ errors: [{ msg: 'Unauthorized' }] });
    }

    const user = await User.findOne({ email });
    if (!user) {
        return res.status(404).json({ errors: [{ msg: 'User not found' }] });
        }

const { title, url, description } = req.body;

    const favorite = new Favorite({title,url,description,});

    await favorite.save();

    user.favorites.push(favorite);
    await user.save();

    res.json({ success: true, favorite });

    } catch (err) {
    res.status(500).json({ errors: [{ msg: 'Internal server error' }] });
    }
    });

// Remove a favorite
app.delete('/users/:email/favorites/:id', async (req, res) => {
try {
        const { email, id } = req.params;

        const decodedToken = jwt.verify(req.headers.authorization.split(' ')[1], JWT_SECRET_KEY);
        if (decodedToken.email !== email) {
            return res.status(401).json({ errors: [{ msg: 'Unauthorized' }] });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ errors: [{ msg: 'User not found' }] });
        }

        const favorite = await Favorite.findById(id);
        if (!favorite) {
            return res.status(404).json({ errors: [{ msg: 'Favorite not found' }] });
        }

        const index = user.favorites.indexOf(favorite._id);
        if (index > -1) {
            user.favorites.splice(index, 1);
            await user.save();
        }

        await favorite.delete();

        res.json({ success: true });

} catch (err) {
    res.status(500).json({ errors: [{ msg: 'Internal server error' }] });
}
});

app.listen(port, () => {
console.log(`Server running on port ${port}`);
});