-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: brand_matrix
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
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `ai_summary` text DEFAULT NULL,
  `ai_summary_generated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (9,'BHC','2026-07-09 19:52:09','2026-07-09 19:52:09',NULL,NULL),(10,'Porta Branding','2026-07-12 23:42:30','2026-07-14 19:22:13','Kinerja akun Porta Branding menunjukkan pola fluktuatif di mana fase awal pertumbuhan pengikut yang masif tidak diikuti dengan konsistensi keterlibatan audiens. Periode Mei menjadi titik terbaik dengan skor kesehatan yang mencapai kategori BAGUS, namun performa kembali menurun pada bulan Juni terutama pada kategori keterlibatan yang kini berada di level CUKUP. Skor pertumbuhan pengikut yang konsisten berada di kategori PARAH menunjukkan bahwa akun ini sedang mengalami stagnasi akuisisi audiens baru setelah lonjakan awal. Kondisi ini mengindikasikan bahwa konten yang diproduksi saat ini mungkin kurang memiliki daya tarik untuk menjangkau audiens di luar pengikut yang sudah ada, sehingga jangkauan dan interaksi cenderung melandai. Untuk mengatasi stagnasi pertumbuhan pengikut tersebut, Anda perlu segera meluncurkan kampanye konten kolaborasi dengan kreator atau akun relevan di ceruk pasar yang sama guna membuka akses ke audiens baru yang lebih luas. Langkah ini krusial untuk memicu kembali pertumbuhan organik yang sempat terhenti dan meningkatkan visibilitas akun secara berkelanjutan.','2026-07-14 19:22:13'),(11,'Perdana','2026-07-13 21:31:36','2026-07-13 21:31:36',NULL,NULL),(12,'Vamos World','2026-07-13 21:57:48','2026-07-13 21:57:48',NULL,NULL),(13,'Wahyu Redjo','2026-07-13 22:01:05','2026-07-13 22:01:05',NULL,NULL),(14,'Jackson','2026-07-13 22:03:37','2026-07-13 22:03:37',NULL,NULL),(15,'Arena Ban','2026-07-13 23:28:07','2026-07-13 23:28:07',NULL,NULL),(16,'Ando Boots','2026-07-13 23:30:28','2026-07-15 02:32:10','Performa Ando Boots menunjukkan tren pertumbuhan yang sangat stabil dengan skor kesehatan yang konsisten di angka 83,3 dalam dua bulan terakhir. Meskipun jumlah pengikut terus bertambah secara signifikan, kategori visibilitas tetap berada di level CUKUP karena skor jangkauan yang stagnan di angka nol, yang menandakan adanya ketimpangan antara jumlah penayangan konten yang masif dengan jangkauan unik yang dihasilkan. Kondisi ini menunjukkan bahwa konten Anda sangat disukai oleh audiens yang sudah ada, namun belum berhasil menembus audiens baru secara organik melalui distribusi jangkauan yang lebih luas. Implikasi bisnisnya adalah Anda memiliki basis penggemar yang sangat loyal dan aktif, tetapi Anda berisiko mengalami kejenuhan audiens jika tidak segera memperluas jangkauan ke luar lingkaran pengikut saat ini. Untuk mengatasi masalah pada kategori visibilitas ini, Anda harus segera melakukan eksperimen dengan format konten yang lebih berorientasi pada fitur penemuan seperti Reels atau konten kolaborasi yang dirancang khusus untuk memicu algoritma agar mendistribusikan konten kepada pengguna yang belum mengikuti akun Anda.','2026-07-15 02:32:10'),(17,'Bibilop.id','2026-07-13 23:54:54','2026-07-13 23:54:54',NULL,NULL),(19,'UBS','2026-07-14 00:41:00','2026-07-14 00:41:00',NULL,NULL),(20,'Amakute','2026-07-14 01:29:53','2026-07-14 21:36:03','Performa akun Amakute menunjukkan tren penurunan yang mengkhawatirkan pada periode terbaru, di mana pertumbuhan pengikut berubah dari positif menjadi negatif dan skor engagement berdasarkan jangkauan merosot drastis ke kategori PARAH. Meskipun visibilitas dan jangkauan konten justru meningkat pesat di bulan Juni, hal ini tidak dibarengi dengan kemampuan untuk mempertahankan audiens atau memicu interaksi yang bermakna. Fenomena ini mengindikasikan bahwa konten yang Anda produksi mungkin berhasil menjangkau audiens baru yang luas namun gagal memberikan nilai tambah atau relevansi yang cukup untuk mengubah penonton menjadi pengikut setia. Jika tren kehilangan pengikut ini berlanjut, efektivitas akun dalam membangun komunitas akan tergerus meskipun angka impresi terlihat tinggi. Untuk memperbaiki masalah ini, Anda harus segera melakukan evaluasi terhadap kualitas konten yang viral tersebut dan mulai menyisipkan ajakan bertindak atau elemen interaktif yang lebih kuat di setiap postingan agar penonton yang terjangkau merasa terdorong untuk berinteraksi dan mengikuti akun Anda.','2026-07-14 21:36:03'),(21,'Inside Porta','2026-07-14 19:53:55','2026-07-14 19:53:55',NULL,NULL),(22,'Mc Lewis','2026-07-14 20:42:55','2026-07-14 20:42:55',NULL,NULL),(23,'GMB','2026-07-14 20:53:24','2026-07-14 20:53:24',NULL,NULL),(24,'Rawit Tabur','2026-07-14 21:10:38','2026-07-14 21:10:54',NULL,NULL),(25,'Lem Castol','2026-07-14 21:16:13','2026-07-14 21:16:13',NULL,NULL),(26,'Bon Ami','2026-07-14 21:19:21','2026-07-14 21:19:21',NULL,NULL),(27,'Pok Pok Indonesia','2026-07-14 21:23:29','2026-07-14 21:23:29',NULL,NULL),(28,'Steak With U','2026-07-14 21:28:11','2026-07-14 21:28:11',NULL,NULL),(29,'Jade Imperial','2026-07-14 21:40:44','2026-07-14 21:40:44',NULL,NULL),(30,'Pun Pun Snack','2026-07-14 21:46:18','2026-07-14 21:46:18',NULL,NULL),(31,'Sabang Merauke','2026-07-14 21:49:14','2026-07-14 21:49:14',NULL,NULL),(32,'Tao Padel','2026-07-14 21:52:27','2026-07-14 21:52:27',NULL,NULL),(33,'Ragi','2026-07-15 02:10:25','2026-07-15 02:10:25',NULL,NULL);
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
INSERT INTO `cache` VALUES ('brand-matrix-cache-0bc76adb168ee488ab292af4ba9aa17d','i:1;',1783651635),('brand-matrix-cache-0bc76adb168ee488ab292af4ba9aa17d:timer','i:1783651635;',1783651635),('brand-matrix-cache-118a36cb3863ea5acb3f3f6dd1b56426','i:1;',1784106553),('brand-matrix-cache-118a36cb3863ea5acb3f3f6dd1b56426:timer','i:1784106553;',1784106553),('brand-matrix-cache-49c63540ba702a5486b91d1d5a725f87','i:1;',1783999086),('brand-matrix-cache-49c63540ba702a5486b91d1d5a725f87:timer','i:1783999086;',1783999086),('brand-matrix-cache-5ad7975524bbdaaf21375cdd2a0d28ea','i:1;',1783936905),('brand-matrix-cache-5ad7975524bbdaaf21375cdd2a0d28ea:timer','i:1783936905;',1783936905),('brand-matrix-cache-a6f155de15268698bea3ed1df3f9aab3','i:1;',1784107877),('brand-matrix-cache-a6f155de15268698bea3ed1df3f9aab3:timer','i:1784107877;',1784107877),('brand-matrix-cache-b647b8e9ba1e2770fd5a256d3e87aaa8','i:1;',1784082540),('brand-matrix-cache-b647b8e9ba1e2770fd5a256d3e87aaa8:timer','i:1784082540;',1784082540),('brand-matrix-cache-c127794c7c902ab488e02574dc24b9ad','i:1;',1783651909),('brand-matrix-cache-c127794c7c902ab488e02574dc24b9ad:timer','i:1783651909;',1783651909),('brand-matrix-cache-ffb74c7c28826c4cf9ec3e30b56d8434','i:1;',1783925461),('brand-matrix-cache-ffb74c7c28826c4cf9ec3e30b56d8434:timer','i:1783925461;',1783925461);
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
-- Table structure for table `cycles`
--

DROP TABLE IF EXISTS `cycles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cycles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned NOT NULL,
  `cycle_start_date` date NOT NULL,
  `cycle_end_date` date NOT NULL,
  `start_follower` bigint(20) unsigned NOT NULL,
  `end_follower` bigint(20) unsigned NOT NULL,
  `reach` bigint(20) unsigned NOT NULL,
  `views` bigint(20) unsigned NOT NULL,
  `engagement` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `ai_summary` text DEFAULT NULL,
  `ai_summary_generated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cycles_account_id_foreign` (`account_id`),
  CONSTRAINT `cycles_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cycles`
--

LOCK TABLES `cycles` WRITE;
/*!40000 ALTER TABLE `cycles` DISABLE KEYS */;
INSERT INTO `cycles` VALUES (51,9,'2026-06-01','2026-06-30',24575,22537,181459,397661,4628,'2026-07-09 19:54:06','2026-07-14 00:09:49',NULL,NULL),(52,10,'2026-05-01','2026-05-31',24016,24581,288671,846888,11568,'2026-07-12 23:49:09','2026-07-14 01:20:17','Porta Branding maintained strong visibility and engagement scores this month, yet the growth score is currently weak (KURANG) at 25 despite reaching over 288,000 people. This discrepancy indicates that while your content is successfully capturing attention and keeping current fans active, it is failing to convert new viewers into long-term followers. Essentially, you have high visibility but a low conversion rate, suggesting that the incentive for non-followers to hit the follow button is missing from your viral content. To address this weak growth, you should integrate a specific value-based call to action into your top-performing reels or posts that explicitly tells new viewers what they gain by following. By focusing on this conversion gap, you can turn your high reach into a sustainable audience expansion.','2026-07-14 01:20:17'),(53,10,'2026-06-01','2026-06-30',24016,24581,276789,524840,4038,'2026-07-13 00:00:09','2026-07-14 00:09:49',NULL,NULL),(54,11,'2026-06-02','2026-07-01',17424,17507,58543,96413,1226,'2026-07-13 21:33:43','2026-07-14 00:09:49',NULL,NULL),(55,12,'2026-06-12','2026-07-11',7828,7454,36240,62669,918,'2026-07-13 22:00:02','2026-07-14 02:33:44','Akun Vamos World mengalami penurunan jumlah pengikut yang cukup signifikan sebesar 4,78%, yang menyebabkan skor pertumbuhan anjlok ke angka nol meskipun tingkat interaksi atau engagement masih tergolong bagus di angka 75. Kondisi ini menunjukkan adanya masalah retensi pengikut dan kurangnya jangkauan ke audiens baru, di mana konten yang ada mungkin disukai oleh pengikut setia namun gagal menarik minat orang luar untuk mulai mengikuti akun. Jika tren kehilangan pengikut ini terus berlanjut tanpa adanya aliran audiens baru, basis komunitas akun akan terus menyusut dan efektivitas pemasaran akan melemah secara jangka panjang. Untuk memperbaiki skor pertumbuhan yang sangat lemah ini, segera jalankan kampanye iklan berbasis jangkauan atau kolaborasi dengan influencer relevan untuk memperluas visibilitas di luar lingkaran pengikut saat ini. Strategi ini sangat krusial untuk menyeimbangkan angka churn dengan akuisisi audiens baru guna memulihkan kesehatan akun secara keseluruhan.','2026-07-14 02:33:44'),(56,13,'2026-06-09','2026-07-08',138091,143872,168472,9860384,38573,'2026-07-13 22:02:32','2026-07-14 00:09:49',NULL,NULL),(57,14,'2026-06-01','2026-06-01',31632,31705,240962,518386,3728,'2026-07-13 22:05:13','2026-07-14 00:09:49',NULL,NULL),(58,15,'2026-06-01','2026-06-30',3928,4186,104574,168518,4319,'2026-07-13 23:29:47','2026-07-14 00:09:49',NULL,NULL),(59,16,'2026-06-01','2026-06-30',1745,1934,9531,21342,4385,'2026-07-13 23:32:06','2026-07-14 00:09:49',NULL,NULL),(60,17,'2026-06-12','2026-07-11',17489,17485,83064,577655,336,'2026-07-14 00:18:09','2026-07-14 02:48:13','Akun Bibilop.id mengalami stagnasi pertumbuhan pengikut dengan skor pertumbuhan nol, sementara skor keterlibatan berada di level yang sangat mengkhawatirkan meskipun visibilitas masih tergolong cukup. Masalah utamanya terletak pada konten yang memiliki jumlah tayangan tinggi namun gagal memicu interaksi aktif, sehingga audiens hanya menjadi penonton pasif tanpa ada konversi menjadi pengikut baru. Kondisi ini menunjukkan adanya ketidakselarasan antara materi konten dengan minat audiens yang menyebabkan rendahnya relevansi akun di mata algoritma interaksi. Untuk memperbaiki skor keterlibatan yang sangat rendah ini, tim harus segera mengimplementasikan konten berbasis ajakan bertindak yang kuat seperti kuis interaktif atau carousel informatif yang dirancang khusus agar audiens mau menyimpan dan membagikan unggahan tersebut.','2026-07-14 02:48:13'),(62,19,'2026-06-10','2026-07-09',30619,33856,873248,2149071,8613,'2026-07-14 00:44:54','2026-07-14 00:44:54',NULL,NULL),(63,20,'2026-06-02','2026-07-01',5939,5902,457057,833746,1223,'2026-07-14 01:33:06','2026-07-14 01:47:06','Amakute’s visibility is currently at a perfect score of 100, yet the growth score has plummeted to zero due to a net loss of 37 followers over the last month. This disconnect indicates that while your content is successfully reaching a massive audience of over 450,000 people, it is failing to convert those viewers into long-term followers or is actively alienating the existing base. The moderate engagement and health scores suggest that the content is being seen but not deeply resonated with, leading to high churn despite the high view counts. To address the critical growth deficit, you should implement a \"follow-worthy\" content series that explicitly highlights the unique value proposition of the account or uses a clear call-to-action in the first three seconds of high-reach videos to capture the attention of new viewers. This shift will help transform your high visibility into a sustainable community rather than just temporary views.','2026-07-14 01:47:06'),(64,10,'2026-04-03','2026-04-30',0,23747,237410,488032,2636,'2026-07-14 03:01:21','2026-07-14 03:01:21',NULL,NULL),(65,21,'2026-04-01','2026-04-30',94,94,10511,29620,1112,'2026-07-14 19:56:27','2026-07-14 19:56:27',NULL,NULL),(66,21,'2026-05-01','2026-05-30',94,94,4704,13074,412,'2026-07-14 20:04:27','2026-07-14 20:04:27',NULL,NULL),(67,21,'2026-06-01','2026-06-30',94,104,11147,23839,669,'2026-07-14 20:05:50','2026-07-14 20:38:14','Performa akun Inside Porta selama bulan Juni menunjukkan hasil yang sangat impresif dengan pertumbuhan pengikut sebesar sepuluh persen serta skor sempurna di seluruh kategori utama seperti visibilitas dan keterlibatan. Angka-angka ini menandakan bahwa strategi konten saat ini sangat selaras dengan minat audiens sehingga mampu menarik pengikut baru secara organik sekaligus mempertahankan interaksi yang konsisten. Pencapaian ini sangat krusial karena menunjukkan bahwa basis pengikut Anda sedang berada dalam fase ekspansi yang sehat dan berkualitas tinggi. Mengingat semua metrik berada di level maksimal, fokus Anda sekarang harus bergeser dari sekadar menarik audiens ke arah konversi atau retensi jangka panjang. Sebagai langkah konkret berikutnya, Anda disarankan untuk mulai mengimplementasikan strategi konten eksklusif atau ajakan bertindak yang lebih spesifik guna mengubah pengikut baru tersebut menjadi komunitas yang lebih loyal dan bernilai bagi bisnis Anda.','2026-07-14 20:38:14'),(68,9,'2026-05-01','2026-05-31',6768,24575,253066,991458,28196,'2026-07-14 20:14:59','2026-07-14 20:14:59',NULL,NULL),(69,11,'2026-05-02','2026-06-01',19821,17424,91364,164216,1428,'2026-07-14 20:17:52','2026-07-14 20:17:52',NULL,NULL),(70,14,'2026-05-01','2026-05-31',31464,31632,248183,650555,3841,'2026-07-14 20:22:11','2026-07-14 20:22:11',NULL,NULL),(71,15,'2026-05-01','2026-05-31',3369,3928,124621,170181,3535,'2026-07-14 20:24:25','2026-07-14 20:24:25',NULL,NULL),(72,16,'2026-05-01','2026-05-31',1539,1745,2997,9762,4119,'2026-07-14 20:26:30','2026-07-14 20:26:30',NULL,NULL),(73,13,'2026-05-09','2026-06-08',131557,138091,148259,8888900,60140,'2026-07-14 20:30:22','2026-07-14 20:30:22',NULL,NULL),(75,12,'2026-05-12','2026-06-11',1479,7828,90870,164064,1304,'2026-07-14 20:36:32','2026-07-14 20:36:32',NULL,NULL),(76,17,'2026-05-12','2026-06-11',17538,17489,81620,690711,418,'2026-07-14 20:38:46','2026-07-14 20:38:46',NULL,NULL),(77,19,'2026-05-10','2026-06-09',27114,30619,627227,1784572,7840,'2026-07-14 20:41:06','2026-07-14 20:41:06',NULL,NULL),(78,22,'2026-05-01','2026-05-31',144195,155764,266163,293390,2914,'2026-07-14 20:44:31','2026-07-14 20:44:31',NULL,NULL),(79,22,'2026-06-01','2026-06-30',155764,237601,363791,2113897,9959,'2026-07-14 20:45:54','2026-07-14 20:45:54',NULL,NULL),(80,20,'2026-05-02','2026-06-01',5862,5939,308884,441675,3294,'2026-07-14 20:51:08','2026-07-14 20:51:08',NULL,NULL),(81,23,'2026-05-05','2026-06-04',1607,2614,171009,267221,929,'2026-07-14 20:55:14','2026-07-14 20:55:14',NULL,NULL),(82,23,'2026-06-05','2026-07-04',2614,3096,208051,332737,1185,'2026-07-14 20:56:28','2026-07-15 02:31:02','Akun GMB menunjukkan pertumbuhan pengikut yang sangat impresif sebesar 18,4 persen dengan skor visibilitas dan pertumbuhan yang sempurna, namun skor keterlibatan masih berada di level cukup karena rasio interaksi belum sebanding dengan lonjakan jangkauan konten. Ketimpangan ini mengindikasikan bahwa meskipun strategi akuisisi audiens baru melalui konten viral atau iklan berjalan efektif, konten tersebut gagal memicu percakapan atau loyalitas yang mendalam dari audiens yang baru bergabung. Masalah utama di sini adalah rendahnya konversi dari penonton menjadi pengikut yang aktif berinteraksi, yang berisiko membuat pertumbuhan pengikut hanya bersifat sementara. Untuk mengatasi hal ini, Anda harus segera menerapkan strategi konten berbasis komunitas seperti sesi tanya jawab atau jajak pendapat di Instagram Stories untuk meningkatkan interaksi dua arah secara langsung dengan pengikut baru tersebut.','2026-07-15 02:31:02'),(83,24,'2026-05-13','2026-06-12',4041,4279,125975,55097,5423,'2026-07-14 21:12:55','2026-07-14 21:12:55',NULL,NULL),(84,24,'2026-06-13','2026-07-12',4279,4476,69252,156897,11630,'2026-07-14 21:15:00','2026-07-14 21:15:00',NULL,NULL),(85,25,'2026-05-01','2026-05-31',34664,34701,235446,197078,8463,'2026-07-14 21:17:36','2026-07-14 21:17:36',NULL,NULL),(86,25,'2026-06-01','2026-06-30',34701,34856,263107,276134,21208,'2026-07-14 21:18:35','2026-07-14 21:18:35',NULL,NULL),(87,26,'2026-05-11','2026-06-10',10261,10453,4180,37009,480,'2026-07-14 21:20:30','2026-07-14 21:20:30',NULL,NULL),(88,26,'2026-06-11','2026-07-10',10453,10570,3815,39326,1522,'2026-07-14 21:22:11','2026-07-14 21:22:11',NULL,NULL),(89,27,'2026-05-01','2026-05-31',16375,16661,232492,466672,11267,'2026-07-14 21:25:12','2026-07-14 21:26:34',NULL,NULL),(90,27,'2026-06-01','2026-06-30',16661,16693,149175,261863,4276,'2026-07-14 21:27:33','2026-07-14 21:27:33',NULL,NULL),(91,28,'2026-05-01','2026-05-31',22136,22112,162013,155877,2293,'2026-07-14 21:29:33','2026-07-14 21:29:33',NULL,NULL),(92,28,'2026-06-01','2026-06-30',22112,22009,130887,127339,1861,'2026-07-14 21:30:30','2026-07-14 21:30:30',NULL,NULL),(93,29,'2026-05-01','2026-05-30',11958,11892,237,37752,11089,'2026-07-14 21:42:11','2026-07-14 21:43:22',NULL,NULL),(94,29,'2026-06-01','2026-06-30',11892,11824,32955,71380,11601,'2026-07-14 21:44:40','2026-07-14 21:44:40',NULL,NULL),(95,30,'2026-05-01','2026-05-31',26895,26827,29123,219722,171,'2026-07-14 21:47:23','2026-07-14 21:47:23',NULL,NULL),(96,30,'2026-06-01','2026-06-30',26827,26778,10379,34186,98,'2026-07-14 21:48:21','2026-07-14 21:48:21',NULL,NULL),(97,31,'2026-05-01','2026-05-31',7048,7098,923,3581,62,'2026-07-14 21:50:35','2026-07-14 21:50:35',NULL,NULL),(98,31,'2026-06-01','2026-06-30',7098,7050,3397,6943,262,'2026-07-14 21:51:48','2026-07-14 21:51:48',NULL,NULL),(99,32,'2026-05-01','2026-05-31',0,531,58243,137064,2252,'2026-07-14 21:53:51','2026-07-14 21:53:51',NULL,NULL),(100,32,'2026-06-01','2026-06-30',531,612,31630,69885,730,'2026-07-14 21:55:06','2026-07-14 21:55:06',NULL,NULL),(101,33,'2026-06-05','2026-07-04',3013,3259,9773,137024,1081,'2026-07-15 02:20:18','2026-07-15 02:20:18',NULL,NULL);
/*!40000 ALTER TABLE `cycles` ENABLE KEYS */;
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
-- Table structure for table `filter_summaries`
--

DROP TABLE IF EXISTS `filter_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filter_summaries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filters`)),
  `provider` varchar(255) NOT NULL,
  `custom_prompt` text DEFAULT NULL,
  `summary` longtext NOT NULL,
  `cycle_count` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filter_summaries`
--

LOCK TABLES `filter_summaries` WRITE;
/*!40000 ALTER TABLE `filter_summaries` DISABLE KEYS */;
INSERT INTO `filter_summaries` VALUES (1,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Porta Branding experienced a concerning decline in overall performance as the health score dropped from a strong BAGUS in May to a CUKUP level in June. While visibility and growth remained stagnant across both months, the primary driver of this downturn was a significant 25-point crash in engagement scores. This pattern suggests that while the brand is maintaining its reach, the content strategy in June failed to provoke meaningful interaction, risking a future decline in follower loyalty and algorithm favorability. To address this weakening engagement, the team should immediately pivot from passive broadcast posts to interactive content formats like community-driven polls or direct Q&A sessions that mirror the high-performing themes seen during the more successful May cycle. This specific shift will help convert the existing visibility back into active participation before the audience becomes completely indifferent to the brand\'s messaging.',2,'2026-07-14 02:13:19','2026-07-14 02:13:19'),(2,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Porta Branding experienced a downward shift in overall health from May to June, moving from a BAGUS rating to CUKUP as engagement quality significantly weakened. While visibility remains a strong point with high view scores, the account is struggling with a persistent weakness in follower growth, which remained stagnant at a low score of 25 across both cycles. This trend indicates that while the content successfully captures initial attention, it fails to provide a compelling reason for new viewers to stay or interact, leading to a sharp drop in engagement-per-reach. The business is currently burning through high reach without building a loyal community, which risks long-term audience fatigue. To address the weak follower conversion, the brand should replace one high-reach video per week with a \"part-one\" series of educational carousels that require following the account to see the subsequent branding tips. This specific shift targets the stagnant growth score by providing a tangible incentive for viewers to hit the follow button.',2,'2026-07-14 02:18:23','2026-07-14 02:18:23'),(3,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Performa Porta Branding mengalami penurunan kesehatan akun dari kategori BAGUS di bulan Mei menjadi CUKUP pada bulan Juni, yang dipicu oleh anjloknya skor engagement rate terhadap reach secara drastis dari 75 ke angka 25. Meskipun visibilitas dan jumlah penayangan video tetap berada di level maksimal, pertumbuhan pengikut',2,'2026-07-14 02:25:02','2026-07-14 02:25:02'),(4,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Performa Porta Branding mengalami penurunan dari kategori BAGUS di bulan Mei menjadi CUKUP pada bulan Juni, terutama dipicu oleh anjloknya skor keterlibatan audiens secara signifikan. Meskipun visibilitas konten tetap bertahan di level BAGUS, pertumbuhan pengikut secara konsisten berada di kategori KURANG dan menjadi titik terlemah yang belum menunjukkan perbaikan selama dua periode terakhir. Penurunan interaksi yang drastis ini mengindikasikan bahwa meskipun konten masih mampu menjangkau banyak orang, daya tarik atau relevansinya mulai memudar sehingga gagal memicu aksi dari audiens. Jika tren stagnasi pertumbuhan dan penurunan keterlibatan ini terus berlanjut, akun berisiko kehilangan',2,'2026-07-14 02:29:28','2026-07-14 02:29:28'),(5,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Performa akun Porta Branding menunjukkan tren penurunan dari kategori BAGUS di bulan Mei menjadi CUKUP pada bulan Juni akibat anjloknya tingkat keterlibatan audiens secara signifikan. Meskipun metrik visibilitas dan jumlah tayangan tetap bertahan di level yang sangat kuat, skor keterlibatan berdasarkan jangkauan merosot tajam ke kategori KURANG, sementara pertumbuhan pengikut konsisten berada di level rendah yang perlu diwaspadai. Fenomena ini mengindikasikan bahwa konten yang diproduksi mulai kehilangan relevansi emosional atau daya tarik interaktifnya, sehingga audiens hanya menonton secara pasif tanpa merasa perlu memberikan respons atau mengikuti akun. Implikasi bisnisnya adalah efektivitas konten dalam membangun loyalitas merek melemah, yang jika dibiarkan akan membuat jangkauan luas tersebut sia-sia karena gagal dikonversi menjadi pertumbuhan basis pelanggan yang loyal. Sebagai langkah perbaikan konkret untuk mengatasi lemahnya interaksi, Anda harus segera menerapkan format konten \"saveable\" seperti infografis strategi branding yang mendalam atau checklist teknis yang mendorong audiens untuk menyimpan postingan dan memberikan komentar untuk mendapatkan materi tambahan.',2,'2026-07-14 02:32:30','2026-07-14 02:32:30'),(6,'{\"search\":null,\"account_id\":null,\"health_label\":null,\"month\":\"2026-06\"}','gemini',NULL,'Performa media sosial di bulan Juni 2026 menunjukkan tren yang cukup bervariasi dengan rata-rata kesehatan akun sebesar 55,3. Akun Ando Boots dan UBS tampil sebagai yang terbaik dengan skor kesehatan 83,3 berkat pertumbuhan pengikut yang kuat, sementara Bibilop.id berada di posisi terendah dengan kategori kesehatan KURANG dan keterlibatan yang masuk kategori PARAH. Secara umum, kategori penayangan sangat kuat di hampir seluruh akun, namun pertumbuhan pengikut dan jangkauan masih menjadi titik lemah yang dominan. Tingginya angka penayangan yang tidak dibarengi dengan konversi pengikut atau interaksi yang dalam menandakan bahwa konten berhasil menarik perhatian sesaat namun gagal membangun loyalitas atau relevansi jangka panjang. Jika tren ini berlanjut, akun-akun tersebut hanya akan menjadi saluran distribusi konten yang lewat begitu saja tanpa membangun basis komunitas yang solid. Khusus untuk Bibilop.id yang memiliki keterlibatan paling rendah, segera ubah strategi konten dari sekadar informatif menjadi interaktif dengan menerapkan format ajakan bertindak yang eksplisit seperti kuis di kolom komentar atau polling di Stories untuk memicu respons audiens secara langsung.',11,'2026-07-14 02:42:18','2026-07-14 02:42:18'),(7,'{\"search\":null,\"account_id\":null,\"health_label\":null,\"month\":null}','gemini',NULL,'Performa media sosial di seluruh siklus menunjukkan ketimpangan yang cukup tajam, di mana Ando Boots dan UBS tampil sangat kuat sementara Bibilop.id mencatat hasil yang paling mengkhawatirkan dengan kategori keterlibatan yang berada di level parah. Secara keseluruhan, hampir semua akun berhasil mencapai skor maksimal dalam jumlah penayangan, namun sering kali gagal dalam mempertahankan jangkauan organik dan pertumbuhan pengikut yang konsisten. Fenomena tingginya angka penonton yang tidak berbanding lurus dengan interaksi ini menandakan bahwa konten mungkin cukup menarik secara visual untuk dilihat sekilas, tetapi kurang memiliki nilai relevansi atau urgensi yang mendorong audiens untuk menetap sebagai pengikut setia. Hal ini berimplikasi pada rendahnya efektivitas konversi jangka panjang karena audiens hanya sekadar lewat tanpa membangun ikatan emosional yang kuat dengan merek. Sebagai langkah perbaikan nyata untuk mengatasi lemahnya keterlibatan, tim harus segera mengimplementasikan strategi konten berbasis komunitas dengan menyertakan instruksi interaksi yang spesifik, seperti kuis singkat atau pertanyaan terbuka di setiap takarir, guna memicu audiens agar tidak hanya menonton tetapi juga aktif memberikan komentar.',12,'2026-07-14 02:42:27','2026-07-14 02:42:27'),(8,'{\"search\":null,\"account_id\":null,\"health_label\":\"BAGUS\",\"month\":\"2026-06\"}','gemini',NULL,'Performa media sosial sepanjang Juni 2026 secara keseluruhan menunjukkan tren yang positif dengan kategori BAGUS, di mana Ando Boots dan UBS mencatatkan skor kesehatan tertinggi sementara Wahyu Redjo menjadi yang terendah. Meskipun angka tayangan sangat masif, terdapat kelemahan mencolok pada kategori visibilitas, khususnya skor jangkauan atau reach rate yang berada di level PARAH untuk beberapa akun besar. Fenomena ini menandakan bahwa konten sangat efektif dalam memicu retensi atau ditonton berulang kali, namun gagal menembus audiens baru secara organik di luar lingkaran pengikut yang sudah ada. Jika ketimpangan antara jumlah tayangan dan jangkauan unik ini terus berlanjut, efektivitas kampanye akan menurun karena konten hanya berputar di audiens yang sama sehingga pertumbuhan pengikut baru terhambat. Sebagai langkah konkret untuk memperbaiki visibilitas pada akun Wahyu Redjo dan Ando Boots, tim harus segera mengimplementasikan strategi Instagram Collabs dengan mitra brand atau influencer untuk memaksa algoritma mendistribusikan konten ke basis audiens yang lebih luas dan segar.',4,'2026-07-14 02:45:29','2026-07-14 02:45:29'),(9,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Performa Porta Branding menunjukkan tren penurunan dari kategori BAGUS di bulan Mei menjadi CUKUP pada bulan Juni akibat anjloknya kualitas interaksi audiens. Meskipun angka tayangan tetap sangat tinggi, skor keterlibatan terhadap jangkauan merosot tajam dari 75 ke 25, sementara pertumbuhan pengikut tetap menjadi titik terlemah yang stagnan di level rendah selama dua periode. Hal ini menandakan bahwa konten Anda mulai kehilangan daya tarik untuk memicu aksi nyata, sehingga audiens hanya menonton secara pasif tanpa memberikan reaksi atau memutuskan untuk mengikuti akun. Kondisi ini berbahaya bagi kesehatan akun jangka panjang karena jangkauan yang luas tanpa konversi pengikut hanya akan menghasilkan pertumbuhan yang semu. Untuk memperbaikinya, Anda perlu segera menerapkan strategi konten interaktif yang mewajibkan audiens memberikan respon langsung, seperti membuat seri video \"Pilih A atau B\" atau sesi tanya-jawab teknis di kolom komentar. Fokuslah pada peningkatan interaksi dua arah ini untuk memicu konversi pengikut baru dan mengembalikan skor keterlibatan ke angka yang lebih sehat.',2,'2026-07-14 02:49:21','2026-07-14 02:49:21'),(10,'{\"search\":null,\"account_id\":null,\"health_label\":null,\"month\":\"2026-06\"}','gemini',NULL,'Performa media sosial sepanjang Juni 2026 menunjukkan dominasi pada jumlah tayangan yang sangat tinggi, namun terjebak dalam masalah pertumbuhan pengikut yang stagnan bahkan negatif di beberapa akun. Akun Ando Boots dan UBS menonjol sebagai performa terbaik dengan status BAGUS, sementara Bibilop.id menjadi titik terlemah dengan predikat KURANG akibat skor keterlibatan yang masuk kategori PARAH. Ketimpangan ini menandakan bahwa meskipun konten berhasil viral atau ditonton banyak orang, pesan yang disampaikan belum cukup kuat untuk mengonversi penonton menjadi pengikut setia. Jika retensi pengikut terus menurun seperti yang terlihat pada akun BHC, efektivitas jangkauan organik di masa depan akan terancam karena hilangnya basis audiens inti. Untuk mengatasi masalah ini, fokus utama harus diarahkan pada perbaikan interaksi di akun Bibilop.id melalui strategi ajakan bertindak yang lebih agresif, seperti mengadakan kuis interaktif atau diskusi di kolom komentar untuk menghidupkan kembali tingkat keterlibatan yang saat ini sedang mati suri.',11,'2026-07-14 02:55:25','2026-07-14 02:55:25'),(11,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Performa Porta Branding menunjukkan tren penurunan dari kategori BAGUS pada bulan Mei menjadi CUKUP di bulan Juni yang dipicu oleh anjloknya efektivitas interaksi secara signifikan. Meskipun jumlah tayangan video masih tergolong sangat kuat dengan skor maksimal, skor Engagement Rate of Reach merosot tajam ke level PARAH yang menandakan audiens hanya menonton tanpa memberikan respons aktif seperti suka, komentar, atau simpan. Kondisi ini mengindikasikan bahwa konten Anda mulai kehilangan daya pikat atau relevansi yang mendorong aksi, sehingga potensi konversi menjadi pengikut baru tetap stagnan di angka yang rendah selama dua periode berturut-turut. Jika interaksi pasif ini dibiarkan, algoritma akan membaca konten Anda sebagai kurang menarik dan berisiko menurunkan visibilitas akun secara keseluruhan di masa depan. Sebagai langkah konkret untuk memperbaiki area terlemah, Anda harus segera menerapkan strategi konten \"save-able\" atau edukasi mendalam yang diakhiri dengan pertanyaan terbuka yang spesifik guna memancing diskusi di kolom komentar dan meningkatkan skor interaksi yang saat ini sedang jatuh.',2,'2026-07-14 02:57:18','2026-07-14 02:57:18'),(12,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month\":null}','gemini',NULL,'Performa Porta Branding menunjukkan tren fluktuatif dengan puncak kejayaan pada bulan Mei sebelum akhirnya mengalami penurunan efektivitas di bulan Juni. Meskipun aspek visibilitas seperti jumlah tayangan tetap konsisten di kategori BAGUS, tingkat interaksi terhadap jangkauan atau ER-of-reach merosot tajam kembali ke level CUKUP pada periode terakhir. Penurunan ini mengindikasikan bahwa meskipun konten masih mampu menjangkau audiens yang luas, materi yang disajikan di bulan Juni gagal memicu ketertarikan atau relevansi yang cukup untuk menghasilkan aksi dari audiens. Jika ketimpangan antara jangkauan yang luas dan interaksi yang rendah ini terus berlanjut, akun berisiko mengalami penurunan distribusi organik karena algoritma akan menilai konten tersebut kurang berharga bagi pengguna. Sebagai langkah konkret untuk memperbaiki skor interaksi yang lemah, tim harus melakukan audit konten terhadap postingan bulan Mei yang sukses dan mulai memprioritaskan format \"saveable content\" seperti infografis strategi branding yang memberikan nilai edukasi praktis bagi audiens.',3,'2026-07-14 03:02:26','2026-07-14 03:02:26'),(13,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month_from\":\"2026-04\",\"month_to\":\"2026-07\"}','gemini',NULL,'Performa Porta Branding menunjukkan tren fluktuatif dengan puncak kejayaan pada bulan Mei sebelum akhirnya menurun kembali di bulan Juni, terutama pada aspek keterlibatan audiens. Meskipun visibilitas konten tetap berada di kategori BAGUS berkat jumlah tayangan yang tinggi, pertumbuhan pengikut dan rasio interaksi terhadap jangkauan masih tergolong lemah atau berada di level CUKUP. Hal ini mengindikasikan bahwa konten Anda berhasil menjangkau banyak orang namun gagal membangun loyalitas atau memicu percakapan yang mendalam, sehingga pertumbuhan akun menjadi stagnan. Kondisi ini cukup berisiko bagi keberlanjutan merek karena audiens hanya sekadar melihat konten tanpa merasa terikat dengan identitas Porta Branding. Untuk mengatasi rendahnya skor interaksi ini, Anda perlu segera menerapkan strategi konten interaktif seperti penggunaan fitur jajak pendapat atau sesi tanya jawab di Stories yang secara spesifik dirancang untuk memancing respon langsung dari audiens.',3,'2026-07-14 18:28:39','2026-07-14 18:28:39'),(14,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month_from\":null,\"month_to\":null}','gemini',NULL,'Performa Porta Branding menunjukkan tren fluktuatif yang mencapai puncaknya pada bulan Mei namun kembali mengalami penurunan efektivitas keterlibatan di bulan Juni. Meskipun aspek visibilitas dan jumlah tayangan konsisten berada di level BAGUS, pertumbuhan pengikut tetap menjadi kategori yang paling lemah karena skornya stagnan di level rendah. Kondisi ini menandakan bahwa konten Anda memiliki daya tarik visual yang luas tetapi belum mampu membangun ikatan emosional atau memberikan alasan kuat bagi penonton untuk menekan tombol ikuti. Penurunan drastis pada rasio keterlibatan di siklus terakhir menunjukkan bahwa strategi konten saat ini mulai kehilangan relevansinya dalam memicu aksi dari audiens yang dijangkau. Sebagai langkah perbaikan konkret, Anda harus mulai memproduksi konten edukasi atau bercerita yang diakhiri dengan ajakan bertindak (CTA) spesifik yang menawarkan nilai eksklusif bagi pengikut baru guna meningkatkan tingkat konversi dari penonton menjadi komunitas aktif.',3,'2026-07-14 18:53:39','2026-07-14 18:53:39'),(15,'{\"search\":null,\"account_id\":10,\"health_label\":null,\"month_from\":null,\"month_to\":null}','groq',NULL,'Tren keseluruhan menunjukkan peningkatan kesehatan akun Porta Branding seiring waktu, dengan siklus Mei 2026 menjadi yang terbaik dan siklus April 2026 menjadi yang terlemah. Kategori visibilitas dan engagement menunjukkan skor yang kuat, terutama pada siklus Mei 2026 dengan skor BAGUS. Namun, kategori kesehatan masih menunjukkan skor CUKUP, yang menunjukkan adanya kelemahan. \n\nHal ini penting karena menunjukkan bahwa strategi pemasaran yang diterapkan pada siklus Mei 2026 efektif dalam meningkatkan visibilitas dan engagement, tetapi masih perlu ditingkatkan untuk mencapai kesehatan akun yang lebih baik. Penurunan skor engagement pada siklus Juni 2026 juga menunjukkan bahwa perlu dilakukan evaluasi untuk memahami penyebab penurunan tersebut.\n\nUntuk meningkatkan kesehatan akun, disarankan untuk menganalisis konten yang diposting pada siklus Mei 2026 dan menerapkan strategi serupa pada siklus mendatang, terutama dalam hal engagement. Salah satu rekomendasi konkrit adalah membuat konten yang lebih interaktif dan menarik untuk meningkatkan engagement, seperti membuat pertanyaan atau poll yang meminta pengikut untuk berpartisipasi, sehingga dapat meningkatkan skor engagement dan kesehatan akun secara keseluruhan.',3,'2026-07-14 21:27:03','2026-07-14 21:27:03');
/*!40000 ALTER TABLE `filter_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `formula_weights`
--

DROP TABLE IF EXISTS `formula_weights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `formula_weights` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `aggregate` varchar(255) NOT NULL,
  `component` varchar(255) NOT NULL,
  `weight` decimal(6,4) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `formula_weights_aggregate_component_unique` (`aggregate`,`component`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `formula_weights`
--

LOCK TABLES `formula_weights` WRITE;
/*!40000 ALTER TABLE `formula_weights` DISABLE KEYS */;
INSERT INTO `formula_weights` VALUES (1,'visibility','reach_score',0.5000,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(2,'visibility','view_score',0.5000,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(3,'engagement','er_reach_score',0.5000,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(4,'engagement','er_follower_score',0.5000,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(5,'health','growth_score',0.3333,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(6,'health','visibility_rate',0.3333,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(7,'health','engagement_score',0.3333,'2026-07-09 19:40:50','2026-07-09 19:40:50');
/*!40000 ALTER TABLE `formula_weights` ENABLE KEYS */;
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
-- Table structure for table `label_buckets`
--

DROP TABLE IF EXISTS `label_buckets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `label_buckets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `metric` varchar(255) NOT NULL,
  `min_score` decimal(6,2) DEFAULT NULL,
  `label` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `label_buckets_metric_min_score_index` (`metric`,`min_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `label_buckets`
--

LOCK TABLES `label_buckets` WRITE;
/*!40000 ALTER TABLE `label_buckets` DISABLE KEYS */;
INSERT INTO `label_buckets` VALUES (1,'visibility',100.00,'SIP','2026-07-09 19:40:50','2026-07-09 19:40:50'),(2,'visibility',75.00,'BAGUS','2026-07-09 19:40:50','2026-07-09 19:40:50'),(3,'visibility',50.00,'CUKUP','2026-07-09 19:40:50','2026-07-09 19:40:50'),(4,'visibility',25.00,'KURANG','2026-07-09 19:40:50','2026-07-09 19:40:50'),(5,'visibility',NULL,'PARAH','2026-07-09 19:40:50','2026-07-09 19:40:50'),(6,'engagement',100.00,'SIP','2026-07-09 19:40:50','2026-07-09 19:40:50'),(7,'engagement',75.00,'BAGUS','2026-07-09 19:40:50','2026-07-09 19:40:50'),(8,'engagement',50.00,'CUKUP','2026-07-09 19:40:50','2026-07-09 19:40:50'),(9,'engagement',25.00,'KURANG','2026-07-09 19:40:50','2026-07-09 19:40:50'),(10,'engagement',NULL,'PARAH','2026-07-09 19:40:50','2026-07-09 19:40:50'),(11,'health',85.00,'SIP','2026-07-09 19:40:50','2026-07-09 19:40:50'),(12,'health',60.00,'BAGUS','2026-07-09 19:40:50','2026-07-09 19:40:50'),(13,'health',40.00,'CUKUP','2026-07-09 19:40:50','2026-07-09 19:40:50'),(14,'health',10.00,'KURANG','2026-07-09 19:40:50','2026-07-09 19:40:50'),(15,'health',NULL,'PARAH','2026-07-09 19:40:50','2026-07-09 19:40:50');
/*!40000 ALTER TABLE `label_buckets` ENABLE KEYS */;
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
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_07_09_072823_create_accounts_table',1),(5,'2026_07_09_072823_create_cycles_table',1),(6,'2026_07_09_074626_create_score_buckets_table',1),(7,'2026_07_09_091538_create_label_buckets_table',1),(8,'2026_07_10_020949_create_formula_weights_table',1),(9,'2026_07_10_093019_add_ai_summary_to_cycles_table',2),(10,'2026_07_14_090513_create_filter_summaries_table',3),(11,'2026_07_15_015942_add_ai_summary_to_accounts_table',4);
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
-- Table structure for table `score_buckets`
--

DROP TABLE IF EXISTS `score_buckets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `score_buckets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `metric` varchar(255) NOT NULL,
  `min_rate` decimal(8,2) DEFAULT NULL,
  `score` decimal(5,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `score_buckets_metric_min_rate_index` (`metric`,`min_rate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `score_buckets`
--

LOCK TABLES `score_buckets` WRITE;
/*!40000 ALTER TABLE `score_buckets` DISABLE KEYS */;
INSERT INTO `score_buckets` VALUES (1,'growth',10.00,100.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(2,'growth',7.00,75.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(3,'growth',3.00,50.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(4,'growth',1.00,25.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(5,'growth',NULL,0.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(6,'reach',5000.00,100.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(7,'reach',2000.00,75.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(8,'reach',1000.00,50.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(9,'reach',500.00,25.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(10,'reach',NULL,0.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(11,'view',500.00,100.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(12,'view',400.00,75.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(13,'view',200.00,50.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(14,'view',100.00,25.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(15,'view',NULL,0.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(16,'er_reach',5.00,100.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(17,'er_reach',3.50,75.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(18,'er_reach',1.50,50.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(19,'er_reach',0.50,25.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(20,'er_reach',NULL,0.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(21,'er_follower',5.00,100.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(22,'er_follower',3.00,75.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(23,'er_follower',2.00,50.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(24,'er_follower',1.00,25.00,'2026-07-09 19:40:50','2026-07-09 19:40:50'),(25,'er_follower',NULL,0.00,'2026-07-09 19:40:50','2026-07-09 19:40:50');
/*!40000 ALTER TABLE `score_buckets` ENABLE KEYS */;
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
INSERT INTO `sessions` VALUES ('7fEh7Dw7cusKFUudPhGhL6HlvCY5c2ga9V8bcNvR',NULL,'192.168.1.250','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoickJuRHA4cUM4RnJTSEVNRmRvYVlWeUhhcFhGc0cybmwxWjg1OVlTOSI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozNDoiaHR0cDovLzE5Mi4xNjguMS4yMDA6ODAwMC9hY2NvdW50cyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1784106478),('hec9tGIxozqFmtu0cfpoY6ByFw9mX7PEtiXukR06',1,'192.168.1.250','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiUnpjM0tnWUVKRjJidTlDUnpudjZLTVRyR1lPVGs3VERQMmtBMmIxdyI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjc1OiJodHRwOi8vMTkyLjE2OC4xLjIwMDo4MDAwL2FjY291bnRzLzE1L25laWdoYm9yaW5nLWN5Y2xlP2VuZF9kYXRlPTIwMjYtMDctMzEiO3M6NToicm91dGUiO3M6MTg6ImN5Y2xlcy5uZWlnaGJvcmluZyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1784091642),('P0WgLR9iCGUYrVixgHjJQfrFkef7kGyDv3n4ei7N',1,'192.168.1.250','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiaU5ZR29kV1ExRG9uVEZNR21Xc25VMkxXVVpLM0FmTDFIcnVJbmUyTCI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjc1OiJodHRwOi8vMTkyLjE2OC4xLjIwMDo4MDAwL2FjY291bnRzLzMzL25laWdoYm9yaW5nLWN5Y2xlP2VuZF9kYXRlPTIwMjYtMDctMDQiO3M6NToicm91dGUiO3M6MTg6ImN5Y2xlcy5uZWlnaGJvcmluZyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1784107218),('Sa4bgKhatIfsX7RswA1DPPJLt6hawYmL6QigFzDm',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiZVdCR3NGZWZ5amtxckUyNE9mMGU2REpiTTJLc09QY2lHdFZ5d0JINyI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjczOiJodHRwOi8vbG9jYWxob3N0OjgwMDAvYWNjb3VudHMvMTAvbmVpZ2hib3JpbmctY3ljbGU/c3RhcnRfZGF0ZT0yMDI2LTAxLTAxIjtzOjU6InJvdXRlIjtzOjE4OiJjeWNsZXMubmVpZ2hib3JpbmciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToxO30=',1784097090),('zbwkfz3tcoC62V51adqXO9rsvHnw3EU70wGZsJ8q',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiN2MwcnVvN2Y0QksxY1ZkSklqdllVYVBUMmV0aFBOS0NsU0s2WnRKWCI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjM5OiJodHRwOi8vbG9jYWxob3N0OjgwMDAvYWNjb3VudHMvOS9ncm93dGgiO3M6NToicm91dGUiO3M6MTU6ImFjY291bnRzLmdyb3d0aCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1784108165);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
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
INSERT INTO `users` VALUES (1,'Test User','test@example.com','2026-07-09 19:40:50','$2y$12$XZzA8ZQY4duTsRTE0QgK1uMUk/Fh0kn32zbOtXbCqWZwN6O9Taara','ovHFBTKOrR','2026-07-09 19:40:50','2026-07-09 19:40:50');
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

-- Dump completed on 2026-07-15 22:53:05
