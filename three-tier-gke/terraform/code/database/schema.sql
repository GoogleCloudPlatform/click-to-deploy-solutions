-- Copyright 2023 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

CREATE DATABASE IF NOT EXISTS todo;

USE todo;

DROP TABLE IF EXISTS `todo`;

CREATE TABLE `todo` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(512) DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `completed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `todo` WRITE;
/*!40000 ALTER TABLE `todo` DISABLE KEYS */;

INSERT INTO `todo` (`id`, `title`, `updated`, `completed`)
VALUES
  (1,'Install and configure todo app','2021-10-28 12:00:00','2021-10-28 12:00:00'),
	(2,'Add your own todo','2021-10-28 12:00:00',NULL),
	(3,'Mark task 1 done','2021-10-27 14:26:00',NULL);

/*!40000 ALTER TABLE `todo` ENABLE KEYS */;
UNLOCK TABLES;

CREATE USER 'todo_user'@'localhost' IDENTIFIED BY 'todo_pass';
CREATE USER 'todo_user'@'%' IDENTIFIED BY 'todo_pass';

GRANT ALL ON todo.* TO 'todo_user'@'localhost';
GRANT ALL ON todo.* TO 'todo_user'@'%';