CREATE TABLE [dbo].[data_zipcode]
(
[ID] [int] NOT NULL,
[ZipCode] [int] NULL,
[State] [nchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateFIBS] [int] NULL,
[CountryFIBS] [int] NULL,
[Latitide] [int] NULL,
[Longitude] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Preference] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
