CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    limit_amount INTEGER NOT NULL
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    date_time TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_accounts_transactions_id
        FOREIGN KEY (account_id) REFERENCES accounts(id)
);

CREATE TABLE balances (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    CONSTRAINT fk_accounts_balances_id
        FOREIGN KEY (account_id) REFERENCES accounts(id)
);

DO $$
BEGIN
    INSERT INTO accounts (id, name, limit_amount)
    VALUES
        (1, 'o barato sai caro', 1000 * 100),
        (2, 'zan corp ltda', 800 * 100),
        (3, 'les cruders', 10000 * 100),
        (4, 'padaria joia de cocaia', 100000 * 100),
        (5, 'kid mais', 5000 * 100);
    
    INSERT INTO balances (id, account_id, amount)
    VALUES
        (1, 1, 0),
        (2, 2, 0),
        (3, 3, 0),
        (4, 4, 0),
        (5, 5, 0);
END;
$$;
