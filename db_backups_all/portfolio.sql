-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: portfolio
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
-- Current Database: `portfolio`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `portfolio` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `portfolio`;

--
-- Table structure for table `about_settings`
--

DROP TABLE IF EXISTS `about_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `about_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `headline` varchar(255) DEFAULT NULL,
  `intro` text DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `signature_image` varchar(255) DEFAULT NULL,
  `fun_fact` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `about_settings`
--

LOCK TABLES `about_settings` WRITE;
/*!40000 ALTER TABLE `about_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `about_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `abouts`
--

DROP TABLE IF EXISTS `abouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abouts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `profile_image` varchar(255) DEFAULT NULL,
  `signature_image` varchar(255) DEFAULT NULL,
  `accent_color` varchar(255) DEFAULT '#065cc2',
  `quote` varchar(255) DEFAULT NULL,
  `intro_heading` varchar(255) DEFAULT NULL,
  `intro_body` text DEFAULT NULL,
  `skills` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`skills`)),
  `timeline` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`timeline`)),
  `fun_emoji` varchar(8) DEFAULT NULL,
  `fun_text` varchar(255) DEFAULT NULL,
  `cta_portfolio_label` varchar(255) DEFAULT 'View My Work',
  `cta_resume_label` varchar(255) DEFAULT 'Download Resume',
  `resume_file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `abouts`
--

LOCK TABLES `abouts` WRITE;
/*!40000 ALTER TABLE `abouts` DISABLE KEYS */;
INSERT INTO `abouts` VALUES (1,'about/fpJxjehQrUGgVJkNqYqgXmbL9PmSXcrghutUDGHr.webp','about/IGPYbfCAIGRgqMUhbXIqtQrp5bJIsbLAl4ALqUJL.webp','#672c7d','\"Give Your Best, Let God Do The Rest\"','Hi, I\'m Helmy Kurniawan a IT Generalist','An IT & Digital Solutions Specialist with a strong background in network management, web development, multimedia, and digital marketing. Experienced in maintaining and optimizing IT infrastructure, including local and web servers, Google Workspace, and network systems . Skilled in troubleshooting hardware/software, designing company website, and managing digital content for branding and marketing.\r\n\r\nI\'m also adept at bridging communication between overseas principals and local clients, offering technical consulting and IT-based solutions. With a Bachelor’s degree in Information Systems (Cum Laude, GPA 3.72) from UPN “Veteran” East Java, he combines technical expertise with creative skills in web design, photography, and video production.','[{\"icon\":\"bi bi-palette\",\"title\":\"Design\",\"text\":\"Design with Ilustrator and Photoshop\"},{\"icon\":\"bi bi-code-slash\",\"title\":\"Web Dev\",\"text\":\"Experince with Laravel and Codeigniter\"},{\"icon\":\"bi bi-cpu\",\"title\":\"IT Solutions\",\"text\":\"Experience in IT and Digital Solutions\"}]','[]','☕','IT Generalist Based on Surabaya','View My Work','Download Resume','about/AtMTMliZvLNQ6GZAjvBbmSi2Oy0DAY3pLnG7NZDi.pdf','2025-11-07 20:00:55','2026-01-22 01:53:39');
/*!40000 ALTER TABLE `abouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `articles`
--

DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `articles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `excerpt` text DEFAULT NULL,
  `content` longtext NOT NULL,
  `cover_image` varchar(255) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `articles_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `articles`
--

LOCK TABLES `articles` WRITE;
/*!40000 ALTER TABLE `articles` DISABLE KEYS */;
INSERT INTO `articles` VALUES (1,'test','test','test','<p>test</p>','blog/gP5CL8HwLLgiqUjA5PW0vmJZOYoYbl2NrlvZSyJu.jpg','test',1,'2026-05-18 00:26:12','2026-05-18 00:24:26','2026-05-18 01:40:29');
/*!40000 ALTER TABLE `articles` ENABLE KEYS */;
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
-- Table structure for table `certifications`
--

DROP TABLE IF EXISTS `certifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `certifications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `label` varchar(255) NOT NULL,
  `sort` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `credential` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certifications`
--

LOCK TABLES `certifications` WRITE;
/*!40000 ALTER TABLE `certifications` DISABLE KEYS */;
INSERT INTO `certifications` VALUES (1,'BNSP - Junior Graphic Designer',2,'2025-11-07 23:47:16','2025-12-23 02:16:55','5577655'),(2,'BNSP - Junior Web Programmer',3,'2025-11-07 23:47:32','2025-12-23 02:16:55','5863622'),(3,'MikroTik - Certified Network Associate',0,'2025-11-09 05:06:43','2025-12-22 02:50:47','2511NA3728'),(4,'Hikvision - Certified Security Asosiate HNET',1,'2025-11-12 21:41:50','2025-12-22 02:52:20','HCSA-112025-0062-04-2225'),(5,'Dicoding - Start Programming with Dart',4,'2025-12-22 02:50:47','2025-12-22 02:50:57','1RXYQVJDQZVM'),(6,'Dicoding - Basic Javascript',5,'2026-01-13 09:02:44','2026-01-13 09:02:44','QLZ965LDMZ5D'),(7,'Dicoding - Basic AI',99,'2026-01-13 09:06:12','2026-01-13 09:06:12','GRX5J17DKX0M');
/*!40000 ALTER TABLE `certifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_settings`
--

DROP TABLE IF EXISTS `contact_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `section_title` varchar(255) NOT NULL DEFAULT 'Contact',
  `section_subtitle` varchar(255) DEFAULT NULL,
  `section_intro` text DEFAULT NULL,
  `infobox_title` varchar(255) NOT NULL DEFAULT 'Contact Info',
  `infobox_intro` text DEFAULT NULL,
  `location_title` varchar(255) NOT NULL DEFAULT 'Our Location',
  `location_lines` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`location_lines`)),
  `phone_title` varchar(255) NOT NULL DEFAULT 'Phone Number',
  `phones` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`phones`)),
  `email_title` varchar(255) NOT NULL DEFAULT 'Email Address',
  `emails` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`emails`)),
  `map_embed_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_settings`
--

LOCK TABLES `contact_settings` WRITE;
/*!40000 ALTER TABLE `contact_settings` DISABLE KEYS */;
INSERT INTO `contact_settings` VALUES (1,'Contact',NULL,NULL,'Get in touch',NULL,'Location','[\"Rungkut, Surabaya\"]','Phone','[\"+62 899 3704 720\"]','Email','[\"helmykurniawan1313@gmail.com\"]',NULL,'2025-11-09 05:33:33','2025-11-09 05:33:59');
/*!40000 ALTER TABLE `contact_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `educations`
--

DROP TABLE IF EXISTS `educations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `educations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `degree` varchar(255) NOT NULL,
  `institution` varchar(255) NOT NULL,
  `year` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `educations`
--

LOCK TABLES `educations` WRITE;
/*!40000 ALTER TABLE `educations` DISABLE KEYS */;
INSERT INTO `educations` VALUES (1,'Bachelor Degree of Information System','UPN \"Veteran\" Jawa Timur','2018 - 2022','Graduated on time in 8 semesters with Cum Laude honors (GPA 3.72).\r\nServed as Staff of Research and Development Division in the Information Systems Student Association (2019).\r\nAppointed as Head of Event Organizer for EIS 2019 (Event of Information System) in collaboration with Google Indonesia, Data Science Indonesia, and Gapura Digital.\r\nServed as Head of Event Division for ISCOM 2020.\r\nContributed as a Photographer/Videographer in various campus events.',1,'2025-11-09 05:26:16','2025-11-09 05:27:37'),(2,'Multimedia','SMKN 10 Surabaya','2015 - 2018','Recognized as one of the top graduates in the class.\r\nActively involved in school extracurricular activities such as Broadcasting, Badminton, and Scout (Pramuka).',2,'2025-11-09 05:31:09','2025-11-09 05:31:09');
/*!40000 ALTER TABLE `educations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiences`
--

DROP TABLE IF EXISTS `experiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experiences` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role` varchar(200) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `period` varchar(255) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `bullets` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`bullets`)),
  `sort_order` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiences`
--

LOCK TABLES `experiences` WRITE;
/*!40000 ALTER TABLE `experiences` DISABLE KEYS */;
INSERT INTO `experiences` VALUES (1,'IT & Digital Solutions Specialist (Full-Time)','PT Karya Energi Indonesia / PT Alucio Net','September 2023 – November 2025',NULL,'[\"Maintain and troubleshoot company network, hardware, and software to ensure stable operations.\",\"Manage and monitor IT infrastructure including routers, switches, Wi-Fi, and internet connections for optimal performance and security.\",\"Administer user accounts, access rights, data security, and perform regular data backups.\",\"Manage and maintain local servers, web servers, and email servers, including domains and Google Workspace services.\",\"Design, install, and maintain CCTV systems, printers, and other office equipment.\",\"Provide remote technical support for employees, including those working offsite.\",\"Design and develop the company website, update content, and coordinate with web development vendors.\",\"Create graphic designs, brochures, and digital promotional materials to support marketing and branding activities.\",\"Offer IT recommendations, technology consulting, and improvement guidance for internal systems and vendor-managed websites.\",\"Lead and supervise IT Support team members and coordinate with external vendors.\",\"Provide employee training and technical assistance related to IT systems and devices.\",\"Act as technical sales and IT consultant, offering technology-based solutions to internal and external clients.\",\"Serve as a communication bridge between overseas principals and local clients for technical issues and IT system integration.\",\"Assist HSE team to create report\"]',1,'2025-11-09 05:15:07','2025-12-16 19:59:46'),(2,'Digital Marketing (Freelance)','Rilmy Store','October 2020 – Present',NULL,'[\"Create digital content including videos, images, and graphic designs.\",\"Manage online sales and social media platforms (Facebook, Instagram, and E-commerce).\",\"Handle customer service and inquiries via online channels.\"]',2,'2025-11-09 05:16:20','2025-11-09 05:16:20'),(3,'Digital Marketing Staff (Internship)','PT Semeru Inti Sukses','January 2023 – February 2023',NULL,'[\"Manage digital marketing through E-Commerce, company website, Google Business, and social media.\",\"Create graphic design materials using Adobe Photoshop and Adobe Illustrator for marketing needs.\",\"Handle online customer interactions and support.\"]',3,'2025-11-09 05:17:09','2025-11-09 05:17:09'),(4,'Web Developer (Internship)','UPT TIK – Universitas Pembangunan Nasional “Veteran” Jawa Timur','October 2020 – February 2021',NULL,'[\"Developed modules for the \\u201cUPNVJ Quality Development\\u201d application using CodeIgniter 4.\",\"Designed and improved website UI\\/UX using Adobe XD.\"]',4,'2025-11-09 05:18:10','2025-11-09 05:18:10'),(5,'Photographer & Videographer (Freelance)','Ghea Photo and Studio','April 2019 – October 2019',NULL,'[\"Captured photos and videos for events such as graduations and weddings using DSLR, mirrorless, and video cameras.\"]',5,'2025-11-09 05:18:47','2025-11-09 05:18:47'),(6,'Multimedia Assistant (Internship)','Native Multimedia','October 2017 – February 2018',NULL,'[\"Operated video cameras (Sony & Panasonic) for events such as concerts, gatherings, and weddings.\",\"Performed post-production including graphic design, motion graphics, and video editing.\",\"Operated LED videotron, screen, and plasma displays during events.\"]',6,'2025-11-09 05:19:24','2025-11-09 05:19:24'),(7,'IT Support & General Affair','PT Selalu Ada Ruang (Porta Branding Agency)','November 2025 - Present',NULL,'[\"Responsible for managing and maintaining the office\\u2019s wired and wireless network to ensure optimal performance and reliability.\",\"Responsible for recording, documenting, and labeling all company IT assets to ensure organized and traceable inventory management.\",\"Provide assistance to coworkers when they encounter technical difficulties, ensuring timely support and smooth workflow across departments.\",\"Responsible for managing and distributing user passwords and access rights in accordance with company security policies.\"]',0,'2025-11-09 05:22:44','2025-11-25 01:04:54');
/*!40000 ALTER TABLE `experiences` ENABLE KEYS */;
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
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2025_10_31_065903_add_is_admin_to_users_table',1),(5,'2025_10_31_070303_add_is_admin_to_users_table',1),(6,'2025_10_31_072508_create_site_settings_table',1),(7,'2025_10_31_072509_create_services_table',1),(8,'2025_10_31_072510_create_portfolio_items_table',1),(9,'2025_10_31_074827_create_about_settings_table',2),(10,'2025_10_31_074829_create_experiences_table',2),(11,'2025_10_31_074830_create_education_table',2),(12,'2025_10_31_074831_create_contact_messages_table',2),(13,'2025_11_01_041335_add_social_columns_to_site_settings_table',2),(14,'2025_11_01_042646_add_hero_cards_to_site_settings_table',2),(15,'2025_11_03_031935_create_abouts_table',3),(16,'2025_11_03_042358_create_skill_tables',3),(17,'2025_11_04_081447_create_contact_settings_table',4),(18,'2025_11_05_075817_detail_fields_to_portfolio_items',4),(19,'2025_11_05_080017_create_portfolio_item_images_table',4),(20,'2025_11_05_081655_add_detail_fields_to_portfolio_items',4),(21,'2025_11_05_082121_add_detail_fields_to_portfolio_items',4),(22,'2025_11_05_091937_create_portfolio_slider_images_table',4),(23,'2025_11_01_045759_create_experiences_table',5),(24,'2025_11_01_045800_create_educations_table',6),(25,'2025_10_31_073017_create_portfolio_items_table',7),(26,'2025_11_04_024945_create_portfolio_tables',8),(27,'2025_11_10_032553_add_slug_to_portfolio_items_table',9),(28,'2025_11_10_033711_drop_slug_from_portfolio_categories',9),(29,'2025_12_16_020709_remove_meta_lightbox_gallery_key_from_portfolio_items',9),(30,'2025_12_16_100227_add_credential_to_certifications',10),(31,'2025_12_17_015945_add_credential_to_certifications_updated',11),(32,'2026_01_14_144815_add_accent_color_to_abouts_table',12),(33,'2026_01_17_035037_make_role_nullable_in_experiences_table',13),(34,'2026_05_17_162105_create_articles_table',14);
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
INSERT INTO `password_reset_tokens` VALUES ('helmykurniawan1313@gmail.com','$2y$12$bK6jp5JLQsAGLp4xod715umlblvwjeAneW1gxOdebVHMGMjhc9hpO','2025-11-25 00:56:31');
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `portfolio_categories`
--

DROP TABLE IF EXISTS `portfolio_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `portfolio_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `filter_class` varchar(255) NOT NULL,
  `sort` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `portfolio_categories_filter_class_unique` (`filter_class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `portfolio_categories`
--

LOCK TABLES `portfolio_categories` WRITE;
/*!40000 ALTER TABLE `portfolio_categories` DISABLE KEYS */;
INSERT INTO `portfolio_categories` VALUES (1,'Design','design',0,'2025-11-09 05:35:16','2025-11-09 05:35:16'),(2,'Photo','filter-ui',2,'2025-12-07 23:55:53','2025-12-07 23:55:53');
/*!40000 ALTER TABLE `portfolio_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `portfolio_item_images`
--

DROP TABLE IF EXISTS `portfolio_item_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `portfolio_item_images` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `portfolio_item_id` bigint(20) unsigned NOT NULL,
  `path` varchar(255) NOT NULL,
  `is_thumbnail` tinyint(1) NOT NULL DEFAULT 0,
  `sort` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `portfolio_item_images_portfolio_item_id_foreign` (`portfolio_item_id`),
  CONSTRAINT `portfolio_item_images_portfolio_item_id_foreign` FOREIGN KEY (`portfolio_item_id`) REFERENCES `portfolio_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `portfolio_item_images`
--

LOCK TABLES `portfolio_item_images` WRITE;
/*!40000 ALTER TABLE `portfolio_item_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `portfolio_item_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `portfolio_items`
--

DROP TABLE IF EXISTS `portfolio_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `portfolio_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `portfolio_category_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `image_path` varchar(255) NOT NULL,
  `detail_url` varchar(255) DEFAULT NULL,
  `aos_delay` smallint(5) unsigned NOT NULL DEFAULT 300,
  `sort` smallint(5) unsigned NOT NULL DEFAULT 0,
  `is_published` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `portfolio_items_slug_unique` (`slug`),
  KEY `portfolio_items_portfolio_category_id_foreign` (`portfolio_category_id`),
  CONSTRAINT `portfolio_items_portfolio_category_id_foreign` FOREIGN KEY (`portfolio_category_id`) REFERENCES `portfolio_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `portfolio_items`
--

LOCK TABLES `portfolio_items` WRITE;
/*!40000 ALTER TABLE `portfolio_items` DISABLE KEYS */;
INSERT INTO `portfolio_items` VALUES (6,1,'UPN Open Talk 01',NULL,'portfolio/c6WijYGXXi9r4IOaz7V5MnR3lKsIh7EimdeppBng.webp',NULL,300,4,1,'2025-12-18 09:06:56','2026-01-29 00:43:42'),(7,1,'UPN Open Talk 02',NULL,'portfolio/uCEtoqkAbp8uTeyuvEr1dhV819F5cqXoUZtxsVMO.webp',NULL,300,1,1,'2025-12-18 09:08:11','2026-01-29 00:43:42'),(8,1,'UPN Open Talk 03',NULL,'portfolio/UuP7GLX64Uw6Q43fh9TZObqZVaVAvm8MI1ECGj6g.webp',NULL,300,2,1,'2025-12-18 09:15:25','2026-01-29 00:43:42'),(9,1,'BNSP Junior Graphic Designer',NULL,'portfolio/lpHn3ft17EcDYE4c6uafPbyPz3oCzsK9pPAEwWOa.webp',NULL,300,5,1,'2025-12-18 09:16:37','2026-01-29 00:43:42'),(10,1,'Infografis',NULL,'portfolio/rzJiQVkHds7EvwtV3Th5Y5STUzjNe89lhmNI6snd.webp',NULL,300,3,1,'2025-12-18 09:18:08','2026-01-29 00:43:42');
/*!40000 ALTER TABLE `portfolio_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `portfolio_slider_images`
--

DROP TABLE IF EXISTS `portfolio_slider_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `portfolio_slider_images` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `portfolio_item_id` bigint(20) unsigned NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `sort` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `portfolio_slider_images_portfolio_item_id_foreign` (`portfolio_item_id`),
  CONSTRAINT `portfolio_slider_images_portfolio_item_id_foreign` FOREIGN KEY (`portfolio_item_id`) REFERENCES `portfolio_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `portfolio_slider_images`
--

LOCK TABLES `portfolio_slider_images` WRITE;
/*!40000 ALTER TABLE `portfolio_slider_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `portfolio_slider_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `excerpt` varchar(500) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
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
INSERT INTO `sessions` VALUES ('XUxvzGOmuzxmHFNu9qs4s28zplIh3RG3HuMke1Ds',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiTHdQd0FEWHRpS1lZcnVEeDVkT2RDeFNDTmwwNGZadnZubTc0YVo3SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDI6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wb3J0Zm9saW8vY2F0ZWdvcmllcyI7czo1OiJyb3V0ZSI7czozMjoiYWRtaW4ucG9ydGZvbGlvLmNhdGVnb3JpZXMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToxO30=',1779097617);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_settings`
--

DROP TABLE IF EXISTS `site_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `site_name` varchar(255) NOT NULL DEFAULT 'Style',
  `twitter` varchar(255) DEFAULT NULL,
  `facebook` varchar(255) DEFAULT NULL,
  `instagram` varchar(255) DEFAULT NULL,
  `linkedin` varchar(255) DEFAULT NULL,
  `github` varchar(255) DEFAULT NULL,
  `hero_title` varchar(255) DEFAULT NULL,
  `hero_typed_items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`hero_typed_items`)),
  `hero_lead` text DEFAULT NULL,
  `stat_projects` int(10) unsigned NOT NULL DEFAULT 0,
  `stat_years` int(10) unsigned NOT NULL DEFAULT 0,
  `stat_clients` int(10) unsigned NOT NULL DEFAULT 0,
  `profile_image` varchar(255) DEFAULT NULL,
  `hero_card1_icon` varchar(255) DEFAULT NULL,
  `hero_card1_label` varchar(255) DEFAULT NULL,
  `hero_card2_icon` varchar(255) DEFAULT NULL,
  `hero_card2_label` varchar(255) DEFAULT NULL,
  `hero_card3_icon` varchar(255) DEFAULT NULL,
  `hero_card3_label` varchar(255) DEFAULT NULL,
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_links`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_settings`
--

LOCK TABLES `site_settings` WRITE;
/*!40000 ALTER TABLE `site_settings` DISABLE KEYS */;
INSERT INTO `site_settings` VALUES (1,'Helmy Kurniawan',NULL,NULL,'https://www.instagram.com/helmykurniawan_/','https://www.linkedin.com/in/helmy-kurniawan-13649a196/',NULL,'Helmy Kurniawan  is','[\"an IT Specialist\",\"a Graphic Design\",\"a Web Developer\",\"a Multimedia\",\"a Digital Marketing\"]','Hello and welcome! Thank you for taking the time to visit my portfolio. I appreciate your interest and hope you enjoy discovering my projects and experiences.',0,0,0,'profile/v5AzrXSkki9QUHUAPTG5W5hv4Ulugv06Nv0Lq3Fz.png','bi bi-palette','Graphic Design','bi bi-code-slash','Web Dev','bi bi-cpu','IT Solution',NULL,'2025-11-07 00:02:12','2026-01-29 00:19:37','site/DwC91Z5LraI40TjLYcALaCvSn8N0CqVQ7wY5NkNB.webp');
/*!40000 ALTER TABLE `site_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skill_categories`
--

DROP TABLE IF EXISTS `skill_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `skill_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `aos_delay` smallint(5) unsigned NOT NULL DEFAULT 200,
  `sort` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skill_categories`
--

LOCK TABLES `skill_categories` WRITE;
/*!40000 ALTER TABLE `skill_categories` DISABLE KEYS */;
INSERT INTO `skill_categories` VALUES (1,'IT Solutions','bi bi-cpu',100,1,'2025-11-07 21:59:37','2026-01-22 01:54:52'),(2,'Web Development','bi bi-code-slash',100,2,'2025-11-07 22:00:23','2026-01-22 01:54:52'),(3,'Design & Video','bi bi-palette',100,3,'2025-11-07 23:49:00','2026-01-22 01:54:52'),(4,'Digital Marketing','bi bi-shop',100,4,'2025-11-09 04:46:46','2026-01-22 01:54:52'),(5,'Multimedia','bi bi-camera-reels',100,5,'2025-11-09 04:50:00','2026-01-22 01:54:52');
/*!40000 ALTER TABLE `skill_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skill_items`
--

DROP TABLE IF EXISTS `skill_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `skill_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `skill_category_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `percentage` tinyint(3) unsigned NOT NULL,
  `sort` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `skill_items_skill_category_id_foreign` (`skill_category_id`),
  CONSTRAINT `skill_items_skill_category_id_foreign` FOREIGN KEY (`skill_category_id`) REFERENCES `skill_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skill_items`
--

LOCK TABLES `skill_items` WRITE;
/*!40000 ALTER TABLE `skill_items` DISABLE KEYS */;
INSERT INTO `skill_items` VALUES (1,1,'Helpdesk',85,1,'2025-11-07 22:00:23','2025-11-07 22:00:23'),(2,1,'Networking',80,2,'2025-11-07 23:49:00','2025-11-07 23:49:00'),(3,2,'Laravel',60,1,'2025-11-07 23:49:00','2025-11-07 23:49:00'),(4,2,'Codeigniter',50,2,'2025-11-07 23:57:11','2025-11-07 23:57:11'),(5,3,'Photoshop & Ilustrator',70,1,'2025-11-07 23:57:11','2025-11-09 04:46:46'),(6,2,'SQL',65,3,'2025-11-09 04:46:46','2025-11-09 04:46:46'),(7,3,'Figma',50,2,'2025-11-09 04:46:46','2025-11-09 04:46:46'),(8,1,'IT Solution',85,3,'2025-11-09 04:50:00','2025-11-09 04:50:00'),(9,3,'Premiere Pro',60,3,'2025-11-09 04:50:00','2025-11-09 04:50:00'),(10,4,'SEO',45,1,'2025-11-09 04:50:00','2025-11-09 04:50:00'),(11,4,'SMM',45,2,'2025-11-09 04:55:43','2025-11-09 04:55:43'),(12,5,'Photographer',75,1,'2025-11-09 04:55:43','2025-11-09 04:55:43'),(13,5,'Videographer',65,2,'2025-11-09 04:56:03','2025-11-09 04:56:03');
/*!40000 ALTER TABLE `skill_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skill_stats`
--

DROP TABLE IF EXISTS `skill_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `skill_stats` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `icon` varchar(255) DEFAULT NULL,
  `label` varchar(255) NOT NULL,
  `number` varchar(255) NOT NULL,
  `aos_delay` smallint(5) unsigned NOT NULL DEFAULT 300,
  `sort` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skill_stats`
--

LOCK TABLES `skill_stats` WRITE;
/*!40000 ALTER TABLE `skill_stats` DISABLE KEYS */;
INSERT INTO `skill_stats` VALUES (1,'bi bi-trophy','Years of Experience','5',600,0,'2025-11-09 05:08:04','2025-11-09 05:08:04');
/*!40000 ALTER TABLE `skill_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skills_summary`
--

DROP TABLE IF EXISTS `skills_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `skills_summary` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `heading` varchar(255) NOT NULL DEFAULT 'Professional Expertise',
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills_summary`
--

LOCK TABLES `skills_summary` WRITE;
/*!40000 ALTER TABLE `skills_summary` DISABLE KEYS */;
INSERT INTO `skills_summary` VALUES (1,'Professional Expertise',NULL,'2025-11-07 23:47:16','2025-11-07 23:47:16');
/*!40000 ALTER TABLE `skills_summary` ENABLE KEYS */;
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
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Helmy Kurniawan','helmykurniawan1313@gmail.com',NULL,'$2y$12$MaM.koO0OZo8EiUkf7vt4eDWxTDyzkL2EAhDkEGbW0ecN27rS0uVy',NULL,'2025-11-07 00:01:51','2025-11-22 22:59:41',1);
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

-- Dump completed on 2026-07-15 22:54:39
