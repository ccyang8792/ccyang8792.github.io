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
on gac.userId=p.id
where playerId=1002129
group by p.player


---EScore = (TotalSession * .4) + (Events/Session *.1) + (ActiveDays * .5) 

---Loyalty = (AvgDurationSession *.25) + (AvgMoneySpent.75)

---Choosing to weight SessionDuration and CurrencySpent
select avg(sessionDurationMinutes) as avgSession, AVG(case when currencyspent<>0 then currencySpent end) as AvgSpent
from GamesActivityClean

--Checking Currency Spent Column
select sum(currencySpent) as MoneySpent, count(case when currencySpent <>0 then currencySpent end) as Counts
from GamesActivityClean
where playerId=1002129




