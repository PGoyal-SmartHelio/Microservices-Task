const express = require('express');
const axios = require('axios');
const app = express();
app.use(express.json());
const port = process.env.GATEWAY_SERVICE_PORT;

app.get('/health', (req, res) => {
  res.json({ status: 'Gateway Service is healthy' });
});

app.get('/api/users', async (req, res) => {
  try {
    const response = await axios.get(`http://${process.env.USER_SERVICE_HOST}:${process.env.USER_SERVICE_PORT}/users`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Error fetching users' });
  }
});

app.get('/api/products', async (req, res) => {
  try {
    const response = await axios.get(`http://${process.env.PRODUCT_SERVICE_HOST}:${process.env.PRODUCT_SERVICE_PORT}/products`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Error fetching products' });
  }
});

app.get('/api/orders', async (req, res) => {
  try {
    const response = await axios.get(`http://${process.env.ORDER_SERVICE_HOST}:${process.env.ORDER_SERVICE_PORT}/orders`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Error fetching orders' });
  }
});

app.post('/api/orders', async (req, res) => {
  try {
    const response = await axios.post(`http://${process.env.ORDER_SERVICE_HOST}:${process.env.ORDER_SERVICE_PORT}/orders`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Error creating order' });
  }
});

app.listen(port, () => {
  console.log(`Gateway service running on port ${port}`);
});