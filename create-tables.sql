CREATE SCHEMA campeonato_colonial;

SET search_path TO campeonato_colonial;

CREATE DOMAIN CHAMPIONSHIP_STATUS AS VARCHAR(50)
	DEFAULT 'not_started'
	CHECK (
		VALUE = 'not_started'
		OR VALUE = 'started'
		OR VALUE = 'finished'
	);



CREATE TABLE championship(
	id SERIAL PRIMARY key,
	name VARCHAR(255) NOT NULL,
	status CHAMPIONSHIP_STATUS NOT NULL
);

CREATE DOMAIN USER_TYPE AS VARCHAR(50)
	DEFAULT 'admin'
	CHECK (
		VALUE = 'admin'
		OR VALUE = 'owner'
	);


CREATE TABLE "user" (
	username VARCHAR(255) PRIMARY kEY,
	name VARCHAR(255) NOT NULL,
	password TEXT NOT NULL,
	type USER_TYPE NOT NULL,
	id_team INT,
	
	CONSTRAINT check_id_team CHECK(
		("type" = 'admin' AND id_team IS NULL) OR 
		("type" = 'owner' AND id_team IS NOT NULL)
	)
);

-- INSERT INTO "user" (username, name, password, type, id_team) VALUES ('admin', 'joe', '1234', 'admin', NULL);
-- INSERT INTO "user" (username, name, password, type, id_team) VALUES ('abc_owner', 'abc president', 'guerra', 'owner', 1);


CREATE TABLE coach(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	age INT NOT NULL,
	picture TEXT
);




CREATE TABLE team(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	emblem TEXT
);

CREATE TABLE team_championship(
	id_team INT NOT NULL,
	id_championship INT NOT NULL,
	PRIMARY KEY(id_team, id_championship),
	
	CONSTRAINT fk_id_team FOREIGN KEY (id_team) REFERENCES team(id),
	CONSTRAINT fk_id_championship FOREIGN KEY (id_championship) REFERENCES championship(id)
);

ALTER TABLE team_championship
	ADD COLUMN id_coach INT;

ALTER TABLE team_championship
	ADD CONSTRAINT fk_id_coach FOREIGN KEY (id_coach) REFERENCES coach(id);
	
	
ALTER TABLE "user"
	ADD CONSTRAINT fk_id_team FOREIGN KEY (id_team) REFERENCES team(id);

-- INSERT INTO team(name) VALUES ('abc');
-- INSERT INTO team_championship (id_team, id_championship, id_coach) VALUES (1,1,1);




CREATE DOMAIN LEG AS CHAR
	DEFAULT 'R'
	CHECK(VALUE = 'L' OR VALUE = 'R' OR VALUE = 'A');

CREATE TABLE player(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	age INT NOT NULL,
	origin VARCHAR(100),
	picture TEXT,
	dominant_leg LEG NOT NULL
);

CREATE TABLE player_championship(
	id_player INT NOT NULL,
	id_championship INT NOT NULL,
	id_team INT NOT NULL,
	
	PRIMARY KEY(id_player, id_championship),
	
	CONSTRAINT fk_id_player FOREIGN KEY (id_player) REFERENCES player(id),
	CONSTRAINT fk_id_championship FOREIGN KEY (id_championship) REFERENCES championship(id),
	CONSTRAINT fk_id_team FOREIGN KEY (id_team) REFERENCES team(id) -- REFERENCIAR team_championship ao invés de team?
);


-- INSERT INTO player(name, age) VALUES ('pele', 23);
-- INSERT INTO player_championship(id_team, id_championship, id_player) VALUES (1, 1, 1);



CREATE TABLE referee(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	age INT NOT NULL,
	picture TEXT NOT NULL
);

-- Altera a coluna "name" para NOT NULL
ALTER TABLE referee
ALTER COLUMN name SET NOT NULL;

-- Altera a coluna "picture" para opcional
ALTER TABLE referee
ALTER COLUMN picture DROP NOT NULL;







CREATE TABLE "match" (
	id SERIAL PRIMARY KEY,
	id_referee INT,
	id_championship INT NOT NULL,
	home_team INT NOT NULL,
	visiting_team INT NOT NULL,
	winner INT,
	is_draw BOOLEAN GENERATED ALWAYS AS (CASE WHEN winner IS NULL THEN true ELSE false END) STORED,
	is_registered BOOLEAN DEFAULT false,
	round INT NOT NULL,
	
	CONSTRAINT fk_home_team FOREIGN KEY (home_team, id_championship) REFERENCES team_championship(id_team, id_championship),
	CONSTRAINT fk_visiting_team FOREIGN KEY (visiting_team, id_championship) REFERENCES team_championship(id_team, id_championship),
	CONSTRAINT fk_winner FOREIGN KEY (winner, id_championship) REFERENCES team_championship(id_team, id_championship),
	CONSTRAINT fk_referee FOREIGN KEY (id_referee) REFERENCES referee(id),
	CONSTRAINT fk_championship FOREIGN KEY (id_championship) REFERENCES championship(id)
);

ALTER TABLE "match"
	ADD COLUMN home_goals INT;

ALTER TABLE "match"
	ADD COLUMN visiting_goals INT;







CREATE TABLE goal(
	id SERIAL PRIMARY KEY,
	id_match INT NOT NULL,
	id_player INT NOT NULL,
	id_team INT NOT NULL,
	id_championship INT NOT NULL,
	
	CONSTRAINT fk_match FOREIGN KEY (id_match) REFERENCES match(id),
	CONSTRAINT fk_player FOREIGN KEY (id_player, id_championship) REFERENCES player_championship(id_player, id_championship),
	CONSTRAINT fk_team FOREIGN KEY (id_team, id_championship) REFERENCES team_championship(id_team,id_championship),
	CONSTRAINT fk_championship FOREIGN KEY (id_championship) REFERENCES championship(id)
);





CREATE TABLE cards(
	id SERIAL PRIMARY KEY,
	id_player INT NOT NULL,
	id_team INT NOT NULL,
	id_championship INT NOT NULL,
	is_red BOOLEAN NOT NULL,
	
	CONSTRAINT fk_player FOREIGN KEY (id_player, id_championship) REFERENCES player_championship(id_player, id_championship)
);

ALTER TABLE cards
	ADD CONSTRAINT fk_team FOREIGN KEY (id_team, id_championship) REFERENCES team_championship(id_team, id_championship);


CREATE TABLE penalties(
	id SERIAL PRIMARY KEY,
	id_player INT NOT NULL,
	id_team INT NOT NULL,
	id_championship INT NOT NULL,
	round INT NOT NULL,


	CONSTRAINT fk_player FOREIGN KEY (id_player, id_championship) REFERENCES player_championship(id_player, id_championship)
);

ALTER TABLE penalties
	ADD CONSTRAINT fk_team FOREIGN KEY (id_team, id_championship) REFERENCES team_championship(id_team, id_championship);

ALTER TABLE player_championship
	ADD COLUMN yellow_cards INT NOT NULL DEFAULT 0;


-- Lógica de adicionar penalidades e resetar cartões
CREATE OR REPLACE PROCEDURE AtribuirCartaoAmarelo(
    IN id_team_param INT,
    IN id_player_param INT,
    IN id_campeonato_param INT,
    IN round_param INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    num_cartoes INT;
BEGIN
    -- Verificar se o jogador já atingiu 3 cartões amarelos
    SELECT player_championship.yellow_cards INTO num_cartoes
    FROM player_championship
    WHERE player_championship.id_team = id_team_param 
    AND player_championship.id_player = id_player_param 
    AND player_championship.id_championship = id_campeonato_param;

	INSERT INTO cards(id_player,id_team,id_championship,is_red) VALUES (
		id_player_param,
		id_team_param,
		id_campeonato_param,
		false
	);

    -- Incrementar o número de cartões amarelos
    UPDATE player_championship
    SET yellow_cards = yellow_cards + 1
    WHERE id_team = id_team_param 
    AND id_player = id_player_param 
    AND id_championship = id_campeonato_param;

    -- Verificar se o jogador atingiu 3 cartões amarelos
    IF num_cartoes + 1 = 3 THEN
        -- Inserir uma nova linha na tabela de penalidades
        INSERT INTO penalties(id_player, id_team, id_championship, round)
        VALUES (id_player_param, id_team_param, id_campeonato_param, round_param + 1);

        -- Resetar o contador de cartões amarelos para 0
        UPDATE player_championship
        SET yellow_cards = 0
        WHERE id_team = id_team_param 
        AND id_player = id_player_param 
        AND id_championship = id_campeonato_param;
    END IF;
END;
$$;



CREATE OR REPLACE PROCEDURE AdicionarCartaoVermelho(
    IN id_team_param INT,
    IN id_player_param INT,
    IN id_campeonato_param INT,
    IN round_param INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Resetar o número de cartões amarelos
    UPDATE player_championship
    SET yellow_cards = 0
    WHERE id_team = id_team_param 
    AND id_player = id_player_param 
    AND id_championship = id_campeonato_param;

	INSERT INTO cards(id_player,id_team,id_championship,is_red) VALUES (
		id_player_param,
		id_team_param,
		id_campeonato_param,
		true
	);

    -- Inserir uma nova linha na tabela de penalidades
    INSERT INTO penalties(id_player, id_team, id_championship, round)
    VALUES (id_player_param, id_team_param, id_campeonato_param, round_param + 1);
END;
$$;



-- CALL AtribuirCartaoAmarelo(2, 1, 1, 5);
-- CALL AdicionarCartaoVermelho(2,1,1,5);