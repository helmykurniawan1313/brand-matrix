-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: it_inventory
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
-- Current Database: `it_inventory`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `it_inventory` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `it_inventory`;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,'portadesigner01@gmail.com',NULL,'2026-03-05 01:38:20','2026-03-05 01:38:20'),(2,'portadesigner07@gmail.com',NULL,'2026-03-11 19:43:40','2026-03-11 19:43:40'),(3,'asset@portabranding.com',NULL,'2026-03-11 20:44:06','2026-05-11 02:08:24');
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `device_id` bigint(20) unsigned NOT NULL,
  `employee_id` bigint(20) unsigned DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activity_logs_device_id_foreign` (`device_id`),
  KEY `activity_logs_employee_id_foreign` (`employee_id`),
  CONSTRAINT `activity_logs_device_id_foreign` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `activity_logs_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
INSERT INTO `activity_logs` VALUES (16,4,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-06 00:42:09'),(17,4,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-06 00:42:09','2026-03-06 00:42:09'),(18,3,NULL,'Component Attached','Installed Motherboard: MOBO-01.','2025-11-16 17:00:00','2026-03-06 00:42:09'),(19,5,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-06 00:42:22'),(20,5,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-06 00:42:22','2026-03-06 00:42:22'),(21,3,NULL,'Component Attached','Installed Processor: PROC-01.','2025-11-16 17:00:00','2026-03-06 00:42:22'),(22,6,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-06 00:42:36'),(23,6,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-06 00:42:36','2026-03-06 00:42:36'),(24,3,NULL,'Component Attached','Installed RAM: RAM-01.','2025-11-16 17:00:00','2026-03-06 00:42:36'),(25,7,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-06 00:42:49'),(26,7,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-06 00:42:49','2026-03-06 00:42:49'),(27,3,NULL,'Component Attached','Installed RAM: RAM-02.','2025-11-16 17:00:00','2026-03-06 00:42:49'),(28,8,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-06 00:47:44'),(29,8,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-06 00:47:44','2026-03-06 00:47:44'),(30,3,NULL,'Component Attached','Installed SSD: SSD-01.','2025-11-16 17:00:00','2026-03-06 00:47:44'),(31,9,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-06 00:48:00'),(32,9,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-06 00:48:00','2026-03-06 00:48:00'),(33,3,NULL,'Component Attached','Installed HDD: HDD-01.','2025-11-16 17:00:00','2026-03-06 00:48:00'),(34,10,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-06 00:48:10'),(35,10,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-06 00:48:10','2026-03-06 00:48:10'),(36,3,NULL,'Component Attached','Installed GPU: GPU-01.','2025-11-16 17:00:00','2026-03-06 00:48:10'),(37,11,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2026-03-10 17:00:00','2026-03-10 23:55:35'),(38,11,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-10 23:55:35','2026-03-10 23:55:35'),(39,3,NULL,'Component Attached','Installed Monitor: MON-14.','2026-03-10 17:00:00','2026-03-10 23:55:35'),(40,11,NULL,'Transfer','Asset assigned from Sonya to STOCK.','2026-03-10 23:56:08','2026-03-10 23:56:08'),(41,11,NULL,'Detach','Removed from Porta-PC-01 and returned to STOCK.','2025-11-16 17:00:00','2026-03-10 23:56:09'),(42,3,NULL,'Component Detached','Removed Monitor: MON-14.','2025-11-16 17:00:00','2026-03-10 23:56:09'),(43,11,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-03-10 23:56:17'),(44,11,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-10 23:56:17','2026-03-10 23:56:17'),(45,3,NULL,'Component Attached','Installed Monitor: MON-14.','2025-11-16 17:00:00','2026-03-10 23:56:17'),(46,14,NULL,'Attach','Installed into main device: Porta-LP-31.','2026-03-11 17:00:00','2026-03-11 20:41:15'),(47,16,NULL,'Component Attached','Installed Keyboard: Keyboard-01.','2026-03-11 17:00:00','2026-03-11 20:41:15'),(48,12,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2026-02-19 17:00:00','2026-03-26 20:35:20'),(49,12,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-03-26 20:35:20','2026-03-26 20:35:20'),(50,3,NULL,'Component Attached','Installed UPS: UPS-01.','2026-02-19 17:00:00','2026-03-26 20:35:20'),(51,8,NULL,'Health Log: 83%','Diagnostic recorded.','2026-03-26 17:00:00','2026-03-26 20:37:06'),(52,13,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-04-09 19:04:33'),(53,13,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-04-09 19:04:33','2026-04-09 19:04:33'),(54,3,NULL,'Component Attached','Installed Mouse: Mouse-01.','2025-11-16 17:00:00','2026-04-09 19:04:33'),(55,15,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-04-09 19:05:40'),(56,15,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-04-09 19:05:40','2026-04-09 19:05:40'),(57,3,NULL,'Component Attached','Installed OS: OS-01.','2025-11-16 17:00:00','2026-04-09 19:05:40'),(58,14,NULL,'Detach','Removed from Porta-LP-31 and returned to STOCK.','2026-04-09 17:00:00','2026-04-09 19:06:01'),(59,16,NULL,'Component Detached','Removed Keyboard: Keyboard-01.','2026-04-09 17:00:00','2026-04-09 19:06:01'),(60,14,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2025-11-16 17:00:00','2026-04-09 19:06:15'),(61,14,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-04-09 19:06:15','2026-04-09 19:06:15'),(62,3,NULL,'Component Attached','Installed Keyboard: Keyboard-01.','2025-11-16 17:00:00','2026-04-09 19:06:15'),(63,23,NULL,'Attach','Installed into main device: Porta-LP-01.','2026-05-10 17:00:00','2026-05-11 00:05:17'),(64,22,NULL,'Component Attached','Installed Motherboard: LP-MOBO-01.','2026-05-10 17:00:00','2026-05-11 00:05:17'),(65,24,NULL,'Attach','Installed into main device: Porta-LP-01.','2026-05-10 17:00:00','2026-05-11 00:05:23'),(66,22,NULL,'Component Attached','Installed Processor: LP-PROC-01.','2026-05-10 17:00:00','2026-05-11 00:05:23'),(67,25,NULL,'Attach','Installed into main device: Porta-LP-01.','2026-05-10 17:00:00','2026-05-11 00:05:27'),(68,22,NULL,'Component Attached','Installed RAM: LP-RAM-01.','2026-05-10 17:00:00','2026-05-11 00:05:27'),(69,26,NULL,'Attach','Installed into main device: Porta-LP-01.','2026-05-10 17:00:00','2026-05-11 00:05:32'),(70,22,NULL,'Component Attached','Installed SSD: SSD-17.','2026-05-10 17:00:00','2026-05-11 00:05:32'),(71,27,NULL,'Attach','Installed into main device: Porta-LP-01.','2026-05-10 17:00:00','2026-05-11 00:38:26'),(72,22,NULL,'Component Attached','Installed GPU: LP-GPU-01.','2026-05-10 17:00:00','2026-05-11 00:38:26'),(73,28,NULL,'Attach','Installed into main device: Porta-LP-01.','2026-05-10 17:00:00','2026-05-11 00:38:29'),(74,22,NULL,'Component Attached','Installed Battery: LP-Batt-01.','2026-05-10 17:00:00','2026-05-11 00:38:29'),(75,29,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2026-05-10 17:00:00','2026-05-11 00:44:18'),(76,29,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-05-11 00:44:18','2026-05-11 00:44:18'),(77,3,NULL,'Component Attached','Installed Power Supply: PSU-01.','2026-05-10 17:00:00','2026-05-11 00:44:18'),(78,30,NULL,'Transfer','Asset assigned from STOCK to Sonya.','2026-05-10 17:00:00','2026-05-11 00:44:24'),(79,30,NULL,'Attach','Installed into main device: Porta-PC-01.','2026-05-11 00:44:24','2026-05-11 00:44:24'),(80,3,NULL,'Component Attached','Installed UPS: UPS-01.','2026-05-10 17:00:00','2026-05-11 00:44:24'),(81,31,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:39:09'),(82,31,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:39:09','2026-05-11 02:39:09'),(83,17,NULL,'Component Attached','Installed GPU: PC-GPU-02.','2025-11-16 17:00:00','2026-05-11 02:39:09'),(84,32,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-12-10 17:00:00','2026-05-11 02:39:24'),(85,32,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:39:24','2026-05-11 02:39:24'),(86,17,NULL,'Component Attached','Installed HDD: HDD-02.','2025-12-10 17:00:00','2026-05-11 02:39:24'),(87,33,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-12-10 17:00:00','2026-05-11 02:39:35'),(88,33,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:39:35','2026-05-11 02:39:35'),(89,17,NULL,'Component Attached','Installed HDD: HDD-03.','2025-12-10 17:00:00','2026-05-11 02:39:35'),(90,34,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-12-16 17:00:00','2026-05-11 02:40:08'),(91,34,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:40:08','2026-05-11 02:40:08'),(92,17,NULL,'Component Attached','Installed Keyboard: Keyboard-02.','2025-12-16 17:00:00','2026-05-11 02:40:08'),(93,35,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:40:19'),(94,35,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:40:19','2026-05-11 02:40:19'),(95,17,NULL,'Component Attached','Installed Monitor: MON-13.','2025-11-16 17:00:00','2026-05-11 02:40:19'),(96,36,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:40:29'),(97,36,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:40:29','2026-05-11 02:40:29'),(98,17,NULL,'Component Attached','Installed Motherboard: PC-MOBO-02.','2025-11-16 17:00:00','2026-05-11 02:40:29'),(99,37,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:40:42'),(100,37,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:40:42','2026-05-11 02:40:42'),(101,17,NULL,'Component Attached','Installed Mouse: Mouse-02.','2025-11-16 17:00:00','2026-05-11 02:40:42'),(102,38,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:40:50'),(103,38,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:40:50','2026-05-11 02:40:50'),(104,17,NULL,'Component Attached','Installed Processor: PC-PROC-02.','2025-11-16 17:00:00','2026-05-11 02:40:50'),(105,39,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:41:01'),(106,39,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:41:01','2026-05-11 02:41:01'),(107,17,NULL,'Component Attached','Installed RAM: PC-RAM-03.','2025-11-16 17:00:00','2026-05-11 02:41:01'),(108,40,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:43:07'),(109,40,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:43:07','2026-05-11 02:43:07'),(110,17,NULL,'Component Attached','Installed RAM: PC-RAM-04.','2025-11-16 17:00:00','2026-05-11 02:43:07'),(111,41,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:43:15'),(112,41,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:43:15','2026-05-11 02:43:15'),(113,17,NULL,'Component Attached','Installed SSD: SSD-02.','2025-11-16 17:00:00','2026-05-11 02:43:15'),(114,42,NULL,'Transfer','Asset assigned from STOCK to Putra.','2025-11-16 17:00:00','2026-05-11 02:43:25'),(115,42,NULL,'Attach','Installed into main device: Porta-PC-02.','2026-05-11 02:43:25','2026-05-11 02:43:25'),(116,17,NULL,'Component Attached','Installed UPS: UPS-02.','2025-11-16 17:00:00','2026-05-11 02:43:25'),(117,49,NULL,'Health Log: 80%','Diagnostic recorded.','2025-12-29 17:00:00','2026-05-11 02:56:05'),(118,50,NULL,'Transfer','Asset assigned from STOCK to Zaldy.','2026-05-12 01:51:01','2026-05-12 01:51:01'),(121,53,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:30:34','2026-06-01 19:30:34'),(122,54,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:31:44','2026-06-01 19:31:44'),(123,55,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:32:36','2026-06-01 19:32:36'),(124,56,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:33:45','2026-06-01 19:33:45'),(125,57,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:37:47','2026-06-01 19:37:47'),(126,58,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:38:38','2026-06-01 19:38:38'),(127,59,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:39:13','2026-06-01 19:39:13'),(128,60,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:40:25','2026-06-01 19:40:25'),(129,61,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:45:16','2026-06-01 19:45:16'),(130,62,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:47:08','2026-06-01 19:47:08'),(131,63,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:47:48','2026-06-01 19:47:48'),(132,64,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 19:48:00','2026-06-01 19:48:00'),(133,65,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:00:42','2026-06-01 21:00:42'),(134,53,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:10:12','2026-06-01 21:10:12'),(135,50,NULL,'Component Added','Installed Motherboard: PC-MOBO-03.','2026-06-01 21:10:12','2026-06-01 21:10:12'),(136,50,NULL,'Hardware Upgrade','PC-MOBO-03 (Motherboard) was installed.','2026-11-16 17:00:00','2026-06-01 21:10:12'),(137,62,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:10:37','2026-06-01 21:10:37'),(138,50,NULL,'Component Added','Installed UPS: UPS-03.','2026-06-01 21:10:37','2026-06-01 21:10:37'),(139,50,NULL,'Hardware Upgrade','UPS-03 (UPS) was installed.','2025-11-16 17:00:00','2026-06-01 21:10:37'),(140,57,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:10:50','2026-06-01 21:10:50'),(141,50,NULL,'Component Added','Installed SSD: SSD-03.','2026-06-01 21:10:50','2026-06-01 21:10:50'),(142,50,NULL,'Hardware Upgrade','SSD-03 (SSD) was installed.','2025-11-16 17:00:00','2026-06-01 21:10:50'),(143,55,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:11:03','2026-06-01 21:11:03'),(144,50,NULL,'Component Added','Installed RAM: PC-RAM-05.','2026-06-01 21:11:03','2026-06-01 21:11:03'),(145,50,NULL,'Hardware Upgrade','PC-RAM-05 (RAM) was installed.','2025-11-16 17:00:00','2026-06-01 21:11:03'),(146,56,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:11:16','2026-06-01 21:11:16'),(147,50,NULL,'Component Added','Installed RAM: PC-RAM-06.','2026-06-01 21:11:16','2026-06-01 21:11:16'),(148,50,NULL,'Hardware Upgrade','PC-RAM-06 (RAM) was installed.','2025-11-16 17:00:00','2026-06-01 21:11:16'),(149,54,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:11:41','2026-06-01 21:11:41'),(150,50,NULL,'Component Added','Installed Processor: PC-PROC-03.','2026-06-01 21:11:41','2026-06-01 21:11:41'),(151,50,NULL,'Hardware Upgrade','PC-PROC-03 (Processor) was installed.','2025-11-16 17:00:00','2026-06-01 21:11:41'),(152,60,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:11:51','2026-06-01 21:11:51'),(153,50,NULL,'Component Added','Installed GPU: PC-GPU-03.','2026-06-01 21:11:51','2026-06-01 21:11:51'),(154,50,NULL,'Hardware Upgrade','PC-GPU-03 (GPU) was installed.','2025-11-16 17:00:00','2026-06-01 21:11:51'),(155,58,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:12:15','2026-06-01 21:12:15'),(156,50,NULL,'Component Added','Installed HDD: HDD-04.','2026-06-01 21:12:15','2026-06-01 21:12:15'),(157,50,NULL,'Hardware Upgrade','HDD-04 (HDD) was installed.','2025-11-16 17:00:00','2026-06-01 21:12:15'),(158,59,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:12:24','2026-06-01 21:12:24'),(159,50,NULL,'Component Added','Installed HDD: HDD-05.','2026-06-01 21:12:24','2026-06-01 21:12:24'),(160,50,NULL,'Hardware Upgrade','HDD-05 (HDD) was installed.','2025-11-16 17:00:00','2026-06-01 21:12:24'),(161,65,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:12:34','2026-06-01 21:12:34'),(162,50,NULL,'Component Added','Installed Keyboard: Keyboard-03.','2026-06-01 21:12:34','2026-06-01 21:12:34'),(163,50,NULL,'Hardware Upgrade','Keyboard-03 (Keyboard) was installed.','2025-11-16 17:00:00','2026-06-01 21:12:34'),(164,61,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:12:48','2026-06-01 21:12:48'),(165,50,NULL,'Component Added','Installed Monitor: MON-12.','2026-06-01 21:12:48','2026-06-01 21:12:48'),(166,50,NULL,'Hardware Upgrade','MON-12 (Monitor) was installed.','2025-11-16 17:00:00','2026-06-01 21:12:48'),(167,64,NULL,'Attachment','Installed inside Porta-PC-03.','2026-06-01 21:13:05','2026-06-01 21:13:05'),(168,50,NULL,'Component Added','Installed Power Supply: PSU-03.','2026-06-01 21:13:05','2026-06-01 21:13:05'),(169,50,NULL,'Hardware Upgrade','PSU-03 (Power Supply) was installed.','2025-11-16 17:00:00','2026-06-01 21:13:05'),(170,63,NULL,'Attachment','Installed inside Porta-PC-02.','2026-06-01 21:14:18','2026-06-01 21:14:18'),(171,17,NULL,'Component Added','Installed Power Supply: PSU-02.','2026-06-01 21:14:18','2026-06-01 21:14:18'),(172,17,NULL,'Hardware Upgrade','PSU-02 (Power Supply) was installed.','2025-11-16 17:00:00','2026-06-01 21:14:18'),(173,66,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:15:31','2026-06-01 21:15:31'),(174,46,NULL,'Attachment','Installed inside Porta-LP-02.','2026-06-01 21:16:17','2026-06-01 21:16:17'),(175,43,NULL,'Component Added','Installed RAM: LP-RAM-02.','2026-06-01 21:16:17','2026-06-01 21:16:17'),(176,43,NULL,'Hardware Upgrade','LP-RAM-02 (RAM) was installed.','2025-11-16 17:00:00','2026-06-01 21:16:17'),(177,48,NULL,'Attachment','Installed inside Porta-LP-02.','2026-06-01 21:16:29','2026-06-01 21:16:29'),(178,43,NULL,'Component Added','Installed Battery: LP-Batt-02.','2026-06-01 21:16:29','2026-06-01 21:16:29'),(179,43,NULL,'Hardware Upgrade','LP-Batt-02 (Battery) was installed.','2025-11-16 17:00:00','2026-06-01 21:16:29'),(180,44,NULL,'Attachment','Installed inside Porta-LP-02.','2026-06-01 21:16:38','2026-06-01 21:16:38'),(181,43,NULL,'Component Added','Installed Motherboard: LP-MOBO-02.','2026-06-01 21:16:38','2026-06-01 21:16:38'),(182,43,NULL,'Hardware Upgrade','LP-MOBO-02 (Motherboard) was installed.','2025-11-16 17:00:00','2026-06-01 21:16:38'),(183,45,NULL,'Attachment','Installed inside Porta-LP-02.','2026-06-01 21:16:45','2026-06-01 21:16:45'),(184,43,NULL,'Component Added','Installed Processor: LP-PROC-02.','2026-06-01 21:16:45','2026-06-01 21:16:45'),(185,43,NULL,'Hardware Upgrade','LP-PROC-02 (Processor) was installed.','2025-11-16 17:00:00','2026-06-01 21:16:45'),(186,67,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:19:46','2026-06-01 21:19:46'),(187,68,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:20:27','2026-06-01 21:20:27'),(188,69,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:21:11','2026-06-01 21:21:11'),(189,70,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:21:39','2026-06-01 21:21:39'),(190,71,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:22:38','2026-06-01 21:22:38'),(191,72,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:23:53','2026-06-01 21:23:53'),(192,73,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:27:17','2026-06-01 21:27:17'),(193,74,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:28:18','2026-06-01 21:28:18'),(194,75,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:40:02','2026-06-01 21:40:02'),(195,76,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:41:50','2026-06-01 21:41:50'),(196,77,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-01 21:42:36','2026-06-01 21:42:36'),(197,66,NULL,'Reassigned','Assigned to Vania','2026-06-01 23:28:49','2026-06-01 23:28:49'),(198,66,NULL,'Deployment','Asset assigned to Vania.','2026-06-01 23:28:49','2026-06-01 23:28:49'),(199,72,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:29:13','2026-06-01 23:29:13'),(200,66,NULL,'Component Added','Installed HDD: HDD-06.','2026-06-01 23:29:13','2026-06-01 23:29:13'),(201,66,NULL,'Hardware Upgrade','HDD-06 (HDD) was installed.','2025-11-16 17:00:00','2026-06-01 23:29:13'),(202,76,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:29:24','2026-06-01 23:29:24'),(203,66,NULL,'Component Added','Installed Keyboard: Keyboard-04.','2026-06-01 23:29:24','2026-06-01 23:29:24'),(204,66,NULL,'Hardware Upgrade','Keyboard-04 (Keyboard) was installed.','2025-11-16 17:00:00','2026-06-01 23:29:24'),(205,73,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:29:35','2026-06-01 23:29:35'),(206,66,NULL,'Component Added','Installed Monitor: MON-11.','2026-06-01 23:29:35','2026-06-01 23:29:35'),(207,66,NULL,'Hardware Upgrade','MON-11 (Monitor) was installed.','2025-11-16 17:00:00','2026-06-01 23:29:35'),(208,67,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:29:44','2026-06-01 23:29:44'),(209,66,NULL,'Component Added','Installed Motherboard: PC-MOBO-04.','2026-06-01 23:29:44','2026-06-01 23:29:44'),(210,66,NULL,'Hardware Upgrade','PC-MOBO-04 (Motherboard) was installed.','2025-11-16 17:00:00','2026-06-01 23:29:44'),(211,75,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:30:04','2026-06-01 23:30:04'),(212,66,NULL,'Component Added','Installed Power Supply: PSU-04.','2026-06-01 23:30:04','2026-06-01 23:30:04'),(213,66,NULL,'Hardware Upgrade','PSU-04 (Power Supply) was installed.','2025-11-16 17:00:00','2026-06-01 23:30:04'),(214,68,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:30:38','2026-06-01 23:30:38'),(215,66,NULL,'Component Added','Installed Processor: PC-PROC-04.','2026-06-01 23:30:38','2026-06-01 23:30:38'),(216,66,NULL,'Hardware Upgrade','PC-PROC-04 (Processor) was installed.','2025-11-16 17:00:00','2026-06-01 23:30:38'),(217,69,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:30:48','2026-06-01 23:30:48'),(218,66,NULL,'Component Added','Installed RAM: PC-RAM-07.','2026-06-01 23:30:48','2026-06-01 23:30:48'),(219,66,NULL,'Hardware Upgrade','PC-RAM-07 (RAM) was installed.','2025-11-16 17:00:00','2026-06-01 23:30:48'),(220,70,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:30:58','2026-06-01 23:30:58'),(221,66,NULL,'Component Added','Installed RAM: PC-RAM-08.','2026-06-01 23:30:58','2026-06-01 23:30:58'),(222,66,NULL,'Hardware Upgrade','PC-RAM-08 (RAM) was installed.','2025-11-16 17:00:00','2026-06-01 23:30:58'),(223,71,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:31:10','2026-06-01 23:31:10'),(224,66,NULL,'Component Added','Installed SSD: SSD-04.','2026-06-01 23:31:10','2026-06-01 23:31:10'),(225,66,NULL,'Hardware Upgrade','SSD-04 (SSD) was installed.','2025-11-16 17:00:00','2026-06-01 23:31:10'),(226,74,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:31:20','2026-06-01 23:31:20'),(227,66,NULL,'Component Added','Installed UPS: UPS-04.','2026-06-01 23:31:20','2026-06-01 23:31:20'),(228,66,NULL,'Hardware Upgrade','UPS-04 (UPS) was installed.','2025-11-16 17:00:00','2026-06-01 23:31:20'),(229,77,NULL,'Attachment','Installed inside Porta-PC-04.','2026-06-01 23:31:33','2026-06-01 23:31:33'),(230,66,NULL,'Component Added','Installed Mouse: MON-04.','2026-06-01 23:31:33','2026-06-01 23:31:33'),(231,66,NULL,'Hardware Upgrade','MON-04 (Mouse) was installed.','2025-11-16 17:00:00','2026-06-01 23:31:33'),(232,11,NULL,'Detach','Removed from Porta-PC-01 and returned to STOCK.','2026-06-01 23:40:15','2026-06-01 23:40:15'),(233,3,NULL,'Component Detached','Removed Monitor: MON-14.','2026-06-01 23:40:15','2026-06-01 23:40:15'),(234,3,NULL,'Hardware Removed','UPS-06 (UPS) was detached.','2026-06-01 17:00:00','2026-06-01 23:45:26'),(235,12,NULL,'Detach','Removed from Porta-PC-01 and returned to STOCK.','2026-06-01 23:45:26','2026-06-01 23:45:26'),(236,3,NULL,'Component Detached','Removed UPS: UPS-06.','2026-06-01 23:45:26','2026-06-01 23:45:26'),(237,11,NULL,'Attachment','Installed inside Porta-PC-01.','2026-06-01 23:56:26','2026-06-01 23:56:26'),(238,3,NULL,'Component Added','Installed Monitor: MON-04.','2026-06-01 23:56:26','2026-06-01 23:56:26'),(239,3,NULL,'Hardware Removed','UPS-01 (UPS) was detached.','2026-06-01 17:00:00','2026-06-02 00:02:10'),(240,30,NULL,'Detach','Removed from Porta-PC-01 and returned to STOCK.','2026-06-02 00:02:10','2026-06-02 00:02:10'),(241,3,NULL,'Component Detached','Removed UPS: UPS-01.','2026-06-02 00:02:10','2026-06-02 00:02:10'),(242,3,NULL,'Hardware Removed','PC-MOBO-01 (Motherboard) was detached.','2026-06-01 17:00:00','2026-06-02 00:47:23'),(243,4,NULL,'Detach','Removed from Porta-PC-01 and returned to STOCK.','2026-06-02 00:47:23','2026-06-02 00:47:23'),(244,3,NULL,'Component Detached','Removed Motherboard: PC-MOBO-01.','2026-06-02 00:47:23','2026-06-02 00:47:23'),(245,4,NULL,'Returned to Stock','Asset ownership removed.','2026-06-02 00:48:30','2026-06-02 00:48:30'),(246,4,NULL,'Attachment','Installed inside Porta-PC-01.','2026-06-02 00:48:30','2026-06-02 00:48:30'),(247,3,NULL,'Component Added','Installed Motherboard: PC-MOBO-01.','2026-06-02 00:48:30','2026-06-02 00:48:30'),(248,3,NULL,'Hardware Removed','PC-MOBO-01 (Motherboard) was detached.','2026-06-01 17:00:00','2026-06-02 00:48:45'),(249,4,NULL,'Detach','Removed from Porta-PC-01 and returned to STOCK.','2026-06-02 00:48:45','2026-06-02 00:48:45'),(250,3,NULL,'Component Detached','Removed Motherboard: PC-MOBO-01.','2026-06-02 00:48:45','2026-06-02 00:48:45'),(251,4,NULL,'Attachment','Installed inside Porta-PC-01.','2026-06-02 00:48:52','2026-06-02 00:48:52'),(252,3,NULL,'Component Added','Installed Motherboard: PC-MOBO-01.','2026-06-02 00:48:52','2026-06-02 00:48:52'),(253,3,NULL,'Hardware Upgrade','PC-MOBO-01 (Motherboard) was installed.','2026-06-01 17:00:00','2026-06-02 00:48:52'),(254,78,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:18:25','2026-06-03 02:18:25'),(255,79,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:19:30','2026-06-03 02:19:30'),(256,80,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:20:12','2026-06-03 02:20:12'),(257,81,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:21:14','2026-06-03 02:21:14'),(258,82,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:21:55','2026-06-03 02:21:55'),(259,83,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:22:41','2026-06-03 02:22:41'),(260,84,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:23:36','2026-06-03 02:23:36'),(261,85,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:24:24','2026-06-03 02:24:24'),(262,86,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:26:14','2026-06-03 02:26:14'),(263,87,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:27:53','2026-06-03 02:27:53'),(264,88,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:28:11','2026-06-03 02:28:11'),(265,89,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:28:43','2026-06-03 02:28:43'),(266,90,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-03 02:30:37','2026-06-03 02:30:37'),(267,85,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:31:23','2026-06-03 02:31:23'),(268,78,NULL,'Component Added','Installed GPU: PC-GPU-04.','2026-06-03 02:31:23','2026-06-03 02:31:23'),(269,78,NULL,'Hardware Upgrade','PC-GPU-04 (GPU) was installed.','2026-06-02 17:00:00','2026-06-03 02:31:23'),(270,84,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:31:40','2026-06-03 02:31:40'),(271,78,NULL,'Component Added','Installed HDD: HDD-07.','2026-06-03 02:31:40','2026-06-03 02:31:40'),(272,78,NULL,'Hardware Upgrade','HDD-07 (HDD) was installed.','2025-11-16 17:00:00','2026-06-03 02:31:40'),(273,89,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:31:52','2026-06-03 02:31:52'),(274,78,NULL,'Component Added','Installed Keyboard: Keyboard-05.','2026-06-03 02:31:52','2026-06-03 02:31:52'),(275,78,NULL,'Hardware Upgrade','Keyboard-05 (Keyboard) was installed.','2025-11-16 17:00:00','2026-06-03 02:31:52'),(276,86,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:32:04','2026-06-03 02:32:04'),(277,78,NULL,'Component Added','Installed Monitor: MON-10.','2026-06-03 02:32:04','2026-06-03 02:32:04'),(278,78,NULL,'Hardware Upgrade','MON-10 (Monitor) was installed.','2025-11-16 17:00:00','2026-06-03 02:32:04'),(279,79,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:32:17','2026-06-03 02:32:17'),(280,78,NULL,'Component Added','Installed Motherboard: PC-MOBO-05.','2026-06-03 02:32:17','2026-06-03 02:32:17'),(281,78,NULL,'Hardware Upgrade','PC-MOBO-05 (Motherboard) was installed.','2025-11-16 17:00:00','2026-06-03 02:32:17'),(282,90,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:32:36','2026-06-03 02:32:36'),(283,78,NULL,'Component Added','Installed Mouse: Mouse-05.','2026-06-03 02:32:36','2026-06-03 02:32:36'),(284,78,NULL,'Hardware Upgrade','Mouse-05 (Mouse) was installed.','2025-11-16 17:00:00','2026-06-03 02:32:36'),(285,88,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:32:53','2026-06-03 02:32:53'),(286,78,NULL,'Component Added','Installed Power Supply: PSU-05.','2026-06-03 02:32:53','2026-06-03 02:32:53'),(287,78,NULL,'Hardware Upgrade','PSU-05 (Power Supply) was installed.','2025-11-16 17:00:00','2026-06-03 02:32:53'),(288,80,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:33:05','2026-06-03 02:33:05'),(289,78,NULL,'Component Added','Installed Processor: PC-PROC-05.','2026-06-03 02:33:05','2026-06-03 02:33:05'),(290,78,NULL,'Hardware Upgrade','PC-PROC-05 (Processor) was installed.','2025-11-16 17:00:00','2026-06-03 02:33:05'),(291,81,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:33:16','2026-06-03 02:33:16'),(292,78,NULL,'Component Added','Installed RAM: PC-RAM-09.','2026-06-03 02:33:16','2026-06-03 02:33:16'),(293,78,NULL,'Hardware Upgrade','PC-RAM-09 (RAM) was installed.','2025-11-16 17:00:00','2026-06-03 02:33:16'),(294,82,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:33:24','2026-06-03 02:33:24'),(295,78,NULL,'Component Added','Installed RAM: PC-RAM-10.','2026-06-03 02:33:24','2026-06-03 02:33:24'),(296,78,NULL,'Hardware Upgrade','PC-RAM-10 (RAM) was installed.','2025-11-16 17:00:00','2026-06-03 02:33:24'),(297,83,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:33:39','2026-06-03 02:33:39'),(298,78,NULL,'Component Added','Installed SSD: SSD-05.','2026-06-03 02:33:39','2026-06-03 02:33:39'),(299,78,NULL,'Hardware Upgrade','SSD-05 (SSD) was installed.','2025-11-16 17:00:00','2026-06-03 02:33:39'),(300,87,NULL,'Attachment','Installed inside Porta-PC-05.','2026-06-03 02:33:49','2026-06-03 02:33:49'),(301,78,NULL,'Component Added','Installed UPS: UPS-05.','2026-06-03 02:33:49','2026-06-03 02:33:49'),(302,78,NULL,'Hardware Upgrade','UPS-05 (UPS) was installed.','2025-11-16 17:00:00','2026-06-03 02:33:49'),(303,91,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-04 19:20:19','2026-06-04 19:20:19'),(304,92,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-04 19:37:04','2026-06-04 19:37:04'),(305,93,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-04 19:38:28','2026-06-04 19:38:28'),(306,94,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-04 19:41:17','2026-06-04 19:41:17'),(307,95,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-04 19:55:21','2026-06-04 19:55:21'),(308,96,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-04 20:06:05','2026-06-04 20:06:05'),(309,97,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-04 20:13:29','2026-06-04 20:13:29'),(310,98,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-07 18:45:30','2026-06-07 18:45:30'),(311,99,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-07 18:46:57','2026-06-07 18:46:57'),(312,100,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-07 18:47:30','2026-06-07 18:47:30'),(313,96,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:48:46','2026-06-07 18:48:46'),(314,91,NULL,'Component Added','Installed HDD: HDD-08.','2026-06-07 18:48:46','2026-06-07 18:48:46'),(315,91,NULL,'Hardware Upgrade','HDD-08 (HDD) was installed.','2025-11-16 17:00:00','2026-06-07 18:48:46'),(316,99,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:48:57','2026-06-07 18:48:57'),(317,91,NULL,'Component Added','Installed Keyboard: Keyboard-06.','2026-06-07 18:48:57','2026-06-07 18:48:57'),(318,91,NULL,'Hardware Upgrade','Keyboard-06 (Keyboard) was installed.','2025-11-16 17:00:00','2026-06-07 18:48:57'),(319,97,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:49:09','2026-06-07 18:49:09'),(320,91,NULL,'Component Added','Installed Monitor: MON-07.','2026-06-07 18:49:09','2026-06-07 18:49:09'),(321,91,NULL,'Hardware Upgrade','MON-07 (Monitor) was installed.','2025-11-16 17:00:00','2026-06-07 18:49:09'),(322,92,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:49:26','2026-06-07 18:49:26'),(323,91,NULL,'Component Added','Installed Motherboard: PC-MOBO-06.','2026-06-07 18:49:26','2026-06-07 18:49:26'),(324,91,NULL,'Hardware Upgrade','PC-MOBO-06 (Motherboard) was installed.','2025-11-16 17:00:00','2026-06-07 18:49:26'),(325,100,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:55:11','2026-06-07 18:55:11'),(326,91,NULL,'Component Added','Installed Mouse: Mouse-06.','2026-06-07 18:55:11','2026-06-07 18:55:11'),(327,91,NULL,'Hardware Upgrade','Mouse-06 (Mouse) was installed.','2025-11-16 17:00:00','2026-06-07 18:55:11'),(328,98,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:55:21','2026-06-07 18:55:21'),(329,91,NULL,'Component Added','Installed Power Supply: PSU-06.','2026-06-07 18:55:21','2026-06-07 18:55:21'),(330,91,NULL,'Hardware Upgrade','PSU-06 (Power Supply) was installed.','2025-11-16 17:00:00','2026-06-07 18:55:21'),(331,93,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:55:37','2026-06-07 18:55:37'),(332,91,NULL,'Component Added','Installed Processor: PC-PROC-06.','2026-06-07 18:55:37','2026-06-07 18:55:37'),(333,91,NULL,'Hardware Upgrade','PC-PROC-06 (Processor) was installed.','2025-11-16 17:00:00','2026-06-07 18:55:37'),(334,94,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:55:46','2026-06-07 18:55:46'),(335,91,NULL,'Component Added','Installed RAM: PC-RAM-11.','2026-06-07 18:55:46','2026-06-07 18:55:46'),(336,91,NULL,'Hardware Upgrade','PC-RAM-11 (RAM) was installed.','2025-11-16 17:00:00','2026-06-07 18:55:46'),(337,95,NULL,'Attachment','Installed inside Porta-PC-06.','2026-06-07 18:55:55','2026-06-07 18:55:55'),(338,91,NULL,'Component Added','Installed SSD: SSD-06.','2026-06-07 18:55:55','2026-06-07 18:55:55'),(339,91,NULL,'Hardware Upgrade','SSD-06 (SSD) was installed.','2025-11-16 17:00:00','2026-06-07 18:55:55'),(340,91,NULL,'Reassigned','Assigned to Feby','2026-06-07 18:58:31','2026-06-07 18:58:31'),(341,91,NULL,'Deployment','Asset assigned to Feby.','2026-06-07 18:58:31','2026-06-07 18:58:31'),(342,101,NULL,'Asset Registered','Asset was added to the inventory.','2026-06-07 19:30:14','2026-06-07 19:30:14');
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
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
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-helmykurniawan1313@gmail.com|127.0.0.1','i:1;',1775792721),('laravel-cache-helmykurniawan1313@gmail.com|127.0.0.1:timer','i:1775792721;',1775792721);
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
  PRIMARY KEY (`key`)
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
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `departments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `departments_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'Designer','2026-03-05 01:38:45','2026-03-05 01:38:45'),(2,'IT','2026-05-12 00:19:31','2026-05-12 00:19:31');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `device_group` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `device_password` varchar(255) DEFAULT NULL,
  `manufacturer` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `size` varchar(255) DEFAULT NULL,
  `ram` varchar(255) DEFAULT NULL,
  `rom` varchar(255) DEFAULT NULL,
  `current_health` int(11) DEFAULT NULL,
  `employee_id` bigint(20) unsigned DEFAULT NULL,
  `parent_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `image1` varchar(255) DEFAULT NULL,
  `image2` varchar(255) DEFAULT NULL,
  `image3` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `devices_employee_id_foreign` (`employee_id`),
  KEY `devices_parent_id_foreign` (`parent_id`),
  CONSTRAINT `devices_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL,
  CONSTRAINT `devices_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `devices` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devices`
--

LOCK TABLES `devices` WRITE;
/*!40000 ALTER TABLE `devices` DISABLE KEYS */;
INSERT INTO `devices` VALUES (3,'Device','PC','Porta-PC-01','porta','-','Generic PC',NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,'2026-03-06 00:38:52','2026-06-07 19:19:15',NULL,NULL,NULL),(4,'Peripheral','Motherboard','PC-MOBO-01',NULL,'ASRock','A320M-HDV R4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,'2026-03-06 00:39:55','2026-06-02 00:48:52',NULL,NULL,NULL),(5,'Peripheral','Processor','PC-PROC-01',NULL,'AMD','Ryzen 5 2600',NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,3,'2026-03-06 00:40:24','2026-05-10 23:25:11',NULL,NULL,NULL),(6,'Peripheral','RAM','PC-RAM-01',NULL,'KLEVV',NULL,NULL,NULL,'DDR4','8 GB',NULL,NULL,NULL,2,3,'2026-03-06 00:41:14','2026-05-10 23:52:13',NULL,NULL,NULL),(7,'Peripheral','RAM','PC-RAM-02',NULL,'KLEVV',NULL,NULL,NULL,'DDR 4','8 GB',NULL,NULL,NULL,2,3,'2026-03-06 00:41:47','2026-05-10 23:52:20',NULL,NULL,NULL),(8,'Peripheral','SSD','SSD-01',NULL,'SK HYNIX','BC501 HFM256GDJT',NULL,NULL,'M.2 NVMe','256 GB',NULL,NULL,83,2,3,'2026-03-06 00:44:59','2026-03-26 20:37:06',NULL,NULL,NULL),(9,'Peripheral','HDD','HDD-01',NULL,'Toshiba','HDWD220',NULL,NULL,'Sata 3.5','2 TB',NULL,NULL,100,2,3,'2026-03-06 00:46:20','2026-03-06 00:48:00',NULL,NULL,NULL),(10,'Peripheral','GPU','PC-GPU-01',NULL,'Zotac','GTX 1050 Ti',NULL,NULL,NULL,'4 GB',NULL,NULL,NULL,2,3,'2026-03-06 00:47:13','2026-06-03 02:24:35',NULL,NULL,NULL),(11,'Peripheral','Monitor','MON-04',NULL,'Acer','EK240Y',NULL,NULL,NULL,'24 Inch',NULL,NULL,NULL,2,3,'2026-03-06 00:49:31','2026-06-01 23:56:26',NULL,NULL,NULL),(12,'Peripheral','UPS','UPS-06',NULL,'Acer','Altos City 120','2026-02-20',NULL,NULL,'1200 VA',NULL,NULL,NULL,2,NULL,'2026-03-11 19:06:00','2026-06-01 23:45:26',NULL,NULL,NULL),(13,'Peripheral','Mouse','Mouse-01',NULL,'Fantech','Crypto II',NULL,NULL,'Wired',NULL,NULL,NULL,NULL,2,3,'2026-03-11 19:06:52','2026-05-11 00:42:37',NULL,NULL,NULL),(14,'Peripheral','Keyboard','Keyboard-01',NULL,'Logitech','K120',NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,3,'2026-03-11 19:07:22','2026-04-09 19:06:15',NULL,NULL,NULL),(15,'Peripheral','OS','OS-01',NULL,'Microsoft','Windows 10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,3,'2026-03-11 19:07:53','2026-04-09 19:05:40',NULL,NULL,NULL),(16,'Device','Laptop','Porta-LP-31',NULL,'Asus','Vivobook Go E1404FA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-11 20:37:27','2026-03-11 20:37:27',NULL,NULL,NULL),(17,'Device','PC','Porta-PC-02',NULL,'-','Generic PC',NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,NULL,'2026-04-09 19:12:15','2026-04-09 19:12:15',NULL,NULL,NULL),(21,'Device','Phone','Porta-HP-01','0000','Apple','Iphone 7',NULL,NULL,NULL,NULL,'2 GB','128 GB',77,NULL,NULL,'2026-05-10 20:18:12','2026-05-10 21:09:23',NULL,NULL,NULL),(22,'Device','Laptop','Porta-LP-01','portabranding01','Lenovo','ThinkPad X260',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-05-10 23:14:54','2026-05-10 23:14:54',NULL,NULL,NULL),(23,'Peripheral','Motherboard','LP-MOBO-01',NULL,'Lenovo','20F5S2NG00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,22,'2026-05-10 23:26:52','2026-05-11 00:05:17',NULL,NULL,NULL),(24,'Peripheral','Processor','LP-PROC-01',NULL,'Intel','Core i5-6300U',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,22,'2026-05-10 23:51:44','2026-05-11 00:05:23',NULL,NULL,NULL),(25,'Peripheral','RAM','LP-RAM-01',NULL,'-','-',NULL,NULL,'DDR 4','8 GB',NULL,NULL,NULL,NULL,22,'2026-05-10 23:53:38','2026-05-11 00:05:27',NULL,NULL,NULL),(26,'Peripheral','SSD','SSD-17',NULL,'V-Gen',NULL,NULL,NULL,'Sata 2.5','256 GB',NULL,NULL,100,NULL,22,'2026-05-10 23:56:14','2026-05-11 00:05:32',NULL,NULL,NULL),(27,'Peripheral','GPU','LP-GPU-01',NULL,'Intel','UHD 520',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,22,'2026-05-11 00:15:33','2026-05-11 00:38:26',NULL,NULL,NULL),(28,'Peripheral','Battery','LP-Batt-01',NULL,'Lenovo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,5,NULL,22,'2026-05-11 00:37:47','2026-05-11 02:51:31',NULL,NULL,NULL),(29,'Peripheral','Power Supply','PSU-01',NULL,'Acer Altos','City 120',NULL,NULL,NULL,'1200 V',NULL,NULL,NULL,2,3,'2026-05-11 00:40:59','2026-06-03 00:37:30',NULL,NULL,NULL),(30,'Peripheral','UPS','UPS-01',NULL,'APC','Back Ups 650',NULL,NULL,NULL,'650 V',NULL,NULL,NULL,2,NULL,'2026-05-11 00:44:00','2026-06-02 00:02:10',NULL,NULL,NULL),(31,'Peripheral','GPU','PC-GPU-02',NULL,'Nvidia','GTX 1660',NULL,NULL,NULL,'6 GB',NULL,NULL,NULL,3,17,'2026-05-11 02:17:47','2026-05-11 02:39:09',NULL,NULL,NULL),(32,'Peripheral','HDD','HDD-02',NULL,'Toshiba','HDWD220',NULL,NULL,'Sata 3.5','2 TB',NULL,NULL,100,3,17,'2026-05-11 02:21:37','2026-05-11 02:39:24',NULL,NULL,NULL),(33,'Peripheral','HDD','HDD-03',NULL,'Toshiba','DT01ACA100',NULL,NULL,'Sata 3.5','1 TB',NULL,NULL,100,3,17,'2026-05-11 02:22:19','2026-05-11 02:39:35',NULL,NULL,NULL),(34,'Peripheral','Keyboard','Keyboard-02',NULL,'Logitech','K120',NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,17,'2026-05-11 02:23:05','2026-05-11 02:40:08',NULL,NULL,NULL),(35,'Peripheral','Monitor','MON-13',NULL,'LG','24MK430H',NULL,NULL,NULL,'24 Inch',NULL,NULL,NULL,3,17,'2026-05-11 02:25:05','2026-05-11 02:40:19',NULL,NULL,NULL),(36,'Peripheral','Motherboard','PC-MOBO-02',NULL,'Gigabyte','B550M Gaming',NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,17,'2026-05-11 02:25:39','2026-05-11 02:40:29',NULL,NULL,NULL),(37,'Peripheral','Mouse','Mouse-02',NULL,'Fantech','Crypto VX7',NULL,NULL,'Wired',NULL,NULL,NULL,NULL,3,17,'2026-05-11 02:26:30','2026-05-11 02:40:42',NULL,NULL,NULL),(38,'Peripheral','Processor','PC-PROC-02',NULL,'AMD','Ryzen 5 Pro 4650G',NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,17,'2026-05-11 02:27:07','2026-05-11 02:40:50',NULL,NULL,NULL),(39,'Peripheral','RAM','PC-RAM-03',NULL,'Teamgroup',NULL,NULL,NULL,'DDR4','16 GB',NULL,NULL,NULL,3,17,'2026-05-11 02:28:15','2026-05-11 02:41:01',NULL,NULL,NULL),(40,'Peripheral','RAM','PC-RAM-04',NULL,'Teamgroup',NULL,NULL,NULL,'DDR4','16 GB',NULL,NULL,NULL,3,17,'2026-05-11 02:28:38','2026-05-11 02:43:07',NULL,NULL,NULL),(41,'Peripheral','SSD','SSD-02',NULL,'V-Gen','V-GEN 07SM19EG512GP3X4IT',NULL,NULL,'M.2 NVMe 2280','512 GB',NULL,NULL,83,3,17,'2026-05-11 02:32:04','2026-05-11 02:49:37',NULL,NULL,NULL),(42,'Peripheral','UPS','UPS-02',NULL,'APC','Back Ups 650',NULL,NULL,NULL,'650 V',NULL,NULL,NULL,3,17,'2026-05-11 02:37:58','2026-05-11 02:43:25',NULL,NULL,NULL),(43,'Device','Laptop','Porta-LP-02',NULL,'Lenovo','Thinkpad X260',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-05-11 02:44:52','2026-05-11 02:44:52',NULL,NULL,NULL),(44,'Peripheral','Motherboard','LP-MOBO-02',NULL,'Lenovo','20F5S77Y00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,43,'2026-05-11 02:45:27','2026-06-01 21:16:38',NULL,NULL,NULL),(45,'Peripheral','Processor','LP-PROC-02',NULL,'Intel','Core i5 6300U',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,43,'2026-05-11 02:46:11','2026-06-01 21:16:45',NULL,NULL,NULL),(46,'Peripheral','RAM','LP-RAM-02',NULL,NULL,NULL,NULL,NULL,'DDR 4','8 GB',NULL,NULL,NULL,NULL,43,'2026-05-11 02:47:49','2026-06-01 21:16:17',NULL,NULL,NULL),(47,'Peripheral','SSD','SSD-18',NULL,'Adata','SU650',NULL,NULL,'Sata 2.5','256 GB',NULL,NULL,80,NULL,NULL,'2026-05-11 02:49:14','2026-05-11 02:49:14',NULL,NULL,NULL),(48,'Peripheral','Battery','LP-Batt-02',NULL,'Lenovo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,42,NULL,43,'2026-05-11 02:51:22','2026-06-01 21:16:29',NULL,NULL,NULL),(49,'Device','Phone','Porta-HP-07',NULL,'Apple','Iphone X',NULL,NULL,NULL,NULL,'3 GB','256 GB',80,NULL,NULL,'2026-05-11 02:54:46','2026-05-11 02:56:05',NULL,NULL,NULL),(50,'Device','PC','Porta-PC-03','porta',NULL,'Generic PC',NULL,NULL,NULL,NULL,NULL,NULL,NULL,4,NULL,'2026-05-11 02:57:47','2026-06-01 21:09:44',NULL,NULL,NULL),(53,'Peripheral','Motherboard','PC-MOBO-03',NULL,'MSI','B650M Gaming Wifi (MS-7E30)','2025-11-17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,'2026-06-01 19:30:34','2026-06-01 21:10:12',NULL,NULL,NULL),(54,'Peripheral','Processor','PC-PROC-03',NULL,'AMD','Ryzen 5 7500F','2025-11-17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,'2026-06-01 19:31:44','2026-06-01 21:11:41',NULL,NULL,NULL),(55,'Peripheral','RAM','PC-RAM-05',NULL,'Micron',NULL,'2025-11-17',NULL,'DDR5','16 GB',NULL,NULL,NULL,NULL,50,'2026-06-01 19:32:36','2026-06-01 21:11:03',NULL,NULL,NULL),(56,'Peripheral','RAM','PC-RAM-06',NULL,'Micron',NULL,'2025-11-17',NULL,'DDR5','16 GB',NULL,NULL,NULL,NULL,50,'2026-06-01 19:33:45','2026-06-01 21:11:16',NULL,NULL,NULL),(57,'Peripheral','SSD','SSD-03',NULL,'Adata','Legend 710','2025-11-17',NULL,'M.2 NVME','256 GB',NULL,NULL,90,NULL,50,'2026-06-01 19:37:47','2026-06-01 21:10:50',NULL,NULL,NULL),(58,'Peripheral','HDD','HDD-04',NULL,'Toshiba','HDWD220',NULL,NULL,'Sata 3.5','2 TB',NULL,NULL,100,NULL,50,'2026-06-01 19:38:38','2026-06-01 21:12:15',NULL,NULL,NULL),(59,'Peripheral','HDD','HDD-05',NULL,'Toshiba','HDWD240',NULL,NULL,'Sata 3.5','4 TB',NULL,NULL,100,NULL,50,'2026-06-01 19:39:13','2026-06-01 21:12:24',NULL,NULL,NULL),(60,'Peripheral','GPU','PC-GPU-03',NULL,'Nvidia','RTX 3060',NULL,NULL,NULL,'12 GB',NULL,NULL,NULL,NULL,50,'2026-06-01 19:40:25','2026-06-03 02:24:46',NULL,NULL,NULL),(61,'Peripheral','Monitor','MON-12',NULL,'LG','LG24MK430H',NULL,NULL,NULL,'24 Inch',NULL,NULL,NULL,NULL,50,'2026-06-01 19:45:16','2026-06-01 21:12:48',NULL,NULL,NULL),(62,'Peripheral','UPS','UPS-03',NULL,'Prolink','PRO1201SFCU-4U',NULL,NULL,NULL,'1200 VA',NULL,NULL,NULL,NULL,50,'2026-06-01 19:47:08','2026-06-01 21:10:37',NULL,NULL,NULL),(63,'Peripheral','Power Supply','PSU-02',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,17,'2026-06-01 19:47:48','2026-06-01 21:14:18',NULL,NULL,NULL),(64,'Peripheral','Power Supply','PSU-03',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,'2026-06-01 19:48:00','2026-06-01 21:13:05',NULL,NULL,NULL),(65,'Peripheral','Keyboard','Keyboard-03',NULL,'Logitech','K120',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,'2026-06-01 21:00:42','2026-06-01 21:12:34',NULL,NULL,NULL),(66,'Device','PC','Porta-PC-04',NULL,NULL,NULL,'2025-11-17',NULL,NULL,NULL,NULL,NULL,NULL,5,NULL,'2026-06-01 21:15:31','2026-06-01 23:28:49',NULL,NULL,NULL),(67,'Peripheral','Motherboard','PC-MOBO-04',NULL,'MSI','B550M Gaming',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,66,'2026-06-01 21:19:46','2026-06-01 23:29:44',NULL,NULL,NULL),(68,'Peripheral','Processor','PC-PROC-04',NULL,'AMD','Ryzen 5 PRO 4650G',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,66,'2026-06-01 21:20:27','2026-06-01 23:30:38',NULL,NULL,NULL),(69,'Peripheral','RAM','PC-RAM-07',NULL,'TeamGroup',NULL,NULL,NULL,'DDR4','16 GB',NULL,NULL,NULL,NULL,66,'2026-06-01 21:21:11','2026-06-01 23:30:48',NULL,NULL,NULL),(70,'Peripheral','RAM','PC-RAM-08',NULL,'TeamGroup',NULL,NULL,NULL,'DDR4','16 GB',NULL,NULL,NULL,NULL,66,'2026-06-01 21:21:39','2026-06-01 23:30:58',NULL,NULL,NULL),(71,'Peripheral','SSD','SSD-04',NULL,'Adata','SU650',NULL,NULL,'Sata 2.5','256 GB',NULL,NULL,100,NULL,66,'2026-06-01 21:22:38','2026-06-01 23:31:10',NULL,NULL,NULL),(72,'Peripheral','HDD','HDD-06',NULL,'Toshiba','HDWD240',NULL,NULL,'Sata 3.5','4 TB',NULL,NULL,100,NULL,66,'2026-06-01 21:23:53','2026-06-01 23:29:13',NULL,NULL,NULL),(73,'Peripheral','Monitor','MON-11',NULL,'Acer','EK240Y',NULL,NULL,NULL,'24 Inch',NULL,NULL,NULL,NULL,66,'2026-06-01 21:27:17','2026-06-01 23:29:35',NULL,NULL,NULL),(74,'Peripheral','UPS','UPS-04',NULL,'ProLink','PRO700SFC',NULL,NULL,NULL,'650 V',NULL,NULL,NULL,NULL,66,'2026-06-01 21:28:18','2026-06-01 23:31:20',NULL,NULL,NULL),(75,'Peripheral','Power Supply','PSU-04',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,66,'2026-06-01 21:40:02','2026-06-01 23:30:04',NULL,NULL,NULL),(76,'Peripheral','Keyboard','Keyboard-04',NULL,'Logitech','K120',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,66,'2026-06-01 21:41:50','2026-06-01 23:29:24',NULL,NULL,NULL),(77,'Peripheral','Mouse','Mouse-04',NULL,'Fantech','Crypto II',NULL,NULL,'Wired',NULL,NULL,NULL,NULL,NULL,66,'2026-06-01 21:42:36','2026-06-01 23:31:54',NULL,NULL,NULL),(78,'Device','PC','Porta-PC-05',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-03 02:18:25','2026-06-03 02:18:25',NULL,NULL,NULL),(79,'Peripheral','Motherboard','PC-MOBO-05',NULL,'Gigabyte Technology','Z390 AORUS ELITE-CF',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,78,'2026-06-03 02:19:30','2026-06-03 02:32:17',NULL,NULL,NULL),(80,'Peripheral','Processor','PC-PROC-05',NULL,'Intel','Core i7 9700K',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,78,'2026-06-03 02:20:12','2026-06-03 02:33:05',NULL,NULL,NULL),(81,'Peripheral','RAM','PC-RAM-09',NULL,'KLEVV',NULL,NULL,NULL,'DDR4','16 GB',NULL,NULL,NULL,NULL,78,'2026-06-03 02:21:14','2026-06-03 02:33:16',NULL,NULL,NULL),(82,'Peripheral','RAM','PC-RAM-10',NULL,'Klevv',NULL,NULL,NULL,'DDR4','16 GB',NULL,NULL,NULL,NULL,78,'2026-06-03 02:21:55','2026-06-04 19:41:42',NULL,NULL,NULL),(83,'Peripheral','SSD','SSD-05',NULL,'Adata','Legend 710',NULL,NULL,'M.2 NVME','512 GB',NULL,NULL,98,NULL,78,'2026-06-03 02:22:41','2026-06-03 02:33:39',NULL,NULL,NULL),(84,'Peripheral','HDD','HDD-07',NULL,'Seagate','ST4000DM004-2U9104',NULL,NULL,'Sata 3.5','4 TB',NULL,NULL,100,NULL,78,'2026-06-03 02:23:36','2026-06-03 02:31:40',NULL,NULL,NULL),(85,'Peripheral','GPU','PC-GPU-04',NULL,'Nvidia','GTX 1660',NULL,NULL,NULL,'6 GB',NULL,NULL,NULL,NULL,78,'2026-06-03 02:24:24','2026-06-03 02:31:23',NULL,NULL,NULL),(86,'Peripheral','Monitor','MON-10',NULL,'LG','LG24MK430H',NULL,NULL,NULL,'24 Inch',NULL,NULL,NULL,NULL,78,'2026-06-03 02:26:14','2026-06-03 02:32:04',NULL,NULL,NULL),(87,'Peripheral','UPS','UPS-05',NULL,'ProLink','Superfast',NULL,NULL,NULL,'650 V',NULL,NULL,NULL,NULL,78,'2026-06-03 02:27:53','2026-06-03 02:33:49',NULL,NULL,NULL),(88,'Peripheral','Power Supply','PSU-05',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,78,'2026-06-03 02:28:11','2026-06-03 02:32:53',NULL,NULL,NULL),(89,'Peripheral','Keyboard','Keyboard-05',NULL,'Logitech','K120',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,78,'2026-06-03 02:28:43','2026-06-03 02:31:52',NULL,NULL,NULL),(90,'Peripheral','Mouse','Mouse-05',NULL,'Fantech','Kanata VX9',NULL,NULL,'Wired',NULL,NULL,NULL,NULL,NULL,78,'2026-06-03 02:30:37','2026-06-03 02:32:36',NULL,NULL,NULL),(91,'Device','PC','Porta-PC-06','porta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,6,NULL,'2026-06-04 19:20:19','2026-06-07 18:58:31',NULL,NULL,NULL),(92,'Peripheral','Motherboard','PC-MOBO-06',NULL,'MSI','8450M-A PRO MAX (MS-7C52)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,91,'2026-06-04 19:37:04','2026-06-07 18:49:26',NULL,NULL,NULL),(93,'Peripheral','Processor','PC-PROC-06',NULL,'AMD','Ryzen 5 2400G',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,91,'2026-06-04 19:38:28','2026-06-07 18:55:37',NULL,NULL,NULL),(94,'Peripheral','RAM','PC-RAM-11',NULL,'Corsair',NULL,NULL,NULL,'DDR4','16 GB',NULL,NULL,NULL,NULL,91,'2026-06-04 19:41:17','2026-06-07 18:55:46',NULL,NULL,NULL),(95,'Peripheral','SSD','SSD-06',NULL,'Adata','SX8200PNP',NULL,NULL,'M.2 NVME','512 GB',NULL,NULL,72,NULL,91,'2026-06-04 19:55:21','2026-06-07 18:55:55',NULL,NULL,NULL),(96,'Peripheral','HDD','HDD-08',NULL,'Toshiba','HDWD120',NULL,NULL,'Sata 3.5','2 TB',NULL,NULL,100,NULL,91,'2026-06-04 20:06:05','2026-06-07 18:48:46',NULL,NULL,NULL),(97,'Peripheral','Monitor','MON-07',NULL,'LG','LG24MK430H',NULL,NULL,NULL,'24 Inch',NULL,NULL,NULL,NULL,91,'2026-06-04 20:13:29','2026-06-07 18:49:09',NULL,NULL,NULL),(98,'Peripheral','Power Supply','PSU-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,91,'2026-06-07 18:45:30','2026-06-07 18:55:21',NULL,NULL,NULL),(99,'Peripheral','Keyboard','Keyboard-06',NULL,'Logitech','K120',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,91,'2026-06-07 18:46:57','2026-06-07 18:48:57',NULL,NULL,NULL),(100,'Peripheral','Mouse','Mouse-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,91,'2026-06-07 18:47:30','2026-06-07 18:55:11',NULL,NULL,NULL),(101,'Peripheral','SSD','Helmy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100,1,NULL,'2026-06-07 19:30:14','2026-06-07 19:30:14',NULL,NULL,NULL);
/*!40000 ALTER TABLE `devices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employees_email_unique` (`email`),
  KEY `employees_department_id_foreign` (`department_id`),
  CONSTRAINT `employees_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'Helmy',NULL,2,'2026-03-05 01:39:21','2026-05-12 00:19:39'),(2,'Sonya',NULL,1,'2026-03-06 00:38:42','2026-03-06 00:38:42'),(3,'Putra',NULL,1,'2026-04-09 19:12:02','2026-04-09 19:12:02'),(4,'Zaldy',NULL,1,'2026-05-12 00:27:32','2026-05-12 00:27:32'),(5,'Vania',NULL,1,'2026-06-01 23:27:45','2026-06-01 23:27:45'),(6,'Feby',NULL,1,'2026-06-03 02:34:09','2026-06-03 02:34:09');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
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
-- Table structure for table `health_records`
--

DROP TABLE IF EXISTS `health_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `health_records` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `device_id` bigint(20) unsigned DEFAULT NULL,
  `recorded_date` date DEFAULT NULL,
  `health_percentage` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `health_records_device_id_foreign` (`device_id`),
  CONSTRAINT `health_records_device_id_foreign` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_records`
--

LOCK TABLES `health_records` WRITE;
/*!40000 ALTER TABLE `health_records` DISABLE KEYS */;
INSERT INTO `health_records` VALUES (2,8,'2026-03-27',83,NULL,'2026-03-26 20:37:06','2026-03-26 20:37:06'),(3,49,'2025-12-30',80,NULL,'2026-05-11 02:56:05','2026-05-11 02:56:05');
/*!40000 ALTER TABLE `health_records` ENABLE KEYS */;
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
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_02_24_023021_create_departments_table',1),(5,'2026_02_24_023022_create_employees_table',1),(6,'2026_02_24_023023_create_devices_table',1),(7,'2026_02_24_023024_create_activity_logs_table',1),(8,'2026_02_24_023024_create_health_records_table',1),(9,'2026_02_24_023024_create_service_histories_table',1),(10,'2026_03_04_043512_create_accounts_table',1),(11,'2026_03_04_043512_create_subscriptions_table',1),(12,'2026_03_04_043513_create_subscription_allocations_table',1),(13,'2026_03_06_035021_add_new_fields_to_health_records_table',2),(14,'2026_04_30_073146_add_price_and_images_to_devices_table',3),(15,'2026_05_06_012031_make_device_columns_nullable',4),(16,'2026_05_11_024500_add_device_password_to_devices_table',5);
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
-- Table structure for table `service_histories`
--

DROP TABLE IF EXISTS `service_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_histories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `device_id` bigint(20) unsigned DEFAULT NULL,
  `service_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_histories_device_id_foreign` (`device_id`),
  CONSTRAINT `service_histories_device_id_foreign` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_histories`
--

LOCK TABLES `service_histories` WRITE;
/*!40000 ALTER TABLE `service_histories` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_histories` ENABLE KEYS */;
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
INSERT INTO `sessions` VALUES ('3ADyMmS9l4QytUQUHC1dTAIxazDRYgxNhoXFIFda',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiMGNpd1NqU1M5WWpiMWpBbjFZa21ZUzFUTlZTMkRqVnVnRTA3OGhmZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9pbnZlbnRvcnkvRGFzaGJvYXJkIjtzOjU6InJvdXRlIjtzOjE1OiJpbnZlbnRvcnkuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToyO30=',1782718070),('S7Gh3oorFYaFNgLH8RM1OM9KLZwRU6H7MLwjdEJh',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiYWdHa3NJaFZISk8wd3JibEtLNkVpcDJVRzl5aVZLMk9HZHRtdkp1QyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDA6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9pbnZlbnRvcnkvS2V5Ym9hcmQiO3M6NToicm91dGUiO3M6MTU6ImludmVudG9yeS5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjI7fQ==',1780885977);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_allocations`
--

DROP TABLE IF EXISTS `subscription_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_allocations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subscription_id` bigint(20) unsigned NOT NULL,
  `assignable_type` varchar(255) NOT NULL,
  `assignable_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscription_allocations_subscription_id_foreign` (`subscription_id`),
  KEY `subscription_allocations_assignable_type_assignable_id_index` (`assignable_type`,`assignable_id`),
  CONSTRAINT `subscription_allocations_subscription_id_foreign` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_allocations`
--

LOCK TABLES `subscription_allocations` WRITE;
/*!40000 ALTER TABLE `subscription_allocations` DISABLE KEYS */;
INSERT INTO `subscription_allocations` VALUES (4,1,'App\\Models\\Employee',2,'2026-03-08 19:25:08','2026-03-08 19:25:08'),(5,4,'App\\Models\\Device',3,'2026-03-11 20:31:26','2026-03-11 20:31:26'),(6,3,'App\\Models\\Device',3,'2026-03-11 20:31:52','2026-03-11 20:31:52'),(7,4,'App\\Models\\Employee',2,'2026-05-05 22:01:37','2026-05-05 22:01:37');
/*!40000 ALTER TABLE `subscription_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned NOT NULL,
  `plan` varchar(255) NOT NULL,
  `period` varchar(255) NOT NULL,
  `bill` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `next_payment_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscriptions_account_id_foreign` (`account_id`),
  CONSTRAINT `subscriptions_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
INSERT INTO `subscriptions` VALUES (1,1,'Adobe Photoshop & Lightroom','Yearly',782000.00,'IDR','2026-03-19','2026-03-05 01:54:05','2026-03-11 00:15:08'),(3,2,'Adobe Photoshop & Lightroom','Yearly',1579752.00,'IDR','2027-05-07','2026-03-11 20:28:32','2026-05-11 02:08:51'),(4,2,'Adobe Ilustrator','Yearly',1722276.00,'IDR','2027-01-29','2026-03-11 20:30:10','2026-03-11 20:30:25');
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
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
INSERT INTO `users` VALUES (1,'Test User','test@example.com','2026-03-05 01:35:45','$2y$12$BezEwtgW6u2Wfq7/zcQdzOGVJniEo9AO1nhlNBXnbUi6rWWSgsu7u','GgM9oiwP0s','2026-03-05 01:35:45','2026-03-05 01:35:45'),(2,'helmy','helmy@gmail.com',NULL,'$2y$12$VWh3qVm.HQod5mjtSvcMMOc30qgR2N5.6viKHbdJNqqtNBA3O.v5m',NULL,'2026-04-09 19:47:31','2026-04-09 19:47:31');
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

-- Dump completed on 2026-07-15 22:54:38
