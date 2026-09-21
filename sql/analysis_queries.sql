-- MLB Payroll Efficiency Analysis
-- Table: team_seasons
-- Source: mlb_payroll_efficiency_clean.csv


-- 1. Validate imported data
-- QUESTION: Does the imported table contain the expected records?
-- RESULT: 300 team-seasons, 30 teams, and 10 seasons.
-- INTERPRETATION: The full cleaned dataset was imported successfully.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT team_abbreviation) AS teams,
    COUNT(DISTINCT season) AS seasons
FROM team_seasons;


-- 2. Highest-payroll team seasons
-- QUESTION: Which team-seasons had the highest payrolls?
-- RESULT: The 2023 New York Mets ranked first at $341.67 million.
-- INTERPRETATION: The largest payroll did not guarantee a winning season or playoff appearance.
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
-- QUESTION: Which team-seasons recorded the most wins?
-- RESULT: The 2022 Los Angeles Dodgers ranked first with 111 wins.
-- INTERPRETATION: Several top-performing seasons had high payrolls, but payroll levels varied.
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
-- QUESTION: How did results differ between the two payroll groups?
-- RESULT: At-or-above-average teams won 86.1 games and reached the postseason 47.9% of the time.
--         Below-average teams won 76.4 games and reached the postseason 22.8% of the time.
-- INTERPRETATION: Higher payroll was associated with more wins and more postseason appearances.
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
-- QUESTION: How did average payroll change across the ten seasons?
-- RESULT: Average payroll increased from $119.15 million in 2014 to $166.60 million in 2024.
-- INTERPRETATION: Average payroll increased by approximately 40% over the selected period.
SELECT
    season,
    ROUND(AVG(payroll) / 1000000.0, 2) AS average_payroll_millions,
    ROUND(MIN(payroll) / 1000000.0, 2) AS lowest_payroll_millions,
    ROUND(MAX(payroll) / 1000000.0, 2) AS highest_payroll_millions
FROM team_seasons
GROUP BY season
ORDER BY season;


-- 6. Efficient winning seasons
-- QUESTION: Which teams won at least 90 games with below-average payroll?
-- RESULT: Tampa Bay's 2019 season ranked first with 96 wins and $64.18 million in payroll.
-- INTERPRETATION: Strong results were possible without spending at the league-average level.
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
-- QUESTION: Which teams had at least two seasons with 90 wins and below-average payroll?
-- RESULT: Cleveland, Tampa Bay, Milwaukee, Baltimore, Oakland, and Seattle qualified.
-- INTERPRETATION: These teams produced strong results with below-average payroll more than once.
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
-- QUESTION: Which at-or-above-average payroll teams finished below 81 wins and missed the playoffs?
-- RESULT: The 2023 New York Mets ranked first at $341.67 million with 75 wins.
-- INTERPRETATION: High spending did not guarantee a winning season or playoff appearance.
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
ORDER BY payroll_vs_league_avg_pct DESC
LIMIT 15;


-- 9. Teams averaging at least 120% of league-average payroll
-- QUESTION: Which teams averaged at least 120% of league-average payroll across the ten seasons?
-- RESULT: Eight teams qualified, led by the Los Angeles Dodgers at 179.1%.
-- INTERPRETATION: These teams spent substantially above the yearly league average overall.
SELECT
    team_name,
    ROUND(AVG(payroll_vs_league_avg_pct), 1) AS average_payroll_pct,
    ROUND(AVG(wins), 1) AS average_wins,
    SUM(playoff_qualified) AS playoff_seasons
FROM team_seasons
GROUP BY team_name
HAVING AVG(payroll_vs_league_avg_pct) >= 120
ORDER BY average_payroll_pct DESC;
