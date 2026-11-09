-- =============================================================================
-- Panenara Platform — PostgreSQL DDL
-- Database: panenara
-- Encoding: UTF-8
-- Generated: 2025-05-01
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- EXTENSIONS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "citext";     -- case-insensitive text untuk email

-- ─────────────────────────────────────────────────────────────────────────────
-- ENUM TYPES
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TYPE user_role AS ENUM (
    'super_admin',
    'admin',
    'petani',
    'pembeli',
    'pengamat'
);

CREATE TYPE user_status AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending'
);

CREATE TYPE access_level AS ENUM (
    'full',
    'read_only',
    'limited'
);

CREATE TYPE verification_status AS ENUM (
    'waiting',
    'needs_revision',
    'verified',
    'rejected'
);

CREATE TYPE document_type AS ENUM (
    'ktp',
    'selfie',
    'lahan'
);

CREATE TYPE auction_status AS ENUM (
    'draft',
    'active',
    'awaiting_payment',
    'ended',
    'cancelled'
);

CREATE TYPE transaction_status AS ENUM (
    'success',
    'awaiting_payment',
    'failed',
    'dispute'
);

CREATE TYPE complaint_priority AS ENUM (
    'low',
    'medium',
    'high'
);

CREATE TYPE complaint_status AS ENUM (
    'open',
    'in_progress',
    'resolved',
    'escalated'
);

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: users
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name          VARCHAR(255)  NOT NULL,
    email         CITEXT        NOT NULL,
    password_hash VARCHAR(255)  NOT NULL,
    role          user_role     NOT NULL DEFAULT 'petani',
    status        user_status   NOT NULL DEFAULT 'pending',
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT users_email_unique UNIQUE (email)
);

CREATE INDEX idx_users_role   ON users (role);
CREATE INDEX idx_users_status ON users (status);
CREATE INDEX idx_users_email  ON users (email);

COMMENT ON TABLE users IS 'Semua pengguna platform: super admin, admin, petani, pembeli, pengamat.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: admin_profiles
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE admin_profiles (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID         NOT NULL,
    access_level access_level NOT NULL DEFAULT 'limited',
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT admin_profiles_user_fk
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT admin_profiles_user_unique UNIQUE (user_id)
);

CREATE INDEX idx_admin_profiles_user_id ON admin_profiles (user_id);

COMMENT ON TABLE admin_profiles IS 'Profil tambahan untuk user dengan role admin atau super_admin.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: farmer_profiles
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE farmer_profiles (
    id                  UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID                NOT NULL,
    verification_status verification_status NOT NULL DEFAULT 'waiting',
    review_note         TEXT,
    reviewed_by         UUID,
    reviewed_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT farmer_profiles_user_fk
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT farmer_profiles_reviewed_by_fk
        FOREIGN KEY (reviewed_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT farmer_profiles_user_unique UNIQUE (user_id)
);

CREATE INDEX idx_farmer_profiles_user_id             ON farmer_profiles (user_id);
CREATE INDEX idx_farmer_profiles_reviewed_by         ON farmer_profiles (reviewed_by);
CREATE INDEX idx_farmer_profiles_verification_status ON farmer_profiles (verification_status);

COMMENT ON TABLE farmer_profiles IS 'Profil dan status verifikasi petani.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: farmer_documents
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE farmer_documents (
    id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_profile_id UUID          NOT NULL,
    type              document_type NOT NULL,
    url               TEXT          NOT NULL,
    created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT farmer_documents_profile_fk
        FOREIGN KEY (farmer_profile_id) REFERENCES farmer_profiles (id) ON DELETE CASCADE
);

CREATE INDEX idx_farmer_documents_profile_id ON farmer_documents (farmer_profile_id);
CREATE INDEX idx_farmer_documents_type        ON farmer_documents (type);

COMMENT ON TABLE farmer_documents IS 'Dokumen yang diunggah petani untuk proses verifikasi (KTP, selfie, foto lahan).';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: buyer_profiles
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE buyer_profiles (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID         NOT NULL,
    company_name VARCHAR(255),
    npwp         VARCHAR(30),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT buyer_profiles_user_fk
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT buyer_profiles_user_unique UNIQUE (user_id)
);

CREATE INDEX idx_buyer_profiles_user_id ON buyer_profiles (user_id);

COMMENT ON TABLE buyer_profiles IS 'Profil tambahan untuk pembeli (perusahaan atau individu).';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: commodities
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE commodities (
    id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(255) NOT NULL,
    unit       VARCHAR(50)  NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT commodities_name_unique UNIQUE (name)
);

COMMENT ON TABLE commodities IS 'Master data komoditas (padi, jagung, kedelai, dll.).';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: auctions
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE auctions (
    id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id        UUID           NOT NULL,
    commodity_id     UUID           NOT NULL,
    quantity         NUMERIC(15, 2) NOT NULL CHECK (quantity > 0),
    unit_price_start NUMERIC(15, 2) NOT NULL CHECK (unit_price_start > 0),
    status           auction_status NOT NULL DEFAULT 'draft',
    ends_at          TIMESTAMPTZ    NOT NULL,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

    CONSTRAINT auctions_farmer_fk
        FOREIGN KEY (farmer_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT auctions_commodity_fk
        FOREIGN KEY (commodity_id) REFERENCES commodities (id) ON DELETE RESTRICT
);

CREATE INDEX idx_auctions_farmer_id    ON auctions (farmer_id);
CREATE INDEX idx_auctions_commodity_id ON auctions (commodity_id);
CREATE INDEX idx_auctions_status       ON auctions (status);
CREATE INDEX idx_auctions_ends_at      ON auctions (ends_at);

COMMENT ON TABLE auctions IS 'Lelang komoditas yang dibuat oleh petani.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: bids
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE bids (
    id         UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    auction_id UUID           NOT NULL,
    bidder_id  UUID           NOT NULL,
    amount     NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    created_at TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

    CONSTRAINT bids_auction_fk
        FOREIGN KEY (auction_id) REFERENCES auctions (id) ON DELETE CASCADE,
    CONSTRAINT bids_bidder_fk
        FOREIGN KEY (bidder_id) REFERENCES users (id) ON DELETE RESTRICT
);

CREATE INDEX idx_bids_auction_id ON bids (auction_id);
CREATE INDEX idx_bids_bidder_id  ON bids (bidder_id);
CREATE INDEX idx_bids_amount     ON bids (auction_id, amount DESC);

COMMENT ON TABLE bids IS 'Penawaran harga yang dilakukan pembeli pada lelang.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: transactions
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE transactions (
    id           UUID               PRIMARY KEY DEFAULT gen_random_uuid(),
    auction_id   UUID,
    buyer_id     UUID               NOT NULL,
    seller_id    UUID               NOT NULL,
    commodity    VARCHAR(255)       NOT NULL,
    quantity     NUMERIC(15, 2)     NOT NULL CHECK (quantity > 0),
    total_amount NUMERIC(18, 2)     NOT NULL CHECK (total_amount > 0),
    status       transaction_status NOT NULL DEFAULT 'awaiting_payment',
    created_at   TIMESTAMPTZ        NOT NULL DEFAULT NOW(),

    CONSTRAINT transactions_auction_fk
        FOREIGN KEY (auction_id) REFERENCES auctions (id) ON DELETE SET NULL,
    CONSTRAINT transactions_buyer_fk
        FOREIGN KEY (buyer_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT transactions_seller_fk
        FOREIGN KEY (seller_id) REFERENCES users (id) ON DELETE RESTRICT
);

CREATE INDEX idx_transactions_auction_id  ON transactions (auction_id);
CREATE INDEX idx_transactions_buyer_id    ON transactions (buyer_id);
CREATE INDEX idx_transactions_seller_id   ON transactions (seller_id);
CREATE INDEX idx_transactions_status      ON transactions (status);
CREATE INDEX idx_transactions_created_at  ON transactions (created_at DESC);

COMMENT ON TABLE transactions IS 'Rekaman transaksi jual-beli komoditas.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: investments
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE investments (
    id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id        UUID           NOT NULL,
    investor_id      UUID           NOT NULL,
    project_name     VARCHAR(255)   NOT NULL,
    amount           NUMERIC(18, 2) NOT NULL CHECK (amount > 0),
    profit_share_pct NUMERIC(5, 2)  NOT NULL CHECK (profit_share_pct BETWEEN 0 AND 100),
    status           VARCHAR(50)    NOT NULL DEFAULT 'active',
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

    CONSTRAINT investments_farmer_fk
        FOREIGN KEY (farmer_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT investments_investor_fk
        FOREIGN KEY (investor_id) REFERENCES users (id) ON DELETE RESTRICT
);

CREATE INDEX idx_investments_farmer_id   ON investments (farmer_id);
CREATE INDEX idx_investments_investor_id ON investments (investor_id);
CREATE INDEX idx_investments_status      ON investments (status);

COMMENT ON TABLE investments IS 'Investasi / pendanaan proyek pertanian.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: complaints
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE complaints (
    id          UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID              NOT NULL,
    category    VARCHAR(255)      NOT NULL,
    summary     VARCHAR(500)      NOT NULL,
    description TEXT              NOT NULL,
    priority    complaint_priority NOT NULL DEFAULT 'medium',
    status      complaint_status  NOT NULL DEFAULT 'open',
    assigned_to UUID,
    created_at  TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ       NOT NULL DEFAULT NOW(),

    CONSTRAINT complaints_reporter_fk
        FOREIGN KEY (reporter_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT complaints_assigned_to_fk
        FOREIGN KEY (assigned_to) REFERENCES users (id) ON DELETE SET NULL
);

CREATE INDEX idx_complaints_reporter_id  ON complaints (reporter_id);
CREATE INDEX idx_complaints_assigned_to  ON complaints (assigned_to);
CREATE INDEX idx_complaints_status       ON complaints (status);
CREATE INDEX idx_complaints_priority     ON complaints (priority);
CREATE INDEX idx_complaints_created_at   ON complaints (created_at DESC);

COMMENT ON TABLE complaints IS 'Pengaduan / keluhan yang diajukan pengguna.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: complaint_replies
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE complaint_replies (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID        NOT NULL,
    author_id    UUID        NOT NULL,
    body         TEXT        NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT complaint_replies_complaint_fk
        FOREIGN KEY (complaint_id) REFERENCES complaints (id) ON DELETE CASCADE,
    CONSTRAINT complaint_replies_author_fk
        FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE RESTRICT
);

CREATE INDEX idx_complaint_replies_complaint_id ON complaint_replies (complaint_id);
CREATE INDEX idx_complaint_replies_author_id    ON complaint_replies (author_id);

COMMENT ON TABLE complaint_replies IS 'Balasan / tanggapan pada setiap thread pengaduan.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: system_settings
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE system_settings (
    key        VARCHAR(100) PRIMARY KEY,
    value      JSONB        NOT NULL,
    updated_by UUID,
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT system_settings_updated_by_fk
        FOREIGN KEY (updated_by) REFERENCES users (id) ON DELETE SET NULL
);

COMMENT ON TABLE system_settings IS 'Konfigurasi sistem platform (key-value, value disimpan sebagai JSONB).';

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: audit_logs
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE audit_logs (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id   UUID,
    actor_name VARCHAR(255) NOT NULL,
    action     VARCHAR(255) NOT NULL,
    module     VARCHAR(100) NOT NULL,
    ip_address INET,
    meta       JSONB        NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT audit_logs_actor_fk
        FOREIGN KEY (actor_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE INDEX idx_audit_logs_actor_id   ON audit_logs (actor_id);
CREATE INDEX idx_audit_logs_module     ON audit_logs (module);
CREATE INDEX idx_audit_logs_action     ON audit_logs (action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs (created_at DESC);

COMMENT ON TABLE audit_logs IS 'Log semua aksi tulis admin untuk keperluan audit trail.';

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER: auto-update updated_at
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_complaints_updated_at
    BEFORE UPDATE ON complaints
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─────────────────────────────────────────────────────────────────────────────
-- SEED DATA
-- ─────────────────────────────────────────────────────────────────────────────

-- Super Admin: bagas@panenara.id / Admin123!
-- Password hash (bcrypt, cost 10) di-generate saat runtime; gunakan bcrypt.hash('Admin123!', 10)
INSERT INTO users (id, name, email, password_hash, role, status)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Bagas Nugroho',
    'bagas@panenara.id',
    '$2b$10$REPLACE_WITH_BCRYPT_HASH_OF_Admin123!',  -- ganti dengan hash asli
    'super_admin',
    'active'
);

INSERT INTO admin_profiles (user_id, access_level)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'full');

-- Admin Ops: rina@panenara.id / Admin123!
INSERT INTO users (id, name, email, password_hash, role, status)
VALUES (
    'b2c3d4e5-f6a7-8901-bcde-f12345678901',
    'Rina Lestari',
    'rina@panenara.id',
    '$2b$10$REPLACE_WITH_BCRYPT_HASH_OF_Admin123!',  -- ganti dengan hash asli
    'admin',
    'active'
);

INSERT INTO admin_profiles (user_id, access_level)
VALUES ('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'full');

-- Seed komoditas dasar
INSERT INTO commodities (name, unit) VALUES
    ('Padi IR64',      'kg'),
    ('Jagung Hibrida', 'kg'),
    ('Kedelai',        'kg'),
    ('Cabai Merah',    'kg'),
    ('Bawang Merah',   'kg');

-- Seed pengaturan sistem awal
INSERT INTO system_settings (key, value, updated_by) VALUES
    ('platform_fee_pct',  '2.5',              'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
    ('maintenance_mode',  'false',             'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
    ('support_email',     '"support@panenara.id"', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
    ('max_bid_extension_minutes', '10',        'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
    ('min_bid_increment_pct', '1.0',           'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
