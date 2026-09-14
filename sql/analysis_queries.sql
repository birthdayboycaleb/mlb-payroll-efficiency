-- 1. Validate imported data
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT team_abbreviation) AS teams,
    COUNT(DISTINCT season) AS seasons
FROM team_seasons;


-- 2. Highest-payroll team seasons
SELECT
    team_name,
    season,
    payroll_millions,
    wins,
    win_percentage,
    playoff_qualified
FROM team_seasons
ORDER BY payroll_millions DESC
LIMIT 10;


-- 3. Most wins
SELECT
    team_name,
    season,
    wins,
    payroll_millions,
    payroll_vs_league_avg_pct,
    playoff_qualified
FROM team_seasons
ORDER BY wins DESC, payroll_millions ASC
LIMIT 10;


-- 4. Above-versus-below-average payroll
SELECT
    CASE
        WHEN payroll_vs_league_avg_pct >= 100
            THEN 'At or above league average'
        ELSE 'Below league average'
    END AS payroll_group,
    COUNT(*) AS team_seasons,
    ROUND(AVG(wins), 1) AS average_wins,
    ROUND(AVG(win_percentage), 3) AS average_win_percentage,
    ROUND(AVG(playoff_qualified) * 100, 1) AS playoff_rate_pct
FROM team_seasons
GROUP BY payroll_group
ORDER BY average_wins DESC;


-- 5. Payroll trends by season
SELECT
    season,
    ROUND(AVG(payroll_millions), 2) AS average_payroll_millions,
    ROUND(MIN(payroll_millions), 2) AS lowest_payroll_millions,
    ROUND(MAX(payroll_millions), 2) AS highest_payroll_millions
FROM team_seasons
GROUP BY season
ORDER BY season;


-- 6. Efficient winning seasons
SELECT
    team_name,
    season,
    wins,
    win_percentage,
    payroll_millions,
    payroll_vs_league_avg_pct,
    wins_per_million,
    postseason_result
FROM team_seasons
WHERE payroll_vs_league_avg_pct < 100
  AND wins >= 90
ORDER BY wins_per_million DESC
LIMIT 15;


-- 7. Teams with repeated efficient winning seasons
SELECT
    team_name,
    COUNT(*) AS efficient_winning_seasons,
    ROUND(AVG(wins), 1) AS average_wins,
    ROUND(AVG(payroll_vs_league_avg_pct), 1) AS average_payroll_pct,
    ROUND(AVG(wins_per_million), 3) AS average_wins_per_million
FROM team_seasons
WHERE payroll_vs_league_avg_pct < 100
  AND wins >= 90
GROUP BY team_name
HAVING COUNT(*) >= 2
ORDER BY efficient_winning_seasons DESC,
         average_wins_per_million DESC;


-- 8. High-spending underperformers
SELECT
    team_name,
    season,
    wins,
    payroll_millions,
    payroll_vs_league_avg_pct,
    postseason_result
FROM team_seasons
WHERE payroll_vs_league_avg_pct >= 100
  AND wins < 81
  AND playoff_qualified = 0
ORDER BY payroll_vs_league_avg_pct DESC;


-- 9. Consistent high-spending teams
SELECT
    team_name,
    ROUND(AVG(payroll_vs_league_avg_pct), 1) AS average_payroll_pct,
    ROUND(AVG(wins), 1) AS average_wins,
    SUM(playoff_qualified) AS playoff_seasons
FROM team_seasons
GROUP BY team_name
HAVING AVG(payroll_vs_league_avg_pct) >= 120
ORDER BY average_payroll_pct DESC;