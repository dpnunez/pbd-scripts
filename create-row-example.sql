-- Criação do Admin
INSERT INTO "user"(username, "password", type, "name") VALUES ('admin.script', '1234', 'admin', 'joel');

-- Criação do Time
INSERT INTO team("name") VALUES ('Gremio Magarça');
INSERT INTO team("name") VALUES ('Skylab');
INSERT INTO team("name") VALUES ('Cariani');

-- Criação do Owner associado à equipe
INSERT INTO "user"(username,
	"password",
	TYPE,
	"name",
	id_team)
VALUES('time.magarca', '1234', 'owner', 'joel', (SELECT id FROM team WHERE "name" = 'Gremio Magarça'));

INSERT INTO "user"(username,
	"password",
	TYPE,
	"name",
	id_team)
VALUES('time.skylab', '1234', 'owner', 'joel', (SELECT id FROM team WHERE "name" = 'Skylab'));

INSERT INTO "user"(username,
	"password",
	TYPE,
	"name",
	id_team)
VALUES('time.cariani', '1234', 'owner', 'joel', (SELECT id FROM team WHERE "name" = 'Cariani'));



-- Criar campeonato
INSERT INTO championship("name", "status") VALUES ('Copinha', 'not_started');


-- Associar times ao campeoanto
INSERT INTO team_championship(id_team, id_championship)
	VALUES (
		(SELECT id from team WHERE "name" = 'Gremio Magarça'),
		(SELECT id FROM championship WHERE "name" = 'Copinha') 
	);


INSERT INTO team_championship(id_team, id_championship)
	VALUES (
		(SELECT id from team WHERE "name" = 'Skylab'),
		(SELECT id FROM championship WHERE "name" = 'Copinha') 
	);

INSERT INTO team_championship(id_team, id_championship)
	VALUES (
		(SELECT id from team WHERE "name" = 'Cariani'),
		(SELECT id FROM championship WHERE "name" = 'Copinha') 
	);

-- Criar jogadores (ainda não associados aos times)
INSERT INTO player("name", age, dominant_leg) VALUES ('Flavio Bolsonaro', 22, 'R');
INSERT INTO player("name", age, dominant_leg) VALUES ('Lula Nine', 13, 'R');
INSERT INTO player("name", age, dominant_leg) VALUES ('Kim Jong Un', 99, 'L');

-- Cadastrar jogadores dentro de times em campeonatos (importante notarmos que não é possível cadastrar um jogador em um time, mas sim em um time dentro de um campeonato)

INSERT INTO player_championship(id_player, id_championship, id_team)
	VALUES(
		(SELECT id FROM player WHERE "name" = 'Flavio Bolsonaro'),
		(SELECT id FROM championship WHERE "name" = 'Copinha'),
		(SELECT id FROM team WHERE "name" = 'Gremio Magarça')
	);


INSERT INTO player_championship(id_player, id_championship, id_team)
	VALUES(
		(SELECT id FROM player WHERE "name" = 'Lula Nine'),
		(SELECT id FROM championship WHERE "name" = 'Copinha'),
		(SELECT id FROM team WHERE "name" = 'Skylab')
	);

INSERT INTO player_championship(id_player, id_championship, id_team)
	VALUES(
		(SELECT id FROM player WHERE "name" = 'Kim Jong Un'),
		(SELECT id FROM championship WHERE "name" = 'Copinha'),
		(SELECT id FROM team WHERE "name" = 'Cariani')
	);

-- Criar coach
INSERT INTO coach("name", "age") VALUES ('Renato', 45);
INSERT INTO coach("name", "age") VALUES ('Lisca', 47);
INSERT INTO coach("name", "age") VALUES ('Coudet', 55);


-- Cadastrar coach em um time dentro do campeonato

UPDATE team_championship
	SET id_coach = (SELECT id FROM coach WHERE "name" = 'Renato')
	WHERE 
		id_team = (SELECT id FROM team WHERE "name" = 'Gremio Magarça') AND
		id_championship = (SELECT id FROM championship WHERE "name" = 'Copinha');

UPDATE team_championship
	SET id_coach = (SELECT id FROM coach WHERE "name" = 'Lisca')
	WHERE 
		id_team = (SELECT id FROM team WHERE "name" = 'Skylab') AND
		id_championship = (SELECT id FROM championship WHERE "name" = 'Copinha');

UPDATE team_championship
	SET id_coach = (SELECT id FROM coach WHERE "name" = 'Coudet')
	WHERE 
		id_team = (SELECT id FROM team WHERE "name" = 'Cariani') AND
		id_championship = (SELECT id FROM championship WHERE "name" = 'Copinha');


-- Cadastrar juiz

INSERT INTO referee("name", age) VALUES ('Linus Torvalds', 50);



-- Cadastrar futuras partidas desse campeonato

INSERT INTO "match" (id_referee, id_championship, winner, is_registered, round, home_team, visiting_team)
	VALUES (
		(SELECT id FROM referee WHERE "name" = 'Linus Torvalds'),
		(SELECT id FROM championship WHERE "name" = 'Copinha'),
		null,
		false,
		1,
		(SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça'),
		(SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab')
	);


INSERT INTO "match" (id_referee, id_championship, winner, is_registered, round, home_team, visiting_team)
	VALUES (
		(SELECT id FROM referee WHERE "name" = 'Linus Torvalds'),
		(SELECT id FROM championship WHERE "name" = 'Copinha'),
		null,
		false,
		2,
		(SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça'),
		(SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani')
	);

INSERT INTO "match" (id_referee, id_championship, winner, is_registered, round, home_team, visiting_team)
	VALUES (
		(SELECT id FROM referee WHERE "name" = 'Linus Torvalds'),
		(SELECT id FROM championship WHERE "name" = 'Copinha'),
		null,
		false,
		3,
		(SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab'),
		(SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani')
	);


-- Iniciar campeonato

UPDATE championship
	SET status = 'started'
	WHERE "name" = 'Copinha';
	


-- Cadastrar resultado dos jogos


-- Cadastro partida 1
UPDATE "match"
	SET home_goals = 2
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab');

UPDATE "match"
	SET visiting_goals = 0
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab');

UPDATE "match"
	SET is_registered = true
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab');

UPDATE "match"
	SET winner = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça')
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab');


-- Cadastro partida 2

UPDATE "match"
	SET home_goals = 2
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani');

UPDATE "match"
	SET visiting_goals = 2
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani');

UPDATE "match"
	SET is_registered = true
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Gremio Magarça') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani');
		


-- Cadastro partida 3
UPDATE "match"
	SET home_goals = 0
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani');

UPDATE "match"
	SET visiting_goals = 2
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani');

UPDATE "match"
	SET is_registered = true
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani');

UPDATE "match"
	SET winner = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani')
	WHERE 
		id_championship = (SELECT id FROM championship WHERE name = 'Copinha') and 
		home_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Skylab') and
		visiting_team = (SELECT id_team FROM team_championship INNER JOIN team ON team_championship.id_team = team.id WHERE name = 'Cariani');



-- Finalizar o campeonato
UPDATE championship
	SET status = 'finished'
	WHERE
		"name" = 'Copinha';
