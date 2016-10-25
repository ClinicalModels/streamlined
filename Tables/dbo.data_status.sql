CREATE TABLE [dbo].[data_status]
(
[Checkin_Date] [date] NULL,
[cycle_min_kept_readyforprovider] [int] NULL,
[cycle_min_kept_checkedout] [int] NULL,
[cycle_min_kept_charted] [int] NULL,
[cycle_min_readyforprovider_checkout] [int] NULL,
[enc_id] [uniqueidentifier] NOT NULL,
[user_readyforprovider] [int] NULL,
[user_checkout] [int] NULL,
[user_charted] [int] NULL,
[user_provider] [int] NULL,
[start_datetime] [datetime] NULL,
[end_datetime] [datetime] NULL
) ON [PRIMARY]
GO
