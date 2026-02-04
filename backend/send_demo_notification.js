
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false
    }
});

async function sendDemoNotification() {
    try {
        // 1. Get the most recent user
        const userRes = await pool.query('SELECT id, name, email FROM users ORDER BY created_at DESC LIMIT 1');

        if (userRes.rows.length === 0) {
            console.log("No users found in the database!");
            return;
        }

        const user = userRes.rows[0];
        console.log(`Found user: ${user.name} (${user.email})`);

        // 2. Insert notification
        const title = "Order Received";
        const description = `Hello ${user.name}, this is a DEMO notification. Your order #DEMO-123 has been received successfully!`;
        const type = "order"; // Simulates an order notification
        const metadata = JSON.stringify({ orderId: "DEMO-123" });

        const notifRes = await pool.query(
            `INSERT INTO notifications (user_id, title, description, type, metadata, is_read, created_at) 
             VALUES ($1, $2, $3, $4, $5, FALSE, NOW()) RETURNING *`,
            [user.id, title, description, type, metadata]
        );

        console.log("✅ Notification Sent Successfully!");
        console.log(notifRes.rows[0]);

    } catch (err) {
        console.error("Error sending notification:", err);
    } finally {
        await pool.end();
    }
}

sendDemoNotification();
