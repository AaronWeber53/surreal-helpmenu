CREATE TABLE IF NOT EXISTS `feature_requests` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `license` varchar(50) DEFAULT NULL,
    `citizenid` varchar(50) DEFAULT NULL,
    `discord` varchar(50) DEFAULT NULL,
    `type` varchar(1) DEFAULT NULL,
    `contact` varchar(50) DEFAULT NULL,
    `summary` varchar(50) DEFAULT NULL,
    `information` varchar(500) DEFAULT NULL,
    `response_contact` varchar(50) DEFAULT NULL,
    `response_value` varchar(10) DEFAULT 'InProgress',
    `response_reason` varchar(500) DEFAULT NULL,
    `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=1;