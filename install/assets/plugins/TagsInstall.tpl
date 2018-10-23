//<?php
/**
 * TagsInstall
 *
 * Tags installer
 *
 * @category    plugin
 * @internal    @events OnWebPageInit,OnManagerPageInit,OnPageNotFound
 * @internal    @installset base
*/

$modx->clearCache('full');

$modx->db->query("
    CREATE TABLE IF NOT EXISTS " . $modx->getFullTablename('site_content_tags') . " (
        `doc_id` int(11) NOT NULL,
        `tag_id` int(11) NOT NULL,
        `tv_id` int(11) NOT NULL DEFAULT '0',
        PRIMARY KEY (`tag_id`,`doc_id`,`tv_id`),
        UNIQUE KEY `dtt` (`doc_id`,`tag_id`,`tv_id`) USING BTREE,
        KEY `doc_id` (`doc_id`),
        KEY `tag_id` (`tag_id`),
        KEY `tv_id` (`tv_id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
");

$modx->db->query("
    CREATE TABLE IF NOT EXISTS " . $modx->getFullTablename('tags') . " (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `name` varchar(50) NOT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `name` (`name`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
");

// remove installer
$site_plugins = $modx->getFullTablename('site_plugins');
$site_plugin_events = $modx->getFullTablename('site_plugin_events');

$query = $modx->db->select('id', $site_plugins, "`name` = '" . $modx->Event->activePlugin . "'");

if ($id = $modx->db->getValue($query)) {
   $modx->db->delete($site_plugins, "`id` = '$id'");
   $modx->db->delete($site_plugin_events, "`pluginid` = '$id'");
};
