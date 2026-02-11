-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE,
    name VARCHAR(100),
    email VARCHAR(100),
    profile_image_url TEXT,
    password VARCHAR(255),
    role VARCHAR(10) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Products Table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount INTEGER DEFAULT 0,
    description TEXT,
    sizes JSONB,
    colors JSONB,
    image_urls JSONB,
    is_available BOOLEAN DEFAULT TRUE,
    category VARCHAR(100) DEFAULT 'General',
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'Confirmed',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    tracking_id VARCHAR(100),
    tracking_slip_url TEXT,
    items JSONB NOT NULL,
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Chats Table
CREATE TABLE IF NOT EXISTS chats (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    admin_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Messages Table
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER REFERENCES chats(id),
    sender_role VARCHAR(10) NOT NULL,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Addresses Table
CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    name VARCHAR(100),
    phone VARCHAR(20),
    street TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    address_type VARCHAR(20) DEFAULT 'Home', -- Home, Office, Others
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Wishlist Table
CREATE TABLE IF NOT EXISTS wishlist (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- Create Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    image_urls JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(255),
    description TEXT,
    type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Create Settings Table
CREATE TABLE IF NOT EXISTS settings (
    key VARCHAR(50) PRIMARY KEY,
    value TEXT
);

-- Seed Initial Admin
INSERT INTO users (phone, email, password, role, name) 
VALUES ('9876543210', 'admin@rkjfashions.com', '$2b$10$YourHashedPasswordHere', 'admin', 'RKJ Admin')
ON CONFLICT (email) DO NOTHING;


-- Seed Default Settings
INSERT INTO settings (key, value) VALUES 
('shop_name', 'RKJ Fashions'),
('shop_email', 'admin@rkjfashions.com'),
('shop_phone', '9876543210'),
('shop_address', '123 Blossom Avenue, Suite 100, New York, NY 10012'),
('upi_id', 'username@bank'),
('upi_name', 'Anjali Sharma'),
('upi_bank', 'HDFC Bank'),
('qr_code_url', 'https://placehold.co/400x400/png?text=QR+Code')
ON CONFLICT (key) DO NOTHING;
