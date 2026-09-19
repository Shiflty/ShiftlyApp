const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@db:5432/shiftly'
});

const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_key';

// Middleware to verify JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Register Route
app.post('/api/auth/register', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email',
      [name, email, hashedPassword]
    );

    const user = result.rows[0];
    const token = jwt.sign({ userId: user.id }, JWT_SECRET);

    res.status(201).json({ user, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'User registration failed' });
  }
});

// Login Route
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user.id }, JWT_SECRET);
    res.json({
      user: { id: user.id, name: user.name, email: user.email },
      token
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Update User Profile
app.put('/api/auth/profile', authenticateToken, async (req, res) => {
  const { name, email } = req.body;
  try {
    const result = await pool.query(
      'UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING id, name, email',
      [name, email, req.user.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// Update User Profile
app.put('/api/auth/profile', authenticateToken, async (req, res) => {
  const { name, email } = req.body;
  try {
    const result = await pool.query(
      'UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING id, name, email',
      [name, email, req.user.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// Health check
app.get('/health', (req, res) => res.send('OK'));

// --- Job Type Routes ---

app.get('/api/job-types', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM job_types WHERE user_id = $1', [req.user.userId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch job types' });
  }
});

app.post('/api/job-types', authenticateToken, async (req, res) => {
  const { id, name, hourly_rate, wage_history } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO job_types (id, user_id, name, hourly_rate, wage_history)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (id) DO UPDATE SET
       name = EXCLUDED.name,
       hourly_rate = EXCLUDED.hourly_rate,
       wage_history = EXCLUDED.wage_history
       RETURNING *`,
      [id, req.user.userId, name, hourly_rate, JSON.stringify(wage_history)]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to save job type' });
  }
});

app.delete('/api/job-types/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM job_types WHERE id = $1 AND user_id = $2', [req.params.id, req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete job type' });
  }
});

// --- Shift Routes ---

// Get all shifts for user
app.get('/api/shifts', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM shifts WHERE user_id = $1 ORDER BY start_time DESC',
      [req.user.userId]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch shifts' });
  }
});

// Create or Update shift (Upsert)
app.post('/api/shifts', authenticateToken, async (req, res) => {
  const {
    id, job_type_id, date, start_time, end_time, tips,
    break_type, unpaid_break_minutes, hourly_rate,
    automatic_expenses, total_pay
  } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO shifts (id, user_id, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, automatic_expenses, total_pay)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       ON CONFLICT (id) DO UPDATE SET
       job_type_id = EXCLUDED.job_type_id,
       date = EXCLUDED.date,
       start_time = EXCLUDED.start_time,
       end_time = EXCLUDED.end_time,
       tips = EXCLUDED.tips,
       break_type = EXCLUDED.break_type,
       unpaid_break_minutes = EXCLUDED.unpaid_break_minutes,
       hourly_rate = EXCLUDED.hourly_rate,
       automatic_expenses = EXCLUDED.automatic_expenses,
       total_pay = EXCLUDED.total_pay
       RETURNING *`,
      [id, req.user.userId, job_type_id, date, start_time, end_time, tips, break_type, unpaid_break_minutes, hourly_rate, JSON.stringify(automatic_expenses), total_pay]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to save shift' });
  }
});

// Delete shift
app.delete('/api/shifts/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM shifts WHERE id = $1 AND user_id = $2', [req.params.id, req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete shift' });
  }
});

// --- Expense Routes ---

app.get('/api/expenses', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM expenses WHERE user_id = $1 ORDER BY date DESC', [req.user.userId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch expenses' });
  }
});

app.post('/api/expenses', authenticateToken, async (req, res) => {
  const { id, date, description, amount } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO expenses (id, user_id, date, description, amount)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (id) DO UPDATE SET
       date = EXCLUDED.date,
       description = EXCLUDED.description,
       amount = EXCLUDED.amount
       RETURNING *`,
      [id, req.user.userId, date, description, amount]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to save expense' });
  }
});

app.delete('/api/expenses/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM expenses WHERE id = $1 AND user_id = $2', [req.params.id, req.user.userId]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete expense' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
