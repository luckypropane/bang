-- phpMyAdmin SQL Dump
-- version 
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Апр 25 2021 г., 13:19
-- Версия сервера: 5.7.33-36-log
-- Версия PHP: 7.4.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `host700505_1890`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `bang` (IN `enemy` VARCHAR(25), IN `codee` INT)  BEGIN

DECLARE tmp int;
DECLARE game_num int;
DECLARE codeet int;
SET game_num=(SELECT ID_Game FROM Players WHERE Nickname=enemy LIMIT 1);
            
            IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE

            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
        
            if(check_card(enemy,7))
            THEN
            
            set tmp=(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=enemy AND ID_Type_of=7 LIMIT 1);
            
          	INSERT INTO Cards_Dumps VALUES (tmp, game_num);
            DELETE FROM Cards_hands WHERE Nickname=enemy AND ID_Card=tmp;
            ELSE
            if((SELECT Current_HP FROM Players WHERE Nickname=enemy)>1)
            THEN
            UPDATE Players SET Current_HP=Current_HP-1 WHERE Nickname=enemy;
            ELSE
            if(check_card(enemy,4))
            THEN
             Set tmp=(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=enemy AND ID_Type_of=4 LIMIT 1);
            INSERT INTO Cards_Dumps VALUES (tmp, game_num);
            DELETE FROM Cards_hands WHERE Nickname=enemy AND ID_Card=tmp;
            ELSE
             set codeet=rand_code();
                INSERT INTO Codes VALUES(game_num,codeet);
            CALL death(enemy, codeet);
            end if;
            
            end if;
       		end if;
            end if;
            end if;


 
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `barrel` (IN `nm` VARCHAR(25), IN `codee` INT)  BEGIN
DECLARE ID INT;
DECLARE game_num INT;
SET game_num=(SELECT ID_Game FROM Players WHERE Nickname=nm LIMIT 1);
            IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
SET ID= (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=1 LIMIT 1);
DELETE FROM Cards_hands WHERE ID_Card=ID AND Nickname=nm;
INSERT INTO Cards_on_table VALUES (ID, nm);
end if;
end if;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `beer` (IN `nm` VARCHAR(25), IN `codee` INT)  BEGIN

DECLARE ID int;
DECLARE game_num INT DEFAULT (SELECT ID_Game FROM Players WHERE Nickname=nm);
 IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
            
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
IF ((SELECT Max_HP FROM Players Where Nickname=nm)>(SELECT Current_HP FROM Players Where Nickname=nm))

THEN

UPDATE Players SET Current_HP=Current_HP+1 Where Nickname=nm;
SET ID= (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=4 LIMIT 1);
INSERT INTO Cards_Dumps VALUES (ID, (SELECT ID_Game FROM Players WHERE Nickname=nm LIMIT 1));
DELETE FROM Cards_hands WHERE ID_Card=ID AND Nickname=nm;
ELSE
Select "Вы не можете пить пиво, у вас максимум ХП";

END IF;
END IF;
END IF;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `card_info` (`name_c` VARCHAR(35))  BEGIN 
SELECT Name as 'Название', Reuseble as 'Постоянная 0- нет, 1 -да', Act as 'Действие' FROM Cards_types WHERE Name=name_C;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `check_dump` (IN `IDD` INT)  BEGIN
SELECT Name,  ID_Card FROM Cards_Dumps INNER JOIN Cards ON Cards_Dumps.ID_Card = Cards.ID INNER JOIN Cards_types ON Cards_types.ID=ID_Type_of WHERE ID_Game=IDD;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `check_game` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35), IN `ID_s` INT)  BEGIN 
DECLARE tmp int;
DECLARE game_num INT DEFAULT (SELECT ID_Game FROM Players WHERE Nickname=nm);
declare codee int;
SET tmp=(SELECT COUNT(*) FROM Players WHERE ID_Game=game_num AND Current_HP!=0);
	IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) THEN 
		SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
IF NOT EXISTS(SELECT * FROM Players WHERE Nickname=nm ) THEN 
SELECT 'Вы еще не в игре';
ELSE
IF ID_S=(SELECT MAX(ID) FROM CHANGES WHERE ID_Game=game_num)
THEN
SELECT 'Ничего не поменялось', ID_s;
ELSE
IF((SELECT ID_Role FROM Players WHERE ID_Game=game_num AND Current_HP!=0 LIMIT 1)=2 AND tmp=1 )
THEN
SELECT 'Игра окончена! Победа Ренегата:',Nickname FROM Players WHERE ID_Role=2 AND ID_Game=game_num;
set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
CALL delete_game(game_num,codee);
ELSE
IF((SELECT Current_HP FROM Players WHERE ID_Role=1 AND ID_Game=game_num LIMIT 1)=0)
THEN
SELECT 'Игра окончена! Победили бандиты:',Nickname FROM Players WHERE ID_Role=3 AND ID_Game=game_num;
set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
CALL delete_game(game_num,codee);
ELSE
IF((SELECT ID_Role FROM Players WHERE ID_Game=game_num AND Current_HP!=0 LIMIT 1)=1 AND tmp=1 )
THEN
SELECT 'Игра окончена! Победа Шерифа:',Nickname FROM Players WHERE ID_Role=1 AND ID_Game=game_num;
set codee=rand_code();
INSERT INTO Codes VALUES(game_num,codee);
CALL delete_game(game_num,codee);
END IF;
END IF;
   END IF;






		UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm;
 CREATE TEMPORARY TABLE OFF_USER (off_name VARCHAR(30) PRIMARY KEY); 
		INSERT INTO OFF_USER (SELECT Nickname FROM Users WHERE Nickname IN(SELECT Nickname FROM Players WHERE ID_Game=game_num) 
				  AND DATEDIFF(CURRENT_TIMESTAMP, Activity)>600 LIMIT 1);
		IF EXISTS(SELECT * FROM OFF_USER LIMIT 1) THEN
        	set codee=rand_code();
			INSERT INTO Codes VALUES(game_num,codee);
			CALL death((SELECT off_name FROM OFF_USER LIMIT 1),codee);
            DROP TABLE OFF_USER;
		END IF;
SELECT 'Ходит', Name_who as 'Игрок', ' ' FROM  Moves WHERE Name_who in(SELECT Nickname FROM Players WHERE ID_Game=game_num and Nickname=Name_who) UNION
SELECT '____', 'Имя игрока', 'Номер очереди' UNION
SELECT 'Порядок очереди', Nickname, ID_Queue as 'Номер очереди' FROM Players WHERE Current_HP!=0 AND ID_Game=game_num UNION
SELECT 'СТАТУС ХОДА: ', Status, ' ' FROM Moves WHERE Name_who in(SELECT Nickname FROM Players WHERE ID_Game=game_num) UNION
SELECT 'Бэнгов сыграно: ', Bang_count, ' ' FROM Moves WHERE Name_who in(SELECT Nickname FROM Players WHERE ID_Game=game_num) UNION
SELECT 'Ваша роль:', Name as ' ',' ' FROM Roles WHERE ID_Role IN(SELECT ID_Role FROM Players WHERE Nickname=nm) UNION
SELECT 'Ваши карты в руках:', Name as 'Название карты', ID_Card FROM Cards_hands, Cards_types, Cards WHERE ID_Card=Cards.ID and Cards_types.ID=Cards.ID_Type_of AND Nickname=nm UNION
SELECT 'ID:', MAX(ID), ' ' FROM CHANGES WHERE ID_Game=game_num UNION
SELECT 'Шериф:', Nickname, ' ' FROM Players WHERE ID_Role=1 AND ID_Game=game_num UNION
SELECT 'Карты на столе:', Name, Nickname FROM Cards_on_table, Cards_types, Cards WHERE ID_Card=Cards.ID and Cards_types.ID=Cards.ID_Type_of AND Nickname in(SELECT Nickname FROM Players WHERE ID_Game=game_num) UNION
SELECT 'Имя игрока ', 'Максимум ХП ', 'Текущее хп' UNION
SELECT Nickname, Max_HP,Current_HP FROM Players WHERE ID_Game=game_num
UNION
SELECT '_____', '_____', '_____'
UNION
SELECT 'Количество карт в руке:', Nickname, COUNT( ID_Card) as 'Количество' FROM Cards_hands WHERE Nickname IN(SELECT Nickname FROM Players WHERE ID_Game=game_num) GROUP BY Nickname;



END IF;
END IF;
END IF;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `death` (IN `nm` VARCHAR(25), IN `codee` INT)  BEGIN
DECLARE tmp2 varchar(90);
DECLARE game_num INT DEFAULT (SELECT ID_Game FROM Players WHERE Nickname=nm);
 IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
            
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;

CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_hands WHERE Nickname=nm;
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_on_table WHERE Nickname=nm;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
DELETE FROM Cards_on_table WHERE ID_Card IN(SELECT id_cd FROM TEMP);
INSERT INTO Cards_Dumps  SELECT id_cd,  ID_Game FROM Players, TEMP WHERE Nickname=nm;
DROP TABLE TEMP;
UPDATE Players SET Current_HP=0 WHERE Nickname=nm;
SET tmp2=(SELECT concat('Игрок ',nm, ' с ролью ',(SELECT Name FROM Roles WHERE ID_Role IN (SELECT ID_Role FROM Players where Nickname=nm)),' погибает'));
SELECT tmp2;
UPDATE Moves SET Status=tmp2 WHERE Name_who IN (SELECT Nickname FROM Players WHERE ID_Game IN (SELECT ID_Game FROM Players WHERE Nickname=nm));

end if;
end if;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `delete_game` (IN `IDD` INT, IN `codee` INT)  BEGIN
declare game_num int;
set game_num=idd;
 IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
            
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
DELETE FROM Cards WHERE ID IN(SELECT ID_Card FROM Cards_Decks WHERE ID_game=IDD);
DELETE FROM Cards WHERE ID IN(SELECT ID_Card FROM Cards_Dumps WHERE ID_game=IDD);

			CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID NATURAL JOIN Players WHERE ID_Game=IDD;
DELETE FROM Cards WHERE ID IN(SELECT id_cd FROM TEMP);
DELETE FROM TEMP;
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_on_table INNER JOIN Cards ON ID_Card = Cards.ID NATURAL JOIN Players WHERE ID_Game=IDD;
DELETE FROM Cards WHERE ID IN(SELECT id_cd FROM TEMP);
DROP TABLE TEMP;
DELETE FROM Cards_on_table WHERE Nickname in(SELECT Nickname FROM Players WHERE ID_Game=IDD);
DELETE FROM Moves WHERE Name_who in(SELECT Nickname FROM Players WHERE ID_Game=IDD);
DELETE FROM Players WHERE ID_game=IDD;
DELETE FROM Game WHERE Game.ID=IDD;
end if;
end if;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `drop_card` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35), IN `card_name` VARCHAR(30))  BEGIN
DECLARE ID INT;
DECLARE tmp INT;
	IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) THEN 
		SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
    IF NOT EXISTS (SELECT Name_who FROM Moves WHERE Name_who=nm)
     THEN SELECT "Error! It's not your turn; Ошибка! Ход не ваш!";
     ELSE
UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm ; 

IF NOT EXISTS(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID INNER JOIN Cards_types ON Cards.ID_Type_of=Cards_types.ID WHERE Nickname=nm AND name=card_name) THEN 
SELECT 'такой карты нет в вашей руке';
ELSE

START TRANSACTION;
SET ID=(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID INNER JOIN Cards_types ON Cards.ID_Type_of=Cards_types.ID WHERE Nickname=nm AND name=card_name LIMIT 1);
INSERT INTO Cards_Dumps VALUES ((SELECT ID_Card FROM Cards_hands WHERE Nickname=nm AND ID_Card=ID LIMIT 1), (SELECT ID_Game FROM Players WHERE Nickname=nm));
            DELETE FROM Cards_hands WHERE Nickname=nm AND ID_Card=ID  LIMIT 1;
            COMMIT;
            SELECT 'Вы сбросили карту ', card_name as 'Имя карты';
             END IF;
             END IF;
             END IF;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `duel` (IN `nm` VARCHAR(25), IN `enemy` VARCHAR(25), IN `codee` INT)  BEGIN
            DECLARE c_nm INT;
            DECLARE c_enemy INT;
            DECLARE tmp Int;
            DECLARE tmp2 Int;
            DECLARE ID int;
            DECLARE codeet int;
           DECLARE game_num INT DEFAULT (SELECT ID_Game FROM Players WHERE Nickname=nm);
  IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
            
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
            SET c_enemy=(SELECT COUNT(ID_Card) FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=enemy AND ID_Type_of=8);
            SET c_nm=(SELECT COUNT(ID_Card) FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=8);
            SET tmp=c_nm+1;
            SET tmp2=c_enemy+1;
            if((c_nm>c_enemy) OR (c_nm=c_enemy))
            THEN
            IF((c_nm!=0) and (c_enemy!=0))
            THEN
            IF(c_nm>c_enemy)
            THEN
            CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=8 LIMIT c_enemy;

            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
  DROP TABLE TEMP;    
  CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
  INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=enemy AND ID_Type_of=8 LIMIT c_enemy;
            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
          DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
            DROP TABLE TEMP; 
            ELSE
            IF((c_nm=c_enemy) AND c_nm!=0)
            THEN
             CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=8 LIMIT c_nm;
            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
  DROP TABLE TEMP;    
            
            CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=enemy AND ID_Type_of=8 LIMIT c_enemy;
            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
  DROP TABLE TEMP;
 
            END IF;
            END IF;
            END IF;
            
            IF(c_nm=c_enemy OR c_nm>c_enemy)
               THEN
            if((SELECT Current_HP FROM Players WHERE Nickname=enemy)>1)
            THEN
            UPDATE Players SET Current_HP=Current_HP-1 WHERE Nickname=enemy;
            ELSE
            if(check_card(enemy,4))
            THEN
            CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=enemy AND ID_Type_of=4 LIMIT 1;
            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
  DROP TABLE TEMP;   
            ELSE
            set codeet=rand_code();
                INSERT INTO Codes VALUES(game_num,codeet);
            CALL death(enemy, codeet);
            end if;
            end if;
               END if;
               
            ELSE
            IF(c_enemy!=0)
            THEN
            CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=8 LIMIT c_nm;
            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
  DROP TABLE TEMP;   
  
  CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=enemy AND ID_Type_of=8 LIMIT tmp;
            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
  DROP TABLE TEMP; 
 END if;
            if((SELECT Current_HP FROM Players WHERE Nickname=nm)>1)
            THEN
            UPDATE Players SET Current_HP=Current_HP-1 WHERE Nickname=nm;
            ELSE
            if(check_card(nm,4))
            THEN
            CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL,ID_Card FROM Cards_hands INNER JOIN Cards_hands.Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=4 LIMIT 1;
            INSERT INTO Cards_Dumps  SELECT id_cd, game_num FROM TEMP;
DELETE FROM Cards_hands WHERE ID_Card IN(SELECT id_cd FROM TEMP);
  DROP TABLE TEMP;
            ELSE
            set codeet=rand_code();
                INSERT INTO Codes VALUES(game_num,codeet);
            CALL death(nm, codeet);
            end if;
			END if;
            END if;
            
            
            end IF;
            END if;


END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `end_move` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35))  BEGIN
DECLARE tmp int;
declare tmp2 int;
DECLARE ID_t int;
DECLARE game_num INT;
DECLARE dice int;
SET game_num=(SELECT ID_Game FROM Players WHERE Nickname=nm);
SET tmp=(SELECT COUNT(*) FROM Players WHERE ID_Game=(SELECT ID_Game FROM Players WHERE Nickname=nm));
IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) 
    
    THEN 
	SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
	UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm; 
	 IF NOT EXISTS (SELECT Name_who FROM Moves WHERE Name_who=nm)
     THEN SELECT "Error! It's not your turn; Ошибка! Ход не ваш!";
     ELSE
     If((SELECT COUNT(*) FROM Cards_hands WHERE Nickname=nm)>(SELECT Current_HP FROM Players WHERE Nickname=nm))
     THEN
     SELECT 'Сбросьте карты, карт должно быть столько, сколько текущего здоровья';
     Else
     IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=1)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=2 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=2;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=3 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=3;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=4 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=4;
         END if;
         END if;
         END if;
         END if;
         
	IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=2)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=3 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=3;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=4 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=4;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=1 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=1;
         END if;
         END if;
         END if;
         END if;
    
   IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=3)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=4 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=4;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=1 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=1;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=2 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=2;
         END if;
         END if;
         END if;
         END if;
         
         IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=4)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=1 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=1;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=2 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=2;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=3 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=3;
         END if;
         END if;
         END if;
         END if;
 
        
    if(check_card_t((SELECT Nickname from Players WHERE ID_Queue=tmp AND ID_Game=game_num),3))
    THEN
    START TRANSACTION;
    SET ID_t=(SELECT ID_Card FROM Cards_on_table INNER JOIN Cards ON Cards_on_table.ID_Card = Cards.ID WHERE Nickname in(SELECT Nickname FROM Players WHERE ID_Queue=tmp AND ID_Game=game_num) AND ID_Type_of=3 LIMIT 1);
  
    INSERT INTO Cards_Dumps VALUES (ID_t, game_num);
            DELETE FROM Cards_on_table WHERE Nickname in(SELECT Nickname FROM Players WHERE ID_Queue=tmp) AND ID_Card=ID_t;
    set dice=(SELECT rollDice());    
    SET tmp2=tmp;
    COMMIT;
    IF(dice<4)
    THEN
      UPDATE Moves SET Status=(SELECT CONCAT('Игроку ', (SELECT Nickname FROM Players WHERE ID_Queue=tmp AND ID_Game=game_num),' не повезло и он пропускает ход,',' на кубике выпало:',dice)) WHERE Name_who=nm;
    IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=1)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=2 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=2;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=3 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=3;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=4 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=4;
         END if;
         END if;
         END if;
         END if;
         
	IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=2)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=3 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=3;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=4 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=4;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=1 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=1;
         END if;
         END if;
         END if;
         END if;
    
   IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=3)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=4 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=4;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=1 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=1;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=2 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=2;
         END if;
         END if;
         END if;
         END if;
         
         IF ((SELECT ID_Queue FROM Players WHERE Nickname=nm LIMIT 1)=4)
     THEN
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=1 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=1;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=2 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=2;
         ELSE
         IF((SELECT Current_HP FROM Players WHERE ID_Queue=3 AND ID_Game=game_num LIMIT 1)!=0)
         THEN
         SET tmp=3;
         END if;
         END if;
         END if;
         END if;
    ELSE
     UPDATE Moves SET Status=(SELECT CONCAT('Игроку ', (SELECT Nickname FROM Players WHERE ID_Queue=tmp AND ID_Game=game_num),' повезло и он выходит из тюрьмы,',' кубик:',dice)) WHERE Name_who=nm;
    end if;
        end if;

If((SELECT COUNT(*) FROM Cards_Decks WHERE ID_Game=game_num)<2)
THEN
INSERT INTO Cards_Decks SELECT ID_Card, game_num FROM Cards_Dumps WHERE ID_Game=game_num ORDER BY RAND();
DELETE FROM Cards_Dumps WHERE ID_Game=game_num;
end if;

START TRANSACTION;
CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);

INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_Decks WHERE ID_Game IN (SELECT ID_Game FROM Players WHERE Nickname=nm) ORDER by rand() LIMIT 2 ;
DELETE FROM Cards_Decks WHERE ID_Card IN(SELECT id_cd FROM TEMP);

INSERT INTO Cards_hands  SELECT id_cd, Nickname FROM Players, TEMP WHERE Nickname IN (SELECT Nickname FROM Players WHERE ID_Queue=tmp) AND Nickname IN (SELECT Nickname FROM Players WHERE ID_Game=game_num);

DROP TABLE TEMP;
    UPDATE Moves SET Name_who=(SELECT Nickname from Players WHERE ID_Queue=tmp AND ID_Game=game_num), Bang_count=0 WHERE Name_who=nm;
  COMMIT;
    SELECT 'Ход передан игроку ',Nickname from Players WHERE ID_Queue=tmp AND ID_Game=game_num;

     END IF;
     END IF;
     END IF;	
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `jail` (IN `nm` VARCHAR(25), IN `who` VARCHAR(25), IN `codee` INT)  BEGIN
DECLARE ID int;
DECLARE game_num int;
SET game_num=(SELECT ID_Game FROM Players WHERE Nickname=nm LIMIT 1);
            
IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
           
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
IF(check_card_t(who,3))
THEN
SELECT 'Игрок уже в тюрьме';
ELSE
SET ID= (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=3 LIMIT 1);
INSERT INTO Cards_on_table VALUES (ID, who);
DELETE FROM Cards_hands WHERE ID_Card=ID AND Nickname=nm;
      UPDATE Moves SET Status=(SELECT CONCAT('Игрок ', nm,' использовал карту ','Тюрьма',' на игрока ', who)) WHERE Name_who=nm;



END IF;
END IF;
END IF;

END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `log_in` (IN `nm` VARCHAR(30), IN `pw` VARCHAR(30))  BEGIN 
		DECLARE game_num INT;
    	DECLARE num INT;
        DECLARE p1 INT;
        DECLARE p2 INT;
        DECLARE p3 INT;
        DECLARE p4 INT;
        
         CREATE TEMPORARY TABLE OFF_USER (off_name VARCHAR(30) PRIMARY KEY); 
		INSERT INTO OFF_USER (SELECT Nickname FROM Users WHERE Waiting_room=1 AND DATEDIFF(CURRENT_TIMESTAMP, Activity)>600 LIMIT 1);
		IF EXISTS(SELECT * FROM OFF_USER LIMIT 1) THEN
			UPDATE Users SET Waiting_room=0 WHERE Nickname=(SELECT off_name FROM OFF_USER LIMIT 1);
            END IF;
            DROP TABLE OFF_USER;
	IF NOT EXISTS (SELECT * FROM Users WHERE Nickname=nm AND Password=pw) THEN 
    	SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 	
	ELSE
    IF EXISTS (SELECT * FROM Players Natural Join Users WHERE Nickname=nm AND ID_Game is NOT NULL) THEN
		SELECT "Error! You are in a game; Ошибка! Вы уже в игре";
	ELSE 
		UPDATE Users SET Activity=CURRENT_TIMESTAMP, Waiting_room = true WHERE Nickname=nm ; 
        SELECT 'Вы успешно залогинились, ждите начало игры';
		IF (SELECT COUNT(*) FROM Users WHERE Waiting_room = 1)>=4  THEN
        IF GET_LOCK("host700505_1890_log_in", 5) THEN -- блокировка        START TRANSACTION;
        	INSERT INTO Game VALUES(NULL);
			SET game_num=last_insert_id();
			INSERT INTO Players SELECT Nickname, 1, NULL, game_num, 0, 0 FROM Users WHERE Waiting_room = 1 LIMIT 4;
 UPDATE Users SET Waiting_room=0 WHERE Nickname in ( SELECT Nickname FROM Players WHERE ID_Game=game_num);
INSERT INTO Cards VALUES (NULL, 1);
INSERT INTO Cards VALUES (NULL, 1);
INSERT INTO Cards VALUES (NULL, 2);
INSERT INTO Cards VALUES (NULL, 2);
INSERT INTO Cards VALUES (NULL, 3);
INSERT INTO Cards VALUES (NULL, 3);
INSERT INTO Cards VALUES (NULL, 3);
INSERT INTO Cards VALUES (NULL, 4);
INSERT INTO Cards VALUES (NULL, 4);
INSERT INTO Cards VALUES (NULL, 4);
INSERT INTO Cards VALUES (NULL, 4);
INSERT INTO Cards VALUES (NULL, 4);
INSERT INTO Cards VALUES (NULL, 4);
INSERT INTO Cards VALUES (NULL, 5);
INSERT INTO Cards VALUES (NULL, 5);
INSERT INTO Cards VALUES (NULL, 5);
INSERT INTO Cards VALUES (NULL, 6);
INSERT INTO Cards VALUES (NULL, 6);
INSERT INTO Cards VALUES (NULL, 6);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 7);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 8);
INSERT INTO Cards VALUES (NULL, 9);
INSERT INTO Cards VALUES (NULL, 9);
INSERT INTO Cards VALUES (NULL, 9);
INSERT INTO Cards VALUES (NULL, 9);
INSERT INTO Cards VALUES (NULL, 10);
INSERT INTO Cards VALUES (NULL, 10);
INSERT INTO Cards VALUES (NULL, 10);
INSERT INTO Cards VALUES (NULL, 10);
INSERT INTO Cards VALUES (NULL, 11);
INSERT INTO Cards VALUES (NULL, 11);
INSERT INTO Cards VALUES (NULL, 11);
INSERT INTO Cards_Decks SELECT ID, game_num FROM Cards ORDER by ID DESC LIMIT 67;
			CREATE TEMPORARY TABLE TMP1 (ID INT PRIMARY KEY AUTO_INCREMENT, login VARCHAR(25)); 
			INSERT INTO TMP1 SELECT NULL, Nickname FROM Players WHERE ID_Game=game_num; 
            CREATE TEMPORARY TABLE TMP2 (ID INT PRIMARY KEY AUTO_INCREMENT, login VARCHAR(25));
			INSERT INTO TMP2 SELECT NULL, login FROM TMP1 ORDER BY RAND(); 
			UPDATE Players SET ID_Queue=(SELECT ID FROM TMP2 WHERE Login=Players.Nickname) WHERE ID_Game=game_num;
			INSERT INTO Moves VALUES ((SELECT login FROM TMP2 WHERE ID=1), 'Ходит первый игрок', 0);
			
		
				UPDATE Players SET ID_Role=1 WHERE ID_Queue=1 AND ID_Game=game_num;
			UPDATE Players SET ID_Role=2 WHERE ID_Queue=2 AND ID_Game=game_num;
			UPDATE Players SET ID_Role=3 WHERE ID_Queue=3 AND ID_Game=game_num;
			UPDATE Players SET ID_Role=3 WHERE ID_Queue=4 AND ID_Queue!=3 AND ID_Game=game_num;
            COMMIT;
			IF ((SELECT rolldice())>=4) THEN
			UPDATE Players SET Current_HP=4 WHERE ID_Role=1 AND ID_Game=game_num;
			ELSE 
            UPDATE Players SET Current_HP=3 WHERE ID_Role=1 AND ID_Game=game_num;
            END IF;
			UPDATE Players SET Current_HP=Current_HP+1 WHERE ID_Role=1 AND ID_Game=game_num;
			UPDATE Players SET Max_HP=Current_HP WHERE ID_Role=1 AND ID_Game=game_num;
			
			IF ((SELECT rolldice())>=4) 
            THEN
			UPDATE Players SET Current_HP=4, Max_HP=4 WHERE ID_Queue=2 AND ID_Game=game_num;
			ELSE 
            UPDATE Players SET Current_HP=3, Max_HP=3 WHERE ID_Queue=2 AND ID_Game=game_num;
			END IF;
			IF ((SELECT rolldice())>=4) THEN
			UPDATE Players SET Current_HP=4, Max_HP=4 WHERE ID_Queue=3 AND ID_Game=game_num;
			ELSE 
            UPDATE Players SET Current_HP=3, Max_HP=3 WHERE ID_Queue=3 AND ID_Game=game_num;
			END IF;
			IF ((SELECT rolldice())>=4) THEN
			UPDATE Players SET Current_HP=4, Max_HP=4 WHERE ID_Queue=4 AND ID_Game=game_num;
			ELSE 
            UPDATE Players SET Current_HP=3, Max_HP=3 WHERE ID_Queue=4 AND ID_Game=game_num; 	
			END IF;
   
		
            
START TRANSACTION;
			CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_Decks WHERE ID_Game=game_num ORDER by rand() LIMIT 2 ;
INSERT INTO Cards_hands  SELECT id_cd, Nickname FROM Players, TEMP WHERE ID_Role=1 AND ID_Game=game_num;
DELETE FROM Cards_Decks WHERE ID_Card IN(SELECT id_cd FROM TEMP);
DELETE FROM TEMP;
SET p1=(SELECT Max_HP FROM Players WHERE  ID_Role=1 AND ID_Game=game_num);
SET p2=(SELECT Max_HP FROM Players WHERE  ID_Queue=2 AND ID_Game=game_num);
SET p3=(SELECT Max_HP FROM Players WHERE  ID_Queue=3 AND ID_Game=game_num);
SET p4=(SELECT Max_HP FROM Players WHERE  ID_Queue=4 AND ID_Game=game_num);
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_Decks WHERE ID_Game=game_num ORDER by rand() LIMIT p1;
INSERT INTO Cards_hands  SELECT id_cd, Nickname FROM Players, TEMP WHERE ID_Role=1 AND ID_Game=game_num;
DELETE FROM Cards_Decks WHERE ID_Card IN(SELECT id_cd FROM TEMP);
DELETE FROM TEMP;
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_Decks WHERE ID_Game=game_num ORDER by rand() LIMIT p2;
INSERT INTO Cards_hands  SELECT id_cd, Nickname FROM Players, TEMP WHERE ID_Queue=2 AND ID_Game=game_num;
DELETE FROM Cards_Decks WHERE ID_Card IN(SELECT id_cd FROM TEMP);
DELETE FROM TEMP;
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_Decks WHERE ID_Game=game_num ORDER by rand() LIMIT p3;
INSERT INTO Cards_hands  SELECT id_cd, Nickname FROM Players, TEMP WHERE ID_Queue=3 AND ID_Game=game_num;
DELETE FROM Cards_Decks WHERE ID_Card IN(SELECT id_cd FROM TEMP);
DELETE FROM TEMP;
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_Decks WHERE ID_Game=game_num ORDER by rand() LIMIT p4;
INSERT INTO Cards_hands  SELECT id_cd, Nickname FROM Players, TEMP WHERE ID_Queue=4 AND ID_Game=game_num;
DELETE FROM Cards_Decks WHERE ID_Card IN(SELECT id_cd FROM TEMP);




DROP TABLE TEMP;

DROP TABLE TMP1;
DROP TABLE TMP2;
COMMIT;
			CALL check_game(nm, pw);
            END IF;
            END IF;
	END IF;
    DO RELEASE_LOCK("host700505_1890_log_in");
    END IF;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `panic_beauty` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35), IN `enemy` VARCHAR(25), IN `card_name` VARCHAR(30))  BEGIN
DECLARE game_num INT;
declare random int;
declare tmp int;
DECLARE flg INT;
SET flg=0;
IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) 
    THEN 
	SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
    IF NOT EXISTS(SELECT Nickname FROM Players WHERE Nickname=nm) 
    THEN
    SELECT 'Вы не в игре';
    ELSE
     SET game_num= (SELECT ID_Game FROM Players WHERE Nickname=nm);
	
	UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm;
    
	 IF NOT EXISTS (SELECT Name_who FROM Moves WHERE Name_who=nm)
     THEN SELECT "Error! It's not your turn; Ошибка! Ход не ваш!";
     ELSE
	   IF NOT EXISTS (SELECT Nickname FROM Players WHERE Nickname=enemy AND ID_Game=game_num) 
       THEN 
		SELECT "Error! Wrong name of enemy; Ошибка! Игрока с таким именем не существует"; 
	   ELSE
       IF ((SELECT Current_HP FROM Players WHERE Nickname=enemy)=0)
       THEN
       SELECT "Вы не можете взаимодействовать с мертвым игроком";
       ELSE
	    IF NOT EXISTS (SELECT Nickname, Name FROM Cards_hands, Cards_types, Cards WHERE ID_Card=Cards.ID AND  Cards_types.ID=Cards.ID_Type_of AND Cards_types.Name=card_name AND Cards_hands.Nickname=nm)
    THEN SELECT "Error! You don't have this card";
    ELSE
     IF (nm=enemy) 
         THEN
           SELECT "Error! You cannot atack yourself; Ошибка! Вы не можете ходить против себя";
	     ELSE 
    IF ( (SELECT COUNT(*) FROM Cards_hands WHERE Nickname=enemy)=0)
    THEN SELECT "У данного игрока нет карт в руке";
    ELSE
    SET random=(SELECT ID_Card from Cards_hands WHERE Nickname=enemy ORDER BY rand() LIMIT 1);
   
    IF (card_name like 'Красотка')
           THEN
           start TRANSACTION;
            SET tmp=(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=10 LIMIT 1);
           INSERT INTO Cards_Dumps VALUES (tmp, game_num);
            DELETE FROM Cards_hands WHERE Nickname=nm AND ID_Card=tmp;
          INSERT INTO Cards_Dumps VALUES (random, game_num);  
          DELETE FROM Cards_hands WHERE Nickname=enemy AND ID_Card=random;
          COMMIT;
          ELSE
          IF (card_name like 'Паника' OR card_name like 'паника')
          THEN
          START TRANSACTION;
           SET tmp=(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=9 LIMIT 1);
           INSERT INTO Cards_Dumps VALUES (tmp, game_num);
            DELETE FROM Cards_hands WHERE Nickname=nm AND ID_Card=tmp;
            
         DELETE FROM Cards_hands WHERE Nickname=enemy AND ID_Card=random;
          INSERT INTO Cards_hands VALUES (random, nm);
          commit;
          ELSE
          SELECT 'Карты для данного запроса не существует'; set flg=1;


          END IF;
          END if;
    END IF;
       

	IF(flg=0)
           THEN
          UPDATE Moves SET Status=(SELECT CONCAT('Игрок ', nm,' изъял карту из руки с помощью карты ',card_name,' у игрока ', enemy)) WHERE Name_who=nm;
           SELECT Status from Moves WHERE Name_who=nm;
    
     
    END IF;      
END if;
    END IF;
    END IF;
     END IF;
        END IF;
        END IF;
        END IF;
end$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `panic_beauty_t` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35), IN `enemy` VARCHAR(25), IN `card_name` VARCHAR(30), IN `take` VARCHAR(30))  BEGIN
DECLARE flg INT;
DECLARE game_num INT;
declare tmp int;

SET flg=0;
IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) 
    THEN 
	SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
     IF NOT EXISTS(SELECT Nickname FROM Players WHERE Nickname=nm) 
    THEN
    SELECT 'Вы не в игре';
    ELSE
     SET game_num= (SELECT ID_Game FROM Players WHERE Nickname=nm);
	UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm; 
	 IF NOT EXISTS (SELECT Name_who FROM Moves WHERE Name_who=nm)
     THEN SELECT "Error! It's not your turn; Ошибка! Ход не ваш!";
     ELSE
	   IF NOT EXISTS (SELECT Nickname FROM Players WHERE Nickname=enemy AND game_num=(SELECT ID_Game FROM Players WHERE Nickname=enemy)) 
       THEN 
		SELECT "Error! Wrong name of enemy; Ошибка! Игрока с таким именем не существует"; 
	   ELSE
       IF ((SELECT Current_HP FROM Players WHERE Nickname=enemy)=0)
       THEN
       SELECT "Вы не можете взаимодействовать с мертвым игроком";
       ELSE
	    IF NOT EXISTS (SELECT Nickname, Name FROM Cards_hands, Cards_types, Cards WHERE ID_Card=Cards.ID AND  Cards_types.ID=Cards.ID_Type_of AND Cards_types.Name=card_name AND Cards_hands.Nickname=nm)
    THEN SELECT "Error! You don't have this card";
    ELSE
     IF (nm=enemy) 
         THEN
           SELECT "Error! You cannot atack yourself; Ошибка! Вы не можете ходить против себя";
           ELSE
                       
    IF NOT( (check_card_t(enemy,1)) OR (check_card_t(enemy,2)) OR (check_card_t(enemy,3)) ) 
        THEN
        set flg=1;
        SELECT 'У игрока нет такой карты';
       ELSE
    IF (card_name like 'Красотка')
           THEN
            
           IF((take='Бочка') OR (take='Тюрьма') OR (take='Волканик'))
            THEN
            START TRANSACTION;
            SET tmp=(SELECT ID_Card FROM Cards_on_table INNER JOIN Cards ON ID_Card = Cards.ID INNER JOIN Cards_types ON Cards.ID_Type_of=Cards_types.ID WHERE Nickname=enemy AND name=take LIMIT 1);
          INSERT INTO Cards_Dumps VALUES (tmp, game_num); 
          DELETE FROM Cards_on_table WHERE Nickname=enemy AND ID_Card=tmp;
          SET tmp=(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=10 LIMIT 1);
           INSERT INTO Cards_Dumps VALUES (tmp, game_num);
            DELETE FROM Cards_hands WHERE Nickname=nm AND ID_Card=tmp;
            COMMIT;
          ELSE
          SELECT 'Такой карты нет на столе';
          SET flg=1;
         END IF;
          ELSE
          IF (card_name like 'Паника')
          THEN
           
            IF((take='Бочка') OR (take='Тюрьма') OR (take='Волканик'))
            THEN
            START TRANSACTION;
             SET tmp=(SELECT ID_Card FROM Cards_on_table INNER JOIN Cards ON ID_Card = Cards.ID INNER JOIN Cards_types ON Cards.ID_Type_of=Cards_types.ID WHERE Nickname=enemy AND name=take LIMIT 1);
          INSERT INTO Cards_hands VALUES (tmp, nm);  
          DELETE FROM Cards_on_table WHERE Nickname=enemy AND ID_Card=tmp;
          SET tmp=(SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=9 LIMIT 1);
          INSERT INTO Cards_Dumps VALUES (tmp, game_num);
            DELETE FROM Cards_hands WHERE Nickname=nm AND ID_Card=tmp;
            COMMIT;
          ELSE
          SELECT 'Такой карты нет на столе';
          SET flg=1;
          END IF;
          ELSE
          SELECT 'Карты для данного запроса не существует';
          SET flg=1;
          END IF;
          END if;
    END IF;
     

        
	IF(flg=0)
           THEN
          UPDATE Moves SET Status=(SELECT CONCAT('Игрок ', nm,' изъял со стола с помощью карты ',card_name,' у игрока ', enemy,' карту ',take)) WHERE Name_who=nm;
          SELECT Status from Moves WHERE Name_who=nm;
END if;

    END IF;
    END IF;
    END IF;
    END IF;
    END IF;
           END IF;
                      END IF;
end$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `put_card_atk` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35), IN `enemy` VARCHAR(25), IN `card_name` VARCHAR(35))  BEGIN
 DECLARE flg INT;
  DECLARE ID Int;
   DECLARE dice Int;
   declare codee int;
DECLARE game_num INT DEFAULT (SELECT ID_Game FROM Players WHERE Nickname=nm);
SET flg=0;
	IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) 
    THEN 
	SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
	UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm; 
	 IF NOT EXISTS (SELECT Name_who FROM Moves WHERE Name_who=nm)
     THEN SELECT "Error! It's not your turn; Ошибка! Ход не ваш!";
     ELSE
	   IF NOT EXISTS (SELECT * FROM Players WHERE Nickname=enemy AND ID_Game=game_num) 
       THEN 
		SELECT "Error! Wrong name of enemy; Ошибка! Игрока с таким именем не существует"; 
	   ELSE
        IF ((SELECT Current_HP FROM Players WHERE Nickname=enemy)=0)
       THEN
       SELECT "Вы не можете взаимодействовать с мертвым игроком";
       ELSE
	    IF NOT EXISTS (SELECT Nickname, Name FROM Cards_hands, Cards_types, Cards WHERE Cards_hands.ID_Card=Cards.ID AND  Cards_types.ID=Cards.ID_Type_of AND Cards_types.Name=card_name AND Cards_hands.Nickname=nm)
    THEN SELECT "Error! You don't have this card";
    ELSE
	     IF (nm=enemy) 
         THEN
           SELECT "Error! You cannot atack yourself; Ошибка! Вы не можете ходить против себя";
	     ELSE 
          

	      IF (card_name like 'Бэнг') 
          THEN
          
          	IF ((SELECT Bang_count FROM Moves WHERE Name_who=nm)=0 OR check_card_t(nm,2))
          	THEN
                      START TRANSACTION;
            if(check_card_t(enemy,1)) 
            THEN 
            set dice=(SELECT rollDice());
            If(dice>=4) THEN
            SELECT 'Бочка отменила бэнг';
            SET flg=1;
            UPDATE Moves SET Status=(SELECT CONCAT('Игроку ', (SELECT Nickname FROM Players WHERE Nickname=enemy AND ID_Game=game_num),' повезло и он удачно укрывается за бочкой,',' на кубике выпало:',dice)) WHERE Name_who=nm;
            UPDATE Moves SET Bang_count=Bang_count+1 WHERE Name_who=nm;
            ELSE
            SET flg=1;
                UPDATE Moves SET Status=(SELECT CONCAT('Игроку ', (SELECT Nickname FROM Players WHERE Nickname=enemy AND ID_Game=game_num),' не повезло и он получает урон, бочка не спасает,',' на кубике выпало:',dice)) WHERE Name_who=nm;
                set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
                 UPDATE Moves SET Bang_count=Bang_count+1 WHERE Name_who=nm;
                 
          	CALL bang(enemy,codee);     
         	
             END IF;
            ELSE
             set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
                UPDATE Moves SET Bang_count=Bang_count+1 WHERE  Name_who=nm;
                
          	CALL bang(enemy,codee);   
             END IF;
             COMMIT;
          ELSE
          SELECT 'Вы уже делали ход бэнг';
          SET flg=1;
          end if;
          
          else
          IF (card_name like 'Дуэль')
          THEN
          START TRANSACTION;
           set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
               
          CALL duel(nm, enemy, codee);
           COMMIT;
          else 
          IF (card_name like 'Тюрьма')
          THEN
          if((SELECT ID_Role FROM Players WHERE Nickname=enemy)!=1) 
          THEN
          START TRANSACTION;
           set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
          CALL jail(nm, enemy, codee);
          set flg=1;
                          COMMIT;
          ELSE
          SELECT 'Шериф не может сесть в тюрьму!';
          SET flg=1;
          END IF;
          ELSE
          SELECT 'Карты для данного запроса не существует';
         
          SET flg=1;
        	END IF;
            END IF;
  
            END IF;

	

           IF(flg=0)
           THEN
          START TRANSACTION;
SET ID= (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID INNER JOIN Cards_types ON Cards.ID_Type_of=Cards_types.ID WHERE Nickname=nm AND name=card_name LIMIT 1);
INSERT INTO Cards_Dumps VALUES (ID, game_num);
DELETE FROM Cards_hands WHERE ID_Card=ID AND Nickname=nm;

          UPDATE Moves SET Status=(SELECT CONCAT('Игрок ', nm,' использовал карту ',card_name,' на игрока ', enemy)) WHERE Name_who=nm;
          COMMIT;
          END IF;
          call check_game(nm,pw,0);
          SELECT Status from Moves WHERE Name_who=nm;
          

END IF;
        END IF;
         END IF;
	  END IF;
      END IF;
	 END IF;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `put_card_gatling` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35))  BEGIN 
DECLARE game_num int;
DECLARE ID int;
DECLARE codee int;
DECLARE player2 varchar (30);
DECLARE player3 varchar (30);
DECLARE player4 varchar (30);
set game_num=(SELECT ID_Game FROM Players WHERE Nickname=nm);
IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) 
    THEN 
	SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
	UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm; 
	 IF NOT EXISTS (SELECT Name_who FROM Moves WHERE Name_who=nm)
     THEN SELECT "Error! It's not your turn; Ошибка! Ход не ваш!";
     ELSE
	    IF NOT EXISTS (SELECT Nickname, Name FROM Cards_hands, Cards_types, Cards WHERE ID_Card=Cards.ID AND  Cards_types.ID=Cards.ID_Type_of AND Cards_types.Name='Гатлинг' AND Cards_hands.Nickname=nm)
    THEN SELECT "Error! You don't have this card";
    ELSE

START TRANSACTION;
CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd varchar (30));
INSERT INTO TEMP SELECT NULL, Nickname FROM Players WHERE ID_Game=game_num AND Nickname!=nm;

SET player2=(SELECT id_cd FROM TEMP WHERE i=1);
SET player3=(SELECT id_cd FROM TEMP WHERE i=2);
SET player4=(SELECT id_cd FROM TEMP WHERE i=3);
DROP TABLE TEMP;
START TRANSACTION;
IF((SELECT Current_HP FROM Players WHERE Nickname=player2)!=0)
THEN

set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
                
CALL bang(player2, codee);
END if;
IF((SELECT Current_HP FROM Players WHERE Nickname=player3)!=0)
THEN
set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
CALL bang(player3, codee);
END if;
IF((SELECT Current_HP FROM Players WHERE Nickname=player4)!=0)
THEN
set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
CALL bang(player4, codee);
END if;
COMMIT;
START TRANSACTION;
SET ID= (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=6 LIMIT 1);
INSERT INTO Cards_Dumps VALUES (ID, (SELECT ID_Game FROM Players WHERE Nickname=nm LIMIT 1));
DELETE FROM Cards_hands WHERE ID_Card=ID AND Nickname=nm;

 UPDATE Moves SET Status=(SELECT CONCAT('Игрок ', nm,' использовал карту ','Гатлинг')) WHERE Name_who=nm;
          SELECT Status from Moves WHERE Name_who=nm;
          COMMIT;
 call check_game(nm,pw,0);
END if;
END if;
END if;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `put_card_peace` (IN `nm` VARCHAR(30), IN `pw` VARCHAR(30), IN `card_name` VARCHAR(30))  BEGIN
DECLARE flg INT;

DECLARE ID Int;
DECLARE codee Int;
DECLARE beerf Int;
DECLARE game_num int;
declare curhp int;
set curhp=(SELECT Current_HP FROM Players WHERE Nickname=nm);
set game_num=(SELECT ID_Game FROM Players WHERE Nickname=nm);
SET flg=0;
IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm AND Password=pw) 
    THEN 
	SELECT "Error! Wrong name or pass; Ошибка! Неверное имя или пароль"; 
	ELSE
	UPDATE Users SET Activity=CURRENT_TIMESTAMP WHERE Nickname=nm; 
	 IF NOT EXISTS (SELECT Name_who FROM Moves WHERE Name_who=nm)
     THEN SELECT "Error! It's not your turn; Ошибка! Ход не ваш!";
	   ELSE
         
	    IF NOT EXISTS (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID INNER JOIN Cards_types ON Cards.ID_Type_of=Cards_types.ID WHERE Nickname=nm AND name=card_name)
    THEN 
    SELECT "Error! You don't have this card";
    set flg=1;
    ELSE
    
    IF (card_name like 'Пиво' OR card_name like 'пиво')
           THEN
           START TRANSACTION;
            set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
               
           CALL beer(nm,codee);
           set beerf=1;
            COMMIT;
           ELSE
           IF (card_name like 'Дилижанс' OR card_name like 'дилижанс')
           THEN
           START TRANSACTION;
            set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
           CALL stage_coach(nm,codee);
                           COMMIT;
           else
           IF (card_name like 'Бочка' OR card_name like 'бочка')
           THEN
           IF (check_card_t(nm,1))
               THEN
               SET flg=1;
               SELECT 'У вас уже есть бочка';
               ELSE
               START TRANSACTION;
               set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
           CALL barrel(nm,codee);
                           COMMIT;
               END IF;
           ELSE
           IF (card_name like 'Волканик' OR card_name like 'волканик')
           THEN
               IF (check_card_t(nm,2))
               THEN
               SET flg=1;
               SELECT 'У вас уже есть волканик';
               ELSE
               START TRANSACTION;
               set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
               	CALL volcanic(nm, codee);
                                COMMIT;

           END IF;
           ELSE
           SELECT 'Карты для данного запроса не существует';
           set flg=1;
            end if;
           end if;
           end if;
           end if;
           end if;
          
   IF ((Curhp=(SELECT Current_HP FROM Players WHERE Nickname=nm)) AND beerf=1)
   THEN
   SET flg=1;
   END if;
   
	IF(flg=0)
    THEN
          UPDATE Moves SET Status=(SELECT CONCAT('Игрок ',nm,' использовал карту ', card_name)) WHERE Name_who=nm;
          SELECT Status from Moves WHERE Name_who=nm;
           end if;
           
       
END if;
END if;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `registration` (IN `nm` VARCHAR(25), IN `pw` VARCHAR(35))  BEGIN 
	IF NOT EXISTS(SELECT * FROM Users WHERE Nickname=nm) THEN
		INSERT INTO Users VALUES(nm, pw, CURRENT_TIMESTAMP,0); 
	ELSE SELECT "Error! User already exists; Ошибка! Пользователь уже существует"; 
	END IF;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `stage_coach` (IN `nm` VARCHAR(30), IN `codee` INT)  BEGIN
DECLARE ID int;
DECLARE game_num int;
set game_num=(SELECT ID_game FROM Players WHERE Nickname=nm LIMIT 1);
IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
            
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
            
If((SELECT COUNT(*) FROM Cards_Decks WHERE ID_Game=game_num)<2)
THEN
INSERT INTO Cards_Decks SELECT ID_Card, game_num FROM Cards_Dumps WHERE ID_Game=game_num ORDER BY RAND();
DELETE FROM Cards_Dumps WHERE ID_Game=game_num;
end if;

CREATE TEMPORARY TABLE TEMP (i INT PRIMARY KEY AUTO_INCREMENT, id_cd INT);
INSERT INTO TEMP SELECT NULL, ID_Card FROM Cards_Decks WHERE ID_Game=game_num ORDER BY rand() LIMIT 2 ;
DELETE FROM Cards_Decks WHERE ID_Card IN(SELECT id_cd FROM TEMP) AND ID_Game in(SELECT ID_Game FROM Players WHERE Nickname=nm);
INSERT INTO Cards_hands SELECT id_cd, Nickname FROM TEMP, Players where Nickname=nm;
DROP TABLE TEMP;
SET ID= (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=11 LIMIT 1);
DELETE FROM Cards_hands WHERE ID_Card=ID AND Nickname=nm;

end if;
end if;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `test` ()  NO SQL
BEGIN
DECLARE player1 varchar(30);
DECLARE player2 varchar(30);
DECLARE player3 varchar(30);
DECLARE player4 varchar(30);
DECLARE currentp varchar(30);
DECLARE pl2 varchar(30);
DECLARE pl3 varchar(30);
DECLARE pl4 varchar(30);
DECLARE special varchar(30);
DECLARE currentr int;
DECLARE alive int;
declare secret int;
DECLARE endd int;
declare codee int;
declare tmp int;


declare game_num int;
set secret=10;
set endd=0;
SET player1=concat('A',FLOOR(RAND()*(100000-1+1)+1));
SET player2=concat('A',FLOOR(RAND()*(100000-1+1)+1));
SET player3=concat('A',FLOOR(RAND()*(100000-1+1)+1));
SET player4=concat('A',FLOOR(RAND()*(100000-1+1)+1));
CALL registration(player1, 1);
CALL registration(player2, 1);	
CALL registration(player3, 1);	
CALL registration(player4, 1);

CALL log_in(player1, 1);
CALL log_in(player2, 1);	
CALL log_in(player3, 1);	
CALL log_in(player4, 1);
set game_num=(SELECT ID_Game from Players Where Nickname=player1);

WHILE (endd=0) 
DO

SELECT 'О';
set alive=(SELECT COUNT(*) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
set currentp=(SELECT Name_who FROM Moves WHERE Name_who in(SELECT Nickname FROM Players WHERE ID_Game=game_num));
set pl2=(SELECT Nickname FROM Players WHERE ID_Game=game_num AND Nickname!=currentp LIMIT 1);
set pl3=(SELECT Nickname FROM Players WHERE ID_Game=game_num AND Nickname!=currentp AND Nickname!=pl2 LIMIT 1);
set pl4=(SELECT Nickname FROM Players WHERE ID_Game=game_num AND Nickname!=currentp AND Nickname!=pl2 AND Nickname!=pl3 LIMIT 1);
set currentr=(SELECT ID_Role FROM Players WHERE Nickname=currentp);

SELECT '1';
call put_card_peace(currentp,1,'Дилижанс');
call put_card_peace(currentp,1,'Бочка');
call put_card_peace(currentp,1,'Волканик');
SELECT '2';
call put_card_gatling(currentp,1);
call panic_beauty(currentp,1,pl2,'Паника');
call panic_beauty(currentp,1,pl2,'Красотка');
call panic_beauty(currentp,1,pl3,'Паника');
call panic_beauty(currentp,1,pl3,'Красотка');
call panic_beauty(currentp,1,pl4,'Паника');
call panic_beauty(currentp,1,pl4,'Красотка');

IF(currentr=1 or currentr=2) 
THEN
IF(currentr=1)
THEN
set special=(SELECT Nickname FROM Players WHERE ID_Game=game_num and ID_Role=2);
ELSE
set special=(SELECT Nickname FROM Players WHERE ID_Game=game_num and ID_Role=1);
END IF;

SELECT '3';
IF ((alive=2))
THEN
call put_card_atk(currentp,1,(SELECT Nickname FROM Players WHERE ID_Game=game_num and Current_HP!=0 LIMIT 1),'Дуэль');
call put_card_atk(currentp,1,(SELECT Nickname FROM Players WHERE ID_Game=game_num and Current_HP!=0 LIMIT 1),'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
SELECT '4';
IF (SELECT prov(pl2,special))
THEN
if((SELECT Current_HP FROM Players WHERE Nickname=pl2)!=0)
THEN
call put_card_atk(currentp,1,pl2,'Дуэль');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
call put_card_atk(currentp,1,pl3,'Бэнг');

set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
END IF;
SELECT '5';

IF ((SELECT Nickname FROM Players WHERE Nickname=pl3)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl3)!=0)
THEN
call put_card_atk(currentp,1,pl3,'Дуэль');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
call put_card_atk(currentp,1,pl3,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl4)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl4)!=0)
THEN
call put_card_atk(currentp,1,pl4,'Дуэль');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
call put_card_atk(currentp,1,pl4,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;

SELECT '6';
IF (check_card_t(currentp,2)) THEN

IF (alive=2)
THEN
call put_card_atk(currentp,1,(SELECT Nickname FROM Players WHERE ID_Game=game_num and Current_HP!=0 LIMIT 1),'Бэнг');
call put_card_atk(currentp,1,(SELECT Nickname FROM Players WHERE ID_Game=game_num and Current_HP!=0 LIMIT 1),'Бэнг');
call put_card_atk(currentp,1,(SELECT Nickname FROM Players WHERE ID_Game=game_num and Current_HP!=0 LIMIT 1),'Бэнг');
call put_card_atk(currentp,1,(SELECT Nickname FROM Players WHERE ID_Game=game_num and Current_HP!=0 LIMIT 1),'Бэнг');
call put_card_atk(currentp,1,(SELECT Nickname FROM Players WHERE ID_Game=game_num and Current_HP!=0 LIMIT 1),'Бэнг');

END IF;
SELECT '7';
IF ((SELECT Nickname FROM Players WHERE Nickname=pl2)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl2)!=0)
THEN
call put_card_atk(currentp,1,pl2,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl2)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl2)!=0)
THEN
call put_card_atk(currentp,1,pl2,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl2)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl2)!=0)
THEN
call put_card_atk(currentp,1,pl2,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl2)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl2)!=0)
THEN
call put_card_atk(currentp,1,pl2,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl2)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl2)!=0)
THEN
call put_card_atk(currentp,1,pl2,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
SELECT '8';
IF ((SELECT Nickname FROM Players WHERE Nickname=pl3)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl3)!=0)
THEN
call put_card_atk(currentp,1,pl3,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl3)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl3)!=0)
THEN
call put_card_atk(currentp,1,pl3,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl3)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl3)!=0)
THEN
call put_card_atk(currentp,1,pl3,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl3)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl3)!=0)
THEN
call put_card_atk(currentp,1,pl3,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl3)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl3)!=0)
THEN
call put_card_atk(currentp,1,pl3,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
SELECT '9';
IF ((SELECT Nickname FROM Players WHERE Nickname=pl4)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl4)!=0)
THEN
call put_card_atk(currentp,1,pl4,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl4)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl4)!=0)
THEN
call put_card_atk(currentp,1,pl4,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl4)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl4)!=0)
THEN
call put_card_atk(currentp,1,pl4,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl4)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl4)!=0)
THEN
call put_card_atk(currentp,1,pl4,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;
IF ((SELECT Nickname FROM Players WHERE Nickname=pl4)!=Special AND (SELECT Current_HP FROM Players WHERE Nickname=pl4)!=0)
THEN
call put_card_atk(currentp,1,pl4,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
END IF;

SELECT '10';
END IF;
END IF;
SELECT '11';

IF(currentr=3)
THEN
SELECT '11.1';
set special=(SELECT Nickname FROM Players WHERE ID_Game=game_num and ID_Role=1);
call put_card_atk(currentp,1,specal,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
call put_card_atk(currentp,1,specal,'Дуэль');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
SELECT '11.11';
IF (check_card_t(currentp,2)) THEN
SELECT '11.2';
call put_card_atk(currentp,1,specal,'Бэнг');
call put_card_atk(currentp,1,specal,'Бэнг');
call put_card_atk(currentp,1,specal,'Бэнг');
call put_card_atk(currentp,1,specal,'Бэнг');
call put_card_atk(currentp,1,specal,'Бэнг');
call put_card_atk(currentp,1,specal,'Бэнг');
call put_card_atk(currentp,1,specal,'Бэнг');
set alive=(SELECT COUNT(Nickname) FROM Players WHERE ID_Game=game_num and Current_HP!=0);
SELECT '11.3';
END IF;
END IF;

SELECT '12';
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call put_card_peace(currentp,1,'Дилижанс');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call put_card_peace(currentp,1,'Бочка');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call put_card_peace(currentp,1,'Волканик');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call put_card_peace(currentp,1,'Пиво');
END IF;

SELECT '13';

IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'бэнг');

END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'Тюрьма');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'Тюрьма');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'Тюрьма');
END IF;

SELECT '14';

IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'бэнг');
END IF;

IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'бэнг');

END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'бэнг');

END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'бэнг');

END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'мимо');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'мимо');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'мимо');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'мимо');
END IF;
IF((SELECT COUNT(ID_Card) FROM Cards_hands WHERE Nickname=currentp)>(SELECT Current_HP FROM Players WHERE Nickname=currentp))
THEN
call drop_card(currentp,'мимо');
END IF;


SELECT '15';
SET alive=(SELECT COUNT(*) FROM Players WHERE ID_Game=game_num AND Current_HP!=0);
set tmp=alive;
IF((SELECT ID_Role FROM Players WHERE ID_Game=game_num AND Current_HP!=0 LIMIT 1)=2 AND tmp=1 )
THEN
SELECT 'Игра окончена! Победа Ренегата:',Nickname FROM Players WHERE ID_Role=2 AND ID_Game=game_num;
set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
CALL delete_game(game_num,codee);
set endd=1;
ELSE
IF((SELECT Current_HP FROM Players WHERE ID_Role=1 AND ID_Game=game_num LIMIT 1)=0)
THEN
SELECT 'Игра окончена! Победили бандиты:',Nickname FROM Players WHERE ID_Role=3 AND ID_Game=game_num;
set codee=rand_code();
                INSERT INTO Codes VALUES(game_num,codee);
CALL delete_game(game_num,codee);
set endd=1;
ELSE
IF((SELECT ID_Role FROM Players WHERE ID_Game=game_num AND Current_HP!=0 LIMIT 1)=1 AND tmp=1 )
THEN
SELECT 'Игра окончена! Победа Шерифа:',Nickname FROM Players WHERE ID_Role=1 AND ID_Game=game_num;
set codee=rand_code();
INSERT INTO Codes VALUES(game_num,codee);
CALL delete_game(game_num,codee);
set endd=1;
END IF;
END IF;
   END IF;
   SELECT '16';
   call end_move(currentp,1);
END WHILE;
DELETE FROM Users WHERE Nickname=player1;
DELETE FROM Users WHERE Nickname=player2;
DELETE FROM Users WHERE Nickname=player3;
DELETE FROM Users WHERE Nickname=player4;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` PROCEDURE `volcanic` (IN `nm` VARCHAR(25), IN `codee` INT)  BEGIN
DECLARE ID Int;
DECLARE game_num int;
SET game_num=(SELECT ID_Game FROM Players WHERE Nickname=nm LIMIT 1);
 IF NOT EXISTS(SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)
            THEN
            SELECT 'Ошибка, кода не существует';
            else
            IF NOT((SELECT Code FROM Codes WHERE ID_Game=game_num LIMIT 1)=codee)
            THEN
            SELECT 'Ошибка, неверный код';
            ELSE
            DELETE FROM Codes WHERE ID_Game=game_num limit 1;
SET ID= (SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON Cards_hands.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=2 LIMIT 1);
INSERT INTO Cards_on_table VALUES (ID, nm);
DELETE FROM Cards_hands WHERE ID_Card=ID AND Nickname=nm;

END if;
END if;
END$$

--
-- Функции
--
CREATE DEFINER=`host700505_1890`@`localhost` FUNCTION `check_card` (`nm` VARCHAR(25), `type` INT) RETURNS INT(11) BEGIN 
DECLARE flag int;

IF EXISTS ( SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=type )
THEN set flag=1;
ELSE
IF EXISTS (SELECT ID_Card FROM Cards_on_table INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=type)
THEN set flag=1;
ELSE 
set flag=0;
end if; 
end if; 
RETURN flag; 
END$$

CREATE DEFINER=`host700505_1890`@`localhost` FUNCTION `check_card_h` (`nm` VARCHAR(25), `type` INT) RETURNS INT(11) BEGIN
	DECLARE flag int;
    DECLARE game_num INT;
SET game_num=(SELECT ID_Game FROM Players WHERE Nickname=nm LIMIT 1);
    IF EXISTS ( SELECT ID_Card FROM Cards_hands INNER JOIN Cards ON ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=type)
    THEN
    set flag=1;
    ELSE
    set flag=0;
    end if;
    RETURN flag;
   
END$$

CREATE DEFINER=`host700505_1890`@`localhost` FUNCTION `check_card_t` (`nm` VARCHAR(25), `type` INT) RETURNS INT(11) BEGIN
	DECLARE flag int;
    IF EXISTS ( SELECT ID_Card FROM Cards_on_table INNER JOIN Cards ON Cards_on_table.ID_Card = Cards.ID WHERE Nickname=nm AND ID_Type_of=type)
    THEN
    set flag=1;
    ELSE
    set flag=0;
    end if;
    RETURN flag;
   
END$$

CREATE DEFINER=`host700505_1890`@`localhost` FUNCTION `prov` (`a` VARCHAR(25), `b` VARCHAR(25)) RETURNS INT(11) NO SQL
BEGIN
IF (a!=b)
THEN
RETURN 1;
ELSE
RETURN 0;
END IF;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` FUNCTION `rand_code` () RETURNS INT(11) BEGIN
DECLARE rand int;
SET rand = FLOOR( 1 + RAND( ) *10000 );
RETURN rand;
END$$

CREATE DEFINER=`host700505_1890`@`localhost` FUNCTION `rollDice` () RETURNS INT(11) BEGIN
	DECLARE diceNum INT;
	SET diceNum = FLOOR( 1 + RAND( ) *6 );
	RETURN diceNum;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `Cards`
--

CREATE TABLE `Cards` (
  `ID` int(11) NOT NULL,
  `ID_Type_of` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `Cards_Decks`
--

CREATE TABLE `Cards_Decks` (
  `ID_Card` int(11) NOT NULL,
  `ID_Game` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `Cards_Dumps`
--

CREATE TABLE `Cards_Dumps` (
  `ID_Card` int(11) NOT NULL,
  `ID_Game` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `Cards_hands`
--

CREATE TABLE `Cards_hands` (
  `ID_Card` int(11) NOT NULL,
  `Nickname` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Триггеры `Cards_hands`
--
DELIMITER $$
CREATE TRIGGER `CHANGE4` AFTER UPDATE ON `Cards_hands` FOR EACH ROW INSERT INTO CHANGES VALUES(NULL, (SELECT ID_Game FROM Players WHERE Players.Nickname=NEW.Players.Nickname))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `Cards_on_table`
--

CREATE TABLE `Cards_on_table` (
  `ID_Card` int(11) NOT NULL,
  `Nickname` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Триггеры `Cards_on_table`
--
DELIMITER $$
CREATE TRIGGER `CHANGE3` AFTER UPDATE ON `Cards_on_table` FOR EACH ROW INSERT INTO CHANGES VALUES(NULL, (SELECT ID_Game FROM Players WHERE Players.Nickname=NEW.Players.Nickname))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `Cards_types`
--

CREATE TABLE `Cards_types` (
  `ID` int(11) NOT NULL,
  `Name` varchar(35) NOT NULL,
  `Reuseble` tinyint(1) NOT NULL,
  `Act` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Дамп данных таблицы `Cards_types`
--

INSERT INTO `Cards_types` (`ID`, `Name`, `Reuseble`, `Act`) VALUES
(1, 'Бочка', 1, 'Позволяет уклониться от бэнга, если на кубике 4=<6'),
(2, 'Волканик', 1, 'Позволяет использовать бэнг сколько угодно'),
(3, 'Тюрьма', 1, 'Вы пропускаете ход, если на кубике >4'),
(4, 'Пиво', 0, 'Добавляет очко здоровья'),
(5, 'Дуэль', 0, 'Позволяет вызвать на дуэль любого игрока'),
(6, 'Гатлинг', 0, 'Позволяет выстрелить по всем игрокам из гатлинга'),
(7, 'Мимо', 0, 'Позволяет избежать урона от карты Бэнг'),
(8, 'Бэнг', 0, 'Позволяет нанести урон игроку'),
(9, 'Паника', 0, 'Заберите себе на руку карту у любого игрока'),
(10, 'Красотка', 0, 'Заставьте любого игрока сбросить карту'),
(11, 'Дилижанс', 0, 'Возьмите две карты из колоды');

-- --------------------------------------------------------

--
-- Структура таблицы `CHANGES`
--

CREATE TABLE `CHANGES` (
  `ID` int(11) NOT NULL,
  `ID_Game` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `Codes`
--

CREATE TABLE `Codes` (
  `ID_Game` int(11) NOT NULL,
  `Code` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `Game`
--

CREATE TABLE `Game` (
  `ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `Moves`
--

CREATE TABLE `Moves` (
  `Name_who` varchar(25) NOT NULL,
  `Status` varchar(150) NOT NULL,
  `Bang_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Триггеры `Moves`
--
DELIMITER $$
CREATE TRIGGER `CHANGE1` AFTER UPDATE ON `Moves` FOR EACH ROW INSERT INTO CHANGES VALUES(NULL, (SELECT ID_Game FROM Players WHERE Players.Nickname=NEW.Players.Nickname))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `Players`
--

CREATE TABLE `Players` (
  `Nickname` varchar(25) NOT NULL,
  `ID_Role` int(11) NOT NULL,
  `ID_Queue` int(11) DEFAULT NULL,
  `ID_Game` int(11) DEFAULT NULL,
  `Max_HP` int(11) NOT NULL,
  `Current_HP` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Триггеры `Players`
--
DELIMITER $$
CREATE TRIGGER `CHANGE2` AFTER UPDATE ON `Players` FOR EACH ROW INSERT INTO CHANGES VALUES(NULL, (SELECT ID_Game FROM Players WHERE Players.Nickname=NEW.Players.Nickname))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `Roles`
--

CREATE TABLE `Roles` (
  `ID_Role` int(11) NOT NULL,
  `Name` varchar(30) DEFAULT NULL,
  `BonusHP` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Дамп данных таблицы `Roles`
--

INSERT INTO `Roles` (`ID_Role`, `Name`, `BonusHP`) VALUES
(1, 'Шериф', 1),
(2, 'Ренегат', 0),
(3, 'Бандит', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `Users`
--

CREATE TABLE `Users` (
  `Nickname` varchar(25) NOT NULL,
  `Password` varchar(25) NOT NULL,
  `Activity` timestamp NULL DEFAULT NULL,
  `Waiting_room` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

--
-- Дамп данных таблицы `Users`
--

INSERT INTO `Users` (`Nickname`, `Password`, `Activity`, `Waiting_room`) VALUES
('an', '1', '2021-04-05 10:08:03', 0),
('b', '1', '2021-04-16 09:34:35', 0),
('bb', '1', '2021-04-16 17:59:40', 0),
('c', '1', '2021-04-16 14:53:01', 0),
('d', '1', '2021-04-16 11:25:49', 0),
('dd', '1', '2021-04-15 18:09:26', 0),
('f', '1', '2021-04-02 17:08:49', 0),
('i', '1', '2021-04-02 17:08:49', 0),
('o', '1', '2021-04-02 17:08:49', 0),
('pi', '1', '2021-04-05 10:08:03', 0),
('u', '1', '2021-04-02 17:08:51', 0),
('Vasya', '1', '2021-04-17 13:24:46', 0);

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `Cards`
--
ALTER TABLE `Cards`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Type_of` (`ID_Type_of`);

--
-- Индексы таблицы `Cards_Decks`
--
ALTER TABLE `Cards_Decks`
  ADD PRIMARY KEY (`ID_Card`,`ID_Game`),
  ADD KEY `ID_Game` (`ID_Game`);

--
-- Индексы таблицы `Cards_Dumps`
--
ALTER TABLE `Cards_Dumps`
  ADD PRIMARY KEY (`ID_Card`,`ID_Game`),
  ADD KEY `ID_Game` (`ID_Game`);

--
-- Индексы таблицы `Cards_hands`
--
ALTER TABLE `Cards_hands`
  ADD PRIMARY KEY (`ID_Card`),
  ADD KEY `Nickname` (`Nickname`);

--
-- Индексы таблицы `Cards_on_table`
--
ALTER TABLE `Cards_on_table`
  ADD PRIMARY KEY (`ID_Card`),
  ADD KEY `Nickname` (`Nickname`);

--
-- Индексы таблицы `Cards_types`
--
ALTER TABLE `Cards_types`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `AK1` (`Act`) USING BTREE,
  ADD UNIQUE KEY `AK2` (`Name`) USING BTREE;

--
-- Индексы таблицы `CHANGES`
--
ALTER TABLE `CHANGES`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Game` (`ID_Game`);

--
-- Индексы таблицы `Codes`
--
ALTER TABLE `Codes`
  ADD PRIMARY KEY (`ID_Game`),
  ADD KEY `Index1` (`Code`);

--
-- Индексы таблицы `Game`
--
ALTER TABLE `Game`
  ADD PRIMARY KEY (`ID`);

--
-- Индексы таблицы `Moves`
--
ALTER TABLE `Moves`
  ADD PRIMARY KEY (`Name_who`);

--
-- Индексы таблицы `Players`
--
ALTER TABLE `Players`
  ADD PRIMARY KEY (`Nickname`),
  ADD UNIQUE KEY `AK1` (`ID_Game`,`ID_Queue`) USING BTREE,
  ADD KEY `ID_Role` (`ID_Role`),
  ADD KEY `ID_Game` (`ID_Game`),
  ADD KEY `Index1` (`Current_HP`);

--
-- Индексы таблицы `Roles`
--
ALTER TABLE `Roles`
  ADD PRIMARY KEY (`ID_Role`);

--
-- Индексы таблицы `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`Nickname`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `Cards`
--
ALTER TABLE `Cards`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7840;
--
-- AUTO_INCREMENT для таблицы `Cards_types`
--
ALTER TABLE `Cards_types`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `CHANGES`
--
ALTER TABLE `CHANGES`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `Game`
--
ALTER TABLE `Game`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=203;
--
-- AUTO_INCREMENT для таблицы `Roles`
--
ALTER TABLE `Roles`
  MODIFY `ID_Role` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `Cards`
--
ALTER TABLE `Cards`
  ADD CONSTRAINT `Cards_ibfk_1` FOREIGN KEY (`ID_Type_of`) REFERENCES `Cards_types` (`ID`);

--
-- Ограничения внешнего ключа таблицы `Cards_Decks`
--
ALTER TABLE `Cards_Decks`
  ADD CONSTRAINT `Cards_Decks_ibfk_1` FOREIGN KEY (`ID_Card`) REFERENCES `Cards` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `Cards_Decks_ibfk_2` FOREIGN KEY (`ID_Game`) REFERENCES `Game` (`ID`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `Cards_Dumps`
--
ALTER TABLE `Cards_Dumps`
  ADD CONSTRAINT `Cards_Dumps_ibfk_1` FOREIGN KEY (`ID_Card`) REFERENCES `Cards` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `Cards_Dumps_ibfk_2` FOREIGN KEY (`ID_Game`) REFERENCES `Game` (`ID`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `Cards_hands`
--
ALTER TABLE `Cards_hands`
  ADD CONSTRAINT `Cards_hands_ibfk_1` FOREIGN KEY (`ID_Card`) REFERENCES `Cards` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `Cards_hands_ibfk_2` FOREIGN KEY (`Nickname`) REFERENCES `Players` (`Nickname`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `Cards_on_table`
--
ALTER TABLE `Cards_on_table`
  ADD CONSTRAINT `Cards_on_table_ibfk_1` FOREIGN KEY (`ID_Card`) REFERENCES `Cards` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `Cards_on_table_ibfk_2` FOREIGN KEY (`Nickname`) REFERENCES `Players` (`Nickname`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `CHANGES`
--
ALTER TABLE `CHANGES`
  ADD CONSTRAINT `CHANGES_ibfk_1` FOREIGN KEY (`ID_Game`) REFERENCES `Game` (`ID`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `Codes`
--
ALTER TABLE `Codes`
  ADD CONSTRAINT `Codes_ibfk_1` FOREIGN KEY (`ID_Game`) REFERENCES `Game` (`ID`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `Moves`
--
ALTER TABLE `Moves`
  ADD CONSTRAINT `Moves_ibfk_1` FOREIGN KEY (`Name_who`) REFERENCES `Players` (`Nickname`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `Players`
--
ALTER TABLE `Players`
  ADD CONSTRAINT `Players_ibfk_1` FOREIGN KEY (`Nickname`) REFERENCES `Users` (`Nickname`),
  ADD CONSTRAINT `Players_ibfk_2` FOREIGN KEY (`ID_Role`) REFERENCES `Roles` (`ID_Role`),
  ADD CONSTRAINT `Players_ibfk_3` FOREIGN KEY (`ID_Game`) REFERENCES `Game` (`ID`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
