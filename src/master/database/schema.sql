
PRAGMA foreign_keys = ON;

-- 1. URL registry and crawl frontier
CREATE TABLE IF NOT EXISTS urls (
    url TEXT PRIMARY KEY,

    depth INTEGER NOT NULL DEFAULT 0
        CHECK (depth >= 0),

    is_seed INTEGER NOT NULL DEFAULT 0
        CHECK (is_seed IN (0, 1)),

    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending', 'queued', 'crawling',
            'crawled', 'failed', 'skipped'
        )),

    attempts INTEGER NOT NULL DEFAULT 0
        CHECK (attempts >= 0),

    assigned_worker TEXT,
    lease_expires_at TEXT,

    discovered_at TEXT NOT NULL,
    last_crawled_at TEXT,
    next_crawl_at TEXT,
    last_error TEXT
);


-- 2. Latest stored version of each webpage
CREATE TABLE IF NOT EXISTS pages (
    url TEXT PRIMARY KEY
        REFERENCES urls(url) ON DELETE CASCADE,

    title TEXT,
    description TEXT,
    language TEXT,
    content_type TEXT,
    status_code INTEGER,

    extracted_text TEXT,

    -- Optional HTML snapshots stored outside SQLite
    raw_html_path TEXT,
    rendered_html_path TEXT,

    content_hash TEXT,
    is_usable INTEGER NOT NULL DEFAULT 0
        CHECK (is_usable IN (0, 1)),

    word_count INTEGER,
    crawled_at TEXT NOT NULL
);


-- 3. Links discovered on crawled pages
CREATE TABLE IF NOT EXISTS links (
    id INTEGER PRIMARY KEY,

    crawl_run_id INTEGER NOT NULL
        REFERENCES crawl_runs(id) ON DELETE CASCADE,

    source_url TEXT NOT NULL REFERENCES urls(url),
    target_url TEXT NOT NULL REFERENCES urls(url),

    anchor_text TEXT,
    rel TEXT,

    UNIQUE (crawl_run_id, source_url, target_url, anchor_text)
);


-- 4. Image occurrences found on webpages
CREATE TABLE IF NOT EXISTS assets (
    id INTEGER PRIMARY KEY,

    crawl_run_id INTEGER NOT NULL
        REFERENCES crawl_runs(id) ON DELETE CASCADE,

    source_url TEXT NOT NULL REFERENCES urls(url),
    image_url TEXT NOT NULL,

    alt_text TEXT,
    title TEXT,
    caption TEXT,

    srcset TEXT,
    mime_type TEXT,

    width INTEGER,
    height INTEGER,
    element_index INTEGER,

    discovered_at TEXT NOT NULL
);


-- 5. History of individual crawl attempts
CREATE TABLE IF NOT EXISTS crawl_runs (
    id INTEGER PRIMARY KEY,

    url TEXT NOT NULL REFERENCES urls(url),
    worker_id TEXT,

    started_at TEXT NOT NULL,
    finished_at TEXT,

    outcome TEXT NOT NULL DEFAULT 'running'
        CHECK (outcome IN (
            'running', 'success', 'failed', 'timeout', 'rejected'
        )),

    status_code INTEGER,
    duration_ms INTEGER,
    error_message TEXT
);


-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_urls_status_depth
    ON urls(status, depth);

CREATE INDEX IF NOT EXISTS idx_urls_lease
    ON urls(status, lease_expires_at);

CREATE INDEX IF NOT EXISTS idx_urls_next_crawl
    ON urls(status, next_crawl_at);

CREATE INDEX IF NOT EXISTS idx_pages_usable
    ON pages(is_usable);

CREATE INDEX IF NOT EXISTS idx_pages_content_hash
    ON pages(content_hash);

CREATE INDEX IF NOT EXISTS idx_links_source
    ON links(source_url);

CREATE INDEX IF NOT EXISTS idx_links_target
    ON links(target_url);

CREATE INDEX IF NOT EXISTS idx_assets_source
    ON assets(source_url);

CREATE INDEX IF NOT EXISTS idx_assets_image
    ON assets(image_url);

CREATE INDEX IF NOT EXISTS idx_assets_run
    ON assets(crawl_run_id);

CREATE INDEX IF NOT EXISTS idx_runs_url
    ON crawl_runs(url, started_at);
