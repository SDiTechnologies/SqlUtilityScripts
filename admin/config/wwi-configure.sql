USE WideWorldImporters;
GO

-- Enable full text indexing
EXECUTE [Application].[Configuration_ApplyFullTextIndexing];

-- Enable sql server auditing
EXECUTE [Application].[Configuration_ApplyAuditing];

-- Enable row level security
EXECUTE [Application].[Configuration_ApplyRowLevelSecurity];
