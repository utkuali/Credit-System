CREATE TABLE `credit` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `amount` int(11) NOT NULL DEFAULT "0",

  PRIMARY KEY (`id`) USING BTREE
)