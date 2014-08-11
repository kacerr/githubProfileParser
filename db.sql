create table working_queue (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`handle` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
	`status` int(11) default 0,
	PRIMARY KEY (`id`),
	UNIQUE KEY `unique_handle` (`handle`)
);


create table contacts (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`handle` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
	`works_for` varchar(255),
	`home_location` varchar(255),
	`email` varchar(255),
	`url` varchar(255),
	`created_at` datetime,
	UNIQUE KEY `unique_handle` (`handle`),
	PRIMARY KEY (`id`)	
);