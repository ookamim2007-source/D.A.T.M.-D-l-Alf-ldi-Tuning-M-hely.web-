-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2026. Ápr 24. 09:17
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
-- Adatbázis: `turbo_webshop`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `engine_series`
--

CREATE TABLE `engine_series` (
  `id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `engine_code` varchar(50) NOT NULL,
  `notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `engine_series`
--

INSERT INTO `engine_series` (`id`, `manufacturer_id`, `engine_code`, `notes`) VALUES
(1, 1, '2JZ-GTE', NULL),
(2, 1, '1JZ-GTE', NULL),
(3, 1, '3S-GTE', NULL),
(4, 1, 'G16E-GTS', NULL),
(5, 1, '7M-GTE', NULL),
(6, 1, '4A-GE', 'turbo konverzió'),
(7, 2, 'M20', 'turbo konv.'),
(8, 2, 'M30', 'turbo konv.'),
(9, 2, 'M50', 'turbo konv.'),
(10, 2, 'S14', NULL),
(11, 2, 'S38', NULL),
(12, 2, 'M21D24', 'dízel'),
(13, 2, 'M51D25', 'dízel'),
(14, 3, 'B16A', NULL),
(15, 3, 'B18C', NULL),
(16, 3, 'K20A', NULL),
(17, 3, 'K24', NULL),
(18, 3, 'H22A', NULL),
(19, 3, 'F20C', NULL),
(20, 4, 'M104', NULL),
(21, 4, 'M113', 'kompresszor helyett'),
(22, 4, 'M156', 'kompresszor helyett'),
(23, 4, 'OM606', 'dízel'),
(24, 4, 'M177', 'eredeti twin-turbo'),
(25, 4, 'M178', 'eredeti twin-turbo'),
(26, 5, '4G63T', NULL),
(27, 5, '4B11T', NULL),
(28, 5, '6G72', NULL),
(29, 5, '4G93', 'GSR / Putra'),
(30, 6, 'EJ20', NULL),
(31, 6, 'EJ207', NULL),
(32, 6, 'EJ25', NULL),
(33, 6, 'EJ257', NULL),
(34, 6, 'FA20DIT', NULL),
(35, 6, 'FA24', NULL),
(36, 6, 'EE20', 'dízel'),
(37, 7, 'EA113', '1.8T / 2.0TFSI'),
(38, 7, 'EA888', '1.8T / 2.0TFSI'),
(39, 7, 'VR6', 'AAA / ABV / R32'),
(40, 7, '1.9TDI', 'dízel (AFN, ASZ, ARL)'),
(41, 7, '2.0TDI', 'dízel (AFN, ASZ, ARL)'),
(42, 8, 'Cosworth YB', NULL),
(43, 8, 'Modular V8', '4.6 / 5.4'),
(44, 8, '2.3L EcoBoost', NULL),
(45, 8, '3.5L EcoBoost V6', NULL),
(46, 9, 'M96', NULL),
(47, 9, 'M97', NULL),
(48, 9, '9A1', NULL),
(49, 9, 'MA1', NULL),
(50, 9, 'M64', '964/993');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `engine_turbo_fitment`
--

CREATE TABLE `engine_turbo_fitment` (
  `id` int(11) NOT NULL,
  `engine_id` int(11) NOT NULL,
  `turbo_id` int(11) NOT NULL,
  `fitment_note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `engine_turbo_fitment`
--

INSERT INTO `engine_turbo_fitment` (`id`, `engine_id`, `turbo_id`, `fitment_note`) VALUES
(1, 1, 1, NULL),
(2, 2, 1, NULL),
(3, 1, 2, NULL),
(4, 2, 2, NULL),
(5, 1, 21, NULL),
(6, 2, 21, NULL),
(7, 1, 22, NULL),
(8, 2, 22, NULL),
(9, 1, 35, NULL),
(10, 2, 35, NULL),
(11, 1, 36, NULL),
(12, 2, 36, NULL),
(13, 1, 39, NULL),
(14, 2, 39, NULL),
(15, 1, 44, NULL),
(16, 2, 44, NULL),
(17, 1, 45, NULL),
(18, 2, 45, NULL),
(32, 3, 3, NULL),
(33, 3, 4, NULL),
(34, 3, 37, NULL),
(35, 3, 40, NULL),
(36, 3, 46, NULL),
(37, 3, 47, NULL),
(38, 3, 75, NULL),
(39, 4, 5, NULL),
(40, 4, 41, NULL),
(42, 5, 6, NULL),
(43, 5, 23, NULL),
(44, 5, 72, NULL),
(45, 5, 73, NULL),
(49, 6, 7, NULL),
(50, 6, 53, NULL),
(52, 7, 8, NULL),
(53, 8, 8, NULL),
(54, 9, 8, NULL),
(55, 7, 23, NULL),
(56, 8, 23, NULL),
(57, 9, 23, NULL),
(58, 7, 63, NULL),
(59, 8, 63, NULL),
(60, 9, 63, NULL),
(61, 7, 64, NULL),
(62, 8, 64, NULL),
(63, 9, 64, NULL),
(67, 10, 9, NULL),
(68, 11, 9, NULL),
(69, 10, 35, NULL),
(70, 11, 35, NULL),
(74, 12, 13, NULL),
(75, 13, 13, NULL),
(76, 12, 24, NULL),
(77, 13, 24, NULL),
(81, 14, 9, NULL),
(82, 15, 9, NULL),
(83, 16, 9, NULL),
(84, 17, 9, NULL),
(85, 18, 9, NULL),
(86, 19, 9, NULL),
(87, 14, 10, NULL),
(88, 15, 10, NULL),
(89, 16, 10, NULL),
(90, 17, 10, NULL),
(91, 18, 10, NULL),
(92, 19, 10, NULL),
(93, 14, 11, NULL),
(94, 15, 11, NULL),
(95, 16, 11, NULL),
(96, 17, 11, NULL),
(97, 18, 11, NULL),
(98, 19, 11, NULL),
(99, 14, 25, NULL),
(100, 15, 25, NULL),
(101, 16, 25, NULL),
(102, 17, 25, NULL),
(103, 18, 25, NULL),
(104, 19, 25, NULL),
(105, 14, 26, NULL),
(106, 15, 26, NULL),
(107, 16, 26, NULL),
(108, 17, 26, NULL),
(109, 18, 26, NULL),
(110, 19, 26, NULL),
(111, 14, 37, NULL),
(112, 15, 37, NULL),
(113, 16, 37, NULL),
(114, 17, 37, NULL),
(115, 18, 37, NULL),
(116, 19, 37, NULL),
(117, 14, 38, NULL),
(118, 15, 38, NULL),
(119, 16, 38, NULL),
(120, 17, 38, NULL),
(121, 18, 38, NULL),
(122, 19, 38, NULL),
(123, 14, 48, NULL),
(124, 15, 48, NULL),
(125, 16, 48, NULL),
(126, 17, 48, NULL),
(127, 18, 48, NULL),
(128, 19, 48, NULL),
(129, 14, 49, NULL),
(130, 15, 49, NULL),
(131, 16, 49, NULL),
(132, 17, 49, NULL),
(133, 18, 49, NULL),
(134, 19, 49, NULL),
(135, 14, 61, NULL),
(136, 15, 61, NULL),
(137, 16, 61, NULL),
(138, 17, 61, NULL),
(139, 18, 61, NULL),
(140, 19, 61, NULL),
(141, 14, 62, NULL),
(142, 15, 62, NULL),
(143, 16, 62, NULL),
(144, 17, 62, NULL),
(145, 18, 62, NULL),
(146, 19, 62, NULL),
(208, 20, 2, NULL),
(209, 20, 22, NULL),
(211, 21, 6, 'kompresszor helyett'),
(212, 22, 6, 'kompresszor helyett'),
(213, 21, 36, 'kompresszor helyett'),
(214, 22, 36, 'kompresszor helyett'),
(218, 23, 8, NULL),
(219, 23, 63, NULL),
(220, 23, 65, NULL),
(221, 24, 66, 'Upgrade'),
(222, 25, 66, 'Upgrade'),
(224, 26, 8, NULL),
(225, 27, 8, NULL),
(226, 26, 9, NULL),
(227, 27, 9, NULL),
(228, 26, 27, NULL),
(229, 27, 27, NULL),
(230, 26, 28, NULL),
(231, 27, 28, NULL),
(232, 26, 35, NULL),
(233, 27, 35, NULL),
(234, 26, 37, NULL),
(235, 27, 37, NULL),
(236, 26, 42, NULL),
(237, 27, 42, NULL),
(238, 26, 50, NULL),
(239, 27, 50, NULL),
(240, 26, 51, NULL),
(241, 27, 51, NULL),
(242, 26, 52, NULL),
(243, 27, 52, NULL),
(255, 28, 46, NULL),
(256, 28, 47, NULL),
(257, 28, 54, NULL),
(258, 28, 75, NULL),
(262, 29, 3, NULL),
(263, 29, 7, NULL),
(264, 29, 55, NULL),
(265, 30, 8, NULL),
(266, 31, 8, NULL),
(267, 32, 8, NULL),
(268, 33, 8, NULL),
(269, 30, 12, NULL),
(270, 31, 12, NULL),
(271, 32, 12, NULL),
(272, 33, 12, NULL),
(273, 30, 27, NULL),
(274, 31, 27, NULL),
(275, 32, 27, NULL),
(276, 33, 27, NULL),
(277, 30, 29, NULL),
(278, 31, 29, NULL),
(279, 32, 29, NULL),
(280, 33, 29, NULL),
(281, 30, 35, NULL),
(282, 31, 35, NULL),
(283, 32, 35, NULL),
(284, 33, 35, NULL),
(285, 30, 37, NULL),
(286, 31, 37, NULL),
(287, 32, 37, NULL),
(288, 33, 37, NULL),
(289, 30, 56, NULL),
(290, 31, 56, NULL),
(291, 32, 56, NULL),
(292, 33, 56, NULL),
(293, 30, 57, NULL),
(294, 31, 57, NULL),
(295, 32, 57, NULL),
(296, 33, 57, NULL),
(297, 30, 59, NULL),
(298, 31, 59, NULL),
(299, 32, 59, NULL),
(300, 33, 59, NULL),
(301, 30, 60, NULL),
(302, 31, 60, NULL),
(303, 32, 60, NULL),
(304, 33, 60, NULL),
(328, 34, 12, NULL),
(329, 35, 12, NULL),
(330, 34, 25, NULL),
(331, 35, 25, NULL),
(332, 34, 74, NULL),
(333, 35, 74, NULL),
(335, 36, 15, NULL),
(336, 36, 32, NULL),
(338, 37, 17, NULL),
(339, 38, 17, NULL),
(340, 37, 30, NULL),
(341, 38, 30, NULL),
(342, 37, 31, NULL),
(343, 38, 31, NULL),
(344, 37, 37, NULL),
(345, 38, 37, NULL),
(353, 37, 76, NULL),
(354, 38, 76, NULL),
(355, 37, 77, NULL),
(356, 38, 77, NULL),
(360, 39, 2, NULL),
(361, 39, 6, NULL),
(362, 39, 22, NULL),
(363, 39, 43, NULL),
(367, 40, 18, NULL),
(368, 41, 18, NULL),
(369, 40, 19, NULL),
(370, 41, 19, NULL),
(371, 40, 20, NULL),
(372, 41, 20, NULL),
(373, 40, 32, NULL),
(374, 41, 32, NULL),
(375, 40, 33, NULL),
(376, 41, 33, NULL),
(382, 42, 16, NULL),
(383, 42, 38, NULL),
(385, 43, 14, NULL),
(386, 43, 34, NULL),
(387, 43, 71, NULL),
(388, 44, 10, NULL),
(389, 44, 26, NULL),
(390, 44, 67, NULL),
(391, 44, 68, NULL),
(395, 45, 2, 'twin'),
(396, 46, 1, NULL),
(397, 47, 1, NULL),
(398, 48, 1, NULL),
(399, 49, 1, NULL),
(400, 46, 27, NULL),
(401, 47, 27, NULL),
(402, 48, 27, NULL),
(403, 49, 27, NULL),
(404, 46, 69, NULL),
(405, 47, 69, NULL),
(406, 48, 69, NULL),
(407, 49, 69, NULL),
(408, 46, 70, NULL),
(409, 47, 70, NULL),
(410, 48, 70, NULL),
(411, 49, 70, NULL),
(427, 50, 6, NULL),
(428, 50, 78, NULL);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `manufacturers`
--

CREATE TABLE `manufacturers` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `manufacturers`
--

INSERT INTO `manufacturers` (`id`, `name`) VALUES
(2, 'BMW'),
(8, 'Ford'),
(3, 'Honda'),
(4, 'Mercedes'),
(5, 'Mitsubishi'),
(9, 'Porsche'),
(6, 'Subaru'),
(1, 'Toyota'),
(7, 'Volkswagen');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `turbos`
--

CREATE TABLE `turbos` (
  `id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `model` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `turbos`
--

INSERT INTO `turbos` (`id`, `manufacturer_id`, `model`) VALUES
(1, 1, 'GTX3076R'),
(2, 1, 'GTX3582R'),
(3, 1, 'GT28RS'),
(4, 1, 'GT2871R'),
(5, 1, 'G25-550'),
(6, 1, 'GT35R'),
(7, 1, 'GT2554R'),
(8, 1, 'GTX3576R'),
(9, 1, 'GT3076R'),
(10, 1, 'GTX3071R'),
(11, 1, 'GT2860RS'),
(12, 1, 'GTX2971R'),
(13, 1, 'GT2260V'),
(14, 1, 'GTX4202R'),
(15, 1, 'GT2056V'),
(16, 1, 'T3/T04E'),
(17, 1, 'GTX2860R'),
(18, 1, 'GT1749V'),
(19, 1, 'GTB1756VK'),
(20, 1, 'GTB2260VK'),
(21, 2, 'S362'),
(22, 2, 'S366'),
(23, 2, 'S257SX'),
(24, 2, 'K26'),
(25, 2, 'EFR 6258'),
(26, 2, 'EFR 6758'),
(27, 2, 'EFR 7670'),
(28, 2, 'EFR 8370'),
(29, 2, 'EFR 7163'),
(30, 2, 'K04-064'),
(31, 2, 'K04-001'),
(32, 2, 'BV43'),
(33, 2, 'BV50'),
(34, 2, 'S475'),
(35, 3, '6262'),
(36, 3, '6466'),
(37, 3, '5858'),
(38, 3, '5431'),
(39, 4, 'GTII 7460R'),
(40, 4, 'GT2835'),
(41, 4, 'GTIII-5L'),
(42, 4, 'GT3240'),
(43, 4, 'T04Z'),
(44, 5, 'T67'),
(45, 5, 'T88'),
(46, 5, 'TD06 20G'),
(47, 6, 'TD06 20G'),
(48, 6, 'TD05H-16G'),
(49, 6, 'TD05H-20G'),
(50, 6, 'TD05-16G'),
(51, 6, 'TD05-18G'),
(52, 6, 'TD05-20G'),
(53, 6, 'TD04L-13T'),
(54, 6, 'TD04HL-15T'),
(55, 6, 'TD04L'),
(56, 7, 'VF34'),
(57, 7, 'VF48'),
(58, 7, 'RHF55'),
(59, 8, '1.5XTR'),
(60, 8, '3.0XTR'),
(61, 9, 'T3/T4 hybrid'),
(62, 10, 'T3/T4'),
(63, 11, 'HX35'),
(64, 11, 'HE351VE'),
(65, 11, 'HE221W'),
(66, 12, 'M177 stage2+'),
(67, 13, 'Cobb upgrade'),
(68, 14, 'Mountune upgrade'),
(69, 15, 'TPC Racing turbo'),
(70, 16, '996TT turbo upgrade'),
(71, 17, '76mm'),
(72, 18, 'CT26 upgrade (57-trim)'),
(73, 18, 'CT26 upgrade (60-1)'),
(74, 18, 'OEM VB'),
(75, 5, 'TD06 20G'),
(76, 19, 'TTE420'),
(77, 19, 'TTE525'),
(78, 20, 'K27 turbo');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `turbo_manufacturers`
--

CREATE TABLE `turbo_manufacturers` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `turbo_manufacturers`
--

INSERT INTO `turbo_manufacturers` (`id`, `name`) VALUES
(8, 'Blouch'),
(2, 'BorgWarner'),
(13, 'Cobb'),
(16, 'ESCO'),
(1, 'Garrett'),
(5, 'GReddy'),
(4, 'HKS'),
(11, 'Holset'),
(7, 'IHI'),
(20, 'KKK'),
(6, 'Mitsubishi Heavy Industries (MHI)'),
(14, 'Mountune'),
(18, 'OEM'),
(17, 'On3'),
(3, 'Precision'),
(12, 'Pure Turbos'),
(10, 'Rev9'),
(15, 'TPC Racing'),
(19, 'TTE'),
(9, 'Turbonetics');

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `engine_series`
--
ALTER TABLE `engine_series`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manufacturer_id` (`manufacturer_id`);

--
-- A tábla indexei `engine_turbo_fitment`
--
ALTER TABLE `engine_turbo_fitment`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_fitment` (`engine_id`,`turbo_id`),
  ADD KEY `turbo_id` (`turbo_id`);

--
-- A tábla indexei `manufacturers`
--
ALTER TABLE `manufacturers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- A tábla indexei `turbos`
--
ALTER TABLE `turbos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manufacturer_id` (`manufacturer_id`);

--
-- A tábla indexei `turbo_manufacturers`
--
ALTER TABLE `turbo_manufacturers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `engine_series`
--
ALTER TABLE `engine_series`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT a táblához `engine_turbo_fitment`
--
ALTER TABLE `engine_turbo_fitment`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=429;

--
-- AUTO_INCREMENT a táblához `manufacturers`
--
ALTER TABLE `manufacturers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `turbos`
--
ALTER TABLE `turbos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT a táblához `turbo_manufacturers`
--
ALTER TABLE `turbo_manufacturers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `engine_series`
--
ALTER TABLE `engine_series`
  ADD CONSTRAINT `engine_series_ibfk_1` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `engine_turbo_fitment`
--
ALTER TABLE `engine_turbo_fitment`
  ADD CONSTRAINT `engine_turbo_fitment_ibfk_1` FOREIGN KEY (`engine_id`) REFERENCES `engine_series` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `engine_turbo_fitment_ibfk_2` FOREIGN KEY (`turbo_id`) REFERENCES `turbos` (`id`) ON DELETE CASCADE;

--
-- Megkötések a táblához `turbos`
--
ALTER TABLE `turbos`
  ADD CONSTRAINT `turbos_ibfk_1` FOREIGN KEY (`manufacturer_id`) REFERENCES `turbo_manufacturers` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
