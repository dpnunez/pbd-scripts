-- Time que fez mais gols dentro de um campeonato
SELECT
	goal.id_team,
	team. "name",
	COUNT(*) AS total_goals
FROM
	goal
	JOIN campeonato_colonial.team ON team.id = goal.id_team
WHERE
	goal.id_championship = 9
GROUP BY
	goal.id_team,
	team. "name"
ORDER BY
	total_goals DESC
LIMIT 1;



-- Lista quantos cartões cada time tomou
SELECT
    team.id AS team_id,
    team.name AS team_name,
    COUNT(*) AS total_cards
FROM
    campeonato_colonial.cards
JOIN
    campeonato_colonial.team ON team.id = cards.id_team
WHERE
    cards.id_championship = 9 -- Substitua pelo ID do campeonato desejado
GROUP BY
    team.id
ORDER BY
    team_name;


-- Lista quantos cartões VERMELHOS cada time tomou
SELECT
    team.id AS team_id,
    team.name AS team_name,
    COUNT(cards.id) AS total_cards
FROM
    campeonato_colonial.cards
JOIN
    campeonato_colonial.team ON team.id = cards.id_team
WHERE
    cards.id_championship = 9 AND cards.is_red -- Substitua pelo ID do campeonato desejado
GROUP BY
    team.id, team.name
ORDER BY
    team_name;


-- Lista os times com a quantidade de penalidades sofridas em um campeonato
SELECT 
	team."name",
	penalties.id_team,
	COUNT(*) AS total_penalties
FROM penalties
	
JOIN campeonato_colonial.team ON team.id = penalties.id_team

WHERE
	penalties.id_championship = 9
	
GROUP BY
	penalties.id_team,
	team.name
;



-- Seleciona o time que mais fez gols em um campeonato
SELECT
	goal.id_team,
	team."name",
	COUNT(*) AS total_goals
FROM goal

JOIN campeonato_colonial.team ON team.id = goal.id_team

WHERE goal.id_championship = 9

GROUP BY
	goal.id_team,
	team."name"
	
ORDER BY
	total_goals DESC
LIMIT 1;



-- Mostrar todos os jogadores de um time
SELECT 
	player.name,
	player.age,
	player.picture,
	player.dominant_leg,
	player.origin,
	team."name"
	
FROM player_championship

JOIN campeonato_colonial.player ON player.id = player_championship.id_player
JOIN campeonato_colonial.team ON team.id = player_championship.id_team

WHERE 
	player_championship.id_championship = 9 AND player_championship.id_team = 13;


-- Listar quantos destros, canhotos e ambidestros tem dentro de cada campeonato
SELECT 
	championship."name",
	championship.id,
	SUM(CASE WHEN player.dominant_leg = 'R' THEN 1 ELSE 0 END) AS total_right,
    SUM(CASE WHEN player.dominant_leg = 'L' THEN 1 ELSE 0 END) AS total_left,
    SUM(CASE WHEN player.dominant_leg = 'A' THEN 1 ELSE 0 END) AS total_amb
FROM player_championship 
JOIN player ON player.id = player_championship.id_player
JOIN championship ON player_championship.id_championship = championship.id
GROUP BY
	championship.id,
	championship."name"
;