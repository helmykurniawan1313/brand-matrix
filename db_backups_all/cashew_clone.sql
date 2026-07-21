-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: cashew_clone
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `cashew_clone`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cashew_clone` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `cashew_clone`;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ledger_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `base_balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `icon` varchar(255) NOT NULL DEFAULT '?',
  `color` varchar(255) NOT NULL DEFAULT '#3b82f6',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_ledger_id_foreign` (`ledger_id`),
  CONSTRAINT `accounts_ledger_id_foreign` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,1,'NEO Helmy',4020000.00,1047000.00,1,'😺','#967d00','2026-04-01 18:51:36','2026-07-04 10:54:30'),(2,1,'BCA',2637000.00,6855000.00,0,'⚜️','#0561a3','2026-04-01 19:02:12','2026-07-04 05:28:40'),(3,1,'BRI',157000.00,2153000.00,6,'🅱️','#005e91','2026-04-01 19:40:35','2026-07-04 04:52:33'),(4,1,'Mandiri',218000.00,749000.00,5,'〽️','#005b94','2026-04-01 19:42:16','2026-06-23 23:39:02'),(5,1,'Krom',5513000.00,2500000.00,7,'🆗','#6216cc','2026-04-01 19:42:36','2026-07-04 05:46:45'),(6,1,'Jago',846000.00,1148000.00,8,'⛎','#54d948','2026-04-01 19:43:58','2026-06-23 23:40:05'),(7,1,'Superbank',5095500.00,4994000.00,4,'💱','#e8ffc7','2026-04-01 19:44:28','2026-06-29 00:05:27'),(8,1,'Gopay',8000.00,112000.00,9,'🎯','#3cc83e','2026-04-01 19:46:38','2026-07-04 04:06:51'),(9,1,'Seabank',1630000.00,22000.00,12,'💳','#1e3a8a','2026-04-01 19:47:15','2026-06-20 21:23:43'),(10,1,'Shopeepay',3000.00,18500.00,11,'💳','#1e3a8a','2026-04-01 19:47:42','2026-06-20 21:23:24'),(11,1,'Dana',77000.00,119000.00,10,'💶','#acadaf','2026-04-01 19:48:05','2026-07-04 05:59:31'),(12,1,'Bibit',2073000.00,2073000.00,28,'📈','#1e3a8a','2026-04-01 20:26:54','2026-05-17 01:25:26'),(13,1,'Cash Helmy',-64000.00,2763000.00,2,'💵','#009e32','2026-04-01 20:43:24','2026-06-29 00:01:19'),(14,1,'NEO Ibu',45000.00,45000.00,3,'😼','#fff066','2026-04-02 00:11:48','2026-05-17 01:25:26'),(15,1,'Gopay Coin',0.00,0.00,22,'🧿','#20df7c','2026-04-02 00:41:23','2026-05-17 01:25:26'),(16,1,'Cash Khusus',75000.00,75000.00,23,'💸','#2c8a00','2026-04-02 00:42:28','2026-05-17 01:25:26'),(17,1,'E-Money',17000.00,30000.00,24,'🎴','#1e3a8a','2026-04-02 00:43:13','2026-05-17 01:25:26'),(18,1,'Indodax',1347000.00,1347000.00,26,'📉','#1e3a8a','2026-04-02 00:43:49','2026-05-17 01:25:26'),(19,1,'Toko Crypto',2265000.00,2265000.00,25,'📉','#1e3a8a','2026-04-02 00:44:29','2026-05-17 01:25:26'),(20,1,'Pluang',5526000.00,5526000.00,27,'📉','#1e3a8a','2026-04-02 00:44:56','2026-05-17 01:25:26'),(21,1,'Cash Rika',5555000.00,0.00,13,'💴','#1e8a44','2026-04-12 23:22:29','2026-06-28 23:43:44'),(22,1,'BCA x Blibli Card',0.00,63500.00,18,'💳','#1e3a8a','2026-04-13 02:46:42','2026-07-04 06:26:57'),(23,1,'SpayLater',0.00,0.00,19,'💰','#ff8800','2026-04-13 20:45:28','2026-06-29 01:04:35'),(26,1,'TopedCard Rika',0.00,0.00,20,'🦉','#129900','2026-04-13 20:56:21','2026-06-20 21:25:02'),(28,1,'Toped card Helmy',0.00,0.00,21,'💳','#1e3a8a','2026-04-24 06:21:53','2026-06-20 21:24:32'),(29,1,'Krom Rika',700540.00,0.00,14,'🆗','#ffe8a8','2026-05-07 18:43:44','2026-06-28 23:36:40'),(30,1,'Tiktok Paylater',0.00,0.00,17,'🎵','#000000','2026-05-11 20:29:44','2026-05-24 08:17:21'),(31,1,'Shopeepay Rika',600.00,0.00,15,'✅','#fe7b34','2026-05-17 00:28:28','2026-05-22 18:38:03'),(32,1,'krom Bagus',0.00,0.00,16,'💳','#1e3a8a','2026-05-17 00:32:55','2026-06-23 23:11:30'),(33,1,'Seabank Rika',4500.00,0.00,0,'👑','#ff9500','2026-05-22 18:37:49','2026-05-22 18:41:09');
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-11b714a6ffcbe7277fd6d3494a3b1ab409475143','i:1;',1783145696),('laravel-cache-11b714a6ffcbe7277fd6d3494a3b1ab409475143:timer','i:1783145696;',1783145696),('laravel-cache-1a08ff3537b58141d5c2a9021f9f4d924e3f67a1','i:2;',1783224855),('laravel-cache-1a08ff3537b58141d5c2a9021f9f4d924e3f67a1:timer','i:1783224855;',1783224855),('laravel-cache-2ea55ddb1e19aef65263c0fc0909c76198e8eb4d','i:2;',1783145626),('laravel-cache-2ea55ddb1e19aef65263c0fc0909c76198e8eb4d:timer','i:1783145626;',1783145626),('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba','i:1;',1783226413),('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba:timer','i:1783226413;',1783226413),('laravel-cache-a133d5a005c87a7c5695935ccf17d358503b82df','i:3;',1783224710),('laravel-cache-a133d5a005c87a7c5695935ccf17d358503b82df:timer','i:1783224710;',1783224710);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ledger_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'both',
  `icon` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `categories_ledger_id_foreign` (`ledger_id`),
  CONSTRAINT `categories_ledger_id_foreign` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,1,'Gaji','both','💰','#167500','2026-04-01 19:03:46','2026-04-01 19:03:46'),(2,1,'Tagihan Bulanan','both','🧾','#ff0000','2026-04-01 19:18:36','2026-04-01 19:18:36'),(3,1,'Makanan & Minuman','both','🍽','#ba3b3b','2026-04-12 23:19:51','2026-04-13 23:23:12'),(4,1,'Pengembalian Hutang','both','🤑','#85ffa3','2026-04-13 02:08:39','2026-04-13 02:08:39'),(5,1,'Reimbustment','both','📁','#78d7e8','2026-04-13 02:42:48','2026-04-13 02:42:48'),(6,1,'Service Kendaraan','both','🛵','#fff475','2026-04-13 02:47:52','2026-04-13 23:24:34'),(7,1,'Others','both','📁','#78d7e8','2026-04-13 02:51:30','2026-04-13 02:51:30'),(8,1,'Non Personal','both','📁','#78d7e8','2026-04-14 23:04:55','2026-05-18 20:26:41'),(9,1,'Belanja','both','📁','#78d7e8','2026-04-14 23:06:43','2026-04-14 23:06:43'),(10,1,'Parkir','both','🅿️','#0000ff','2026-04-15 21:05:12','2026-04-15 21:05:12'),(11,1,'Olahraga','both','👻','#78d7e8','2026-04-18 01:37:35','2026-04-18 01:37:35'),(12,1,'BBM','both','⛽','#ffffff','2026-04-18 01:40:18','2026-04-18 01:40:18'),(13,1,'Cashback','both','⭐','#fdffba','2026-04-18 01:50:13','2026-04-18 01:50:54'),(14,1,'Utang Vina','both','💎','#d1b0b0','2026-04-21 06:47:29','2026-04-21 06:47:29'),(15,1,'Orang tua','both','📁','#ffffff','2026-04-22 09:53:50','2026-04-22 09:53:50'),(16,1,'Corrections','both','📁','#78d7e8','2026-05-23 23:24:43','2026-05-23 23:24:43'),(17,1,'Biaya Admin','both','📁','#78d7e8','2026-06-02 00:16:15','2026-06-02 00:16:15'),(18,1,'Traveling','both','📁','#78d7e8','2026-06-11 01:42:01','2026-06-11 01:42:01'),(19,1,'Jual Barang','both','📁','#78d7e8','2026-06-17 01:38:18','2026-06-17 01:38:18'),(20,1,'Office','both','🏢','#78d7e8','2026-07-03 10:03:28','2026-07-04 06:14:34'),(21,1,'Cicilan','expense','💸','#a78bfa','2026-07-04 06:25:00','2026-07-04 06:32:21');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `installments`
--

DROP TABLE IF EXISTS `installments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `installments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ledger_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `monthly_amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `start_date` date NOT NULL,
  `duration_months` int(11) NOT NULL,
  `base_price` decimal(15,2) NOT NULL,
  `account_id` bigint(20) unsigned NOT NULL,
  `category_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `installments_ledger_id_foreign` (`ledger_id`),
  KEY `installments_account_id_foreign` (`account_id`),
  KEY `installments_category_id_foreign` (`category_id`),
  CONSTRAINT `installments_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`),
  CONSTRAINT `installments_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `installments_ledger_id_foreign` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `installments`
--

LOCK TABLES `installments` WRITE;
/*!40000 ALTER TABLE `installments` DISABLE KEYS */;
INSERT INTO `installments` VALUES (1,1,'Sepatu Bagus',508000.00,127000.00,63500.00,0.00,'2026-04-14',8,508000.00,22,7,'2026-04-13 19:45:11','2026-07-04 06:26:57'),(2,1,'Laptop Bagus',920000.00,920000.00,460000.00,0.00,'2026-04-30',2,920000.00,22,7,'2026-04-13 20:41:32','2026-05-18 20:29:58'),(6,1,'X300 pro',14320000.00,8592000.00,2864000.00,0.00,'2026-04-22',5,14320000.00,23,2,'2026-04-22 09:44:11','2026-06-29 00:59:55'),(7,1,'Brownies',130500.00,130500.00,43500.00,0.00,'2026-04-22',3,130500.00,23,3,'2026-04-22 09:45:08','2026-06-29 01:00:37'),(8,1,'Cheesecake',61500.00,61500.00,20500.00,0.00,'2026-04-22',3,61500.00,23,3,'2026-04-22 09:46:06','2026-06-29 01:00:58'),(9,1,'Mikrotik E50UG',608000.00,152000.00,76000.00,0.00,'2026-05-17',8,608000.00,28,9,'2026-05-18 20:36:36','2026-06-17 00:50:48'),(10,1,'Vivo V70 FE',4680000.00,936000.00,468000.00,0.00,'2026-05-17',10,4680000.00,28,9,'2026-05-18 20:38:56','2026-06-17 00:50:47'),(12,1,'Beelink Mini S',840000.00,240000.00,120000.00,0.00,'2026-05-17',7,840000.00,28,9,'2026-05-18 20:42:06','2026-06-17 00:50:42'),(13,1,'Bumbu dimsum',117000.00,78000.00,39000.00,0.00,'2026-05-24',3,117000.00,23,3,'2026-05-23 23:03:02','2026-06-29 01:01:12'),(14,1,'AC Gree 1 PK',4719000.00,393250.00,393250.00,0.00,'2026-06-17',12,4719000.00,28,9,'2026-06-17 00:31:03','2026-06-17 00:50:34'),(15,1,'Jasa Pasang AC dkk',807000.00,67250.00,67250.00,0.00,'2026-06-17',12,807000.00,28,9,'2026-06-17 00:32:11','2026-06-17 00:50:33'),(16,1,'MNC HiFi 100 Mbps',1104000.00,184000.00,184000.00,0.00,'2026-06-17',6,1104000.00,28,2,'2026-06-17 00:44:24','2026-06-17 00:50:29'),(17,1,'Xiaomi Air Purifier 4 Compact',699000.00,58250.00,58250.00,0.00,'2026-06-17',12,699000.00,28,9,'2026-06-17 00:50:02','2026-06-17 00:50:23'),(18,1,'paket data vina',61500.00,20500.00,20500.00,0.00,'2026-06-19',3,61500.00,26,14,'2026-06-18 21:36:38','2026-06-18 21:36:53'),(19,1,'jaket olahraga',81000.00,27000.00,27000.00,0.00,'2026-06-29',3,81000.00,23,9,'2026-06-29 01:03:30','2026-06-29 01:03:39');
/*!40000 ALTER TABLE `installments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ledger_user`
--

DROP TABLE IF EXISTS `ledger_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ledger_user` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `ledger_id` bigint(20) unsigned NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'member',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ledger_user_user_id_foreign` (`user_id`),
  KEY `ledger_user_ledger_id_foreign` (`ledger_id`),
  CONSTRAINT `ledger_user_ledger_id_foreign` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ledger_user_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ledger_user`
--

LOCK TABLES `ledger_user` WRITE;
/*!40000 ALTER TABLE `ledger_user` DISABLE KEYS */;
INSERT INTO `ledger_user` VALUES (1,1,1,'member','2026-04-01 18:50:52','2026-04-01 18:50:52'),(2,2,1,'member','2026-04-01 18:50:52','2026-04-01 18:50:52');
/*!40000 ALTER TABLE `ledger_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ledgers`
--

DROP TABLE IF EXISTS `ledgers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ledgers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `currency` varchar(255) NOT NULL DEFAULT 'IDR',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ledgers`
--

LOCK TABLES `ledgers` WRITE;
/*!40000 ALTER TABLE `ledgers` DISABLE KEYS */;
INSERT INTO `ledgers` VALUES (1,'Main Family Ledger','IDR','2026-04-01 18:50:52','2026-04-01 18:50:52');
/*!40000 ALTER TABLE `ledgers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_03_27_072701_create_personal_access_tokens_table',1),(5,'2026_03_27_072739_create_ledgers_table',1),(6,'2026_03_27_072827_create_ledger_user_table',1),(7,'2026_03_27_072828_create_accounts_table',1),(8,'2026_03_27_072832_create_categories_table',1),(9,'2026_03_27_072840_create_transactions_table',1),(10,'2026_03_30_064536_add_to_account_id_to_transactions',1),(11,'2026_03_30_071357_create_installments_table',1),(12,'2026_03_30_092134_add_start_date_to_installments_table',1),(13,'2026_03_30_095429_add_interest_rate_to_installments_table',1),(14,'2026_04_02_020834_add_sort_order_to_accounts_table',2),(15,'2026_07_03_000001_add_notes_and_installment_id_to_transactions',3),(16,'2026_07_03_000002_make_category_type_optional',4),(17,'2026_07_04_000001_add_base_balance_to_accounts',5);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'cashew_clone_device','2bc1912510ca9358b0265dc35911c53a6f4dfb74cfc3f36fc4aadf4f95545b36','[\"*\"]','2026-04-01 20:53:05',NULL,'2026-04-01 18:51:22','2026-04-01 20:53:05'),(2,'App\\Models\\User',1,'cashew_clone_device','a2f4c5c2d5d2841acf88ddc922b55e95b58543d8a85f703fb67126fcba07d871','[\"*\"]','2026-04-05 01:01:24',NULL,'2026-04-01 18:53:52','2026-04-05 01:01:24'),(3,'App\\Models\\User',1,'cashew_clone_device','82e3f43e7e1829d7e4729f163d883ce517457a556f32b64e48f791aaa41adf66','[\"*\"]','2026-04-02 01:23:45',NULL,'2026-04-01 19:14:34','2026-04-02 01:23:45'),(4,'App\\Models\\User',1,'cashew_clone_device','f67f943f1e62dd1d2a2552303b401645fb946922f3fe1efa3b5caa98304c3217','[\"*\"]','2026-04-02 00:32:20',NULL,'2026-04-02 00:10:58','2026-04-02 00:32:20'),(5,'App\\Models\\User',2,'cashew_clone_device','e313e10a122b04be2b8e24f2c64da78f5f6fec98ce8637e24ef348b32c5639b4','[\"*\"]','2026-04-02 00:48:18',NULL,'2026-04-02 00:32:35','2026-04-02 00:48:18'),(6,'App\\Models\\User',1,'cashew_clone_device','08b4be29e94ec3e088f5e7aad60d8a0cc3a4dbaf4df6fdfc07777ec0ce7873e1','[\"*\"]','2026-04-05 01:01:35',NULL,'2026-04-05 01:01:33','2026-04-05 01:01:35'),(7,'App\\Models\\User',2,'cashew_clone_device','228f3c2f36def8f877d0903c0f736f839a34559ae6d12719986c55819fa3515f','[\"*\"]','2026-04-13 02:57:20',NULL,'2026-04-10 02:19:08','2026-04-13 02:57:20'),(8,'App\\Models\\User',1,'cashew_clone_device','e6d0e81eba154031ac8358145ca40548757ce8c9ea5133235331eb47dbbe9bf8','[\"*\"]','2026-04-24 06:23:42',NULL,'2026-04-10 02:19:46','2026-04-24 06:23:42'),(9,'App\\Models\\User',1,'cashew_clone_device','806584e8a5a3785377f996028505e81517ebffa28ca4a93eca4137fad26baddf','[\"*\"]','2026-04-13 16:42:37',NULL,'2026-04-12 02:58:06','2026-04-13 16:42:37'),(10,'App\\Models\\User',1,'cashew_clone_device','5f3ba55e06eccde10041f5fee55a02976284e43b44b79a749bd757ea8826f092','[\"*\"]','2026-06-11 07:02:44',NULL,'2026-04-12 02:59:38','2026-06-11 07:02:44'),(11,'App\\Models\\User',1,'cashew_clone_device','ebfbb6810f650ac0bf89567a655e16fa9e9fe862e5cbe4e39aa36123d67dd6aa','[\"*\"]','2026-06-29 01:04:37',NULL,'2026-04-13 01:59:22','2026-06-29 01:04:37'),(12,'App\\Models\\User',1,'cashew_clone_device','81992043ffdd916bc4bac97b820170328806d78cf9d07f7ed7bda077c96a0295','[\"*\"]','2026-06-03 19:50:10',NULL,'2026-04-13 19:42:57','2026-06-03 19:50:10'),(13,'App\\Models\\User',1,'cashew_clone_device','34a5269c0022ebc286f95cbe36606665fc425afc4064cccba0142a350e8e1601','[\"*\"]','2026-04-26 20:30:59',NULL,'2026-04-14 17:44:27','2026-04-26 20:30:59'),(14,'App\\Models\\User',1,'cashew_clone_device','278a46c3d20021f6ff3b63b0ca19cb8624e100d3a6452384516bbfaa35654e07','[\"*\"]','2026-04-18 22:21:32',NULL,'2026-04-18 22:11:16','2026-04-18 22:21:32'),(15,'App\\Models\\User',1,'cashew_clone_device','8f417dec5182472d7a95d9d016990f5bc92529e2ecc8b501db65a4138e36d646','[\"*\"]','2026-04-26 20:25:04',NULL,'2026-04-26 20:21:46','2026-04-26 20:25:04'),(16,'App\\Models\\User',1,'cashew_clone_device','4c40b2c0eee3ab8bf3f76d167f29bf3e7f9479a479b5915ea5e7e2256608b42c','[\"*\"]','2026-05-14 21:23:19',NULL,'2026-04-26 20:31:07','2026-05-14 21:23:19'),(17,'App\\Models\\User',1,'cashew_clone_device','072df8de308e91927f7e4025d402cddb6cb7b973cbb6f3b39200fc39d50c9119','[\"*\"]','2026-04-26 20:46:50',NULL,'2026-04-26 20:46:43','2026-04-26 20:46:50'),(18,'App\\Models\\User',1,'cashew_clone_device','0db77ab8c2daec0520b5593f0f3b5fcb5c4c21b9cefc841bc99ef4fa9bfd2eb0','[\"*\"]','2026-04-26 20:46:55',NULL,'2026-04-26 20:46:45','2026-04-26 20:46:55'),(19,'App\\Models\\User',1,'cashew_clone_device','d0b7b005197e11602948c9cb0a83b6884f28c3cf66b184c3cf6e36bf4be6a52c','[\"*\"]','2026-04-26 20:46:59',NULL,'2026-04-26 20:46:49','2026-04-26 20:46:59'),(20,'App\\Models\\User',1,'cashew_clone_device','908cd9eb81f7ef60829ac9e95ee352c87d2cb39de827d19fb448984c2653e026','[\"*\"]','2026-04-26 22:50:14',NULL,'2026-04-26 20:46:50','2026-04-26 22:50:14'),(21,'App\\Models\\User',1,'cashew_clone_device','57f0b493aab214280c1496066e630575c8a2047a05002bf04d08573e649c9f89','[\"*\"]','2026-04-30 20:36:31',NULL,'2026-04-26 23:09:58','2026-04-30 20:36:31'),(22,'App\\Models\\User',1,'cashew_clone_device','9101f9a872c16a28f3a71784ec62c2492067ff7fd9e34644a6624d71342efcf8','[\"*\"]','2026-06-03 16:56:49',NULL,'2026-05-05 19:29:25','2026-06-03 16:56:49'),(23,'App\\Models\\User',1,'cashew_clone_device','ce9b1a27282830f285b9dd15c4b67c8e090703b1528833cc674b5b3acc92d144','[\"*\"]','2026-06-03 19:51:10',NULL,'2026-06-03 19:51:09','2026-06-03 19:51:10'),(24,'App\\Models\\User',1,'cashew_clone_device','019da20ea584c96e7225698a7a41143b0a7ebf43d96ffd6f570d0c59ffafc269','[\"*\"]','2026-06-29 00:07:02',NULL,'2026-06-03 19:51:29','2026-06-29 00:07:02'),(25,'App\\Models\\User',1,'cashew_clone_device','9e507d0dfb0ab9050aebb240f33bb1236ab43684aa4c63191186ac049d4eaee8','[\"*\"]','2026-06-23 23:40:06',NULL,'2026-06-18 23:32:47','2026-06-23 23:40:06'),(26,'App\\Models\\User',1,'cashew_clone_device','7c1a2833d6be7fc0591d86cc532d6b6d65ac063c785425169013bbd21acab763','[\"*\"]','2026-07-04 06:25:45',NULL,'2026-07-03 09:31:55','2026-07-04 06:25:45'),(27,'App\\Models\\User',1,'cashew_clone_device','112308a5367e67f403fcefd857003bb0b89ebcd2185a64a3dcdb84aadf7cc2c9','[\"*\"]','2026-07-03 09:37:46',NULL,'2026-07-03 09:37:46','2026-07-03 09:37:46'),(28,'App\\Models\\User',1,'cashew_clone_device','31916064d7e411c04c948c54f2c16c30da771574b4366fc14dc2a206a949e360','[\"*\"]','2026-07-03 09:38:26',NULL,'2026-07-03 09:38:25','2026-07-03 09:38:26'),(29,'App\\Models\\User',1,'cashew_clone_device','67e8342bde156e7a60dab07d5be01b3d7c0fd9f5e5b2f792bc784b421809e2e0','[\"*\"]','2026-07-03 09:39:19',NULL,'2026-07-03 09:39:19','2026-07-03 09:39:19'),(30,'App\\Models\\User',1,'cashew_clone_device','3eafd6f6df3f4e47176f2cf5d19a78f684c3baad1a172bcff20aaa1f7f5cd4b4','[\"*\"]','2026-07-03 09:39:29',NULL,'2026-07-03 09:39:28','2026-07-03 09:39:29'),(31,'App\\Models\\User',1,'cashew_clone_device','77eac6fb432e8e31fca3de0f63702eaaa7f1fd8e79b6bf1e323cb2df4fb43667','[\"*\"]','2026-07-03 10:03:28',NULL,'2026-07-03 10:03:28','2026-07-03 10:03:28'),(32,'App\\Models\\User',1,'cashew_clone_device','a1bdb28f8b839b0654e0c8943ee73ad7641022a8898adc4120e39e4083621bf4','[\"*\"]','2026-07-03 10:03:38',NULL,'2026-07-03 10:03:38','2026-07-03 10:03:38'),(33,'App\\Models\\User',1,'cashew_clone_device','e0ccda6361a325b4f5c4130c22fa6542eb3aeea652ca3b8daa0c4c536798f3e6','[\"*\"]','2026-07-03 10:03:47',NULL,'2026-07-03 10:03:47','2026-07-03 10:03:47'),(34,'App\\Models\\User',1,'cashew_clone_device','45c3ff244ac1c0e06cfcd9f5897d6723d345ef47f20b5db15eb57729dabeb212','[\"*\"]','2026-07-03 10:03:55',NULL,'2026-07-03 10:03:54','2026-07-03 10:03:55'),(35,'App\\Models\\User',1,'cashew_clone_device','64833ae1fdbbb97d8d77b48015fc9ad039486c554010ff32fec001ca95c8c0ea','[\"*\"]','2026-07-04 04:02:44',NULL,'2026-07-04 04:02:43','2026-07-04 04:02:44'),(36,'App\\Models\\User',1,'cashew_clone_device','e54c853a8d9c1ea14987b5506297c5a675543db45a55f3a0ebb20fac15ffb0dc','[\"*\"]','2026-07-04 04:02:54',NULL,'2026-07-04 04:02:54','2026-07-04 04:02:54'),(37,'App\\Models\\User',1,'cashew_clone_device','dfd8191d1d276e5c752c5cfad8a72f502ffe75a0767d29057133bce8f0a9df69','[\"*\"]','2026-07-04 04:06:10',NULL,'2026-07-04 04:06:10','2026-07-04 04:06:10'),(38,'App\\Models\\User',1,'cashew_clone_device','339ccf1778bda9c72b18aedfbfb1bae6443507e37f8cb248eb82de2fac7fef6a','[\"*\"]','2026-07-04 11:10:52',NULL,'2026-07-04 06:13:56','2026-07-04 11:10:52'),(39,'App\\Models\\User',1,'cashew_clone_device','ddc7f220551f0b94247dee9496f998034c98fa0a31a9ce50b755d9d285447d1d','[\"*\"]','2026-07-04 06:25:00',NULL,'2026-07-04 06:25:00','2026-07-04 06:25:00'),(40,'App\\Models\\User',1,'cashew_clone_device','0619bc3621faae074bad8db191388feb9adc6ae94c10fdfdcc646fb3c0f034b2','[\"*\"]','2026-07-04 06:26:33',NULL,'2026-07-04 06:26:33','2026-07-04 06:26:33'),(41,'App\\Models\\User',1,'cashew_clone_device','93bf68b2e94073b6627c9b78dbef01598fb22936ef837d578d551e350ad8aea3','[\"*\"]','2026-07-04 06:26:40',NULL,'2026-07-04 06:26:39','2026-07-04 06:26:40'),(42,'App\\Models\\User',1,'cashew_clone_device','f26d53a8efd5a617f82209afa381adb66273a914e3aaccf000d1d87a308a09f1','[\"*\"]','2026-07-04 06:26:47',NULL,'2026-07-04 06:26:47','2026-07-04 06:26:47'),(43,'App\\Models\\User',1,'cashew_clone_device','ebe408e2dacdcd65e7917b1a30e6e3ddcecc3a245342245bb7cac3f03f1bbbe6','[\"*\"]','2026-07-04 06:26:57',NULL,'2026-07-04 06:26:57','2026-07-04 06:26:57'),(44,'App\\Models\\User',1,'cashew_clone_device','60f13aa602d191fd9903ff3a6c474e4a3af1da2a9149d266139e5d3596e944fe','[\"*\"]','2026-07-04 06:27:05',NULL,'2026-07-04 06:27:05','2026-07-04 06:27:05'),(45,'App\\Models\\User',1,'cashew_clone_device','e46448f57edf3a936144566e2ec515d3bb5c19f5846e050e75421d494ff122c7','[\"*\"]','2026-07-04 06:27:19',NULL,'2026-07-04 06:27:19','2026-07-04 06:27:19'),(46,'App\\Models\\User',1,'cashew_clone_device','f0086669ecb64acdfe44a56b36b817ff8a65f4c8be88d2de2ac8c5bdd30d6ec3','[\"*\"]','2026-07-04 10:51:29',NULL,'2026-07-04 10:51:29','2026-07-04 10:51:29'),(47,'App\\Models\\User',1,'cashew_clone_device','37784221c194f29371e5dcdec843900b9f1e67555d648d63d80ed6689bb5c99c','[\"*\"]','2026-07-04 10:51:52',NULL,'2026-07-04 10:51:51','2026-07-04 10:51:52'),(48,'App\\Models\\User',1,'cashew_clone_device','bd65b21ed82a07ef1dc6add0abf1982ce201660f0c19b4556e653367d47d5ae9','[\"*\"]','2026-07-04 10:54:30',NULL,'2026-07-04 10:54:30','2026-07-04 10:54:30'),(49,'App\\Models\\User',1,'cashew_clone_device','00a3cda5c398092abfeecacd21d14c27292a7d2ba450d4a646af7f4c092661a4','[\"*\"]','2026-07-04 10:58:39',NULL,'2026-07-04 10:58:38','2026-07-04 10:58:39'),(50,'App\\Models\\User',1,'cashew_clone_device','21bcccf32bc7f0fe8261f41518a619c26303ecfd84dcbc56ddda15ecd093a832','[\"*\"]','2026-07-04 10:58:47',NULL,'2026-07-04 10:58:47','2026-07-04 10:58:47'),(51,'App\\Models\\User',1,'cashew_clone_device','da04fc7dc7cff4e244062acb4ad136e699d9209375eff8c6b087ad1a1206ed6b','[\"*\"]','2026-07-04 10:58:54',NULL,'2026-07-04 10:58:53','2026-07-04 10:58:54'),(52,'App\\Models\\User',1,'cashew_clone_device','e4ba7ef1745c434a036ae074b5824aac855287f1dd558d821e6985383a1b91b4','[\"*\"]','2026-07-04 10:59:02',NULL,'2026-07-04 10:59:01','2026-07-04 10:59:02'),(53,'App\\Models\\User',1,'cashew_clone_device','e5b13e6c068538da34ac1bb3692e4fe6e352782bb7751a6cae93353d375c8df1','[\"*\"]','2026-07-04 10:59:14',NULL,'2026-07-04 10:59:14','2026-07-04 10:59:14'),(54,'App\\Models\\User',1,'cashew_clone_device','0210271619a35f2d5533d95753213594a262bdac5c7803c668476cf08fab0ba4','[\"*\"]','2026-07-04 10:59:23',NULL,'2026-07-04 10:59:22','2026-07-04 10:59:23'),(55,'App\\Models\\User',1,'cashew_clone_device','6b085f4f7fc64813ded28b6e98b846aec5a5f6a3b5e004c4c9e9bd3a53f20d02','[\"*\"]',NULL,NULL,'2026-07-04 10:59:43','2026-07-04 10:59:43'),(56,'App\\Models\\User',1,'cashew_clone_device','693e87cfa6fd0c84d683a183df0771cf73285723d87c1ce28e8fccfe21f89d8f','[\"*\"]','2026-07-04 11:00:18',NULL,'2026-07-04 11:00:11','2026-07-04 11:00:18'),(57,'App\\Models\\User',1,'cashew_clone_device','8a916ced03ff6828e2f62ac62f5fb2574737c0be66ec5b32188d0cfc10482fee','[\"*\"]','2026-07-05 05:03:22',NULL,'2026-07-05 04:11:23','2026-07-05 05:03:22'),(58,'App\\Models\\User',1,'cashew_clone_device','6a8303eb8c14786fc6b26cf2759da47f2d3795fe407c71949908c93f35ddb02d','[\"*\"]',NULL,NULL,'2026-07-05 04:13:24','2026-07-05 04:13:24'),(59,'App\\Models\\User',1,'cashew_clone_device','950578ee23c3f21e574bdfa6cd65ad16422d0b76d1ff2f07040bced2e7255ddc','[\"*\"]','2026-07-05 04:39:15',NULL,'2026-07-05 04:39:14','2026-07-05 04:39:15');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('5co3KOtsszYk6nVdJmZXLrJUyf7GBajHf0kgoaEp',NULL,'192.168.1.111','AVG Antivirus','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZVNPV1JMZVZ1cVYwcERsSmNDMFFMRllyVnEzQlpPbGhqQnNzNU9vTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly8xOTIuMTY4LjEuMTU5OjgwMDAiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1775101188),('D1NdIaggzp19DfkcsORZmkqk0jeUjpIsj2nklz63',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQklFUDFXMlBXQ0xuYkh1TzNQbmJRUWo1a0hSZTBFdTJER0J3amZKTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1775376072),('M4Y45OUBffQyLaU62ut4zfJPPP9PWq3prp0LKAAF',NULL,'192.168.1.111','','YTozOntzOjY6Il90b2tlbiI7czo0MDoiNVprbDRlZ3VndXRXUEoyNzJXUWpJTlpYZndtU1FBcnBGaG1SMUU4cCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly8xOTIuMTY4LjEuMTU5OjgwMDAiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1775101226);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ledger_id` bigint(20) unsigned NOT NULL,
  `account_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `category_id` bigint(20) unsigned DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `date` datetime NOT NULL,
  `title` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `to_account_id` bigint(20) unsigned DEFAULT NULL,
  `installment_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transactions_ledger_id_foreign` (`ledger_id`),
  KEY `transactions_account_id_foreign` (`account_id`),
  KEY `transactions_user_id_foreign` (`user_id`),
  KEY `transactions_to_account_id_foreign` (`to_account_id`),
  KEY `transactions_installment_id_foreign` (`installment_id`),
  CONSTRAINT `transactions_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transactions_installment_id_foreign` FOREIGN KEY (`installment_id`) REFERENCES `installments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `transactions_ledger_id_foreign` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transactions_to_account_id_foreign` FOREIGN KEY (`to_account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,1,1,2,3,12000.00,'2026-04-13 13:19:00','Mas Boss',NULL,'expense','2026-04-12 23:19:56','2026-04-12 23:19:56',NULL,NULL),(2,1,13,2,NULL,50000.00,'2026-04-13 13:22:00','Sangu',NULL,'transfer','2026-04-12 23:22:57','2026-04-12 23:22:57',21,NULL),(3,1,2,2,NULL,6500000.00,'2026-04-13 14:30:00','Transfer',NULL,'transfer','2026-04-13 00:30:47','2026-04-13 00:30:47',1,NULL),(4,1,21,1,4,20000.00,'2026-04-13 16:06:00','pengembalian belikopi',NULL,'income','2026-04-13 02:08:50','2026-04-13 02:08:50',NULL,NULL),(5,1,2,2,5,683500.00,'2026-04-13 16:41:00','Porta - Mouse, Keyboard, Stand Laptop',NULL,'income','2026-04-13 02:43:58','2026-04-13 02:43:58',NULL,NULL),(6,1,22,2,6,683500.00,'2026-04-13 16:46:00','03/03 Servis Mobil',NULL,'expense','2026-04-13 02:47:58','2026-04-13 02:47:58',NULL,NULL),(7,1,13,1,NULL,2000000.00,'2026-04-14 06:42:00','Transfer',NULL,'transfer','2026-04-13 16:42:36','2026-04-13 16:42:36',2,NULL),(8,1,22,1,21,63500.00,'2026-04-14 03:05:03','Sepatu Bagus (Cicilan Payment)',NULL,'expense','2026-04-13 20:05:03','2026-04-13 20:05:03',NULL,1),(9,1,7,1,3,11000.00,'2026-04-14 13:15:00','Es Masboss',NULL,'expense','2026-04-13 23:15:21','2026-04-13 23:15:21',NULL,NULL),(10,1,8,1,3,7000.00,'2026-04-14 13:22:00','Es chacup',NULL,'expense','2026-04-13 23:22:33','2026-04-13 23:22:33',NULL,NULL),(11,1,21,1,3,10000.00,'2026-04-14 00:03:00','Tahu krispi',NULL,'expense','2026-04-14 23:03:45','2026-04-14 23:07:33',NULL,NULL),(12,1,13,1,8,300000.00,'2026-04-15 13:04:00','Ganti Pajak Beat',NULL,'income','2026-04-14 23:05:16','2026-04-14 23:05:16',NULL,NULL),(13,1,7,1,3,13000.00,'2026-04-15 13:05:00','Es Mas Boss',NULL,'expense','2026-04-14 23:05:39','2026-04-14 23:05:39',NULL,NULL),(15,1,13,1,9,16000.00,'2026-04-14 02:06:00','Map & Paper Clip',NULL,'expense','2026-04-14 23:06:46','2026-04-15 00:41:20',NULL,NULL),(16,1,13,1,3,27000.00,'2026-04-15 13:07:00','Pentol',NULL,'expense','2026-04-14 23:07:35','2026-04-14 23:07:35',NULL,NULL),(18,1,21,1,4,10000.00,'2026-04-15 13:09:00','Uang Pentol mbak norma',NULL,'income','2026-04-14 23:09:13','2026-04-14 23:09:13',NULL,NULL),(19,1,13,1,3,3000.00,'2026-04-16 11:04:00','Lumpia',NULL,'expense','2026-04-15 21:04:35','2026-04-15 21:06:59',NULL,NULL),(20,1,13,1,10,2000.00,'2026-04-15 00:04:00','Parkir Bakso Sarjana',NULL,'expense','2026-04-15 21:05:37','2026-04-16 18:14:40',NULL,NULL),(21,1,21,1,3,8500.00,'2026-04-16 11:15:00','Udang Rambutan',NULL,'expense','2026-04-16 18:13:55','2026-04-16 18:13:55',NULL,NULL),(22,1,21,1,4,19000.00,'2026-04-16 08:14:00','Uang Pentol kopi nadia',NULL,'income','2026-04-16 18:15:08','2026-04-16 18:15:08',NULL,NULL),(23,1,7,1,3,59000.00,'2026-04-15 15:32:00','Bakso',NULL,'expense','2026-04-18 01:33:05','2026-04-18 01:33:05',NULL,NULL),(24,1,17,1,10,4000.00,'2026-04-15 15:34:00','Parkir WTC',NULL,'expense','2026-04-18 01:34:30','2026-04-18 01:34:30',NULL,NULL),(25,1,1,1,3,12000.00,'2026-04-16 15:34:00','Es mas boss',NULL,'expense','2026-04-18 01:35:07','2026-04-18 01:35:07',NULL,NULL),(26,1,7,1,3,12000.00,'2026-04-17 15:35:00','Es mas boss',NULL,'expense','2026-04-18 01:35:59','2026-04-18 01:35:59',NULL,NULL),(27,1,13,1,3,3000.00,'2026-04-17 15:36:00','Lumpia',NULL,'expense','2026-04-18 01:36:31','2026-04-18 01:36:31',NULL,NULL),(28,1,2,1,11,24000.00,'2026-04-17 15:36:00','Futsal',NULL,'expense','2026-04-18 01:37:38','2026-04-18 01:37:38',NULL,NULL),(29,1,7,1,3,10000.00,'2026-04-17 15:38:00','Degan',NULL,'expense','2026-04-18 01:38:37','2026-04-18 01:38:37',NULL,NULL),(30,1,1,1,3,15000.00,'2026-04-17 14:38:00','Pentol',NULL,'expense','2026-04-18 01:38:53','2026-04-18 01:38:53',NULL,NULL),(31,1,13,1,3,15000.00,'2026-04-17 15:39:00','Tahu tek',NULL,'expense','2026-04-18 01:39:13','2026-04-18 01:39:13',NULL,NULL),(32,1,13,1,12,28000.00,'2026-04-18 05:39:00','Bensin',NULL,'expense','2026-04-18 01:39:38','2026-04-18 01:41:14',NULL,NULL),(33,1,13,1,3,22000.00,'2026-04-18 15:40:00','Degan',NULL,'expense','2026-04-18 01:40:46','2026-04-18 01:40:46',NULL,NULL),(34,1,13,1,3,15000.00,'2026-04-18 15:40:00','Pentol',NULL,'expense','2026-04-18 01:41:02','2026-04-18 01:41:02',NULL,NULL),(35,1,21,1,3,20000.00,'2026-04-17 15:41:00','Pentol',NULL,'expense','2026-04-18 01:42:00','2026-04-18 01:42:00',NULL,NULL),(36,1,21,1,7,10000.00,'2026-04-17 15:42:00','Dipinjam Devin',NULL,'expense','2026-04-18 01:42:31','2026-04-18 01:42:31',NULL,NULL),(37,1,21,1,4,10000.00,'2026-04-18 15:42:00','Pentol mba norma',NULL,'income','2026-04-18 01:43:15','2026-04-18 01:43:15',NULL,NULL),(38,1,2,1,4,10000.00,'2026-04-17 15:43:00','Tf devin',NULL,'income','2026-04-18 01:43:43','2026-04-18 01:43:43',NULL,NULL),(39,1,8,1,2,21400.00,'2026-04-17 15:44:00','Pgn',NULL,'expense','2026-04-18 01:47:21','2026-05-17 01:10:07',NULL,NULL),(40,1,15,1,2,5050.00,'2026-04-17 15:47:00','Pgn',NULL,'expense','2026-04-18 01:47:42','2026-04-18 01:47:42',NULL,NULL),(41,1,15,1,13,5050.00,'2026-04-17 15:54:00','Cashback topedcard',NULL,'income','2026-04-18 01:54:32','2026-04-18 01:54:32',NULL,NULL),(42,1,6,1,3,93500.00,'2026-04-18 15:56:00','Belikopi',NULL,'expense','2026-04-18 01:57:20','2026-04-18 01:57:20',NULL,NULL),(43,1,2,1,4,12000.00,'2026-04-18 15:57:00','Icha kopi',NULL,'income','2026-04-18 01:57:45','2026-04-18 01:57:45',NULL,NULL),(44,1,21,1,4,14000.00,'2026-04-18 15:57:00','Norma kopi',NULL,'income','2026-04-18 01:58:09','2026-04-18 01:58:09',NULL,NULL),(45,1,21,1,4,15000.00,'2026-04-18 15:58:00','Brian kopi',NULL,'income','2026-04-18 01:58:34','2026-04-18 01:58:34',NULL,NULL),(46,1,21,1,4,13000.00,'2026-04-18 15:58:00','Pipit kopi',NULL,'income','2026-04-18 01:59:00','2026-04-18 01:59:00',NULL,NULL),(47,1,8,1,2,19500.00,'2026-04-18 16:19:00','Gojek madiun',NULL,'expense','2026-04-18 02:27:23','2026-04-18 02:27:23',NULL,NULL),(48,1,21,1,3,10000.00,'2026-04-18 12:11:00','Tahu tek',NULL,'expense','2026-04-18 22:12:42','2026-04-18 22:12:42',NULL,NULL),(56,1,23,1,21,2864000.00,'2026-04-22 23:46:00','X300 pro (Cicilan Payment)',NULL,'expense','2026-04-22 09:46:36','2026-04-22 09:46:36',NULL,6),(57,1,23,1,21,43500.00,'2026-04-22 23:46:00','Brownies (Cicilan Payment)',NULL,'expense','2026-04-22 09:46:51','2026-04-22 09:46:51',NULL,7),(58,1,23,1,21,20500.00,'2026-04-22 23:46:00','Cheesecake (Cicilan Payment)',NULL,'expense','2026-04-22 09:46:55','2026-04-22 09:46:55',NULL,8),(59,1,26,1,9,38000.00,'2026-04-22 23:47:00','amplop lebaran',NULL,'expense','2026-04-22 09:48:34','2026-04-22 09:48:34',NULL,NULL),(60,1,26,1,14,62000.00,'2026-04-22 23:48:00','paket data vina',NULL,'expense','2026-04-22 09:49:23','2026-05-11 19:17:05',NULL,NULL),(61,1,26,1,2,269000.00,'2026-04-22 23:49:00','wifi rika',NULL,'expense','2026-04-22 09:50:15','2026-04-22 09:50:15',NULL,NULL),(62,1,26,1,2,355000.00,'2026-04-22 23:50:00','Listrik rika',NULL,'expense','2026-04-22 09:51:02','2026-04-22 09:51:02',NULL,NULL),(63,1,26,1,14,297000.00,'2026-04-22 23:51:00','Wifi vina',NULL,'expense','2026-04-22 09:51:58','2026-05-11 19:19:00',NULL,NULL),(64,1,26,1,9,32000.00,'2026-04-22 23:52:00','Case headset hp',NULL,'expense','2026-04-22 09:52:56','2026-04-22 09:52:56',NULL,NULL),(65,1,26,1,15,87000.00,'2026-04-22 23:53:00','Cream mama',NULL,'expense','2026-04-22 09:53:56','2026-04-22 09:53:56',NULL,NULL),(66,1,26,1,14,150000.00,'2026-04-22 23:54:00','Paket data vina',NULL,'expense','2026-04-22 09:54:59','2026-05-11 19:19:13',NULL,NULL),(67,1,26,1,9,129000.00,'2026-04-22 23:55:00','Jersey bagus',NULL,'expense','2026-04-22 09:55:41','2026-04-22 09:55:41',NULL,NULL),(68,1,26,1,9,183000.00,'2026-04-22 23:56:00','Tas mbak kiki',NULL,'expense','2026-04-22 09:56:27','2026-04-22 09:56:27',NULL,NULL),(69,1,26,1,9,101000.00,'2026-04-22 23:57:00','Wardah lipstik',NULL,'expense','2026-04-22 09:57:50','2026-04-22 09:57:50',NULL,NULL),(70,1,26,1,14,150000.00,'2026-04-22 23:58:00','Paket data vina',NULL,'expense','2026-04-22 09:58:18','2026-05-11 19:20:08',NULL,NULL),(71,1,26,1,14,150000.00,'2026-04-22 23:58:00','Paket data vina',NULL,'expense','2026-04-22 09:58:40','2026-05-11 19:20:00',NULL,NULL),(72,1,26,1,14,202000.00,'2026-04-22 23:58:00','Token vina',NULL,'expense','2026-04-22 09:59:04','2026-05-11 19:19:46',NULL,NULL),(73,1,26,1,15,81000.00,'2026-04-22 23:59:00','Lipstik mama',NULL,'expense','2026-04-22 09:59:27','2026-04-22 09:59:36',NULL,NULL),(74,1,26,1,15,8000.00,'2026-04-22 23:59:00','Paket data mama',NULL,'expense','2026-04-22 10:00:12','2026-04-22 10:00:12',NULL,NULL),(75,1,26,1,14,100000.00,'2026-04-22 23:58:00','Pulsa vina',NULL,'expense','2026-04-22 10:00:38','2026-05-11 19:19:26',NULL,NULL),(77,1,1,1,NULL,2928000.00,'2026-04-23 00:05:00','Bayar spaylater',NULL,'transfer','2026-04-22 10:06:31','2026-04-24 06:13:59',23,NULL),(78,1,1,1,2,2394000.00,'2026-04-23 00:07:00','Bayar topedcard rika',NULL,'transfer','2026-04-22 10:08:43','2026-04-24 06:14:06',26,NULL),(79,1,2,1,NULL,100000.00,'2026-04-22 12:14:00','Tukar pudam',NULL,'transfer','2026-04-22 10:11:28','2026-04-22 10:11:28',21,NULL),(80,1,2,1,NULL,100000.00,'2026-04-22 12:11:00','Tukar nadya',NULL,'transfer','2026-04-22 10:11:56','2026-04-22 10:11:56',21,NULL),(81,1,21,1,1,3795000.00,'2026-04-18 12:50:00','Gaji',NULL,'income','2026-04-22 22:50:49','2026-04-23 18:41:07',NULL,NULL),(82,1,21,1,15,950000.00,'2026-04-19 12:50:00','Kasih mama',NULL,'expense','2026-04-22 22:51:21','2026-04-24 06:04:35',NULL,NULL),(83,1,21,1,NULL,2800000.00,'2026-04-20 12:51:00','Gaji rika',NULL,'transfer','2026-04-22 22:52:02','2026-04-23 18:42:01',2,NULL),(84,1,21,1,3,10000.00,'2026-04-23 08:27:00','cheese roll',NULL,'expense','2026-04-23 18:27:43','2026-04-23 18:27:43',NULL,NULL),(85,1,21,1,3,20000.00,'2026-04-19 08:39:00','Tahu bulat',NULL,'expense','2026-04-23 18:39:58','2026-04-23 18:39:58',NULL,NULL),(86,1,21,1,4,20000.00,'2026-04-20 08:47:00','kopi nadia',NULL,'income','2026-04-23 18:47:47','2026-04-23 19:15:34',NULL,NULL),(87,1,2,1,11,30000.00,'2026-04-19 20:02:00','Badminton',NULL,'expense','2026-04-24 06:02:50','2026-04-24 06:02:50',NULL,NULL),(88,1,13,1,3,41000.00,'2026-04-19 20:02:00','Capcin',NULL,'expense','2026-04-24 06:03:20','2026-04-24 06:03:20',NULL,NULL),(89,1,21,1,9,10000.00,'2026-04-19 20:03:00','Softex',NULL,'expense','2026-04-24 06:04:20','2026-04-24 06:04:20',NULL,NULL),(90,1,1,1,3,12000.00,'2026-04-20 20:04:00','Mas bos',NULL,'expense','2026-04-24 06:05:04','2026-04-24 06:05:41',NULL,NULL),(91,1,13,1,3,8000.00,'2026-04-20 20:05:00','Kiranti',NULL,'expense','2026-04-24 06:06:33','2026-04-24 06:07:10',NULL,NULL),(92,1,13,1,3,15000.00,'2026-04-20 20:06:00','Permen',NULL,'expense','2026-04-24 06:07:00','2026-04-24 06:08:08',NULL,NULL),(93,1,13,1,3,3000.00,'2026-04-20 20:08:00','Lumpia',NULL,'expense','2026-04-24 06:08:55','2026-04-24 06:08:55',NULL,NULL),(94,1,1,1,3,12000.00,'2026-04-21 20:08:00','Mas boss',NULL,'expense','2026-04-24 06:09:12','2026-04-24 06:09:12',NULL,NULL),(95,1,1,1,3,12000.00,'2026-04-22 20:09:00','Mas boss',NULL,'expense','2026-04-24 06:09:42','2026-04-24 06:09:42',NULL,NULL),(96,1,1,1,3,59000.00,'2026-04-22 20:09:00','Bakso',NULL,'expense','2026-04-24 06:10:07','2026-04-24 06:10:07',NULL,NULL),(97,1,13,1,10,2000.00,'2026-04-22 20:10:00','Parkir',NULL,'expense','2026-04-24 06:10:28','2026-04-24 06:10:28',NULL,NULL),(98,1,1,1,3,12000.00,'2026-04-23 20:10:00','Mas boss',NULL,'expense','2026-04-24 06:10:54','2026-04-24 06:10:54',NULL,NULL),(99,1,1,1,3,11000.00,'2026-04-24 20:11:00','Mas boss',NULL,'expense','2026-04-24 06:11:14','2026-04-24 06:11:14',NULL,NULL),(100,1,5,1,3,58000.00,'2026-04-24 20:11:00','Bakso',NULL,'expense','2026-04-24 06:11:38','2026-04-24 06:11:38',NULL,NULL),(101,1,13,1,10,2000.00,'2026-04-24 20:11:00','Parkir',NULL,'expense','2026-04-24 06:12:07','2026-04-24 06:12:07',NULL,NULL),(102,1,2,1,NULL,788500.00,'2026-04-24 20:14:00','Bayar cc',NULL,'transfer','2026-04-24 06:16:34','2026-04-24 06:16:34',22,NULL),(103,1,28,1,21,460000.00,'2026-04-24 20:16:00','Laptop Bagus (Cicilan Payment)',NULL,'expense','2026-04-24 06:16:47','2026-05-17 00:36:51',NULL,2),(104,1,2,1,3,8000.00,'2026-04-24 20:18:00','Lumpia',NULL,'expense','2026-04-24 06:19:08','2026-04-24 06:19:08',NULL,NULL),(105,1,1,1,NULL,2775500.00,'2026-04-24 20:21:00','Bayar topedcard',NULL,'transfer','2026-04-24 06:22:33','2026-04-24 06:22:33',28,NULL),(107,1,13,1,12,30000.00,'2026-04-25 09:23:00','bensin',NULL,'expense','2026-04-24 19:23:44','2026-04-24 19:23:44',NULL,NULL),(108,1,21,1,NULL,50000.00,'2026-04-25 09:24:00','tukar cash mas arif',NULL,'transfer','2026-04-24 19:24:26','2026-04-24 19:24:26',2,NULL),(109,1,13,1,10,2000.00,'2026-04-25 20:17:00','parkir taman prestasi',NULL,'expense','2026-04-26 18:18:59','2026-04-26 18:18:59',NULL,NULL),(110,1,13,1,3,7000.00,'2026-04-25 20:19:00','pop ice',NULL,'expense','2026-04-26 18:20:27','2026-04-26 18:20:27',NULL,NULL),(111,1,21,1,3,24000.00,'2026-04-25 02:39:00','degan',NULL,'expense','2026-04-26 18:22:08','2026-04-26 18:22:08',NULL,NULL),(112,1,6,1,3,67000.00,'2026-04-25 11:22:00','belikopi',NULL,'expense','2026-04-26 18:23:07','2026-04-26 18:23:07',NULL,NULL),(113,1,21,1,4,12000.00,'2026-04-25 11:23:00','BK mbak norma',NULL,'income','2026-04-26 18:23:53','2026-04-26 18:24:25',NULL,NULL),(114,1,21,1,4,10000.00,'2026-04-25 11:24:00','BK ICHA',NULL,'income','2026-04-26 18:25:11','2026-04-26 18:28:00',NULL,NULL),(115,1,21,1,4,13000.00,'2026-04-25 11:27:00','bk mas brian',NULL,'income','2026-04-26 18:27:32','2026-04-26 18:32:58',NULL,NULL),(116,1,21,1,4,10000.00,'2026-04-25 11:28:00','bk lusi',NULL,'income','2026-04-26 18:28:39','2026-04-26 18:28:39',NULL,NULL),(117,1,21,1,4,12000.00,'2026-04-25 11:28:00','bk pudam',NULL,'income','2026-04-26 18:29:03','2026-04-26 18:29:03',NULL,NULL),(118,1,21,1,3,8500.00,'2026-04-25 08:38:00','uc',NULL,'expense','2026-04-26 18:39:14','2026-04-26 18:39:14',NULL,NULL),(119,1,13,1,3,32000.00,'2026-04-26 00:39:00','degan',NULL,'expense','2026-04-26 18:40:46','2026-04-26 18:40:46',NULL,NULL),(120,1,13,1,NULL,100000.00,'2026-04-27 09:40:00','Tukar Cash',NULL,'transfer','2026-04-26 19:40:50','2026-04-26 19:40:50',6,NULL),(121,1,13,1,3,16000.00,'2026-04-27 16:39:00','uc larutan',NULL,'expense','2026-04-27 02:40:16','2026-04-27 02:40:16',NULL,NULL),(122,1,1,1,3,12000.00,'2026-04-27 16:40:00','mas boss',NULL,'expense','2026-04-27 02:40:32','2026-04-27 02:40:32',NULL,NULL),(123,1,21,1,7,28000.00,'2026-04-27 20:15:00','laundry',NULL,'expense','2026-04-27 18:15:57','2026-04-27 18:15:57',NULL,NULL),(124,1,2,1,4,1121500.00,'2026-04-27 08:16:00','Uang mba vina',NULL,'income','2026-04-27 18:16:49','2026-04-27 18:16:49',NULL,NULL),(126,1,2,1,1,5000000.00,'2026-04-28 21:12:00','Gaji helmy',NULL,'income','2026-04-28 07:12:49','2026-04-28 07:12:49',NULL,NULL),(127,1,1,1,3,12000.00,'2026-04-28 08:43:00','mas bos',NULL,'expense','2026-04-29 18:43:23','2026-04-29 18:43:23',NULL,NULL),(128,1,13,1,3,8000.00,'2026-04-29 08:43:00','uc',NULL,'expense','2026-04-29 18:44:16','2026-04-29 18:44:16',NULL,NULL),(129,1,1,1,3,12000.00,'2026-04-29 08:44:00','mas bos',NULL,'expense','2026-04-29 18:44:37','2026-04-29 18:44:37',NULL,NULL),(130,1,5,1,3,58000.00,'2026-04-29 08:44:00','bakso',NULL,'expense','2026-04-29 18:45:09','2026-04-29 18:45:09',NULL,NULL),(131,1,21,1,10,2000.00,'2026-04-29 08:45:00','parkir',NULL,'expense','2026-04-29 18:45:43','2026-04-29 18:45:43',NULL,NULL),(132,1,21,1,3,15000.00,'2026-04-28 08:46:00','pentol',NULL,'expense','2026-04-29 18:46:54','2026-04-29 18:46:54',NULL,NULL),(133,1,1,1,3,12000.00,'2026-04-30 08:39:00','mas bos',NULL,'expense','2026-05-07 18:39:56','2026-05-07 18:39:56',NULL,NULL),(134,1,1,1,3,12000.00,'2026-05-04 08:40:00','mas bos',NULL,'expense','2026-05-07 18:40:48','2026-05-07 18:40:48',NULL,NULL),(135,1,29,1,3,13000.00,'2026-05-05 08:40:00','mas bos',NULL,'expense','2026-05-07 18:41:12','2026-05-07 18:47:15',NULL,NULL),(136,1,1,1,3,12000.00,'2026-05-06 08:41:00','mas bos',NULL,'expense','2026-05-07 18:41:33','2026-05-07 18:41:33',NULL,NULL),(137,1,1,1,3,12000.00,'2026-05-07 08:41:00','mas bos',NULL,'expense','2026-05-07 18:41:55','2026-05-07 18:41:55',NULL,NULL),(138,1,29,1,3,10000.00,'2026-05-08 08:43:00','kopi janjiw',NULL,'expense','2026-05-07 18:44:10','2026-05-07 18:44:10',NULL,NULL),(139,1,13,1,3,20000.00,'2026-04-30 00:52:00','pentol',NULL,'expense','2026-05-07 18:48:31','2026-05-07 18:49:01',NULL,NULL),(140,1,21,1,4,10000.00,'2026-04-30 01:55:00','pentol mbak nor',NULL,'income','2026-05-07 18:49:38','2026-05-07 18:49:38',NULL,NULL),(141,1,5,1,3,58000.00,'2026-05-06 17:50:00','bakso',NULL,'expense','2026-05-07 18:51:03','2026-05-07 18:51:03',NULL,NULL),(142,1,13,1,10,2000.00,'2026-05-06 08:51:00','parkir',NULL,'expense','2026-05-07 18:51:22','2026-05-07 18:51:22',NULL,NULL),(143,1,21,1,3,10000.00,'2026-05-05 08:51:00','tahu krispi',NULL,'expense','2026-05-07 18:52:07','2026-05-07 18:52:07',NULL,NULL),(144,1,21,1,3,20000.00,'2026-05-03 08:54:00','batagor',NULL,'expense','2026-05-07 18:55:00','2026-05-07 18:55:00',NULL,NULL),(145,1,21,1,3,31000.00,'2026-05-02 08:55:00','es jeruk',NULL,'expense','2026-05-07 18:56:13','2026-05-07 18:56:13',NULL,NULL),(146,1,21,1,3,10000.00,'2026-05-07 08:56:00','permen',NULL,'expense','2026-05-07 18:56:36','2026-05-07 18:56:36',NULL,NULL),(147,1,21,1,4,14000.00,'2026-05-04 08:57:00','uang gojek mas arif',NULL,'income','2026-05-07 18:58:01','2026-05-07 18:58:01',NULL,NULL),(148,1,21,1,3,54000.00,'2026-05-08 08:26:00','sosis otak otak basreng',NULL,'expense','2026-05-10 18:26:43','2026-05-11 20:22:56',NULL,NULL),(149,1,21,1,3,53000.00,'2026-05-09 08:26:00','es teh kota',NULL,'expense','2026-05-10 18:27:16','2026-05-10 18:27:16',NULL,NULL),(150,1,29,1,3,30000.00,'2026-05-09 08:29:00','burger',NULL,'expense','2026-05-10 18:29:35','2026-05-10 18:29:35',NULL,NULL),(151,1,29,1,3,13000.00,'2026-05-09 08:29:00','teh chacup',NULL,'expense','2026-05-10 18:30:00','2026-06-24 01:37:42',NULL,NULL),(152,1,2,1,7,255000.00,'2026-05-11 16:45:00','cctv',NULL,'expense','2026-05-11 02:45:22','2026-05-11 02:45:22',NULL,NULL),(153,1,21,1,4,107000.00,'2026-05-11 16:45:00','cctv chacup burger norma',NULL,'income','2026-05-11 02:45:50','2026-05-11 02:45:50',NULL,NULL),(154,1,21,1,4,85000.00,'2026-05-11 16:45:00','cctv nadya',NULL,'income','2026-05-11 02:46:29','2026-05-11 02:46:29',NULL,NULL),(155,1,21,1,NULL,50000.00,'2026-05-11 16:46:00','tukar cash arif',NULL,'transfer','2026-05-11 02:46:51','2026-05-11 02:46:51',2,NULL),(156,1,1,1,3,11000.00,'2026-05-11 16:46:00','mas boss',NULL,'expense','2026-05-11 02:47:03','2026-05-17 01:09:19',NULL,NULL),(157,1,1,1,NULL,2500000.00,'2026-05-01 10:26:00','saldo awal',NULL,'transfer','2026-05-11 20:26:35','2026-05-11 20:26:35',29,NULL),(159,1,13,1,3,6000.00,'2026-05-12 16:03:00','cilok',NULL,'expense','2026-05-13 02:03:58','2026-05-13 02:03:58',NULL,NULL),(160,1,1,1,3,11000.00,'2026-05-12 16:04:00','mas boss',NULL,'expense','2026-05-13 02:04:21','2026-05-17 01:09:12',NULL,NULL),(161,1,1,1,3,13000.00,'2026-05-13 16:04:00','mas bos',NULL,'expense','2026-05-13 02:04:35','2026-05-17 01:09:06',NULL,NULL),(162,1,13,1,3,15000.00,'2026-05-17 12:31:00','Pentol',NULL,'expense','2026-05-16 22:31:29','2026-05-16 22:31:29',NULL,NULL),(163,1,1,1,NULL,300000.00,'2026-05-17 12:31:00','Transfer',NULL,'transfer','2026-05-16 22:32:00','2026-05-16 22:32:00',6,NULL),(164,1,1,1,NULL,300000.00,'2026-05-17 13:36:00','Transfer',NULL,'transfer','2026-05-16 23:36:26','2026-05-16 23:36:26',6,NULL),(165,1,5,1,3,28000.00,'2026-05-16 20:12:00','Martabak',NULL,'expense','2026-05-17 00:13:20','2026-05-17 00:13:20',NULL,NULL),(166,1,13,1,10,2000.00,'2026-05-16 14:13:00','Parkir Momoyo',NULL,'expense','2026-05-17 00:13:46','2026-05-17 00:13:46',NULL,NULL),(167,1,17,1,10,5000.00,'2026-05-16 14:13:00','Parkir Grand City',NULL,'expense','2026-05-17 00:14:18','2026-05-17 00:14:18',NULL,NULL),(168,1,13,1,3,10000.00,'2026-05-16 14:14:00','Permen Frozz',NULL,'expense','2026-05-17 00:14:40','2026-05-17 00:14:40',NULL,NULL),(169,1,13,1,3,24000.00,'2026-05-16 14:14:00','Es Degan',NULL,'expense','2026-05-17 00:15:03','2026-05-17 00:15:03',NULL,NULL),(170,1,21,1,4,25000.00,'2026-05-16 14:19:00','kopi norma',NULL,'income','2026-05-17 00:19:28','2026-05-17 00:19:28',NULL,NULL),(171,1,13,1,12,30000.00,'2026-05-16 14:26:00','bensin',NULL,'expense','2026-05-17 00:26:34','2026-05-17 00:27:03',NULL,NULL),(172,1,31,1,7,7500.00,'2026-05-16 14:28:00','bayar bca',NULL,'expense','2026-05-17 00:28:56','2026-05-17 00:28:56',NULL,NULL),(173,1,28,1,9,2315500.00,'2026-04-24 14:35:00','tagihan toped apr',NULL,'expense','2026-05-17 00:36:02','2026-05-17 00:37:49',NULL,NULL),(174,1,29,1,NULL,10000.00,'2026-05-16 14:37:00','bayar bca',NULL,'transfer','2026-05-17 00:38:32','2026-05-17 00:38:32',31,NULL),(175,1,2,1,NULL,10431500.00,'2026-05-17 14:39:00','penyesuaian',NULL,'transfer','2026-05-17 00:40:03','2026-05-17 00:40:03',1,NULL),(176,1,1,1,NULL,1574000.00,'2026-05-17 14:41:00','penyesuaian',NULL,'transfer','2026-05-17 00:42:02','2026-05-17 00:42:02',32,NULL),(177,1,13,1,NULL,28000.00,'2026-05-17 14:43:00','penyesuaian',NULL,'transfer','2026-05-17 00:43:33','2026-05-17 00:43:33',7,NULL),(178,1,13,1,NULL,136000.00,'2026-05-17 14:44:00','penyesuaian',NULL,'transfer','2026-05-17 00:44:21','2026-05-17 00:44:21',4,NULL),(179,1,3,1,NULL,926000.00,'2026-05-17 14:45:00','penyesuaian',NULL,'transfer','2026-05-17 00:46:06','2026-05-17 00:46:06',32,NULL),(180,1,6,1,NULL,3000.00,'2026-05-17 14:46:00','penyesuaian',NULL,'transfer','2026-05-17 00:47:16','2026-05-17 00:47:16',4,NULL),(181,1,6,1,NULL,5100.00,'2026-05-17 14:47:00','penyesuaian',NULL,'transfer','2026-05-17 00:48:12','2026-05-17 00:48:12',31,NULL),(182,1,13,1,12,120000.00,'2026-05-10 14:50:00','bensin',NULL,'expense','2026-05-17 00:50:55','2026-05-17 00:50:55',NULL,NULL),(183,1,13,1,3,30000.00,'2026-05-02 14:51:00','martabak tb',NULL,'expense','2026-05-17 00:51:32','2026-05-17 00:51:32',NULL,NULL),(184,1,13,1,3,15000.00,'2026-05-03 14:51:00','badminton',NULL,'expense','2026-05-17 00:52:10','2026-05-17 00:52:10',NULL,NULL),(185,1,13,1,7,26000.00,'2026-05-11 14:52:00','paketan pulsa',NULL,'expense','2026-05-17 00:52:42','2026-05-17 00:52:42',NULL,NULL),(187,1,13,1,3,58000.00,'2026-05-06 14:54:00','bakso',NULL,'expense','2026-05-17 00:54:27','2026-05-17 00:54:27',NULL,NULL),(188,1,13,1,3,58000.00,'2026-05-13 14:54:00','bakso',NULL,'expense','2026-05-17 00:54:45','2026-05-17 00:54:45',NULL,NULL),(189,1,13,1,2,84000.00,'2026-05-15 14:54:00','gemini',NULL,'expense','2026-05-17 00:55:14','2026-05-17 00:55:14',NULL,NULL),(190,1,13,1,2,19000.00,'2026-05-08 14:55:00','masa aktif 3',NULL,'expense','2026-05-17 00:55:54','2026-05-17 00:55:54',NULL,NULL),(191,1,22,1,2,105000.00,'2026-05-17 14:57:00','penyesuaian bca',NULL,'expense','2026-05-17 00:57:46','2026-05-17 00:59:48',NULL,NULL),(192,1,6,1,13,300000.00,'2026-05-17 14:58:00','cashback',NULL,'income','2026-05-17 00:58:59','2026-05-17 00:58:59',NULL,NULL),(193,1,13,1,7,14500.00,'2026-05-17 15:00:00','gojek mas arif',NULL,'expense','2026-05-17 01:01:14','2026-05-17 01:01:14',NULL,NULL),(195,1,13,1,2,1024000.00,'2026-05-17 15:04:00','PLN tambah daya',NULL,'expense','2026-05-17 01:05:17','2026-05-17 01:05:17',NULL,NULL),(196,1,13,1,3,40000.00,'2026-05-03 15:05:00','es jeruk',NULL,'expense','2026-05-17 01:06:00','2026-05-17 01:06:00',NULL,NULL),(197,1,1,1,NULL,3000.00,'2026-05-17 15:11:00','penyesuaian',NULL,'transfer','2026-05-17 01:11:35','2026-05-17 01:11:35',13,NULL),(198,1,3,1,NULL,1054000.00,'2026-05-17 15:12:00','penyesuaian',NULL,'transfer','2026-05-17 01:12:23','2026-05-17 01:12:23',13,NULL),(199,1,5,1,NULL,49000.00,'2026-05-17 15:12:00','penyesuaian',NULL,'transfer','2026-05-17 01:13:06','2026-05-17 01:13:06',13,NULL),(200,1,21,1,NULL,260000.00,'2026-05-17 15:13:00','penyesuaian',NULL,'transfer','2026-05-17 01:13:55','2026-05-17 01:13:55',13,NULL),(201,1,29,1,NULL,41000.00,'2026-05-17 15:14:00','penyesuaian',NULL,'transfer','2026-05-17 01:14:29','2026-05-17 01:14:29',13,NULL),(202,1,9,1,NULL,18000.00,'2026-05-17 15:14:00','penyesuaian',NULL,'transfer','2026-05-17 01:15:15','2026-05-17 01:15:15',13,NULL),(203,1,11,1,NULL,42000.00,'2026-05-17 15:15:00','penyesuaian',NULL,'transfer','2026-05-17 01:15:52','2026-05-17 01:15:52',13,NULL),(204,1,8,1,NULL,14100.00,'2026-05-17 15:16:00','penyesuaian',NULL,'transfer','2026-05-17 01:16:31','2026-05-17 01:16:31',13,NULL),(205,1,6,1,NULL,7400.00,'2026-05-17 15:16:00','penyesuaian',NULL,'transfer','2026-05-17 01:17:10','2026-05-17 01:17:10',13,NULL),(206,1,17,1,10,4000.00,'2026-05-07 15:18:00','parkir siola',NULL,'expense','2026-05-17 01:19:18','2026-05-17 01:19:18',NULL,NULL),(207,1,13,1,3,10000.00,'2026-05-17 21:26:00','Sempol otak otak',NULL,'expense','2026-05-17 07:26:54','2026-05-17 07:26:54',NULL,NULL),(208,1,13,1,3,10000.00,'2026-05-17 21:26:00','Es Jeruk',NULL,'expense','2026-05-17 07:27:08','2026-05-17 07:27:08',NULL,NULL),(209,1,1,1,3,48000.00,'2026-05-17 21:27:00','Martabak terangbulan',NULL,'expense','2026-05-17 07:27:28','2026-05-17 07:27:28',NULL,NULL),(210,1,13,1,13,40000.00,'2026-05-17 21:27:00','Dikasih ibu',NULL,'income','2026-05-17 07:27:52','2026-05-17 07:27:52',NULL,NULL),(211,1,6,1,NULL,1900000.00,'2026-05-19 10:15:00','Transfer',NULL,'transfer','2026-05-18 20:15:40','2026-05-18 20:15:40',1,NULL),(212,1,1,1,NULL,6000000.00,'2026-05-19 10:15:00','Transfer',NULL,'transfer','2026-05-18 20:16:19','2026-05-18 20:16:43',3,NULL),(213,1,3,1,NULL,6028500.00,'2026-05-19 10:17:00','Bayar CC',NULL,'transfer','2026-05-18 20:17:34','2026-05-18 20:17:34',28,NULL),(214,1,28,1,2,72500.00,'2026-05-17 00:00:00','BPJS Apr 2026',NULL,'expense','2026-05-18 20:21:43','2026-05-18 20:22:12',NULL,NULL),(215,1,28,1,2,58000.00,'2026-05-17 00:01:00','PDAM Apr 2026',NULL,'expense','2026-05-18 20:23:56','2026-05-18 20:23:56',NULL,NULL),(216,1,28,1,2,696000.00,'2026-05-17 00:02:00','PLN Apr 2026',NULL,'expense','2026-05-18 20:24:42','2026-05-18 20:24:55',NULL,NULL),(217,1,28,1,8,60500.00,'2026-05-17 00:03:00','Porta - Tokopedia Headset Jete',NULL,'expense','2026-05-18 20:25:54','2026-05-18 20:27:27',NULL,NULL),(218,1,28,1,3,51500.00,'2026-05-17 00:04:00','Shopee food - Gacoan',NULL,'expense','2026-05-18 20:28:36','2026-05-18 20:28:36',NULL,NULL),(219,1,28,1,21,460000.00,'2026-05-19 10:29:00','Laptop Bagus (Cicilan Payment)',NULL,'expense','2026-05-18 20:29:59','2026-05-18 20:30:12',NULL,2),(220,1,28,1,8,53000.00,'2026-05-17 00:06:00','Shopee - Box Container',NULL,'expense','2026-05-18 20:33:08','2026-05-18 20:33:08',NULL,NULL),(221,1,28,1,21,76000.00,'2026-05-19 10:36:00','Mikrotik E50UG (Cicilan Payment)',NULL,'expense','2026-05-18 20:36:48','2026-05-18 20:36:48',NULL,9),(222,1,28,1,21,468000.00,'2026-05-19 10:39:00','Vivo V70 FE (Cicilan Payment)',NULL,'expense','2026-05-18 20:39:41','2026-05-18 20:39:41',NULL,10),(223,1,28,1,21,120000.00,'2026-05-19 10:42:00','Beelink Mini S (Cicilan Payment)',NULL,'expense','2026-05-18 20:42:12','2026-05-18 20:42:12',NULL,12),(224,1,28,1,8,3915500.00,'2026-05-17 00:11:00','Porta - Asus ProArt',NULL,'expense','2026-05-18 20:43:18','2026-05-18 20:43:18',NULL,NULL),(225,1,1,1,3,3000.00,'2026-05-19 11:28:00','Lumpia',NULL,'expense','2026-05-18 21:28:34','2026-05-18 21:28:34',NULL,NULL),(226,1,2,1,5,3915500.00,'2026-05-19 16:47:00','Porta - Asus Pro Art',NULL,'income','2026-05-19 02:48:24','2026-05-19 02:48:24',NULL,NULL),(227,1,1,1,3,12000.00,'2026-05-18 11:16:00','mas boss',NULL,'expense','2026-05-20 00:43:57','2026-05-20 00:43:57',NULL,NULL),(228,1,1,1,3,11000.00,'2026-05-19 11:17:00','mas bos',NULL,'expense','2026-05-20 00:44:39','2026-05-20 00:44:39',NULL,NULL),(229,1,1,1,3,11000.00,'2026-05-20 11:17:00','mas bos',NULL,'expense','2026-05-20 00:45:07','2026-05-20 00:45:07',NULL,NULL),(230,1,13,1,NULL,40000.00,'2026-05-21 08:19:00','kasih rika',NULL,'transfer','2026-05-21 18:19:28','2026-05-21 18:19:28',21,NULL),(231,1,21,1,3,10000.00,'2026-05-21 08:19:00','kopi sejutajiwa',NULL,'expense','2026-05-21 18:19:57','2026-05-21 18:19:57',NULL,NULL),(232,1,31,1,3,7000.00,'2026-05-21 08:19:00','teh chacup',NULL,'expense','2026-05-21 18:20:15','2026-05-21 18:20:15',NULL,NULL),(233,1,21,1,7,22000.00,'2026-05-22 18:32:00','paracetamol siladex',NULL,'expense','2026-05-22 18:33:42','2026-05-22 18:33:42',NULL,NULL),(234,1,21,1,4,13000.00,'2026-05-22 08:33:00','BK norma',NULL,'income','2026-05-22 18:34:11','2026-05-22 18:34:11',NULL,NULL),(235,1,29,1,NULL,100000.00,'2026-05-22 08:34:00','tukar cash',NULL,'transfer','2026-05-22 18:34:40','2026-05-22 18:34:40',21,NULL),(236,1,29,1,3,58000.00,'2026-05-20 05:34:00','bakso',NULL,'expense','2026-05-22 18:35:33','2026-05-22 18:35:33',NULL,NULL),(237,1,13,1,10,2000.00,'2026-05-20 08:35:00','parkir',NULL,'expense','2026-05-22 18:35:51','2026-05-22 18:35:51',NULL,NULL),(238,1,29,1,NULL,60000.00,'2026-05-22 08:36:00','pindah saldo',NULL,'transfer','2026-05-22 18:36:38','2026-05-22 18:38:03',33,NULL),(239,1,21,1,12,20000.00,'2026-05-23 08:38:00','Bensin',NULL,'expense','2026-05-22 18:38:31','2026-05-22 18:38:31',NULL,NULL),(240,1,29,1,3,70000.00,'2026-05-23 08:38:00','otak otak cak andik',NULL,'expense','2026-05-22 18:38:46','2026-05-22 18:38:46',NULL,NULL),(241,1,33,1,3,55500.00,'2026-05-22 08:40:00','ayam giling',NULL,'expense','2026-05-22 18:41:09','2026-05-22 18:41:09',NULL,NULL),(242,1,21,1,4,11000.00,'2026-05-23 14:34:00','Otak arif',NULL,'income','2026-05-23 00:35:24','2026-05-23 00:35:24',NULL,NULL),(243,1,21,1,4,7000.00,'2026-05-23 14:35:00','Otak norma',NULL,'income','2026-05-23 00:35:58','2026-05-23 00:35:58',NULL,NULL),(244,1,21,1,4,6000.00,'2026-05-23 14:36:00','Otak icha',NULL,'income','2026-05-23 00:36:14','2026-05-23 00:36:14',NULL,NULL),(245,1,21,1,4,6000.00,'2026-05-23 14:36:00','Otak pipit',NULL,'income','2026-05-23 00:36:34','2026-05-23 00:36:34',NULL,NULL),(246,1,21,1,4,6000.00,'2026-05-23 14:36:00','Otak farah',NULL,'income','2026-05-23 00:36:52','2026-05-23 00:36:52',NULL,NULL),(247,1,21,1,4,5000.00,'2026-05-23 14:36:00','Otak brian',NULL,'income','2026-05-23 00:37:11','2026-05-23 00:37:11',NULL,NULL),(248,1,21,1,4,11000.00,'2026-05-23 14:37:00','Otak agung',NULL,'income','2026-05-23 00:37:36','2026-05-23 00:37:36',NULL,NULL),(249,1,8,1,3,11000.00,'2026-05-23 14:37:00','Ambil otak otak',NULL,'expense','2026-05-23 00:38:13','2026-05-23 00:38:13',NULL,NULL),(250,1,21,1,4,6000.00,'2026-05-23 14:39:00','Otak pudam',NULL,'income','2026-05-23 00:40:05','2026-05-23 00:40:05',NULL,NULL),(251,1,2,1,NULL,1500000.00,'2026-05-20 12:17:00','Tarik Tunai',NULL,'transfer','2026-05-23 22:18:47','2026-05-23 22:18:47',13,NULL),(252,1,13,1,7,90000.00,'2026-05-21 12:19:00','Selang',NULL,'expense','2026-05-23 22:20:03','2026-05-23 22:20:03',NULL,NULL),(253,1,13,1,7,40000.00,'2026-05-21 12:20:00','Kabel engkol',NULL,'expense','2026-05-23 22:20:48','2026-05-23 22:20:48',NULL,NULL),(254,1,13,1,7,26000.00,'2026-05-21 12:20:00','Kabel listrik',NULL,'expense','2026-05-23 22:21:04','2026-05-23 22:21:04',NULL,NULL),(255,1,13,1,3,10000.00,'2026-05-23 12:21:00','Pentol',NULL,'expense','2026-05-23 22:21:27','2026-05-23 22:21:27',NULL,NULL),(256,1,4,1,NULL,600000.00,'2026-05-24 12:32:00','Transfer',NULL,'transfer','2026-05-23 22:33:19','2026-05-23 22:33:19',6,NULL),(257,1,5,1,NULL,700000.00,'2026-05-24 12:33:00','Transfer',NULL,'transfer','2026-05-23 22:33:47','2026-05-23 22:33:47',2,NULL),(258,1,2,1,NULL,3264000.00,'2026-05-24 12:33:00','Bayar spaylater',NULL,'transfer','2026-05-23 22:34:42','2026-05-23 22:34:42',23,NULL),(259,1,23,1,21,2864000.00,'2026-05-24 12:57:00','X300 pro (Cicilan Payment)',NULL,'expense','2026-05-23 22:57:23','2026-05-23 22:57:23',NULL,6),(260,1,23,1,21,43500.00,'2026-05-24 12:57:00','Brownies (Cicilan Payment)',NULL,'expense','2026-05-23 22:57:31','2026-05-23 22:57:31',NULL,7),(261,1,23,1,21,20500.00,'2026-05-24 12:57:00','Cheesecake (Cicilan Payment)',NULL,'expense','2026-05-23 22:57:36','2026-05-23 22:57:36',NULL,8),(262,1,23,1,14,151000.00,'2026-05-24 12:59:00','Paket data vina',NULL,'expense','2026-05-23 23:00:31','2026-05-23 23:00:31',NULL,NULL),(263,1,23,1,14,146000.00,'2026-05-24 13:00:00','Paket data vina',NULL,'expense','2026-05-23 23:00:58','2026-05-23 23:03:42',NULL,NULL),(264,1,23,1,21,39000.00,'2026-05-24 13:03:00','Bumbu dimsum (Cicilan Payment)',NULL,'expense','2026-05-23 23:03:24','2026-05-23 23:03:24',NULL,13),(265,1,5,1,NULL,1500000.00,'2026-05-24 13:03:00','Transfer',NULL,'transfer','2026-05-23 23:05:04','2026-05-23 23:05:04',3,NULL),(266,1,1,1,11,400000.00,'2026-05-24 13:05:00','Transfer',NULL,'transfer','2026-05-23 23:05:47','2026-05-23 23:05:47',3,NULL),(267,1,3,1,NULL,1864000.00,'2026-05-24 13:06:00','Bayar topedcard rika',NULL,'transfer','2026-05-23 23:06:47','2026-05-23 23:06:47',26,NULL),(268,1,26,1,9,37000.00,'2026-05-24 13:08:00','Kemeja rika',NULL,'expense','2026-05-23 23:08:44','2026-05-23 23:08:44',NULL,NULL),(269,1,26,1,2,267000.00,'2026-05-24 13:08:00','Wifi',NULL,'expense','2026-05-23 23:09:34','2026-05-23 23:09:34',NULL,NULL),(270,1,26,1,2,440000.00,'2026-05-24 13:09:00','Listrik',NULL,'expense','2026-05-23 23:10:16','2026-05-23 23:10:16',NULL,NULL),(271,1,26,1,14,290000.00,'2026-05-24 13:10:00','Wifi vina',NULL,'expense','2026-05-23 23:11:22','2026-05-23 23:11:22',NULL,NULL),(272,1,26,1,9,43000.00,'2026-05-24 13:11:00','Cd helmy',NULL,'expense','2026-05-23 23:12:36','2026-05-23 23:12:36',NULL,NULL),(273,1,26,1,14,203000.00,'2026-05-24 13:12:00','Token vina',NULL,'expense','2026-05-23 23:13:37','2026-05-23 23:13:37',NULL,NULL),(274,1,26,1,9,137000.00,'2026-05-24 13:14:00','Kaos',NULL,'expense','2026-05-23 23:15:04','2026-05-23 23:15:04',NULL,NULL),(275,1,26,1,9,37000.00,'2026-05-24 13:15:00','Shampoo',NULL,'expense','2026-05-23 23:15:53','2026-05-23 23:15:53',NULL,NULL),(276,1,26,1,9,108000.00,'2026-05-24 13:15:00','Box container ayah',NULL,'expense','2026-05-23 23:16:34','2026-05-23 23:16:34',NULL,NULL),(277,1,26,1,3,72000.00,'2026-05-24 13:17:00','Momoyo 3x',NULL,'expense','2026-05-23 23:18:00','2026-05-23 23:18:00',NULL,NULL),(278,1,26,1,9,111000.00,'2026-05-24 13:18:00','Cream mama',NULL,'expense','2026-05-23 23:18:34','2026-05-23 23:18:34',NULL,NULL),(279,1,26,1,14,100000.00,'2026-05-24 13:18:00','Pulsa vina',NULL,'expense','2026-05-23 23:19:13','2026-05-23 23:19:13',NULL,NULL),(280,1,26,1,9,19000.00,'2026-05-24 13:19:00','Case hp',NULL,'expense','2026-05-23 23:19:44','2026-05-23 23:20:22',NULL,NULL),(281,1,28,1,16,2500.00,'2026-05-24 13:23:00','Unknown',NULL,'income','2026-05-23 23:24:50','2026-05-23 23:24:50',NULL,NULL),(282,1,13,1,13,40000.00,'2026-05-24 22:15:00','Dikasih ibu helmy',NULL,'income','2026-05-24 08:16:08','2026-05-24 08:16:08',NULL,NULL),(283,1,4,1,3,58000.00,'2026-05-24 22:16:00','Penyetan',NULL,'expense','2026-05-24 08:16:23','2026-05-24 08:16:23',NULL,NULL),(284,1,2,1,9,69000.00,'2026-05-24 22:16:00','Bayar tiktok paylater',NULL,'transfer','2026-05-24 08:16:57','2026-05-24 08:16:57',30,NULL),(285,1,30,1,9,69000.00,'2026-05-24 22:17:00','Parfum',NULL,'expense','2026-05-24 08:17:21','2026-05-24 08:17:21',NULL,NULL),(286,1,21,1,1,3940000.00,'2026-05-25 08:45:00','gaji mei rika',NULL,'income','2026-05-25 18:46:35','2026-05-25 18:46:35',NULL,NULL),(287,1,1,1,3,12000.00,'2026-05-25 08:50:00','mas bos',NULL,'expense','2026-05-25 18:50:56','2026-05-25 18:50:56',NULL,NULL),(288,1,5,1,3,12000.00,'2026-05-26 08:24:00','chacup',NULL,'expense','2026-05-28 18:24:47','2026-05-28 18:24:59',NULL,NULL),(289,1,5,1,3,58000.00,'2026-05-26 08:25:00','bakso',NULL,'expense','2026-05-28 18:25:27','2026-06-23 23:31:20',NULL,NULL),(290,1,13,1,10,2000.00,'2026-05-26 08:25:00','parkir',NULL,'expense','2026-05-28 18:25:44','2026-05-28 18:25:44',NULL,NULL),(291,1,13,1,3,25000.00,'2026-05-27 08:25:00','martabak',NULL,'expense','2026-05-28 18:26:13','2026-05-28 18:26:13',NULL,NULL),(292,1,13,1,3,11000.00,'2026-05-27 08:26:00','degan',NULL,'expense','2026-05-28 18:26:49','2026-05-28 18:26:49',NULL,NULL),(293,1,5,1,3,12000.00,'2026-05-28 08:26:00','chacup',NULL,'expense','2026-05-28 18:27:17','2026-05-28 18:27:17',NULL,NULL),(294,1,21,1,3,24000.00,'2026-05-30 16:35:00','Degan',NULL,'expense','2026-05-31 02:36:11','2026-05-31 02:36:11',NULL,NULL),(295,1,13,1,3,20000.00,'2026-05-30 16:36:00','Punten',NULL,'expense','2026-05-31 02:36:49','2026-05-31 02:36:49',NULL,NULL),(296,1,1,1,3,19000.00,'2026-05-31 21:47:00','Es Teh',NULL,'expense','2026-05-31 16:48:02','2026-05-31 16:48:02',NULL,NULL),(297,1,13,1,3,20000.00,'2026-05-31 21:40:00','Terang Bulan',NULL,'expense','2026-05-31 16:48:36','2026-05-31 16:48:36',NULL,NULL),(298,1,13,1,10,2000.00,'2026-05-31 20:48:00','Parkir Nikah Dani',NULL,'expense','2026-05-31 16:49:06','2026-05-31 16:49:06',NULL,NULL),(299,1,13,1,7,200000.00,'2026-05-31 06:49:00','Bowo Dani',NULL,'expense','2026-05-31 16:49:32','2026-05-31 16:49:32',NULL,NULL),(300,1,21,1,3,11000.00,'2026-05-30 17:58:00','Batagor',NULL,'expense','2026-06-01 03:58:38','2026-06-01 04:02:36',NULL,NULL),(304,1,21,1,3,15000.00,'2026-05-30 18:02:00','Kopi',NULL,'expense','2026-06-01 04:02:57','2026-06-01 04:02:57',NULL,NULL),(305,1,21,1,3,12000.00,'2026-05-29 18:03:00','Chacup',NULL,'expense','2026-06-01 04:03:35','2026-06-01 17:25:06',NULL,NULL),(306,1,29,1,3,13000.00,'2026-05-30 18:03:00','Nasgorin',NULL,'expense','2026-06-01 04:04:10','2026-06-01 04:04:10',NULL,NULL),(307,1,6,1,3,52000.00,'2026-06-01 18:04:00','Hisana',NULL,'expense','2026-06-01 04:04:50','2026-06-01 04:04:50',NULL,NULL),(308,1,21,1,NULL,2900000.00,'2026-06-01 18:08:00','Setor',NULL,'transfer','2026-06-01 04:08:33','2026-06-01 04:08:33',2,NULL),(309,1,13,1,NULL,600000.00,'2026-06-01 18:08:00','Setor',NULL,'transfer','2026-06-01 04:09:00','2026-06-01 04:09:00',2,NULL),(310,1,13,1,12,30000.00,'2026-05-29 18:15:00','Bensin',NULL,'expense','2026-06-01 04:15:51','2026-06-01 04:15:51',NULL,NULL),(311,1,5,1,3,13000.00,'2026-06-02 14:13:00','Es Mas boss',NULL,'expense','2026-06-02 00:14:12','2026-06-02 00:14:12',NULL,NULL),(312,1,13,1,3,10000.00,'2026-06-02 14:14:00','Pentol Urat',NULL,'expense','2026-06-02 00:14:26','2026-06-02 00:14:26',NULL,NULL),(313,1,2,1,1,5000000.00,'2026-05-30 14:14:00','Gaji Porta',NULL,'income','2026-06-02 00:14:57','2026-06-02 00:14:57',NULL,NULL),(314,1,2,1,17,10000.00,'2026-06-02 14:15:00','Admin BCA',NULL,'expense','2026-06-02 00:16:22','2026-06-02 00:16:22',NULL,NULL),(315,1,2,1,4,925000.00,'2026-05-27 14:29:00','Tf dari vina',NULL,'income','2026-06-02 00:29:43','2026-06-02 00:29:43',NULL,NULL),(316,1,8,1,7,20000.00,'2026-05-28 14:30:00','Gopay Plus',NULL,'expense','2026-06-02 00:31:12','2026-06-02 00:31:12',NULL,NULL),(317,1,4,1,17,6000.00,'2026-06-02 14:31:00','Admin Mandiri',NULL,'expense','2026-06-02 00:32:00','2026-06-02 00:32:00',NULL,NULL),(318,1,1,1,7,301000.00,'2026-05-30 14:35:00','Unknown',NULL,'expense','2026-06-02 00:36:02','2026-06-02 00:36:38',NULL,NULL),(319,1,7,1,13,16000.00,'2026-05-30 14:36:00','Bunga',NULL,'income','2026-06-02 00:36:31','2026-06-02 00:36:31',NULL,NULL),(320,1,5,1,16,44000.00,'2026-05-31 14:37:00','Unknown',NULL,'income','2026-06-02 00:37:39','2026-06-02 00:37:39',NULL,NULL),(321,1,6,1,16,253000.00,'2026-05-31 14:37:00','Unknown',NULL,'income','2026-06-02 00:38:13','2026-06-02 00:38:13',NULL,NULL),(322,1,13,1,16,28000.00,'2026-05-31 14:38:00','Unknown',NULL,'income','2026-06-02 00:38:49','2026-06-02 00:38:49',NULL,NULL),(323,1,2,1,NULL,9000000.00,'2026-06-03 06:53:00','Transfer',NULL,'transfer','2026-06-02 16:54:09','2026-06-02 16:54:09',1,NULL),(324,1,1,1,NULL,5000000.00,'2026-06-03 06:54:00','Transfer',NULL,'transfer','2026-06-02 16:54:41','2026-06-02 16:54:41',5,NULL),(325,1,13,1,3,20000.00,'2026-06-03 06:54:00','Galon',NULL,'expense','2026-06-02 16:55:00','2026-06-02 16:55:00',NULL,NULL),(326,1,5,1,3,11000.00,'2026-06-03 16:35:00','Mas boss',NULL,'expense','2026-06-03 02:35:35','2026-06-03 02:35:35',NULL,NULL),(327,1,5,1,3,61000.00,'2026-06-03 18:51:00','Gacoan',NULL,'expense','2026-06-03 19:51:57','2026-06-03 19:51:57',NULL,NULL),(328,1,5,1,3,12000.00,'2026-06-04 13:06:00','Mas Boss',NULL,'expense','2026-06-03 23:06:33','2026-06-03 23:06:33',NULL,NULL),(329,1,13,1,12,25000.00,'2026-06-04 13:06:00','Bensin Beat',NULL,'expense','2026-06-03 23:06:52','2026-06-03 23:06:52',NULL,NULL),(330,1,29,1,3,7000.00,'2026-06-05 16:31:00','Es teh',NULL,'expense','2026-06-06 02:31:49','2026-06-06 02:32:55',NULL,NULL),(331,1,29,1,3,40000.00,'2026-06-06 16:32:00','Burger fried skin',NULL,'expense','2026-06-06 02:32:33','2026-06-06 02:32:51',NULL,NULL),(332,1,29,1,4,33000.00,'2026-06-06 16:33:00','Uang mba nor',NULL,'transfer','2026-06-06 02:33:41','2026-06-11 01:48:29',21,NULL),(333,1,29,1,13,7720.00,'2026-05-28 16:35:00','Interest  saving krom',NULL,'income','2026-06-06 02:36:57','2026-06-06 02:37:11',NULL,NULL),(334,1,13,1,9,18000.00,'2026-06-11 08:17:00','Permen',NULL,'expense','2026-06-10 18:18:08','2026-06-10 18:18:08',NULL,NULL),(335,1,13,1,NULL,7000.00,'2026-06-11 08:18:00','Transfer',NULL,'transfer','2026-06-10 18:18:30','2026-06-10 18:18:30',6,NULL),(336,1,13,1,10,2000.00,'2026-06-10 18:19:00','Parkir Bakso',NULL,'expense','2026-06-10 18:19:55','2026-06-10 18:19:55',NULL,NULL),(337,1,32,1,3,58000.00,'2026-06-10 17:35:00','Bakso',NULL,'expense','2026-06-10 18:35:32','2026-06-10 18:35:32',NULL,NULL),(338,1,5,1,3,13000.00,'2026-06-10 08:35:00','Mas boss',NULL,'expense','2026-06-10 18:35:55','2026-06-10 18:35:55',NULL,NULL),(339,1,5,1,13,300000.00,'2026-06-11 08:36:00','Referral Bonus',NULL,'income','2026-06-10 18:37:11','2026-06-10 18:37:11',NULL,NULL),(340,1,32,1,13,150000.00,'2026-06-11 08:37:00','Referral Bonus',NULL,'income','2026-06-10 18:37:39','2026-06-10 18:37:39',NULL,NULL),(341,1,21,1,15,1000000.00,'2026-06-07 15:38:00','kasih mama',NULL,'expense','2026-06-11 01:39:13','2026-06-11 01:39:13',NULL,NULL),(342,1,13,1,3,10000.00,'2026-06-07 15:39:00','pentol',NULL,'expense','2026-06-11 01:40:26','2026-06-11 01:40:26',NULL,NULL),(343,1,13,1,3,10000.00,'2026-06-07 15:40:00','sempol',NULL,'expense','2026-06-11 01:40:44','2026-06-11 01:40:44',NULL,NULL),(344,1,13,1,3,23000.00,'2026-06-07 15:40:00','terangbulan',NULL,'expense','2026-06-11 01:41:10','2026-06-11 01:41:10',NULL,NULL),(345,1,2,1,18,160000.00,'2026-06-07 15:41:00','dp opetrip sarangan',NULL,'expense','2026-06-11 01:42:06','2026-06-11 01:42:06',NULL,NULL),(346,1,1,1,3,12000.00,'2026-06-08 15:43:00','mas boss',NULL,'expense','2026-06-11 01:43:50','2026-06-11 01:43:50',NULL,NULL),(347,1,1,1,3,12000.00,'2026-06-09 15:43:00','mas boss',NULL,'expense','2026-06-11 01:44:16','2026-06-11 01:44:16',NULL,NULL),(348,1,2,1,18,190000.00,'2026-06-09 15:44:00','pelunasan opentrip sarangan',NULL,'expense','2026-06-11 01:44:44','2026-06-11 01:44:44',NULL,NULL),(349,1,29,1,13,150000.00,'2026-06-11 15:44:00','referral bonus',NULL,'income','2026-06-11 01:45:14','2026-06-11 01:45:14',NULL,NULL),(350,1,32,1,3,13000.00,'2026-06-11 15:57:00','Mas boss',NULL,'expense','2026-06-11 01:57:55','2026-06-11 01:57:55',NULL,NULL),(351,1,13,1,3,50000.00,'2026-06-08 20:57:00','Sosis',NULL,'expense','2026-06-11 06:57:49','2026-06-11 06:57:49',NULL,NULL),(352,1,13,1,15,17000.00,'2026-06-10 20:57:00','Siladex',NULL,'expense','2026-06-11 06:58:22','2026-06-11 06:58:22',NULL,NULL),(353,1,13,1,3,15000.00,'2026-06-11 20:58:00','Pentol',NULL,'expense','2026-06-11 06:58:46','2026-06-11 06:58:46',NULL,NULL),(354,1,13,1,12,30000.00,'2026-06-11 20:58:00','Bensin',NULL,'expense','2026-06-11 06:59:13','2026-06-11 06:59:13',NULL,NULL),(355,1,2,1,NULL,110000.00,'2026-06-03 21:00:00','Ganti ongkir',NULL,'transfer','2026-06-11 07:01:11','2026-06-11 07:01:24',13,NULL),(356,1,13,1,12,100000.00,'2026-06-07 21:02:00','Bensin mobil',NULL,'expense','2026-06-11 07:02:42','2026-06-11 07:02:42',NULL,NULL),(357,1,29,1,3,55000.00,'2026-06-12 09:14:00','otak otak cak andik',NULL,'expense','2026-06-14 19:14:40','2026-06-24 01:34:11',NULL,NULL),(358,1,8,1,3,11000.00,'2026-06-13 09:14:00','gojek otak otak',NULL,'expense','2026-06-14 19:15:02','2026-06-14 19:15:02',NULL,NULL),(359,1,21,1,4,24000.00,'2026-06-13 09:18:00','otak lusi farah pipit',NULL,'income','2026-06-14 19:21:44','2026-06-14 19:21:44',NULL,NULL),(360,1,21,1,4,6000.00,'2026-06-13 09:21:00','otak angga',NULL,'income','2026-06-14 19:22:18','2026-06-14 19:22:18',NULL,NULL),(361,1,21,1,4,6000.00,'2026-06-13 09:22:00','otak icha',NULL,'income','2026-06-14 19:22:44','2026-06-14 19:22:44',NULL,NULL),(362,1,21,1,4,6000.00,'2026-06-13 09:22:00','otak nadya',NULL,'income','2026-06-14 19:23:15','2026-06-14 19:23:15',NULL,NULL),(363,1,21,1,4,6000.00,'2026-06-13 09:23:00','otak norma',NULL,'income','2026-06-14 19:23:58','2026-06-14 19:23:58',NULL,NULL),(364,1,21,1,4,12000.00,'2026-06-13 09:24:00','otak nofita nisa',NULL,'income','2026-06-14 19:24:26','2026-06-14 19:24:26',NULL,NULL),(365,1,5,1,18,40000.00,'2026-06-14 09:24:00','lawu pelangi slide',NULL,'expense','2026-06-14 19:25:28','2026-06-14 19:25:28',NULL,NULL),(366,1,21,1,3,15000.00,'2026-06-13 09:25:00','roti tawar',NULL,'expense','2026-06-14 19:34:33','2026-06-14 19:34:33',NULL,NULL),(367,1,21,1,18,150000.00,'2026-06-14 09:34:00','speed boat sarangan',NULL,'expense','2026-06-14 19:35:11','2026-06-14 19:35:11',NULL,NULL),(368,1,21,1,4,37500.00,'2026-06-14 09:35:00','boat singgih',NULL,'income','2026-06-14 19:35:38','2026-06-14 19:35:38',NULL,NULL),(369,1,21,1,4,37500.00,'2026-06-14 09:35:00','boat safiq',NULL,'income','2026-06-14 19:36:00','2026-06-14 19:36:00',NULL,NULL),(370,1,21,1,18,35000.00,'2026-06-14 09:36:00','sate es sarangan',NULL,'expense','2026-06-14 19:36:28','2026-06-14 19:36:28',NULL,NULL),(371,1,13,1,18,60000.00,'2026-06-14 09:36:00','foto',NULL,'expense','2026-06-14 19:36:57','2026-06-14 19:36:57',NULL,NULL),(372,1,21,1,18,5000.00,'2026-06-14 09:37:00','pentol madiun',NULL,'expense','2026-06-14 19:37:27','2026-06-14 19:37:27',NULL,NULL),(373,1,13,1,18,15000.00,'2026-06-14 09:37:00','pentol madiun',NULL,'expense','2026-06-14 19:37:46','2026-06-14 19:37:46',NULL,NULL),(374,1,21,1,18,30000.00,'2026-06-14 09:37:00','sempol es jeruk gorengan madiun',NULL,'expense','2026-06-14 19:38:31','2026-06-14 19:38:31',NULL,NULL),(375,1,5,1,18,28000.00,'2026-06-14 09:39:00','nasi goreng',NULL,'expense','2026-06-14 19:40:15','2026-06-14 19:40:15',NULL,NULL),(376,1,29,1,18,21000.00,'2026-06-14 09:40:00','teh kota',NULL,'expense','2026-06-14 19:40:33','2026-06-14 19:40:33',NULL,NULL),(377,1,13,1,10,6000.00,'2026-06-14 09:40:00','parkir rsal',NULL,'expense','2026-06-14 19:40:54','2026-06-14 19:40:54',NULL,NULL),(378,1,5,1,3,13000.00,'2026-06-17 13:05:00','Mas Boss',NULL,'expense','2026-06-16 23:05:17','2026-06-16 23:05:17',NULL,NULL),(379,1,5,1,3,15000.00,'2026-06-16 21:06:00','Es Jeruk',NULL,'expense','2026-06-16 23:06:19','2026-06-16 23:06:19',NULL,NULL),(380,1,13,1,12,28000.00,'2026-06-16 20:06:00','Bensin Beat',NULL,'expense','2026-06-16 23:06:50','2026-06-16 23:06:50',NULL,NULL),(381,1,28,1,2,72500.00,'2026-06-17 00:03:00','BPJS Helmy',NULL,'expense','2026-06-17 00:34:28','2026-06-17 00:34:28',NULL,NULL),(382,1,28,1,2,61000.00,'2026-06-17 00:03:00','PDAM Helmy',NULL,'expense','2026-06-17 00:36:13','2026-06-17 00:37:21',NULL,NULL),(383,1,28,1,2,119000.00,'2026-06-17 00:04:00','Paket Data AON',NULL,'expense','2026-06-17 00:38:25','2026-06-17 00:38:25',NULL,NULL),(384,1,28,1,3,25500.00,'2026-06-17 00:05:00','Ropang - Belikopi',NULL,'expense','2026-06-17 00:41:45','2026-06-17 00:41:45',NULL,NULL),(385,1,28,1,9,134000.00,'2026-06-17 00:06:00','Tokopedia - Bardi Smart Plug',NULL,'expense','2026-06-17 00:42:51','2026-06-17 00:42:51',NULL,NULL),(386,1,28,1,3,54500.00,'2026-06-17 00:08:00','Shopee Food - Gacoan',NULL,'expense','2026-06-17 00:48:30','2026-06-17 00:48:30',NULL,NULL),(387,1,28,1,21,58250.00,'2026-06-17 14:50:00','Xiaomi Air Purifier 4 Compact (Cicilan Payment)',NULL,'expense','2026-06-17 00:50:24','2026-06-17 00:50:24',NULL,17),(388,1,28,1,21,184000.00,'2026-06-17 14:50:00','MNC HiFi 100 Mbps (Cicilan Payment)',NULL,'expense','2026-06-17 00:50:29','2026-06-17 00:50:29',NULL,16),(389,1,28,1,21,67250.00,'2026-06-17 14:50:00','Jasa Pasang AC dkk (Cicilan Payment)',NULL,'expense','2026-06-17 00:50:34','2026-06-17 00:50:34',NULL,15),(390,1,28,1,21,393250.00,'2026-06-17 14:50:00','AC Gree 1 PK (Cicilan Payment)',NULL,'expense','2026-06-17 00:50:36','2026-06-17 00:50:36',NULL,14),(391,1,28,1,21,120000.00,'2026-06-17 14:50:00','Beelink Mini S (Cicilan Payment)',NULL,'expense','2026-06-17 00:50:43','2026-06-17 00:50:43',NULL,12),(392,1,28,1,21,468000.00,'2026-06-17 14:50:00','Vivo V70 FE (Cicilan Payment)',NULL,'expense','2026-06-17 00:50:49','2026-06-17 00:50:49',NULL,10),(393,1,28,1,21,76000.00,'2026-06-17 14:50:00','Mikrotik E50UG (Cicilan Payment)',NULL,'expense','2026-06-17 00:50:51','2026-06-17 00:50:51',NULL,9),(394,1,28,1,7,3750.00,'2026-06-17 14:51:00','Unknown',NULL,'expense','2026-06-17 00:52:06','2026-06-17 00:52:06',NULL,NULL),(395,1,22,1,9,245500.00,'2026-06-17 02:01:00','Shopee - Baju Polo + Helm honda',NULL,'expense','2026-06-17 00:55:49','2026-06-17 00:55:49',NULL,NULL),(396,1,22,1,21,63500.00,'2026-06-17 14:56:00','Sepatu Bagus (Cicilan Payment)',NULL,'expense','2026-06-17 00:56:16','2026-06-17 00:56:16',NULL,1),(397,1,22,1,2,712500.00,'2026-06-17 02:02:00','PLN Helmy',NULL,'expense','2026-06-17 00:56:45','2026-06-17 00:56:45',NULL,NULL),(398,1,22,1,9,44500.00,'2026-06-17 02:03:00','Shopee - Meccaderm',NULL,'expense','2026-06-17 01:31:08','2026-06-17 01:31:08',NULL,NULL),(399,1,22,1,9,38500.00,'2026-06-17 00:04:00','Shopee - Giv Sabun Cair',NULL,'expense','2026-06-17 01:31:42','2026-06-17 01:31:42',NULL,NULL),(400,1,22,1,9,151000.00,'2026-06-17 02:05:00','Shopee - Kipas Portable Vivan',NULL,'expense','2026-06-17 01:32:19','2026-06-17 01:32:19',NULL,NULL),(401,1,22,1,9,52500.00,'2026-06-17 00:07:00','Shopee - Listerine & Sariayu',NULL,'expense','2026-06-17 01:33:07','2026-06-17 01:33:07',NULL,NULL),(402,1,22,1,9,14000.00,'2026-06-17 00:09:00','Shopee - Tempered Glass Poco F6',NULL,'expense','2026-06-17 01:34:13','2026-06-17 01:34:13',NULL,NULL),(403,1,22,1,9,12000.00,'2026-06-17 02:09:00','Shopee - Windows License',NULL,'expense','2026-06-17 01:34:49','2026-06-17 01:34:49',NULL,NULL),(404,1,22,1,9,28500.00,'2026-06-17 02:10:00','Shopee - Hand Sanitizer 1 Liter',NULL,'expense','2026-06-17 01:35:35','2026-06-17 01:35:35',NULL,NULL),(405,1,22,1,9,22000.00,'2026-06-17 02:11:00','Shopee - License Windows',NULL,'expense','2026-06-17 01:36:10','2026-06-17 01:36:10',NULL,NULL),(406,1,10,1,9,42000.00,'2026-06-14 15:36:00','Google Gemini',NULL,'expense','2026-06-17 01:37:28','2026-06-17 01:37:28',NULL,NULL),(407,1,10,1,19,5452500.00,'2026-06-16 15:37:00','Jual X80 Pro',NULL,'income','2026-06-17 01:39:24','2026-06-17 01:39:24',NULL,NULL),(408,1,5,1,NULL,357000.00,'2026-06-15 15:44:00','Helmy - Porta',NULL,'transfer','2026-06-17 01:45:07','2026-06-17 01:45:07',2,NULL),(409,1,5,1,NULL,1000000.00,'2026-06-18 10:30:00','Transfer',NULL,'transfer','2026-06-17 20:30:59','2026-06-17 20:30:59',2,NULL),(410,1,2,1,NULL,1384500.00,'2026-06-18 10:31:00','Bayar BCA CC',NULL,'transfer','2026-06-17 20:31:29','2026-06-17 20:31:29',22,NULL),(411,1,26,1,14,296000.00,'2026-06-19 11:29:00','wifi vina',NULL,'expense','2026-06-18 21:30:51','2026-06-18 21:30:51',NULL,NULL),(412,1,26,1,2,267000.00,'2026-06-19 11:31:00','wifi rika',NULL,'expense','2026-06-18 21:31:23','2026-06-18 21:31:23',NULL,NULL),(413,1,26,1,2,446000.00,'2026-06-19 11:31:00','listrik rika',NULL,'expense','2026-06-18 21:31:43','2026-06-18 21:31:43',NULL,NULL),(414,1,26,1,14,26000.00,'2026-06-19 11:31:00','pulsa vina',NULL,'expense','2026-06-18 21:32:05','2026-06-18 21:32:05',NULL,NULL),(415,1,26,1,3,12000.00,'2026-06-19 11:32:00','momoyo',NULL,'expense','2026-06-18 21:32:26','2026-06-18 21:32:26',NULL,NULL),(416,1,26,1,3,56000.00,'2026-06-19 11:32:00','belikopi',NULL,'expense','2026-06-18 21:32:45','2026-06-18 21:32:45',NULL,NULL),(417,1,26,1,3,40000.00,'2026-06-19 11:32:00','belikopi',NULL,'expense','2026-06-18 21:33:02','2026-06-18 21:33:02',NULL,NULL),(418,1,26,1,3,16000.00,'2026-06-19 11:33:00','selada',NULL,'expense','2026-06-18 21:33:20','2026-06-18 21:33:20',NULL,NULL),(419,1,26,1,9,92000.00,'2026-06-19 11:33:00','celana chinos',NULL,'expense','2026-06-18 21:33:38','2026-06-18 21:33:38',NULL,NULL),(420,1,26,1,14,203000.00,'2026-06-19 11:33:00','token vina',NULL,'expense','2026-06-18 21:33:59','2026-06-18 21:33:59',NULL,NULL),(421,1,26,1,14,139000.00,'2026-06-19 11:34:00','paket data vina',NULL,'expense','2026-06-18 21:34:16','2026-06-18 21:34:16',NULL,NULL),(422,1,26,1,9,136500.00,'2026-06-19 11:34:00','kado dini',NULL,'expense','2026-06-18 21:34:35','2026-06-18 21:34:35',NULL,NULL),(423,1,26,1,9,140000.00,'2026-06-19 11:34:00','kado nofita',NULL,'expense','2026-06-18 21:34:56','2026-06-18 21:34:56',NULL,NULL),(424,1,26,1,4,10000.00,'2026-06-19 11:34:00','dana salah jam',NULL,'income','2026-06-18 21:35:25','2026-06-18 21:35:25',NULL,NULL),(425,1,26,1,21,20500.00,'2026-06-19 11:36:00','paket data vina (Cicilan Payment)',NULL,'expense','2026-06-18 21:36:53','2026-06-18 21:36:53',NULL,18),(426,1,26,1,14,100000.00,'2026-06-19 11:37:00','pulsa vina',NULL,'expense','2026-06-18 21:37:21','2026-06-18 21:37:21',NULL,NULL),(427,1,13,1,3,15000.00,'2026-06-20 10:36:00','Pentol Pak Bas',NULL,'expense','2026-06-20 20:37:03','2026-06-20 20:37:03',NULL,NULL),(428,1,5,1,3,20000.00,'2026-06-20 10:37:00','Es Jeruk',NULL,'expense','2026-06-20 20:37:30','2026-06-20 20:37:30',NULL,NULL),(429,1,13,1,12,20000.00,'2026-06-20 10:37:00','Pertalite Beat',NULL,'expense','2026-06-20 20:37:54','2026-06-20 20:37:54',NULL,NULL),(430,1,13,1,10,2000.00,'2026-06-19 10:38:00','Parkir Bakso',NULL,'expense','2026-06-20 20:39:06','2026-06-20 20:39:06',NULL,NULL),(431,1,5,1,3,46000.00,'2026-06-19 10:39:00','Bakso Sarjana',NULL,'expense','2026-06-20 20:40:07','2026-06-20 20:40:16',NULL,NULL),(432,1,5,1,3,16000.00,'2026-06-19 10:41:00','UC 1000 & Susu Full Cream',NULL,'expense','2026-06-20 20:42:05','2026-06-20 20:42:05',NULL,NULL),(433,1,5,1,3,14000.00,'2026-06-18 10:43:00','Mas Boss',NULL,'expense','2026-06-20 20:43:26','2026-06-20 20:43:26',NULL,NULL),(434,1,6,1,2,27000.00,'2026-06-20 11:19:00','PGN',NULL,'expense','2026-06-20 21:19:44','2026-06-20 21:19:44',NULL,NULL),(435,1,10,1,NULL,5426000.00,'2026-06-19 11:23:00','Transfer',NULL,'transfer','2026-06-20 21:23:24','2026-06-20 21:23:24',9,NULL),(436,1,9,1,NULL,3800000.00,'2026-06-19 11:23:00','Transfer',NULL,'transfer','2026-06-20 21:23:43','2026-06-20 21:23:43',3,NULL),(437,1,3,1,NULL,1837000.00,'2026-06-20 11:24:00','Bayar topedcard Helmy',NULL,'transfer','2026-06-20 21:24:32','2026-06-20 21:24:32',28,NULL),(438,1,3,1,NULL,1980000.00,'2026-06-20 11:24:00','Bayar toped rika',NULL,'transfer','2026-06-20 21:25:02','2026-06-20 21:25:02',26,NULL),(439,1,13,1,3,30000.00,'2026-06-21 08:30:00','es jeruk',NULL,'expense','2026-06-21 18:31:16','2026-06-21 18:31:16',NULL,NULL),(440,1,13,1,3,30000.00,'2026-06-21 08:31:00','terangbulan',NULL,'expense','2026-06-21 18:31:40','2026-06-21 18:31:40',NULL,NULL),(441,1,13,1,12,18000.00,'2026-06-21 08:31:00','bensin',NULL,'expense','2026-06-21 18:31:56','2026-06-21 18:31:56',NULL,NULL),(442,1,5,1,3,34000.00,'2026-06-21 08:31:00','es jeruk matcha',NULL,'expense','2026-06-21 18:32:13','2026-06-21 18:32:13',NULL,NULL),(443,1,13,1,12,200000.00,'2026-06-21 08:32:00','bensin brio',NULL,'expense','2026-06-21 18:32:30','2026-06-21 18:32:30',NULL,NULL),(446,1,29,1,3,16000.00,'2026-06-22 13:03:00','gado gado',NULL,'expense','2026-06-21 23:04:09','2026-06-21 23:04:09',NULL,NULL),(447,1,29,1,3,7000.00,'2026-06-22 13:04:00','es chacup',NULL,'expense','2026-06-21 23:04:52','2026-06-21 23:04:52',NULL,NULL),(448,1,2,1,5,8830000.00,'2026-06-22 16:09:00','Porta - DJI RS 5 Combo',NULL,'income','2026-06-22 02:10:22','2026-06-22 02:10:22',NULL,NULL),(449,1,2,1,8,8830000.00,'2026-06-23 16:10:00','Porta - DJI RS 5 Combo',NULL,'expense','2026-06-22 02:11:40','2026-06-23 23:08:42',8,NULL),(450,1,5,1,3,14000.00,'2026-06-24 13:08:00','Mas boss',NULL,'expense','2026-06-23 23:09:07','2026-06-23 23:09:07',NULL,NULL),(451,1,5,1,3,12000.00,'2026-06-23 13:09:00','Mas boss',NULL,'expense','2026-06-23 23:10:00','2026-06-23 23:10:00',NULL,NULL),(452,1,32,1,NULL,2587000.00,'2026-06-21 13:10:00','Transfer',NULL,'transfer','2026-06-23 23:10:56','2026-06-23 23:10:56',5,NULL),(453,1,32,1,13,8000.00,'2026-06-24 13:11:00','Bunga',NULL,'income','2026-06-23 23:11:30','2026-06-23 23:11:30',NULL,NULL),(454,1,13,1,9,3000.00,'2026-06-22 13:17:00','Le Minerale',NULL,'expense','2026-06-23 23:18:12','2026-06-23 23:18:12',NULL,NULL),(455,1,5,1,3,12000.00,'2026-06-15 13:26:00','Mas Boss',NULL,'expense','2026-06-23 23:26:58','2026-06-23 23:26:58',NULL,NULL),(456,1,5,1,3,12000.00,'2026-06-09 13:27:00','Mas Boss',NULL,'expense','2026-06-23 23:28:26','2026-06-23 23:28:26',NULL,NULL),(457,1,5,1,3,13000.00,'2026-06-08 13:28:00','Mas Boss',NULL,'expense','2026-06-23 23:28:47','2026-06-23 23:28:47',NULL,NULL),(458,1,5,1,3,15000.00,'2026-06-01 13:29:00','Teh Camilia',NULL,'expense','2026-06-23 23:30:10','2026-06-23 23:30:10',NULL,NULL),(459,1,3,1,17,6500.00,'2026-06-24 13:32:00','Admin Bri',NULL,'expense','2026-06-23 23:32:47','2026-06-23 23:32:47',NULL,NULL),(461,1,2,1,16,12000.00,'2026-06-24 13:37:00','unknown',NULL,'income','2026-06-23 23:37:33','2026-06-23 23:37:33',NULL,NULL),(462,1,1,1,13,33000.00,'2026-06-24 13:37:00','Bunga',NULL,'income','2026-06-23 23:38:04','2026-06-23 23:38:04',NULL,NULL),(463,1,13,1,7,92000.00,'2026-06-24 13:38:00','Unkown',NULL,'expense','2026-06-23 23:38:34','2026-06-23 23:38:34',NULL,NULL),(464,1,4,1,17,6000.00,'2026-06-24 13:38:00','Admin Mandiri',NULL,'expense','2026-06-23 23:39:02','2026-06-23 23:39:02',NULL,NULL),(465,1,5,1,13,24000.00,'2026-06-24 13:39:00','Bunga',NULL,'income','2026-06-23 23:39:39','2026-06-23 23:39:39',NULL,NULL),(466,1,6,1,7,7000.00,'2026-06-24 13:39:00','Unknown',NULL,'expense','2026-06-23 23:40:05','2026-06-23 23:40:05',NULL,NULL),(467,1,29,1,NULL,155000.00,'2026-06-18 15:26:00','tukar tf mbak norma',NULL,'transfer','2026-06-24 01:27:09','2026-06-24 01:27:20',21,NULL),(468,1,29,1,NULL,975000.00,'2026-06-24 15:28:00','tukar cash devin',NULL,'transfer','2026-06-24 01:28:55','2026-06-24 01:28:55',21,NULL),(470,1,21,1,NULL,50000.00,'2026-06-24 15:29:00','tukar cash arif',NULL,'transfer','2026-06-24 01:30:10','2026-06-24 01:30:10',2,NULL),(471,1,29,1,3,20000.00,'2026-06-14 15:31:00','air ice cream pocari',NULL,'expense','2026-06-24 01:32:18','2026-06-24 01:32:18',NULL,NULL),(472,1,29,1,3,14000.00,'2026-06-12 15:32:00','es chacup',NULL,'expense','2026-06-24 01:33:24','2026-06-24 01:33:24',NULL,NULL),(473,1,21,1,4,7000.00,'2026-06-12 15:33:00','chacup norma',NULL,'income','2026-06-24 01:33:47','2026-06-24 01:33:47',NULL,NULL),(474,1,29,1,13,133.00,'2026-06-24 15:47:00','bonus',NULL,'income','2026-06-24 01:48:06','2026-06-24 01:48:06',NULL,NULL),(475,1,13,1,3,24000.00,'2026-06-27 08:22:00','degan',NULL,'expense','2026-06-28 18:22:57','2026-06-28 18:22:57',NULL,NULL),(476,1,13,1,3,16000.00,'2026-06-27 08:23:00','pentol',NULL,'expense','2026-06-28 18:23:15','2026-06-28 18:23:15',NULL,NULL),(477,1,13,1,3,48000.00,'2026-06-28 08:23:00','sosis otak otak',NULL,'expense','2026-06-28 18:24:03','2026-06-28 18:24:03',NULL,NULL),(478,1,13,1,3,18000.00,'2026-06-28 08:24:00','es jeruk',NULL,'expense','2026-06-28 18:24:21','2026-06-28 18:24:21',NULL,NULL),(479,1,29,1,7,48000.00,'2026-06-24 13:29:00','perlengkapan ospek bagus',NULL,'expense','2026-06-28 23:30:21','2026-06-28 23:30:21',NULL,NULL),(480,1,29,1,NULL,98000.00,'2026-06-29 13:30:00','tukar cash ongkir',NULL,'transfer','2026-06-28 23:31:33','2026-06-28 23:31:33',21,NULL),(481,1,29,1,3,58000.00,'2026-06-24 13:34:00','Bakso',NULL,'expense','2026-06-28 23:34:22','2026-06-28 23:34:22',NULL,NULL),(482,1,29,1,13,7687.00,'2026-06-29 13:35:00','cashback krom',NULL,'income','2026-06-28 23:36:40','2026-06-28 23:36:40',NULL,NULL),(483,1,21,1,1,4300000.00,'2026-06-29 13:38:00','gaji',NULL,'income','2026-06-28 23:43:44','2026-06-28 23:43:44',NULL,NULL),(484,1,5,1,3,14000.00,'2026-06-29 13:57:00','Mas Boss',NULL,'expense','2026-06-28 23:57:59','2026-06-28 23:57:59',NULL,NULL),(485,1,2,1,1,5590000.00,'2026-06-29 13:58:00','Gaji Porta',NULL,'income','2026-06-28 23:58:54','2026-06-28 23:58:54',NULL,NULL),(486,1,13,1,6,15000.00,'2026-06-28 14:00:00','Tambal Ban Supra',NULL,'expense','2026-06-29 00:00:30','2026-06-29 00:00:30',NULL,NULL),(487,1,13,1,9,10000.00,'2026-06-28 14:00:00','Vitamin C',NULL,'expense','2026-06-29 00:01:19','2026-06-29 00:01:19',NULL,NULL),(488,1,5,1,3,10000.00,'2026-06-27 14:02:00','Punten',NULL,'expense','2026-06-29 00:02:25','2026-06-29 00:02:25',NULL,NULL),(489,1,5,1,3,14000.00,'2026-06-25 14:02:00','Mas Boss',NULL,'expense','2026-06-29 00:03:03','2026-06-29 00:03:03',NULL,NULL),(490,1,5,1,NULL,500000.00,'2026-06-25 14:03:00','Transfer',NULL,'transfer','2026-06-29 00:03:27','2026-06-29 00:03:27',7,NULL),(491,1,7,1,9,337500.00,'2026-06-25 14:04:00','MCD Rika',NULL,'expense','2026-06-29 00:05:27','2026-06-29 00:05:27',NULL,NULL),(492,1,23,1,21,2864000.00,'2026-06-29 14:59:00','X300 pro (Cicilan Payment)',NULL,'expense','2026-06-29 00:59:55','2026-06-29 00:59:55',NULL,6),(493,1,23,1,21,43500.00,'2026-06-29 15:00:00','Brownies (Cicilan Payment)',NULL,'expense','2026-06-29 01:00:37','2026-06-29 01:00:37',NULL,7),(494,1,23,1,21,20500.00,'2026-06-29 15:00:00','Cheesecake (Cicilan Payment)',NULL,'expense','2026-06-29 01:00:58','2026-06-29 01:00:58',NULL,8),(495,1,23,1,21,39000.00,'2026-06-29 15:01:00','Bumbu dimsum (Cicilan Payment)',NULL,'expense','2026-06-29 01:01:12','2026-06-29 01:01:12',NULL,13),(496,1,23,1,9,58000.00,'2026-06-29 15:01:00','flatshoes',NULL,'expense','2026-06-29 01:01:50','2026-06-29 01:01:50',NULL,NULL),(497,1,23,1,9,70000.00,'2026-06-29 15:01:00','tas',NULL,'expense','2026-06-29 01:02:07','2026-06-29 01:02:07',NULL,NULL),(498,1,23,1,9,38000.00,'2026-06-29 15:02:00','fanbo bedak mama',NULL,'expense','2026-06-29 01:02:37','2026-06-29 01:02:37',NULL,NULL),(499,1,23,1,21,27000.00,'2026-06-29 15:03:00','jaket olahraga (Cicilan Payment)',NULL,'expense','2026-06-29 01:03:40','2026-06-29 01:03:40',NULL,19),(500,1,2,1,NULL,3160000.00,'2026-06-29 15:04:00','bayar spaylater',NULL,'transfer','2026-06-29 01:04:35','2026-06-29 01:04:35',23,NULL),(504,1,5,1,20,100000.00,'2026-07-04 12:12:00','test',NULL,'expense','2026-07-04 05:13:00','2026-07-04 05:13:00',NULL,NULL),(505,1,2,1,20,90000.00,'2026-07-04 12:13:00','test',NULL,'income','2026-07-04 05:13:28','2026-07-04 05:28:40',NULL,NULL),(513,1,2,1,7,1000000.00,'2026-07-17 11:43:00','Test cc',NULL,'expense','2026-07-05 04:43:31','2026-07-05 04:43:31',NULL,NULL);
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Helmy Kurniawan','helmy@example.com',NULL,'$2y$12$N1F7NLvMfuLVkIiO6wQwj.RMPVQv3RAOrcVpTSTrJ2fTWG50Py3OW',NULL,'2026-04-01 18:50:52','2026-07-04 05:49:13'),(2,'Rika','rika@example.com',NULL,'$2y$12$obC.q36cbq1QrZrIady7yOrJ/xVELgxZZDKXxZ/pHcNMKFJ2D1Rw2',NULL,'2026-04-01 18:50:52','2026-04-01 18:50:52');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-15 22:54:37
