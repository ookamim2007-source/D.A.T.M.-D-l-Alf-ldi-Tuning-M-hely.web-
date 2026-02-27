-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2026. Feb 27. 08:34
-- Kiszolgáló verziója: 10.4.28-MariaDB
-- PHP verzió: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `turbo_adatbazis`
--
CREATE DATABASE IF NOT EXISTS `turbo_adatbazis` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_hungarian_ci;
USE `turbo_adatbazis`;

DELIMITER $$
--
-- Eljárások
--
DROP PROCEDURE IF EXISTS `sp_add_motor_turbo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_motor_turbo` (IN `p_gyarto_nev` VARCHAR(50), IN `p_motor_kod` VARCHAR(50), IN `p_turbo_gyarto_nev` VARCHAR(50), IN `p_turbo_modell` VARCHAR(100), IN `p_alkalmassag` ENUM('Gyári','Performance','Verseny','Drag','Daily'), IN `p_min_le` INT, IN `p_max_le` INT, IN `p_megjegyzes` TEXT)   BEGIN
    DECLARE v_motor_id INT UNSIGNED;
    DECLARE v_turbo_id INT UNSIGNED;
    
    -- Motor ID keresése
    SELECT m.id INTO v_motor_id
    FROM motorok m
    JOIN motorcsaladok mc ON m.motorcsalad_id = mc.id
    JOIN autogyartok ag ON mc.gyarto_id = ag.id
    WHERE ag.nev = p_gyarto_nev AND m.motor_kod = p_motor_kod
    LIMIT 1;
    
    -- Turbó ID keresése
    SELECT t.id INTO v_turbo_id
    FROM turbok t
    JOIN turbo_gyartok tg ON t.turbo_gyarto_id = tg.id
    WHERE tg.nev = p_turbo_gyarto_nev AND t.modell = p_turbo_modell
    LIMIT 1;
    
    -- Kapcsolat beszúrása
    IF v_motor_id IS NOT NULL AND v_turbo_id IS NOT NULL THEN
        INSERT INTO motor_turbo_kapcsolat 
        (motor_id, turbo_id, alkalmassag, teljesitmeny_tartomany_from, teljesitmeny_tartomany_to, megjegyzes)
        VALUES (v_motor_id, v_turbo_id, p_alkalmassag, p_min_le, p_max_le, p_megjegyzes);
        
        SELECT 'Sikeres hozzáadás' AS eredmeny;
    ELSE
        SELECT 'Hiba: Motor vagy turbó nem található' AS eredmeny;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_keres_motor_turbo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_keres_motor_turbo` (IN `p_gyarto` VARCHAR(50), IN `p_motor_kod` VARCHAR(50), IN `p_turbo_gyarto` VARCHAR(50), IN `p_turbo_modell` VARCHAR(100))   BEGIN
    SELECT DISTINCT
        ag.nev AS gyarto,
        m.motor_kod,
        tg.nev AS turbo_gyarto,
        t.modell AS turbo_modell,
        mtk.alkalmassag,
        CONCAT(mtk.teljesitmeny_tartomany_from, ' - ', mtk.teljesitmeny_tartomany_to, ' LE') AS teljesitmeny
    FROM motor_turbo_kapcsolat mtk
    JOIN motorok m ON mtk.motor_id = m.id
    JOIN motorcsaladok mc ON m.motorcsalad_id = mc.id
    JOIN autogyartok ag ON mc.gyarto_id = ag.id
    JOIN turbok t ON mtk.turbo_id = t.id
    JOIN turbo_gyartok tg ON t.turbo_gyarto_id = tg.id
    WHERE (p_gyarto IS NULL OR ag.nev LIKE CONCAT('%', p_gyarto, '%'))
      AND (p_motor_kod IS NULL OR m.motor_kod LIKE CONCAT('%', p_motor_kod, '%'))
      AND (p_turbo_gyarto IS NULL OR tg.nev LIKE CONCAT('%', p_turbo_gyarto, '%'))
      AND (p_turbo_modell IS NULL OR t.modell LIKE CONCAT('%', p_turbo_modell, '%'))
    ORDER BY ag.nev, m.motor_kod;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `autogyartok`
--

DROP TABLE IF EXISTS `autogyartok`;
CREATE TABLE `autogyartok` (
  `id` int(10) UNSIGNED NOT NULL,
  `nev` varchar(50) NOT NULL,
  `orszag` varchar(50) DEFAULT NULL,
  `megjegyzes` text DEFAULT NULL,
  `letrehozva` timestamp NOT NULL DEFAULT current_timestamp(),
  `modositva` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Autógyártók táblája';

--
-- A tábla adatainak kiíratása `autogyartok`
--

INSERT INTO `autogyartok` (`id`, `nev`, `orszag`, `megjegyzes`, `letrehozva`, `modositva`) VALUES
(1, 'TOYOTA', 'Japán', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(2, 'BMW', 'Németország', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(3, 'HONDA', 'Japán', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(4, 'MERCEDES', 'Németország', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(5, 'MITSUBISHI', 'Japán', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(6, 'SUBARU', 'Japán', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(7, 'VOLKSWAGEN', 'Németország', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(8, 'FORD', 'USA', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46'),
(9, 'PORSCHE', 'Németország', NULL, '2026-02-27 07:31:46', '2026-02-27 07:31:46');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kategoriak`
--

DROP TABLE IF EXISTS `kategoriak`;
CREATE TABLE `kategoriak` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `kat_nev` varchar(50) NOT NULL,
  `leiras` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Használati kategóriák';

--
-- A tábla adatainak kiíratása `kategoriak`
--

INSERT INTO `kategoriak` (`id`, `kat_nev`, `leiras`) VALUES
(1, 'Daily', 'Napi használatra alkalmas'),
(2, 'Street', 'Utcai sport'),
(3, 'Track', 'Versenypálya'),
(4, 'Drag', 'Gyorsulási verseny'),
(5, 'Drift', 'Drift'),
(6, 'Off-road', 'Terep'),
(7, 'OEM', 'Gyári csere');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `motorcsaladok`
--

DROP TABLE IF EXISTS `motorcsaladok`;
CREATE TABLE `motorcsaladok` (
  `id` int(10) UNSIGNED NOT NULL,
  `gyarto_id` int(10) UNSIGNED NOT NULL,
  `csalad_nev` varchar(100) NOT NULL,
  `hengerelrendezes` enum('Sor','V','Boxer','W','Rotációs') DEFAULT NULL,
  `hengerek_szama` tinyint(3) UNSIGNED DEFAULT NULL,
  `letrehozva` timestamp NOT NULL DEFAULT current_timestamp(),
  `modositva` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Motorcsaládok (pl. 2JZ, B16A, EA888)';

--
-- A tábla adatainak kiíratása `motorcsaladok`
--

INSERT INTO `motorcsaladok` (`id`, `gyarto_id`, `csalad_nev`, `hengerelrendezes`, `hengerek_szama`, `letrehozva`, `modositva`) VALUES
(1, 1, '2JZ', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(2, 1, '1JZ', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(3, 1, '3S', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(4, 1, 'G16E', 'Sor', 3, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(5, 1, '7M', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(6, 1, '4A', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(7, 2, 'M20', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(8, 2, 'M30', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(9, 2, 'M50', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(10, 2, 'S14', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(11, 2, 'S38', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(12, 2, 'M21', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(13, 2, 'M51', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(14, 3, 'B', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(15, 3, 'K', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(16, 3, 'H', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(17, 3, 'F', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(18, 4, 'M104', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(19, 4, 'M113', 'V', 8, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(20, 4, 'M156', 'V', 8, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(21, 4, 'OM606', 'Sor', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(22, 4, 'M177', 'V', 8, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(23, 4, 'M178', 'V', 8, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(24, 5, '4G6', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(25, 5, '4B1', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(26, 5, '6G7', 'V', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(27, 5, '4G9', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(28, 6, 'EJ', 'Boxer', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(29, 6, 'FA', 'Boxer', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(30, 6, 'EE', 'Boxer', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(31, 7, 'EA113', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(32, 7, 'EA888', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(33, 7, 'VR6', '', 6, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(34, 7, 'EA188', 'Sor', 4, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(35, 8, 'Cosworth YB', 'Sor', 4, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(36, 8, 'Modular', 'V', 8, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(37, 8, 'EcoBoost 2.3', 'Sor', 4, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(38, 8, 'EcoBoost 3.5', 'V', 6, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(39, 9, 'M96', 'Boxer', 6, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(40, 9, 'M97', 'Boxer', 6, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(41, 9, '9A1', 'Boxer', 6, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(42, 9, 'MA1', 'Boxer', 6, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(43, 9, 'M64', 'Boxer', 6, '2026-02-27 07:31:48', '2026-02-27 07:31:48');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `motorok`
--

DROP TABLE IF EXISTS `motorok`;
CREATE TABLE `motorok` (
  `id` int(10) UNSIGNED NOT NULL,
  `motorcsalad_id` int(10) UNSIGNED NOT NULL,
  `motor_kod` varchar(50) NOT NULL,
  `teljes_nev` varchar(255) DEFAULT NULL,
  `loero` int(10) UNSIGNED DEFAULT NULL,
  `hengerurtartalom` decimal(4,1) DEFAULT NULL,
  `evjarat_from` smallint(5) UNSIGNED DEFAULT NULL,
  `evjarat_to` smallint(5) UNSIGNED DEFAULT NULL,
  `uzemanyag` enum('Benzin','Dízel','Hybrid','Elektromos') DEFAULT 'Benzin',
  `megjegyzes` text DEFAULT NULL,
  `letrehozva` timestamp NOT NULL DEFAULT current_timestamp(),
  `modositva` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Konkrét motorváltozatok';

--
-- A tábla adatainak kiíratása `motorok`
--

INSERT INTO `motorok` (`id`, `motorcsalad_id`, `motor_kod`, `teljes_nev`, `loero`, `hengerurtartalom`, `evjarat_from`, `evjarat_to`, `uzemanyag`, `megjegyzes`, `letrehozva`, `modositva`) VALUES
(1, 1, '2JZ-GTE', NULL, 280, 3.0, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(2, 1, '1JZ-GTE', NULL, 280, 2.5, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(3, 2, '3S-GTE', NULL, 260, 2.0, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(4, 3, 'G16E-GTS', NULL, 272, 1.6, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(5, 4, '7M-GTE', NULL, 280, 3.0, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(6, 5, '4A-GE', NULL, 130, 1.6, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(7, 7, 'M20B25', NULL, 170, 2.5, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(8, 8, 'M30B35', NULL, 211, 3.5, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(9, 9, 'M50B25', NULL, 192, 2.5, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(10, 10, 'S14B23', NULL, 200, 2.3, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(11, 11, 'S38B36', NULL, 315, 3.6, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(12, 12, 'M21D24', NULL, 115, 2.4, NULL, NULL, 'Dízel', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(13, 13, 'M51D25', NULL, 143, 2.5, NULL, NULL, 'Dízel', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(14, 14, 'B16A', NULL, 160, 1.6, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(15, 14, 'B18C', NULL, 180, 1.8, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(16, 15, 'K20A', NULL, 220, 2.0, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(17, 15, 'K24A', NULL, 200, 2.4, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(18, 16, 'H22A', NULL, 200, 2.2, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(19, 17, 'F20C', NULL, 250, 2.0, NULL, NULL, 'Benzin', NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `motor_turbo_alternativak`
--

DROP TABLE IF EXISTS `motor_turbo_alternativak`;
CREATE TABLE `motor_turbo_alternativak` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `motor_turbo_id` bigint(20) UNSIGNED NOT NULL,
  `alternativ_turbo_id` int(10) UNSIGNED NOT NULL,
  `prioritas` tinyint(3) UNSIGNED DEFAULT 1,
  `megjegyzes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Alternatív turbó opciók';

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `motor_turbo_kapcsolat`
--

DROP TABLE IF EXISTS `motor_turbo_kapcsolat`;
CREATE TABLE `motor_turbo_kapcsolat` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `motor_id` int(10) UNSIGNED NOT NULL,
  `turbo_id` int(10) UNSIGNED NOT NULL,
  `alkalmassag` enum('Gyári','Performance','Verseny','Drag','Daily') DEFAULT 'Performance',
  `teljesitmeny_tartomany_from` int(10) UNSIGNED DEFAULT NULL,
  `teljesitmeny_tartomany_to` int(10) UNSIGNED DEFAULT NULL,
  `megjegyzes` text DEFAULT NULL,
  `forras` varchar(255) DEFAULT NULL,
  `letrehozva` timestamp NOT NULL DEFAULT current_timestamp(),
  `modositva` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Motorokhoz rendelt turbók';

--
-- A tábla adatainak kiíratása `motor_turbo_kapcsolat`
--

INSERT INTO `motor_turbo_kapcsolat` (`id`, `motor_id`, `turbo_id`, `alkalmassag`, `teljesitmeny_tartomany_from`, `teljesitmeny_tartomany_to`, `megjegyzes`, `forras`, `letrehozva`, `modositva`) VALUES
(1, 1, 1, 'Performance', 600, 750, NULL, NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(2, 1, 2, 'Performance', 700, 850, NULL, NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(3, 1, 21, 'Performance', 550, 700, NULL, NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(4, 1, 22, 'Drag', 600, 750, NULL, NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(5, 3, 3, 'Daily', 280, 350, NULL, NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(6, 3, 4, 'Performance', 320, 400, NULL, NULL, '2026-02-27 07:31:48', '2026-02-27 07:31:48');

--
-- Eseményindítók `motor_turbo_kapcsolat`
--
DROP TRIGGER IF EXISTS `trg_motor_turbo_insert`;
DELIMITER $$
CREATE TRIGGER `trg_motor_turbo_insert` AFTER INSERT ON `motor_turbo_kapcsolat` FOR EACH ROW BEGIN
    INSERT INTO motor_turbo_naplo (muvelet, motor_id, turbo_id, datum)
    VALUES ('INSERT', NEW.motor_id, NEW.turbo_id, NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `motor_turbo_kategoria`
--

DROP TABLE IF EXISTS `motor_turbo_kategoria`;
CREATE TABLE `motor_turbo_kategoria` (
  `motor_turbo_id` bigint(20) UNSIGNED NOT NULL,
  `kategoria_id` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Kategória hozzárendelés';

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `turbok`
--

DROP TABLE IF EXISTS `turbok`;
CREATE TABLE `turbok` (
  `id` int(10) UNSIGNED NOT NULL,
  `turbo_gyarto_id` int(10) UNSIGNED NOT NULL,
  `modell` varchar(100) NOT NULL,
  `tipus_id` int(10) UNSIGNED DEFAULT NULL,
  `compressor_trim` varchar(20) DEFAULT NULL,
  `turbine_trim` varchar(20) DEFAULT NULL,
  `aramlasi_kenesseg` decimal(5,2) DEFAULT NULL,
  `max_teljesitmeny` int(10) UNSIGNED DEFAULT NULL,
  `olajozas` enum('Olaj','Víz+Olaj','Csak olaj') DEFAULT 'Olaj',
  `wastegate` enum('Integrált','Külső','Nincs') DEFAULT 'Integrált',
  `megjegyzes` text DEFAULT NULL,
  `aktiv` tinyint(1) DEFAULT 1,
  `letrehozva` timestamp NOT NULL DEFAULT current_timestamp(),
  `modositva` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Turbó modellek';

--
-- A tábla adatainak kiíratása `turbok`
--

INSERT INTO `turbok` (`id`, `turbo_gyarto_id`, `modell`, `tipus_id`, `compressor_trim`, `turbine_trim`, `aramlasi_kenesseg`, `max_teljesitmeny`, `olajozas`, `wastegate`, `megjegyzes`, `aktiv`, `letrehozva`, `modositva`) VALUES
(1, 1, 'GTX3076R', 3, NULL, NULL, 65.00, 750, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(2, 1, 'GTX3582R', 3, NULL, NULL, 75.00, 850, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(3, 1, 'GT28RS', 2, NULL, NULL, 35.00, 350, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(4, 1, 'GT2871R', 2, NULL, NULL, 40.00, 400, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(5, 1, 'G25-550', 3, NULL, NULL, 55.00, 550, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(6, 1, 'GT35R', 2, NULL, NULL, 65.00, 650, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(7, 1, 'GT2554R', 1, NULL, NULL, 25.00, 250, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(8, 1, 'GTX3576R', 3, NULL, NULL, 70.00, 800, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(9, 1, 'GT3076R', 2, NULL, NULL, 60.00, 700, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(10, 1, 'GTX2971R', 3, NULL, NULL, 52.00, 600, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(11, 1, 'GT2860RS', 3, NULL, NULL, 35.00, 360, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(12, 1, 'GTX3071R', 3, NULL, NULL, 62.00, 720, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(13, 1, 'GT1749V', 5, NULL, NULL, 22.00, 180, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(14, 1, 'GTB1756VK', 5, NULL, NULL, 28.00, 220, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(15, 1, 'GTB2260VK', 5, NULL, NULL, 38.00, 280, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(16, 1, 'GT2260V', 5, NULL, NULL, 35.00, 260, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(17, 1, 'GT2056V', 5, NULL, NULL, 25.00, 200, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(18, 1, 'GTX4202R', 3, NULL, NULL, 95.00, 1200, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(19, 2, 'S362', 2, NULL, NULL, 62.00, 700, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(20, 2, 'S366', 2, NULL, NULL, 66.00, 750, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(21, 2, 'S257SX', 2, NULL, NULL, 55.00, 600, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(22, 2, 'EFR 6258', 3, NULL, NULL, 42.00, 450, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(23, 2, 'EFR 6758', 3, NULL, NULL, 48.00, 500, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(24, 2, 'EFR 7670', 3, NULL, NULL, 65.00, 700, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(25, 2, 'EFR 8370', 3, NULL, NULL, 75.00, 850, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(26, 2, 'K04-064', 2, NULL, NULL, 35.00, 320, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(27, 2, 'K04-001', 2, NULL, NULL, 35.00, 320, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(28, 2, 'BV43', 5, NULL, NULL, 38.00, 280, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(29, 2, 'BV50', 5, NULL, NULL, 45.00, 330, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48'),
(30, 2, 'K26', 2, NULL, NULL, 30.00, 250, 'Olaj', 'Integrált', NULL, 1, '2026-02-27 07:31:48', '2026-02-27 07:31:48');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `turbo_gyartok`
--

DROP TABLE IF EXISTS `turbo_gyartok`;
CREATE TABLE `turbo_gyartok` (
  `id` int(10) UNSIGNED NOT NULL,
  `nev` varchar(50) NOT NULL,
  `szekhely` varchar(100) DEFAULT NULL,
  `weboldal` varchar(255) DEFAULT NULL,
  `megjegyzes` text DEFAULT NULL,
  `letrehozva` timestamp NOT NULL DEFAULT current_timestamp(),
  `modositva` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Turbófeltöltő gyártók';

--
-- A tábla adatainak kiíratása `turbo_gyartok`
--

INSERT INTO `turbo_gyartok` (`id`, `nev`, `szekhely`, `weboldal`, `megjegyzes`, `letrehozva`, `modositva`) VALUES
(1, 'Garrett', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(2, 'BorgWarner', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(3, 'Precision', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(4, 'HKS', 'Japán', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(5, 'GReddy', 'Japán', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(6, 'IHI', 'Japán', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(7, 'TD', 'Japán', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(8, 'Holset', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(9, 'Turbonetics', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(10, 'Rev9', 'Kína', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(11, 'Blouch', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(12, 'TTE', 'Németország', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(13, 'Cobb', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(14, 'Mountune', 'UK', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(15, 'Pure Turbos', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(16, 'TPC Racing', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(17, 'ESCO', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47'),
(18, 'On3', 'USA', NULL, NULL, '2026-02-27 07:31:47', '2026-02-27 07:31:47');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `turbo_tipusok`
--

DROP TABLE IF EXISTS `turbo_tipusok`;
CREATE TABLE `turbo_tipusok` (
  `id` int(10) UNSIGNED NOT NULL,
  `tipus_nev` varchar(50) NOT NULL,
  `leiras` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci COMMENT='Turbó típusok (pl. Ball bearing, Journal bearing)';

--
-- A tábla adatainak kiíratása `turbo_tipusok`
--

INSERT INTO `turbo_tipusok` (`id`, `tipus_nev`, `leiras`) VALUES
(1, 'Ball Bearing', 'Golyóscsapágyas, gyorsabb spool'),
(2, 'Journal Bearing', 'Siklócsapágyas, tartósabb'),
(3, 'Dual Ball Bearing', 'Dupla golyóscsapágyas'),
(4, 'Roller Bearing', 'Görgőscsapágyas'),
(5, 'Variable Geometry', 'Változó geometriájú');

-- --------------------------------------------------------

--
-- A nézet helyettes szerkezete `vw_nepszeru_turbok`
-- (Lásd alább az aktuális nézetet)
--
DROP VIEW IF EXISTS `vw_nepszeru_turbok`;
CREATE TABLE `vw_nepszeru_turbok` (
`gyarto` varchar(50)
,`modell` varchar(100)
,`motorok_szama` bigint(21)
,`atlag_teljesitmeny` decimal(14,4)
);

-- --------------------------------------------------------

--
-- A nézet helyettes szerkezete `vw_teljes_turbo_lista`
-- (Lásd alább az aktuális nézetet)
--
DROP VIEW IF EXISTS `vw_teljes_turbo_lista`;
CREATE TABLE `vw_teljes_turbo_lista` (
`autogyarto` varchar(50)
,`motorcsalad` varchar(100)
,`motor_kod` varchar(50)
,`turbo_gyarto` varchar(50)
,`turbo_modell` varchar(100)
,`alkalmassag` enum('Gyári','Performance','Verseny','Drag','Daily')
,`min_LE` int(10) unsigned
,`max_LE` int(10) unsigned
,`megjegyzes` text
);

-- --------------------------------------------------------

--
-- Nézet szerkezete `vw_nepszeru_turbok`
--
DROP TABLE IF EXISTS `vw_nepszeru_turbok`;

DROP VIEW IF EXISTS `vw_nepszeru_turbok`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_nepszeru_turbok`  AS SELECT `tg`.`nev` AS `gyarto`, `t`.`modell` AS `modell`, count(distinct `mtk`.`motor_id`) AS `motorok_szama`, avg(`mtk`.`teljesitmeny_tartomany_to`) AS `atlag_teljesitmeny` FROM ((`motor_turbo_kapcsolat` `mtk` join `turbok` `t` on(`mtk`.`turbo_id` = `t`.`id`)) join `turbo_gyartok` `tg` on(`t`.`turbo_gyarto_id` = `tg`.`id`)) GROUP BY `t`.`id` HAVING `motorok_szama` > 1 ORDER BY count(distinct `mtk`.`motor_id`) DESC ;

-- --------------------------------------------------------

--
-- Nézet szerkezete `vw_teljes_turbo_lista`
--
DROP TABLE IF EXISTS `vw_teljes_turbo_lista`;

DROP VIEW IF EXISTS `vw_teljes_turbo_lista`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_teljes_turbo_lista`  AS SELECT `ag`.`nev` AS `autogyarto`, `mc`.`csalad_nev` AS `motorcsalad`, `m`.`motor_kod` AS `motor_kod`, `tg`.`nev` AS `turbo_gyarto`, `t`.`modell` AS `turbo_modell`, `mtk`.`alkalmassag` AS `alkalmassag`, `mtk`.`teljesitmeny_tartomany_from` AS `min_LE`, `mtk`.`teljesitmeny_tartomany_to` AS `max_LE`, `mtk`.`megjegyzes` AS `megjegyzes` FROM (((((`motor_turbo_kapcsolat` `mtk` join `motorok` `m` on(`mtk`.`motor_id` = `m`.`id`)) join `motorcsaladok` `mc` on(`m`.`motorcsalad_id` = `mc`.`id`)) join `autogyartok` `ag` on(`mc`.`gyarto_id` = `ag`.`id`)) join `turbok` `t` on(`mtk`.`turbo_id` = `t`.`id`)) join `turbo_gyartok` `tg` on(`t`.`turbo_gyarto_id` = `tg`.`id`)) ORDER BY `ag`.`nev` ASC, `m`.`motor_kod` ASC, `mtk`.`teljesitmeny_tartomany_from` ASC ;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `autogyartok`
--
ALTER TABLE `autogyartok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nev` (`nev`),
  ADD KEY `idx_gyarto_nev` (`nev`);

--
-- A tábla indexei `kategoriak`
--
ALTER TABLE `kategoriak`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kat_nev` (`kat_nev`),
  ADD KEY `idx_kat_nev` (`kat_nev`);

--
-- A tábla indexei `motorcsaladok`
--
ALTER TABLE `motorcsaladok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_motorcsalad` (`gyarto_id`,`csalad_nev`),
  ADD KEY `idx_csalad_nev` (`csalad_nev`);

--
-- A tábla indexei `motorok`
--
ALTER TABLE `motorok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_motor` (`motorcsalad_id`,`motor_kod`),
  ADD KEY `idx_motor_kod` (`motor_kod`),
  ADD KEY `idx_loero` (`loero`),
  ADD KEY `idx_evjarat` (`evjarat_from`,`evjarat_to`),
  ADD KEY `idx_motorok_hengerurtartalom` (`hengerurtartalom`);

--
-- A tábla indexei `motor_turbo_alternativak`
--
ALTER TABLE `motor_turbo_alternativak`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_alternativa` (`motor_turbo_id`,`alternativ_turbo_id`),
  ADD KEY `alternativ_turbo_id` (`alternativ_turbo_id`),
  ADD KEY `idx_prioritas` (`prioritas`);

--
-- A tábla indexei `motor_turbo_kapcsolat`
--
ALTER TABLE `motor_turbo_kapcsolat`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_motor_turbo` (`motor_id`,`turbo_id`,`alkalmassag`),
  ADD KEY `turbo_id` (`turbo_id`),
  ADD KEY `idx_teljesitmeny` (`teljesitmeny_tartomany_from`,`teljesitmeny_tartomany_to`),
  ADD KEY `idx_alkalmassag` (`alkalmassag`),
  ADD KEY `idx_motor_turbo_teljesitmeny` (`teljesitmeny_tartomany_from`,`teljesitmeny_tartomany_to`);

--
-- A tábla indexei `motor_turbo_kategoria`
--
ALTER TABLE `motor_turbo_kategoria`
  ADD PRIMARY KEY (`motor_turbo_id`,`kategoria_id`),
  ADD KEY `kategoria_id` (`kategoria_id`);

--
-- A tábla indexei `turbok`
--
ALTER TABLE `turbok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_turbo` (`turbo_gyarto_id`,`modell`),
  ADD KEY `tipus_id` (`tipus_id`),
  ADD KEY `idx_turbo_modell` (`modell`),
  ADD KEY `idx_max_teljesitmeny` (`max_teljesitmeny`),
  ADD KEY `idx_aramlas` (`aramlasi_kenesseg`),
  ADD KEY `idx_turbok_aramlas` (`aramlasi_kenesseg`);
ALTER TABLE `turbok` ADD FULLTEXT KEY `ft_turbo_search` (`modell`,`megjegyzes`);

--
-- A tábla indexei `turbo_gyartok`
--
ALTER TABLE `turbo_gyartok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nev` (`nev`),
  ADD KEY `idx_turbo_gyarto_nev` (`nev`);

--
-- A tábla indexei `turbo_tipusok`
--
ALTER TABLE `turbo_tipusok`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tipus_nev` (`tipus_nev`),
  ADD KEY `idx_tipus_nev` (`tipus_nev`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `autogyartok`
--
ALTER TABLE `autogyartok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `kategoriak`
--
ALTER TABLE `kategoriak`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT a táblához `motorcsaladok`
--
ALTER TABLE `motorcsaladok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT a táblához `motorok`
--
ALTER TABLE `motorok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT a táblához `motor_turbo_alternativak`
--
ALTER TABLE `motor_turbo_alternativak`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `motor_turbo_kapcsolat`
--
ALTER TABLE `motor_turbo_kapcsolat`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT a táblához `turbok`
--
ALTER TABLE `turbok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT a táblához `turbo_gyartok`
--
ALTER TABLE `turbo_gyartok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT a táblához `turbo_tipusok`
--
ALTER TABLE `turbo_tipusok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `motorcsaladok`
--
ALTER TABLE `motorcsaladok`
  ADD CONSTRAINT `motorcsaladok_ibfk_1` FOREIGN KEY (`gyarto_id`) REFERENCES `autogyartok` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `motorok`
--
ALTER TABLE `motorok`
  ADD CONSTRAINT `motorok_ibfk_1` FOREIGN KEY (`motorcsalad_id`) REFERENCES `motorcsaladok` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `motor_turbo_alternativak`
--
ALTER TABLE `motor_turbo_alternativak`
  ADD CONSTRAINT `motor_turbo_alternativak_ibfk_1` FOREIGN KEY (`motor_turbo_id`) REFERENCES `motor_turbo_kapcsolat` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `motor_turbo_alternativak_ibfk_2` FOREIGN KEY (`alternativ_turbo_id`) REFERENCES `turbok` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `motor_turbo_kapcsolat`
--
ALTER TABLE `motor_turbo_kapcsolat`
  ADD CONSTRAINT `motor_turbo_kapcsolat_ibfk_1` FOREIGN KEY (`motor_id`) REFERENCES `motorok` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `motor_turbo_kapcsolat_ibfk_2` FOREIGN KEY (`turbo_id`) REFERENCES `turbok` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `motor_turbo_kategoria`
--
ALTER TABLE `motor_turbo_kategoria`
  ADD CONSTRAINT `motor_turbo_kategoria_ibfk_1` FOREIGN KEY (`motor_turbo_id`) REFERENCES `motor_turbo_kapcsolat` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `motor_turbo_kategoria_ibfk_2` FOREIGN KEY (`kategoria_id`) REFERENCES `kategoriak` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `turbok`
--
ALTER TABLE `turbok`
  ADD CONSTRAINT `turbok_ibfk_1` FOREIGN KEY (`turbo_gyarto_id`) REFERENCES `turbo_gyartok` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `turbok_ibfk_2` FOREIGN KEY (`tipus_id`) REFERENCES `turbo_tipusok` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
