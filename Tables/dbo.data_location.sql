CREATE TABLE [dbo].[data_location]
(
[location_key] [int] NOT NULL IDENTITY(1, 1),
[location_id] [uniqueidentifier] NULL,
[ud_demo3_id] [uniqueidentifier] NULL,
[healthpac_id] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_mstr_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_mh_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[site_id] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_id_unique_flag] [int] NULL,
[ecw_location_id] [int] NULL,
[location_address] [varchar] (140) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[data_location] ADD CONSTRAINT [location_pk] PRIMARY KEY CLUSTERED  ([location_key]) ON [PRIMARY]
GO
