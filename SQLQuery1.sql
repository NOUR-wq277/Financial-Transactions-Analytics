/* =========================
   MERCHANT CATEGORY
   ========================= */
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_merchant_category')
BEGIN
    ALTER TABLE dbo.merchant_category ALTER COLUMN mcc_code BIGINT NOT NULL;
    ALTER TABLE dbo.merchant_category ADD CONSTRAINT PK_merchant_category PRIMARY KEY (mcc_code);
END

/* =========================
   TRANSACTIONS
   ========================= */
-- Drop PK first if blocking alter
IF EXISTS (SELECT * FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.Transactions') AND name LIKE 'PK%')
BEGIN
    ALTER TABLE dbo.Transactions DROP CONSTRAINT [PK_Transactions];
END

-- Alter columns safely
ALTER TABLE dbo.Transactions ALTER COLUMN clean_id BIGINT NOT NULL;
ALTER TABLE dbo.Transactions ALTER COLUMN original_id BIGINT NULL;
ALTER TABLE dbo.Transactions ALTER COLUMN client_id BIGINT NULL;
ALTER TABLE dbo.Transactions ALTER COLUMN card_id BIGINT NULL;
ALTER TABLE dbo.Transactions ALTER COLUMN mcc BIGINT NULL;

-- Re-add PK
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Transactions')
BEGIN
    ALTER TABLE dbo.Transactions ADD CONSTRAINT PK_Transactions PRIMARY KEY (clean_id);
END

/* =========================
   FOREIGN KEYS
   ========================= */
-- Cards ↔ Users
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Cards_Users')
ALTER TABLE dbo.cards_data
ADD CONSTRAINT FK_Cards_Users 
FOREIGN KEY (client_id) REFERENCES dbo.users_data(id);

-- Transactions ↔ Users
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Transactions_Users')
ALTER TABLE dbo.Transactions
ADD CONSTRAINT FK_Transactions_Users 
FOREIGN KEY (client_id) REFERENCES dbo.users_data(id);

-- Transactions ↔ Cards
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Transactions_Cards')
ALTER TABLE dbo.Transactions
ADD CONSTRAINT FK_Transactions_Cards 
FOREIGN KEY (card_id) REFERENCES dbo.cards_data(id);

-- Transactions ↔ Merchant Category
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Transactions_MerchantCategory')
ALTER TABLE dbo.Transactions
ADD CONSTRAINT FK_Transactions_MerchantCategory 
FOREIGN KEY (mcc) REFERENCES dbo.merchant_category(mcc_code);

-- Labels ↔ Transactions
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Labels_Transactions')
ALTER TABLE dbo.train_fraud_labels
ADD CONSTRAINT FK_Labels_Transactions 
FOREIGN KEY (transaction_id) REFERENCES dbo.Transactions(clean_id);
EXEC sp_help 'dbo.Transactions';
EXEC sp_help 'dbo.cards_data';
EXEC sp_help 'dbo.users_data';
EXEC sp_help 'dbo.merchant_category';
EXEC sp_help 'dbo.train_fraud_labels';
-- List columns that should be BIGINT but are not
/* ============= DROP OLD FKs IF EXIST ============= */
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Cards_Users')
    ALTER TABLE dbo.cards_data DROP CONSTRAINT FK_Cards_Users;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Transactions_Users')
    ALTER TABLE dbo.Transactions DROP CONSTRAINT FK_Transactions_Users;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Transactions_Cards')
    ALTER TABLE dbo.Transactions DROP CONSTRAINT FK_Transactions_Cards;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Transactions_MerchantCategory')
    ALTER TABLE dbo.Transactions DROP CONSTRAINT FK_Transactions_MerchantCategory;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Labels_Transactions')
    ALTER TABLE dbo.train_fraud_labels DROP CONSTRAINT FK_Labels_Transactions;

/* ============= RE-ADD CLEAN FKs ============= */
ALTER TABLE dbo.cards_data
    WITH CHECK ADD CONSTRAINT FK_Cards_Users 
    FOREIGN KEY (client_id) REFERENCES dbo.users_data(id);

ALTER TABLE dbo.Transactions
    WITH CHECK ADD CONSTRAINT FK_Transactions_Users 
    FOREIGN KEY (client_id) REFERENCES dbo.users_data(id);

ALTER TABLE dbo.Transactions
    WITH CHECK ADD CONSTRAINT FK_Transactions_Cards 
    FOREIGN KEY (card_id) REFERENCES dbo.cards_data(id);

ALTER TABLE dbo.Transactions
    WITH CHECK ADD CONSTRAINT FK_Transactions_MerchantCategory 
    FOREIGN KEY (mcc) REFERENCES dbo.merchant_category(mcc_code);

ALTER TABLE dbo.train_fraud_labels
    WITH CHECK ADD CONSTRAINT FK_Labels_Transactions 
    FOREIGN KEY (transaction_id) REFERENCES dbo.Transactions(clean_id);

	SELECT 
    fk.name AS FK_Name,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS RefTable,
    cr.name AS RefColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id;
