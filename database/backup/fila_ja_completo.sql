CREATE DATABASE  IF NOT EXISTS `fila_ja` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `fila_ja`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: fila_ja
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `atendimentos`
--

DROP TABLE IF EXISTS `atendimentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atendimentos` (
  `id_atendimento` int NOT NULL,
  `id_fila` int NOT NULL,
  `id_usuario` int NOT NULL,
  `data_inicio` datetime DEFAULT NULL,
  `data_fim` datetime DEFAULT NULL,
  `observacoes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id_atendimento`),
  UNIQUE KEY `id_fila` (`id_fila`),
  KEY `fk_atendimentos_usuario` (`id_usuario`),
  CONSTRAINT `fk_atendimentos_fila` FOREIGN KEY (`id_fila`) REFERENCES `fila` (`id_fila`),
  CONSTRAINT `fk_atendimentos_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `atendimentos`
--

LOCK TABLES `atendimentos` WRITE;
/*!40000 ALTER TABLE `atendimentos` DISABLE KEYS */;
INSERT INTO `atendimentos` VALUES (1,1,4,'2026-11-03 14:08:57','2026-11-03 14:10:37',NULL),(2,2,4,'2026-11-03 14:14:57','2026-11-03 14:15:08',NULL),(3,4,4,'2026-11-03 14:59:21','2026-11-03 14:59:21',NULL);
/*!40000 ALTER TABLE `atendimentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fila`
--

DROP TABLE IF EXISTS `fila`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fila` (
  `id_fila` int NOT NULL,
  `id_paciente` int NOT NULL,
  `id_ubs` int NOT NULL,
  `id_servico` int NOT NULL,
  `id_usuario` int NOT NULL,
  `senha` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_entrada` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('AGUARDANDO','CHAMADO','EM_ATENDIMENTO','FINALIZADO','CANCELADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AGUARDANDO',
  PRIMARY KEY (`id_fila`),
  UNIQUE KEY `id_ubs` (`id_ubs`,`senha`),
  KEY `fk_fila_paciente` (`id_paciente`),
  KEY `fk_fila_usuario` (`id_usuario`),
  KEY `idx_fila_ubs_servico_status` (`id_ubs`,`id_servico`,`status`),
  KEY `idx_fila_data_entrada` (`data_entrada`),
  CONSTRAINT `fk_fila_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `pacientes` (`id_paciente`),
  CONSTRAINT `fk_fila_ubs_servico` FOREIGN KEY (`id_ubs`, `id_servico`) REFERENCES `ubs_servico` (`id_ubs`, `id_servico`),
  CONSTRAINT `fk_fila_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fila`
--

LOCK TABLES `fila` WRITE;
/*!40000 ALTER TABLE `fila` DISABLE KEYS */;
INSERT INTO `fila` VALUES (1,2,2,2,4,'A001','2026-11-03 13:59:41','FINALIZADO'),(2,3,2,3,4,'A002','2026-11-03 13:59:41','FINALIZADO'),(3,4,3,4,4,'B001','2026-11-03 13:59:41','CHAMADO'),(4,5,3,5,4,'B002','2026-11-03 13:59:41','FINALIZADO'),(5,6,2,6,4,'A003','2026-11-03 13:59:41','CHAMADO');
/*!40000 ALTER TABLE `fila` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_historico_status_fila` AFTER UPDATE ON `fila` FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO historico_fila (
            id_historico,
            id_fila,
            id_usuario,
            status_anterior,
            status_novo
        )
        VALUES (
            gerar_id('historico_fila'),
            NEW.id_fila,
            NEW.id_usuario,
            OLD.status,
            NEW.status
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_iniciar_atendimento` AFTER UPDATE ON `fila` FOR EACH ROW BEGIN
    IF OLD.status <> 'EM_ATENDIMENTO'
       AND NEW.status = 'EM_ATENDIMENTO' THEN

        INSERT INTO atendimentos (
            id_atendimento,
            id_fila,
            id_usuario,
            data_inicio
        )
        VALUES (
            gerar_id('atendimentos'),
            NEW.id_fila,
            NEW.id_usuario,
            CURRENT_TIMESTAMP
        );

    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_finalizar_atendimento` AFTER UPDATE ON `fila` FOR EACH ROW BEGIN
    IF OLD.status <> 'FINALIZADO'
       AND NEW.status = 'FINALIZADO' THEN

        UPDATE atendimentos
        SET data_fim = CURRENT_TIMESTAMP
        WHERE id_fila = NEW.id_fila;

    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `grupos_usuarios`
--

DROP TABLE IF EXISTS `grupos_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grupos_usuarios` (
  `id_grupo` int NOT NULL,
  `nome` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_grupo`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupos_usuarios`
--

LOCK TABLES `grupos_usuarios` WRITE;
/*!40000 ALTER TABLE `grupos_usuarios` DISABLE KEYS */;
INSERT INTO `grupos_usuarios` VALUES (1,'Administrador','Acesso completo ao sistema'),(2,'Atendente','Responsável pelo cadastro e gerenciamento da fila'),(3,'Profissional de Saúde','Responsável pela realização dos atendimentos');
/*!40000 ALTER TABLE `grupos_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historico_fila`
--

DROP TABLE IF EXISTS `historico_fila`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historico_fila` (
  `id_historico` int NOT NULL,
  `id_fila` int NOT NULL,
  `id_usuario` int NOT NULL,
  `status_anterior` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_novo` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_alteracao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_historico`),
  KEY `fk_historico_fila` (`id_fila`),
  KEY `fk_historico_usuario` (`id_usuario`),
  CONSTRAINT `fk_historico_fila` FOREIGN KEY (`id_fila`) REFERENCES `fila` (`id_fila`),
  CONSTRAINT `fk_historico_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historico_fila`
--

LOCK TABLES `historico_fila` WRITE;
/*!40000 ALTER TABLE `historico_fila` DISABLE KEYS */;
INSERT INTO `historico_fila` VALUES (1,1,4,'AGUARDANDO','CHAMADO','2026-11-03 14:07:27'),(2,1,4,'CHAMADO','EM_ATENDIMENTO','2026-11-03 14:08:57'),(3,1,4,'EM_ATENDIMENTO','FINALIZADO','2026-11-03 14:10:37'),(4,2,4,'AGUARDANDO','CHAMADO','2026-11-03 14:13:42'),(5,2,4,'CHAMADO','EM_ATENDIMENTO','2026-11-03 14:14:57'),(6,2,4,'EM_ATENDIMENTO','FINALIZADO','2026-11-03 14:15:08'),(7,3,4,'AGUARDANDO','CHAMADO','2026-11-03 14:22:54'),(8,4,4,'AGUARDANDO','EM_ATENDIMENTO','2026-11-03 14:59:21'),(9,4,4,'EM_ATENDIMENTO','FINALIZADO','2026-11-03 14:59:21'),(10,5,4,'AGUARDANDO','CHAMADO','2026-11-03 15:04:42');
/*!40000 ALTER TABLE `historico_fila` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pacientes`
--

DROP TABLE IF EXISTS `pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pacientes` (
  `id_paciente` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cpf` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_nascimento` date NOT NULL,
  `telefone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_cadastro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_paciente`),
  UNIQUE KEY `cpf` (`cpf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pacientes`
--

LOCK TABLES `pacientes` WRITE;
/*!40000 ALTER TABLE `pacientes` DISABLE KEYS */;
INSERT INTO `pacientes` VALUES (2,'João Silva','12345678901','1990-05-15','(61) 99911-1111','joao@email.com','2026-11-03 13:58:22'),(3,'Maria Oliveira','23456789012','1985-08-22','(61) 99922-2222','maria@email.com','2026-11-03 13:58:22'),(4,'Carlos Santos','34567890123','2015-03-10','(61) 99933-3333','carlos@email.com','2026-11-03 13:58:22'),(5,'Ana Souza','45678901234','1978-11-30','(61) 99944-4444','ana@email.com','2026-11-03 13:58:22'),(6,'Pedro Costa','56789012345','2002-01-05','(61) 99955-5555','pedro@email.com','2026-11-03 13:58:22');
/*!40000 ALTER TABLE `pacientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sequencias`
--

DROP TABLE IF EXISTS `sequencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sequencias` (
  `entidade` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `proximo_id` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`entidade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sequencias`
--

LOCK TABLES `sequencias` WRITE;
/*!40000 ALTER TABLE `sequencias` DISABLE KEYS */;
INSERT INTO `sequencias` VALUES ('atendimentos',4),('fila',6),('historico_fila',11),('pacientes',7),('servicos',7),('ubs',4),('usuarios',6);
/*!40000 ALTER TABLE `sequencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicos`
--

DROP TABLE IF EXISTS `servicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicos` (
  `id_servico` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_servico`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicos`
--

LOCK TABLES `servicos` WRITE;
/*!40000 ALTER TABLE `servicos` DISABLE KEYS */;
INSERT INTO `servicos` VALUES (2,'Clínica Geral','Consultas médicas de clínica geral',1),(3,'Pediatria','Atendimento médico infantil',1),(4,'Vacinação','Aplicação de vacinas',1),(5,'Odontologia','Atendimento odontológico',1),(6,'Enfermagem','Procedimentos e consultas de enfermagem',1);
/*!40000 ALTER TABLE `servicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubs`
--

DROP TABLE IF EXISTS `ubs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubs` (
  `id_ubs` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `endereco` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_ubs`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubs`
--

LOCK TABLES `ubs` WRITE;
/*!40000 ALTER TABLE `ubs` DISABLE KEYS */;
INSERT INTO `ubs` VALUES (2,'UBS Asa Sul','Asa Sul, Brasília - DF','(61) 3333-1000',1),(3,'UBS Águas Claras','Águas Claras, Brasília - DF','(61) 3333-2000',1);
/*!40000 ALTER TABLE `ubs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubs_servico`
--

DROP TABLE IF EXISTS `ubs_servico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubs_servico` (
  `id_ubs` int NOT NULL,
  `id_servico` int NOT NULL,
  PRIMARY KEY (`id_ubs`,`id_servico`),
  KEY `fk_ubs_servico_servicos` (`id_servico`),
  CONSTRAINT `fk_ubs_servico_servicos` FOREIGN KEY (`id_servico`) REFERENCES `servicos` (`id_servico`),
  CONSTRAINT `fk_ubs_servico_ubs` FOREIGN KEY (`id_ubs`) REFERENCES `ubs` (`id_ubs`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubs_servico`
--

LOCK TABLES `ubs_servico` WRITE;
/*!40000 ALTER TABLE `ubs_servico` DISABLE KEYS */;
INSERT INTO `ubs_servico` VALUES (2,2),(3,2),(2,3),(3,3),(2,4),(3,4),(2,5),(3,5),(2,6),(3,6);
/*!40000 ALTER TABLE `ubs_servico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_grupo` int NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_usuarios_grupos` (`id_grupo`),
  CONSTRAINT `fk_usuarios_grupos` FOREIGN KEY (`id_grupo`) REFERENCES `grupos_usuarios` (`id_grupo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (3,'Administrador do Sistema','admin@filaja.com','senha_hash_admin',1,1),(4,'Atendente UBS','atendente@filaja.com','senha_hash_atendente',2,1),(5,'Profissional de Saúde','profissional@filaja.com','senha_hash_profissional',3,1);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_atendimentos`
--

DROP TABLE IF EXISTS `vw_atendimentos`;
/*!50001 DROP VIEW IF EXISTS `vw_atendimentos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_atendimentos` AS SELECT 
 1 AS `id_atendimento`,
 1 AS `paciente`,
 1 AS `ubs`,
 1 AS `servico`,
 1 AS `profissional`,
 1 AS `data_inicio`,
 1 AS `data_fim`,
 1 AS `observacoes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_fila_atendimento`
--

DROP TABLE IF EXISTS `vw_fila_atendimento`;
/*!50001 DROP VIEW IF EXISTS `vw_fila_atendimento`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_fila_atendimento` AS SELECT 
 1 AS `id_fila`,
 1 AS `senha`,
 1 AS `paciente`,
 1 AS `ubs`,
 1 AS `servico`,
 1 AS `status`,
 1 AS `data_entrada`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'fila_ja'
--

--
-- Dumping routines for database 'fila_ja'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_contar_fila` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_contar_fila`(
    p_id_ubs INT,
    p_id_servico INT
) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
    INTO v_total
    FROM fila
    WHERE id_ubs = p_id_ubs
      AND id_servico = p_id_servico
      AND status = 'AGUARDANDO';

    RETURN v_total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tempo_espera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_tempo_espera`(p_id_fila INT) RETURNS int
    READS SQL DATA
BEGIN
    DECLARE v_tempo INT;

    SELECT TIMESTAMPDIFF(
        MINUTE,
        data_entrada,
        CURRENT_TIMESTAMP
    )
    INTO v_tempo
    FROM fila
    WHERE id_fila = p_id_fila;

    RETURN v_tempo;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `gerar_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `gerar_id`(p_entidade VARCHAR(50)) RETURNS int
    MODIFIES SQL DATA
BEGIN
    UPDATE sequencias
    SET proximo_id = LAST_INSERT_ID(proximo_id + 1)
    WHERE entidade = p_entidade;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Entidade não encontrada';
    END IF;

    RETURN LAST_INSERT_ID() - 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_chamar_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_chamar_paciente`(
    IN p_id_ubs INT,
    IN p_id_servico INT
)
BEGIN
    DECLARE v_id_fila INT DEFAULT NULL;

    SELECT id_fila
    INTO v_id_fila
    FROM fila
    WHERE id_ubs = p_id_ubs
      AND id_servico = p_id_servico
      AND status = 'AGUARDANDO'
    ORDER BY data_entrada ASC, id_fila ASC
    LIMIT 1;

    IF v_id_fila IS NULL THEN
        SELECT 'Não existem pacientes aguardando.' AS mensagem;
    ELSE
        UPDATE fila
        SET status = 'CHAMADO'
        WHERE id_fila = v_id_fila;

        SELECT
            f.id_fila,
            f.senha,
            p.nome AS paciente,
            u.nome AS ubs,
            s.nome AS servico,
            f.status
        FROM fila f
        INNER JOIN pacientes p ON f.id_paciente = p.id_paciente
        INNER JOIN ubs u ON f.id_ubs = u.id_ubs
        INNER JOIN servicos s ON f.id_servico = s.id_servico
        WHERE f.id_fila = v_id_fila;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_finalizar_atendimento` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_finalizar_atendimento`(
    IN p_id_fila INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM atendimentos
        WHERE id_fila = p_id_fila
          AND data_fim IS NULL
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atendimento não encontrado ou já finalizado';

    ELSE

        UPDATE fila
        SET status = 'FINALIZADO'
        WHERE id_fila = p_id_fila;

    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_atendimentos`
--

/*!50001 DROP VIEW IF EXISTS `vw_atendimentos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_atendimentos` AS select `a`.`id_atendimento` AS `id_atendimento`,`p`.`nome` AS `paciente`,`u`.`nome` AS `ubs`,`s`.`nome` AS `servico`,`us`.`nome` AS `profissional`,`a`.`data_inicio` AS `data_inicio`,`a`.`data_fim` AS `data_fim`,`a`.`observacoes` AS `observacoes` from (((((`atendimentos` `a` join `fila` `f` on((`a`.`id_fila` = `f`.`id_fila`))) join `pacientes` `p` on((`f`.`id_paciente` = `p`.`id_paciente`))) join `ubs` `u` on((`f`.`id_ubs` = `u`.`id_ubs`))) join `servicos` `s` on((`f`.`id_servico` = `s`.`id_servico`))) join `usuarios` `us` on((`a`.`id_usuario` = `us`.`id_usuario`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_fila_atendimento`
--

/*!50001 DROP VIEW IF EXISTS `vw_fila_atendimento`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_fila_atendimento` AS select `f`.`id_fila` AS `id_fila`,`f`.`senha` AS `senha`,`p`.`nome` AS `paciente`,`u`.`nome` AS `ubs`,`s`.`nome` AS `servico`,`f`.`status` AS `status`,`f`.`data_entrada` AS `data_entrada` from (((`fila` `f` join `pacientes` `p` on((`f`.`id_paciente` = `p`.`id_paciente`))) join `ubs` `u` on((`f`.`id_ubs` = `u`.`id_ubs`))) join `servicos` `s` on((`f`.`id_servico` = `s`.`id_servico`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-03 15:59:21
