require('dotenv').config();
const db = require('./db');

const identifier = process.argv[2];

if (!identifier) {
    console.error('Usage: node promote_admin.js <email_or_phone>');
    process.exit(1);
}

async function promoteUser() {
    try {
        await db.initDb();
        console.log(`Searching for user with identifier: ${identifier}...`);

        const result = await db.query(
            "UPDATE users SET role = 'admin' WHERE email = $1 OR phone = $1 RETURNING *",
            [identifier]
        );

        if (result.rows.length === 0) {
            console.error('User not found!');
        } else {
            const user = result.rows[0];
            console.log(`Success! User ${user.name} (${user.email || user.phone}) is now an ADMIN.`);
        }
    } catch (err) {
        console.error('Error promoting user:', err.message);
    } finally {
        // We can't easily close the pool if it's not exposed, but in a script it will exit.
        // If db.js exposes end, call it. If not, process.exit(0) is fine.
        process.exit(0);
    }
}

promoteUser();
