CREATE TABLE [dbo].[data_schedule_slots]
(
[schedule_resource_key] [int] NULL,
[slot_loc_key] [int] NULL,
[category_key] [int] NULL,
[resource_id] [uniqueidentifier] NULL,
[provider_id] [uniqueidentifier] NULL,
[location_id] [uniqueidentifier] NULL,
[category_id] [uniqueidentifier] NULL,
[appt_date] [date] NULL,
[slot_time] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[slot_duration] [int] NULL,
[nbr_slots_can_appt] [int] NULL,
[nbr_slots_open_07am] [int] NULL,
[nbr_slots_open_final] [int] NULL,
[nbr_slots_open_07am_any] [int] NULL,
[nbr_slots_open_final_any] [int] NULL,
[nbr_slots_available] [int] NULL,
[nbr_slots_overbook] [int] NULL,
[resource_key] [int] NULL,
[slot_key] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
