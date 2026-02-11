Use GA_Updated;

with Engage as(
select p.player,
count(distinct matchid) as TotalSession,
    COUNT(
        DISTINCT CASE
            WHEN gac.eventTimestamp >= DATEADD(day, -30, GETDATE())
            THEN gac.matchid
        END
    ) AS Sessions30Days,
count(*)*1.0/(count(distinct matchid)*1.0) as EventsPerSession,
count(distinct cast(eventTimestamp as date)) as ActiveDays,
avg(sessionDurationMinutes) as AvgDurationSessions,
round(STDEVP(sessionDurationMinutes),2) as SessionVariability,
avg(case when currencySpent<> 0 then currencySpent end) as AvgMoneySpent
from GamesActivityClean gac
join Players p
on gac.userid=p.id
join Platforms pt
on gac.platformid=pt.id
join Games g
on gac.gameid=g.id
join Regions r
on gac.regionid=r.id
group by p.player),
---select* from Engage

Features as(
select player,
SessionVariability,
(AvgMoneySpent*.75)+ (AvgDurationSessions*.25) as Loyalty,
(TotalSession*.4) + (EventsPerSession*.1) + (ActiveDays*.5) as EScore,
case when AvgDurationSessions>120 and TotalSession <5 then 'Marathon' when AvgDurationSessions<60 and TotalSession >10 then 'Burst' else 'Balance' end as PlayStyle,
Sessions30Days*1.0/(TotalSession) as RecentActivityRatio
from Engage),
---select * from Features


Analysis as (
select *,
case when EScore < ((max(EScore) over()-min(EScore)over())/3) + min(EScore)over() then 'Casual' when EScore > max(EScore)over()-((max(EScore)over()-min(EScore)over())/3) then 'Hardcore' else 'Core' end as EType,
case when Loyalty < ((max(Loyalty) over()-min(Loyalty)over())/3) + min(Loyalty)over() then 'Low' when Loyalty > max(Loyalty)over()-((max(Loyalty)over()-min(Loyalty)over())/3) then 'High' else 'Medium' end as UserValue
from Features)
---select* from Analysis


select player,
cast(EScore as decimal(4,2)) as EScore,
EType,
PlayStyle, 
SessionVariability as SessionVariance, 
cast(RecentActivityRatio as decimal(4,2)) as RecentActivityRatio,
cast(Loyalty as decimal(5,2)) as Loyalty,
UserValue, rank() over (order by EScore desc) as EScoreRank
from Analysis


