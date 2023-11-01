<H2>Import data in SQL:</H2>

NB: ServerID is retrieved from ServerInfo.tsv file that must be present inside the zip, and it is required if importing the same information from different sources (different domains, for example), otherwise the importer will overwrite the table with the last imported file <BR>
The script must copy a zip file with the ServerInfo and data tsv files into the tools machine Client shared folder.<BR>
ServerInfo tsv file example:<BR>
```
ServerFqdn	Authority	NetbiosDomainName	ServerSID	Timestamp	GUID	sAMAccountName	ForestRootDNS
eucontosodc1.eu.contoso.com	eu.contoso.com	EU	S-1-5-21-1040395697-135212947-117614780-1001	2023-10-18 11:01:01.239	821426bf-0de0-468a-aa7d-61a062a22978	eucontosodc1	contoso.com
```
data tsv file example <BR>
```
DisplayName	SamAccountName	ObjectSID	ID	extensionattribute1	extensionattribute2	extensionattribute3	extensionattribute4	extensionattribute5	extensionattribute6	extensionattribute7	extensionattribute8	extensionattribute9	extensionattribute10	extensionattribute11	extensionattribute12	extensionattribute13	extensionattribute14	extensionattribute15 managedBy
aclxrayuser1	aclxrayuser1	S-1-5-21-3281217239-1686206460-833741877-33604	74fb78b3-dc38-4355-a3f1-0e78a0e7b853	EMSE5	ID 53042901V	Marketing												
```

1. Create custom table in ACLXRAy DB. <BR>
``` sql
USE [ACLXRAY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CT_USER_EXTENDEDATTR](
	[Id] [uniqueidentifier] NOT NULL,
	[ObjectSID] [varchar](64) NOT NULL,
	[ServerID] [uniqueidentifier] NOT NULL,
	[extensionattribute1] [nvarchar](1024) NULL,
	[extensionattribute2] [nvarchar](1024) NULL,
	[extensionattribute3] [nvarchar](1024) NULL,
	[extensionattribute4] [nvarchar](1024) NULL,
	[extensionattribute5] [nvarchar](1024) NULL,
	[extensionattribute6] [nvarchar](1024) NULL,
	[extensionattribute7] [nvarchar](1024) NULL,
	[extensionattribute8] [nvarchar](1024) NULL,
	[extensionattribute9] [nvarchar](1024) NULL,
	[extensionattribute10] [nvarchar](1024) NULL,
	[extensionattribute11] [nvarchar](1024) NULL,
	[extensionattribute12] [nvarchar](1024) NULL,
	[extensionattribute13] [nvarchar](1024) NULL,
	[extensionattribute14] [nvarchar](1024) NULL,
	[extensionattribute15] [nvarchar](1024) NULL,
	[managedBy] [nvarchar](1024) NULL,
	[DisplayName] [nvarchar](256) NULL,
	[SamAccountName] [nvarchar](256) NULL,
 CONSTRAINT [PK_CT_USER_EXTENDEDATTR] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CT_USER_EXTENDEDATTR]  WITH CHECK ADD  CONSTRAINT [FK_CT_USER_EXTENDEDATTR_SERVER_INFO] FOREIGN KEY([ServerID])
REFERENCES [dbo].[SERVER_INFO] ([Id])
GO

ALTER TABLE [dbo].[CT_USER_EXTENDEDATTR] CHECK CONSTRAINT [FK_CT_USER_EXTENDEDATTR_SERVER_INFO]
GO
```

2. Add custom_map.txt to C:\ACLXRAY\DEPLOY\Format-V2
```
extendedattributes, CT_USER_EXTENDEDATTR
```
3. Copy CustomCollector_ExtendedAttributes.ps1 script to \\contoso.com\NETLOGON\ACLXRAY
4. Add CustomCollector_ExtendedAttributes.ps1 script execution to \\contoso.com\NETLOGON\ACLXRAY\Get-DedicatedDC.cmd

powershell.exe .\CustomCollector_ExtendedAttributes.ps1

Report generation <BR>
For example, to add the information to the user information report: <BR>
1. Add columns to T_REP_USER_INFORMATION
``` SQL
ALTER TABLE [dbo].[T_REP_USER_INFORMATION]
ADD [extensionattribute1] [nvarchar](1024) NULL,
	[extensionattribute2] [nvarchar](1024) NULL,
	[extensionattribute3] [nvarchar](1024) NULL,
	[extensionattribute4] [nvarchar](1024) NULL,
	[extensionattribute5] [nvarchar](1024) NULL,
	[extensionattribute6] [nvarchar](1024) NULL,
	[extensionattribute7] [nvarchar](1024) NULL,
	[extensionattribute8] [nvarchar](1024) NULL,
	[extensionattribute9] [nvarchar](1024) NULL,
	[extensionattribute10] [nvarchar](1024) NULL,
	[extensionattribute11] [nvarchar](1024) NULL,
	[extensionattribute12] [nvarchar](1024) NULL,
	[extensionattribute13] [nvarchar](1024) NULL,
	[extensionattribute14] [nvarchar](1024) NULL,
	[extensionattribute15] [nvarchar](1024) NULL,
	[managedBy] [nvarchar](1024) NULL
GO
```
2. Add columns to T_REP_GROUP_EXPANSION
``` SQL
ALTER TABLE [dbo].[T_REP_GROUP_EXPANSION]
ADD [extensionattribute1] [nvarchar](1024) NULL,
	[extensionattribute2] [nvarchar](1024) NULL,
	[extensionattribute3] [nvarchar](1024) NULL,
	[extensionattribute4] [nvarchar](1024) NULL,
	[extensionattribute5] [nvarchar](1024) NULL,
	[extensionattribute6] [nvarchar](1024) NULL,
	[extensionattribute7] [nvarchar](1024) NULL,
	[extensionattribute8] [nvarchar](1024) NULL,
	[extensionattribute9] [nvarchar](1024) NULL,
	[extensionattribute10] [nvarchar](1024) NULL,
	[extensionattribute11] [nvarchar](1024) NULL,
	[extensionattribute12] [nvarchar](1024) NULL,
	[extensionattribute13] [nvarchar](1024) NULL,
	[extensionattribute14] [nvarchar](1024) NULL,
	[extensionattribute15] [nvarchar](1024) NULL,
	[managedBy] [nvarchar](1024) NULL
GO
```
3. Modify sp_CreateUserInformationReport adding the new columns
``` SQL
USE [ACLXRAY]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateUserInformationReport]    Script Date: 10/18/2023 11:50:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paolo Monti
-- Create date: 2019-12-09
-- Modify date: 2020-01-14
-- Modify date: 2021-02-26 - Changed the way the table is purged of Gen0 items
-- Modify date: 2022-05-18 - Added OwnerName column
-- Description:	This procedure processes the User Information report
-- =============================================
ALTER PROCEDURE [dbo].[sp_CreateUserInformationReport] 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Init
	if exists (select * from INFORMATION_SCHEMA.TABLES t where t.TABLE_NAME = 'T_REP_USER_INFORMATION')
	begin
		SELECT TOP 0 * into #tmp FROM T_REP_USER_INFORMATION
		insert #tmp
		select [Id]
      ,[Date]
      ,[Action]
      ,[CKey]
      ,0 as [Gen]
      ,[TrusteeID]
      ,[Sam]
      ,[Domain]
      ,[Sid]
      ,[ObjectClass]
      ,[DisplayName]
      ,[Desc]
      ,[DN]
      ,[ModifiedDate]
      ,[WhenCreated]
      ,[WhenChanged]
      ,[Enabled]
      ,[FirstName]
      ,[LastName]
      ,[PasswordLastSet]
      ,[LastLogon]
      ,[PasswordNeverExpires]
      ,[UserCannotChangePassword]
      ,[ExchMasterAccountSid]
      ,[UPN]
      ,[UAC]
      ,[BadPasswordTime]
      ,[AccountExpires]
      ,[AllowedToDelegateTo]
      ,[KeyVersionNumber]
      ,[LastLogonTimestamp]
	  ,[OwnerName]
	  ,[Owner]
	  ,[extensionattribute1]
      ,[extensionattribute2]
      ,[extensionattribute3]
      ,[extensionattribute4]
      ,[extensionattribute5]
      ,[extensionattribute6]
      ,[extensionattribute7]
      ,[extensionattribute8]
      ,[extensionattribute9]
      ,[extensionattribute10]
      ,[extensionattribute11]
      ,[extensionattribute12]
      ,[extensionattribute13]
      ,[extensionattribute14]
      ,[extensionattribute15]
	  ,[managedBy]
	  from T_REP_USER_INFORMATION R
	  WHERE R.Gen = 1
	  
	  truncate table T_REP_USER_INFORMATION
	  
	  insert T_REP_USER_INFORMATION
	  select * from #tmp
	  
	  drop table #tmp
	end
	if exists (select * from sys.indexes t where t.name = 'IDX_T_REP_USER_INFORMATION_CKEY')
		drop index IDX_T_REP_USER_INFORMATION_CKEY on T_REP_USER_INFORMATION
	if exists (select * from sys.indexes t where t.name = 'IDX_T_REP_USER_INFORMATION_GEN')
		drop index IDX_T_REP_USER_INFORMATION_GEN on T_REP_USER_INFORMATION

	declare @dt datetime2(3) = getdate()
	insert T_REP_USER_INFORMATION
	select
	NEWID()
	,@dt
	,1
	,HASHBYTES('SHA2_256',T.Authority+T.Sid+T.ObjectClass)
	,1, 
	T.Id,	
	T.SamAccountName as Sam,
	T.Authority as Domain,
	T.SID,		
	T.ObjectClass,
	T.DisplayName,
	T.Description as [Desc],
	T.DistinguishedName as DN,
	T.ModifiedDate,
	T.WhenCreated,
	T.WhenChanged,
	P.Enabled,		
	P.FirstName,
	P.LastName,
	P.LastPasswordSet as PasswordLastSet,
	P.LastLogon,	
	P.PasswordNeverExpires,
	P.UserCannotChangePassword,
	P.ExchMasterAccountSid,
	P.UPN,
	P.UAC,					
	P.BadPasswordTime,
	P.AccountExpires,
	P.AllowedToDelegateTo,
	P.KeyVersionNumber,
	P.LastLogonTimestamp
	,O.Name
	,O.SID
	,A.extensionattribute1
    ,A.extensionattribute2
    ,A.extensionattribute3
    ,A.extensionattribute4
    ,A.extensionattribute5
    ,A.extensionattribute6
    ,A.extensionattribute7
    ,A.extensionattribute8
    ,A.extensionattribute9
    ,A.extensionattribute10
    ,A.extensionattribute11
	,A.extensionattribute12
    ,A.extensionattribute13
    ,A.extensionattribute14
    ,A.extensionattribute15
	,A.managedBy
	from Trustees T
	join TrusteesAsPrincipals P on P.Id = T.Id
	join CT_USER_EXTENDEDATTR A on A.Id = T.Id
	left outer join Trustees O on O.Sid = T.OwnerSid
	checkpoint;
	
	create nonclustered index IDX_T_REP_USER_INFORMATION_CKEY on [T_REP_USER_INFORMATION] (Ckey)
	create nonclustered index IDX_T_REP_USER_INFORMATION_GEN on [T_REP_USER_INFORMATION] (Gen, Action) include(CKey)
END
```
4. Modify sp_CreateGroupExpansionReport adding the new columns
```SQL
USE [ACLXRAY]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateGroupExpansionReport]    Script Date: 10/19/2023 5:11:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paolo Monti
-- Create date: 2019-11-30
-- Modified date: 2019-12-02
-- Modified date: 2020-01-21
-- Modified date: 2020-04-21 - adjusted delete batch size and added checkpoint
-- Modified date: 2021-02-26 - Changed how the table is purged from Gen0 entries
-- Modified date: 2021-03-01 - added option (maxdop 1)
-- Description:	This procedure insert GroupExpansion data into the corresponding table
-- =============================================
ALTER PROCEDURE [dbo].[sp_CreateGroupExpansionReport] 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @tm datetime2(3) = getdate()
	-- Init
	print 'Started at '+convert(nvarchar,getdate())

	if exists (select * from sys.indexes S where S.name = 'IDX_T_REP_GROUP_EXPANSION_CKEY')
		drop index IDX_T_REP_GROUP_EXPANSION_CKEY ON [dbo].[T_REP_GROUP_EXPANSION]
	if exists (select * from sys.indexes S where S.name = 'IDX_T_REP_GROUP_EXPANSION_GEN')
		drop index IDX_T_REP_GROUP_EXPANSION_GEN ON [dbo].[T_REP_GROUP_EXPANSION]


	print 'Deleting Gen0 items'
	select top 0 * into #tmp from T_REP_GROUP_EXPANSION
	insert #tmp select 
		[Id]
      ,[Date]
      ,[Action]
      ,[CKey]
      ,0 as Gen
      ,[TrusteeID]
      ,[GroupName]
      ,[GroupSAM]
      ,[GroupDomain]
      ,[GroupScope]
      ,[GroupDN]
      ,[MemberName]
      ,[MemberSAM]
      ,[MemberDomain]
      ,[MemberObjectClass]
      ,[MembershipType]
      ,[MemberDN]
      ,[TotalGroup]
      ,[ExplicitGroup]
      ,[NestedGroup]
      ,[TotalUser]
      ,[ExplicitUser]
      ,[NestedUser]
      --,[IsCircular]
	  ,[GroupSID]
	  ,[extensionattribute1]
      ,[extensionattribute2]
      ,[extensionattribute3]
      ,[extensionattribute4]
      ,[extensionattribute5]
      ,[extensionattribute6]
      ,[extensionattribute7]
      ,[extensionattribute8]
      ,[extensionattribute9]
      ,[extensionattribute10]
      ,[extensionattribute11]
      ,[extensionattribute12]
      ,[extensionattribute13]
      ,[extensionattribute14]
      ,[extensionattribute15]
	  ,[managedBy]
	  from T_REP_GROUP_EXPANSION R
	  where Gen = 1
	  
	  truncate table T_REP_GROUP_EXPANSION
	  
	  insert T_REP_GROUP_EXPANSION
	  select * from #tmp

	 drop table #tmp
	print 'Deleted Gen0 items '+ convert(nvarchar,getdate())

	
    -- Insert statements for procedure here
	print 'Inserting trustees ' + convert(nvarchar,getdate()) 
	insert T_REP_GROUP_EXPANSION
	(
	[Id],
	[Date],
	[Action],
	[CKey],
	[Gen],
	[TrusteeID],	
	GroupName,
	GroupSAM,
	GroupDomain,
	GroupScope,
	GroupDN,
	MemberName,
	MemberSAM,
	MemberDomain,
	MemberObjectClass,
	MembershipType,
	MemberDN,
	TotalGroup,
	ExplicitGroup,
	NestedGroup,
	TotalUser,
	ExplicitUser,
	NestedUser
	--,
	--IsCircular
	,[GroupSID]
	  ,[extensionattribute1]
      ,[extensionattribute2]
      ,[extensionattribute3]
      ,[extensionattribute4]
      ,[extensionattribute5]
      ,[extensionattribute6]
      ,[extensionattribute7]
      ,[extensionattribute8]
      ,[extensionattribute9]
      ,[extensionattribute10]
      ,[extensionattribute11]
      ,[extensionattribute12]
      ,[extensionattribute13]
      ,[extensionattribute14]
      ,[extensionattribute15]
	,[managedBy]
	)	
	select 
	NEWID()
	,@tm
	,1
	,HASHBYTES('SHA2_256',g.Authority+g.Sid+m.Authority+m.Sid)
	,1	
	,tg.Id,	
	g.name, g.SamAccountName, g.Authority, tg.Scope, g.DistinguishedName
	,m.name, m.SamAccountName, m.Authority, m.ObjectClass
	,case when gm.MemberId is null then 'Nested' else 'Explicit' end as MembershipType
	,m.DistinguishedName,
	S.GroupTotal,
	S.GroupDirect,
	S.GroupNested,
	S.PrincipalTotal,
	S.PrincipalDirect,
	S.PrincipalNested
	--,case when geg2.GroupId is null then 0 else 1 end as IsCircular	
	,g.Sid
	,ea.extensionattribute1
	,ea.extensionattribute2
	,ea.extensionattribute3
	,ea.extensionattribute4
	,ea.extensionattribute5
	,ea.extensionattribute6
	,ea.extensionattribute7
	,ea.extensionattribute8
	,ea.extensionattribute9
	,ea.extensionattribute10
	,ea.extensionattribute11
	,ea.extensionattribute12
	,ea.extensionattribute13
	,ea.extensionattribute14
	,ea.extensionattribute15
	,ea.managedBy
	from trusteesasgroups tg with(nolock)
	join trustees g with(nolock) on g.id = tg.id
	join GroupExpandedGroups geg with(nolock) on geg.ExpandedMemberId = tg.id
	join trustees m with(nolock) on m.id = geg.GroupId
	join CT_USER_EXTENDEDATTR ea on ea.Id = tg.Id
	left outer join GroupMembers gm with(nolock) on gm.GroupId = geg.ExpandedMemberId and gm.MemberId = geg.GroupId
	--left outer join GroupExpandedGroups geg2 with(nolock) on geg2.ExpandedMemberId = geg.GroupId and geg2.GroupId = geg.ExpandedMemberId
	join T_STATS s with(nolock) on s.TrusteeId = tg.id
	where tg.Scope <> 'local'	
	union
	select 
	NEWID()
	,@tm
	,1
	,HASHBYTES('SHA2_256',g.Authority+g.Sid+m.Authority+m.Sid)
	,1	
	,tg.Id,
	g.name, g.SamAccountName, g.Authority, tg.Scope, g.DistinguishedName
	,m.name, m.SamAccountName, m.Authority, m.ObjectClass
	,case when gm.MemberId is null then 'Nested' else 'Explicit' end as MembershipType
	,m.DistinguishedName,
	0,0,0,0,0,0
	--,0
	,g.Sid
	,ea.extensionattribute1
	,ea.extensionattribute2
	,ea.extensionattribute3
	,ea.extensionattribute4
	,ea.extensionattribute5
	,ea.extensionattribute6
	,ea.extensionattribute7
	,ea.extensionattribute8
	,ea.extensionattribute9
	,ea.extensionattribute10
	,ea.extensionattribute11
	,ea.extensionattribute12
	,ea.extensionattribute13
	,ea.extensionattribute14
	,ea.extensionattribute15
	,ea.managedBy
	from trusteesasgroups tg with(nolock)
	join trustees g with(nolock) on g.id = tg.id
	join GroupExpandedPrincipals gep with(nolock) on gep.GroupId = tg.id
	join trustees m with(nolock) on m.id = gep.ExpandedMemberId
	join CT_USER_EXTENDEDATTR ea on ea.Id = tg.Id
	left outer join GroupMembers gm with(nolock) on gm.GroupId = gep.GroupId and gm.MemberId = gep.ExpandedMemberId
	where tg.Scope <> 'local'
	--print 'Inserted groups '+convert(nvarchar,getdate())
	--checkpoint;
	--print 'Checkpoint ' + convert(nvarchar,getdate())
	option (maxdop 1)
	CREATE NONCLUSTERED INDEX [IDX_T_REP_GROUP_EXPANSION_CKEY] ON [dbo].[T_REP_GROUP_EXPANSION]
	(
		[CKey] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX [IDX_T_REP_GROUP_EXPANSION_GEN] ON [dbo].[T_REP_GROUP_EXPANSION]
	(
		[Gen] ASC
		,[Action] ASC
	)
	INCLUDE([CKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	print 'Finished '+convert(nvarchar,getdate())
END
```
5. modify "headers" and "exportQuery" in C:\ACLXRAY\DEPLOY\GenerateReports\reportGeneratorConfig.json for the "Group Expansion Report" and "User Information Report" adding the new columns<BR>

6. modify the source query in pbit for the "User Information Report" and "Group Expansion Report" tebles to include all columns (advanced editor -> Columns=##)<BR>
```
= Csv.Document(File.Contents(ReportsFolder & "\User Information Report.CSV"),[Delimiter=",", Columns=43, Encoding=65001, QuoteStyle=QuoteStyle.None])

= Csv.Document(File.Contents(ReportsFolder & "\Group Expansion Report.CSV"),[Delimiter=",", Columns=34, Encoding=65001, QuoteStyle=QuoteStyle.None])
```