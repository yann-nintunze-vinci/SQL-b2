DROP SCHEMA IF EXISTS gestion_evenements CASCADE;

CREATE SCHEMA gestion_evenements;

CREATE TABLE gestion_evenements.festivals
(
    id_festival SERIAL PRIMARY KEY,
    nom         VARCHAR(100) NOT NULL CHECK ( TRIM(nom) != '' )
);

CREATE TABLE gestion_evenements.salles
(
    id_salle SERIAL PRIMARY KEY,
    nom      VARCHAR(50) NOT NULL CHECK (TRIM(nom) != '' ),
    ville    VARCHAR(30) NOT NULL CHECK (TRIM(ville) != '' ),
    capacite INTEGER     NOT NULL CHECK ( capacite > 0 )
);

CREATE TABLE gestion_evenements.artistes
(
    id_artiste  SERIAL PRIMARY KEY,
    nom         VARCHAR(100) NOT NULL CHECK (TRIM(nom) != '' ),
    nationalite CHAR(3)      NULL CHECK ( TRIM(nationalite) SIMILAR TO '[A-Z]{3}')
);

CREATE TABLE gestion_evenements.clients
(
    id_client       SERIAL PRIMARY KEY,
    nom_utilisateur VARCHAR(25) NOT NULL UNIQUE CHECK (TRIM(nom_utilisateur) != '' ),
    email           VARCHAR(50) NOT NULL CHECK ( TRIM(email) != '' AND
                                                 email SIMILAR TO '%@([[:alnum:]]+[.-])*[[:alnum:]]+.[a-zA-Z]{2,4}' ),
    mot_de_passe    CHAR(60)    NOT NULL
);


CREATE TABLE gestion_evenements.evenements
(
    date_evenement      DATE         NOT NULL,
    nom                 VARCHAR(100) NOT NULL CHECK (TRIM(nom) != '' ),
    prix                MONEY        NOT NULL CHECK ( prix >= 0::MONEY ),
    nb_places_restantes INTEGER      NOT NULL CHECK ( nb_places_restantes >= 0 ),
    salle               INTEGER      NOT NULL REFERENCES gestion_evenements.salles (id_salle),
    festival            INTEGER REFERENCES gestion_evenements.festivals (id_festival),
    PRIMARY KEY (salle, date_evenement)
);

CREATE TABLE gestion_evenements.concerts
(
    heure_debut    TIME    NOT NULL,
    artiste        INTEGER NOT NULL REFERENCES gestion_evenements.artistes (id_artiste),
    date_evenement DATE    NOT NULL,
    salle          INTEGER NOT NULL,
    FOREIGN KEY (salle, date_evenement) REFERENCES gestion_evenements.evenements (salle, date_evenement),
    UNIQUE (salle, date_evenement, heure_debut),
    PRIMARY KEY (artiste, date_evenement)
);

CREATE TABLE gestion_evenements.reservations
(
    num_reservation INTEGER NOT NULL,
    nb_tickets      INTEGER NOT NULL CHECK ( nb_tickets BETWEEN 1 AND 4 ),
    date_evenement  DATE    NOT NULL,
    salle           INTEGER NOT NULL,
    client          INTEGER NOT NULL REFERENCES gestion_evenements.clients (id_client),
    FOREIGN KEY (salle, date_evenement) REFERENCES gestion_evenements.evenements (salle, date_evenement),
    PRIMARY KEY (salle, date_evenement, num_reservation)
);

CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_salle(_nom VARCHAR(50), _ville VARCHAR(30), _capacite INTEGER) RETURNS INTEGER AS
$$
DECLARE
    _id_salle INTEGER;
BEGIN
    INSERT INTO gestion_evenements.salles(nom, ville, capacite)
    VALUES (_nom, _ville, _capacite)
    RETURNING id_salle INTO _id_salle;
    RETURN _id_salle;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_festival(_nom VARCHAR(100)) RETURNS INTEGER AS
$$
DECLARE
    _id_festival INTEGER;
BEGIN
    INSERT INTO gestion_evenements.festivals(nom)
    VALUES (_nom)
    RETURNING id_festival INTO _id_festival;
    RETURN _id_festival;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_artiste(_nom VARCHAR(100), _nationalite CHAR(3)) RETURNS INTEGER AS
$$
DECLARE
    _id_artiste INTEGER;
BEGIN
    INSERT INTO gestion_evenements.artistes(nom, nationalite)
    VALUES (_nom, _nationalite)
    RETURNING id_artiste INTO _id_artiste;
    RETURN _id_artiste;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_client(_nom_utilisateur VARCHAR(25), _email VARCHAR(50),
                                                             _mot_de_passe CHAR(60)) RETURNS INTEGER AS
$$
DECLARE
    _id_client INTEGER;
BEGIN
    INSERT INTO gestion_evenements.clients(nom_utilisateur, email, mot_de_passe)
    VALUES (_nom_utilisateur, _email, _mot_de_passe)
    RETURNING id_client INTO _id_client;
    RETURN _id_client;
END;
$$ LANGUAGE plpgsql;

-- AJOUTER EVENEMENT
CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_evenement(_date_evenement DATE, _nom VARCHAR(100), _prix MONEY,
                                                                _nb_places_restantes INTEGER, _salle INTEGER,
                                                                _festival INTEGER)
    RETURNS VOID AS
$$
BEGIN
    INSERT INTO gestion_evenements.evenements(date_evenement, nom, prix, nb_places_restantes, salle, festival)
    VALUES (_date_evenement, _nom, _prix, _nb_places_restantes, _salle, _festival);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gestion_evenements.exceptions_ajouter_evenement()
    RETURNS TRIGGER AS
$$
BEGIN

    IF (NEW.date_evenement <= CURRENT_DATE) THEN
        RAISE EXCEPTION 'La date de l´événement ne peut pas être antérieure à la date actuelle.';
    END IF;

    NEW.nb_places_restantes = (SELECT s.capacite
                               FROM gestion_evenements.salles s
                               WHERE NEW.salle = s.id_salle);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER exceptions_ajouter_evenement_trigger
    BEFORE INSERT
    ON gestion_evenements.evenements
    FOR EACH ROW
EXECUTE PROCEDURE gestion_evenements.exceptions_ajouter_evenement();

CREATE OR REPLACE FUNCTION gestion_evenements.nb_places_restantes() RETURNS TRIGGER AS
$$
BEGIN
    UPDATE gestion_evenements.evenements ev
    SET nb_places_restantes = (nb_places_restantes - NEW.nb_tickets)
    WHERE ev.salle = NEW.salle
      AND ev.date_evenement = NEW.date_evenement;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER nb_places_restantes_trigger
    AFTER INSERT
    ON gestion_evenements.reservations
    FOR EACH ROW
EXECUTE PROCEDURE gestion_evenements.nb_places_restantes();

-- AJOUTER CONCERT
CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_concert(_heure_debut TIME, _artiste INTEGER, _date_evenement DATE,
                                                              _salle INTEGER)
    RETURNS VOID AS
$$
BEGIN
    INSERT INTO gestion_evenements.concerts(heure_debut, artiste, date_evenement, salle)
    VALUES (_heure_debut, _artiste, _date_evenement, _salle);
END ;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gestion_evenements.exceptions_ajouter_concert()
    RETURNS TRIGGER AS
$$
DECLARE
    nb_concerts_par_festival INTEGER;
BEGIN
    IF (NEW.date_evenement <= CURRENT_DATE) THEN
        RAISE EXCEPTION 'La date de l´événement ne peut pas être antérieure à la date actuelle.';
    END IF;
    SELECT COUNT(ev.festival)
    INTO nb_concerts_par_festival
    FROM gestion_evenements.concerts co,
         gestion_evenements.evenements ev
    WHERE ev.salle = co.salle
      AND ev.date_evenement = co.date_evenement
      AND ev.festival =
          (SELECT festival
           FROM gestion_evenements.evenements
           WHERE salle = NEW.salle
             AND date_evenement = NEW.date_evenement)
      AND co.artiste = NEW.artiste;
    IF (nb_concerts_par_festival > 0) THEN RAISE EXCEPTION 'L´artiste a déjà un concert pour ce festival.'; END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_evenement_exceptions_trigger
    BEFORE INSERT
    ON gestion_evenements.concerts
    FOR EACH ROW
EXECUTE PROCEDURE gestion_evenements.exceptions_ajouter_concert();

--AJOUTER RESERVATION
CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_reservation(_nb_tickets INTEGER,
                                                                  _date_evenement DATE,
                                                                  _salle INTEGER,
                                                                  _client INTEGER) RETURNS INTEGER AS
$$
DECLARE
    _num_reservation INTEGER;
BEGIN
    SELECT COUNT(num_reservation)
    INTO _num_reservation
    FROM gestion_evenements.reservations;
    _num_reservation := _num_reservation + 1;
    INSERT INTO gestion_evenements.reservations(num_reservation, nb_tickets, date_evenement, salle, client)
    VALUES (_num_reservation, _nb_tickets, _date_evenement, _salle, _client);
    RETURN _num_reservation;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gestion_evenements.exceptions_ajouter_reservation() RETURNS TRIGGER AS
$$
DECLARE
    exist                   BOOLEAN;
    nb_places_restantes     INTEGER;
    nb_reservations_mm_date INTEGER;
BEGIN
    IF (NEW.date_evenement <= CURRENT_DATE) THEN
        RAISE EXCEPTION 'La date de l´événement ne peut pas être antérieure à la date actuelle.';
    END IF;

    SELECT EXISTS (SELECT 1
                   FROM gestion_evenements.concerts co
                   WHERE co.date_evenement = NEW.date_evenement
                     AND co.salle = NEW.salle)
    INTO exist;
    IF NOT exist THEN
        RAISE EXCEPTION 'Aucun concert n´est prévu à cette date et dans cette salle.';
    END IF;

    SELECT ev.nb_places_restantes
    INTO nb_places_restantes
    FROM gestion_evenements.evenements ev
    WHERE ev.salle = NEW.salle
      AND ev.date_evenement = NEW.date_evenement;

    IF (nb_places_restantes - NEW.nb_tickets < 0)
    THEN
        RAISE EXCEPTION 'Le client réserve trop de places pour l´évènement';
    END IF;

    SELECT COUNT(re.client)
    INTO nb_reservations_mm_date
    FROM gestion_evenements.reservations re
    WHERE re.client = NEW.client
      AND re.date_evenement = NEW.date_evenement;

    IF (nb_reservations_mm_date > 0)
    THEN
        RAISE EXCEPTION 'Le client a déjà une réservation pour un autre événement à la même date';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER exceptions_ajouter_reservation_trigger
    BEFORE INSERT
    ON gestion_evenements.reservations
    FOR EACH ROW
EXECUTE PROCEDURE gestion_evenements.exceptions_ajouter_reservation();

CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_reservation_festival(_nb_tickets INTEGER, _festival INTEGER, _client INTEGER) RETURNS VOID AS
$$
DECLARE
    _evenement RECORD;
BEGIN
    FOR _evenement IN
        SELECT ev.date_evenement, ev.salle
        FROM gestion_evenements.evenements ev
        WHERE ev.festival = _festival
        LOOP
            PERFORM gestion_evenements.ajouter_reservation(_nb_tickets, _evenement.date_evenement, _evenement.salle,
                                                           _client);
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW gestion_evenements.festivals_futurs (nom, date_1er_evenement, date_dernier_evenement, total_prix)
AS
SELECT fe.nom, MIN(ev.date_evenement), MAX(ev.date_evenement), SUM(ev.prix)
FROM gestion_evenements.festivals fe,
     gestion_evenements.evenements ev
WHERE ev.festival = fe.id_festival
GROUP BY fe.id_festival
HAVING CURRENT_DATE < MAX(ev.date_evenement)
ORDER BY 2;

CREATE OR REPLACE VIEW gestion_evenements.reservations_clients
            (nom_evenement, date_evenement, salle, num_reservation, client, nb_places_reservees)
AS
SELECT ev.nom, ev.date_evenement, sa.nom, re.num_reservation, re.client, re.nb_tickets
FROM gestion_evenements.reservations re,
     gestion_evenements.evenements ev,
     gestion_evenements.salles sa
WHERE re.date_evenement = ev.date_evenement
  AND re.salle = ev.salle
  AND sa.id_salle = ev.salle
ORDER BY 2;

CREATE OR REPLACE FUNCTION gestion_evenements.artistes_par_evenement(_date_evenement DATE, _salle INTEGER)
    RETURNS VARCHAR AS
$$
DECLARE
    concerts RECORD;
    artistes VARCHAR;
BEGIN
    FOR concerts IN
        SELECT a.nom
        FROM gestion_evenements.concerts co,
             gestion_evenements.artistes a
        WHERE co.date_evenement = _date_evenement
          AND co.salle = _salle
          AND co.artiste = a.id_artiste
        LOOP
            artistes := CONCAT_WS(' + ', artistes, concerts.nom);
        END LOOP;
    RETURN artistes;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW gestion_evenements.evenements_par_salle
            (nom_evenement, date_evenement, salle, nom_salle, artistes, prix, est_complet)
AS
SELECT DISTINCT ev.nom,
                ev.date_evenement,
                ev.salle,
                sa.nom,
                gestion_evenements.artistes_par_evenement(ev.date_evenement, ev.salle),
                ev.prix,
                ev.nb_places_restantes = 0
FROM gestion_evenements.salles sa,
     gestion_evenements.evenements ev,
     gestion_evenements.concerts co
WHERE sa.id_salle = ev.salle
  AND co.date_evenement = ev.date_evenement
  AND co.salle = ev.salle
ORDER BY 2;

CREATE OR REPLACE VIEW gestion_evenements.evenements_par_artiste
            (nom_evenement, date_evenement, salle, artiste,
             artistes, prix, est_complet)
AS
SELECT ev.nom,
       ev.date_evenement,
       sa.nom,
       co.artiste,
       gestion_evenements.artistes_par_evenement(ev.date_evenement, ev.salle),
       ev.prix,
       ev.nb_places_restantes = 0
FROM gestion_evenements.evenements ev,
     gestion_evenements.concerts co,
     gestion_evenements.salles sa
WHERE co.salle = ev.salle
  AND co.date_evenement = ev.date_evenement
  AND sa.id_salle = ev.salle
ORDER BY 2;

SELECT gestion_evenements.ajouter_salle('forest national', 'forest', 10);
SELECT gestion_evenements.ajouter_salle('ancienne belgique', 'bruxelles', 5000);
SELECT gestion_evenements.ajouter_festival('rolling loud');
SELECT gestion_evenements.ajouter_festival('coachella');
SELECT gestion_evenements.ajouter_festival('kumalala');
SELECT gestion_evenements.ajouter_artiste('osamason', 'USA');
SELECT gestion_evenements.ajouter_artiste('1oneam', 'USA');
SELECT gestion_evenements.ajouter_artiste('ohsxnta', 'USA');
SELECT gestion_evenements.ajouter_client('username1', 'test1@gmail.com', 'az12QaZ2eZ');
SELECT gestion_evenements.ajouter_client('username2', 'test2@gmail.com', 'az12QaZ2eZ1');
SELECT gestion_evenements.ajouter_client('username3', 'test3@gmail.com', 'az12QaZ2eZ3');

SELECT gestion_evenements.ajouter_evenement('2025-01-01', 'narcissist', (12.5)::MONEY, 50, 1, 1);
SELECT gestion_evenements.ajouter_evenement('2025-01-02', 'narcissist 2.0', (12.5)::MONEY, 50, 1, 1);
SELECT gestion_evenements.ajouter_evenement('2025-01-03', 'autre evenmt', (16.5)::MONEY, 5000, 2, 2);

SELECT gestion_evenements.ajouter_concert('00:00', 1, '2025-01-01', 1);
SELECT gestion_evenements.ajouter_concert('01:00', 2, '2025-01-01', 1);
SELECT gestion_evenements.ajouter_concert('02:00', 3, '2025-01-01', 1);
SELECT gestion_evenements.ajouter_concert('00:00', 1, '2025-01-03', 2);
SELECT gestion_evenements.ajouter_concert('01:00', 2, '2025-01-03', 2);

SELECT gestion_evenements.ajouter_reservation(2, '2025-01-01', 1, 1);
SELECT gestion_evenements.ajouter_reservation(4, '2025-01-01', 1, 2);
SELECT gestion_evenements.ajouter_reservation(4, '2025-01-01', 1, 3);

--SELECT gestion_evenements.ajouter_reservation_festival(4, 1, 1);

