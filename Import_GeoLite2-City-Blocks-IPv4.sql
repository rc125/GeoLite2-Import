IF OBJECT_ID('dbo.GeoLite2IPv4', 'U') IS NOT NULL DROP TABLE dbo.GeoLite2IPv4; 
CREATE TABLE [GeoLite2IPv4](
	[network] [nvarchar](64) NOT NULL,
	[geoname_id] [int] NULL,
	[registered_country_geoname_id] [int] NULL,
	[represented_country_geoname_id] [int] NULL,
	[is_anonymous_proxy] [int] NULL DEFAULT ((0)),
	[is_satellite_provider] [int] NULL DEFAULT ((0)),
	[postal_code] [nvarchar](16) NULL,
	[latitude] [decimal](9,6) NULL,
	[longitude] [decimal](9,6) NULL,
	[accuracy_radius] [int] NULL
 CONSTRAINT [PK_GeoLite2IPv4] PRIMARY KEY CLUSTERED 
(
	[network] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

--import csv file
BULK INSERT GeoLite2IPv4 
FROM 'C:\dev\GeoLite2 Import\GeoLite2-City-CSV_20160301\GeoLite2-City-Blocks-IPv4.csv'
WITH 
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '0x0a'  --Use to shift the control to next row
) 

-- add fields from legacy GeoLite database
ALTER TABLE GeoLite2IPv4 ADD startIpNum bigint NOT NULL DEFAULT 0
ALTER TABLE GeoLite2IPv4 ADD endIpNum bigint NOT NULL DEFAULT 0
GO
-- create index for ip range
--CREATE NONCLUSTERED INDEX GeoLite2_IPRange ON [dbo].[GeoLite2IPv4] ([startIpNum],[endIpNum])

-- convert CIDR notation into IP range
UPDATE GeoLite2IPv4 SET startIpNum = dbo.GetStartIp(network)
UPDATE GeoLite2IPv4 SET endIpNum = dbo.GetEndIp(startIpNum, network)
