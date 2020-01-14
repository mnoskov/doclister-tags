//<?php
/**
 * TagSaver
 *
 * @category    plugin,DocLister
 * @version     0.2
 * @license     GNU General Public License (GPL), http://www.gnu.org/copyleft/gpl.html
 * @internal    @properties &tv=ID TV-параметра;input; &sep=Разделитель тегов;input;,
 * @internal    @events  OnDocFormSave
 * @internal    @modx_category Manager and Admin
 * @author      Agel_Nash <Agel_Nash@xaker.ru>
 */

if ($modx->event->name == 'OnDocFormSave') {
    $id   = (int) $modx->event->params['id'];
    $tv   = isset($tv) ? (int) $tv : 0;
    $sep  = isset($sep) ? $sep : "";
    $item = array();
    $out  = array('new' => array(), 'del' => array());

    $tables = array(
        'site_tmplvar_contentvalues' => $modx->getFullTableName("site_tmplvar_contentvalues"),
        'tags' => $modx->getFullTableName("tags"),
        'site_content_tags' => $modx->getFullTableName("site_content_tags"),
    );

    if ($tv > 0 && $id > 0) {
        $sql = "SELECT value FROM " . $tables['site_tmplvar_contentvalues'] . " WHERE contentid='" . $id . "' AND tmplvarid = " . $tv;
        $sql = $modx->db->query($sql);

        if ($modx->db->getRecordCount($sql) == 1) {
            $sql = $modx->db->getValue($sql);
            $item = ($sep != '') ? explode($sep, $sql) : array($sql);

            foreach ($item as $tmp) {
                $tmp = trim($tmp);
                if ($tmp != '') {
                    $out['new'][] = $modx->db->escape($tmp);
                }
            }

            if (count($out['new']) > 0) {
                $keys = implode("'),('", array_values($out['new']));
                $sql = "INSERT IGNORE into " . $tables['tags'] . " (`name`) VALUES ('" . $keys . "')";
                $modx->db->query($sql);

                $keys = implode("','", array_values($out['new']));
                $sql = "SELECT id FROM " . $tables['tags'] . " WHERE name IN('" . $keys . "')";
                $sql = $modx->db->query($sql);
                $sql = $modx->db->makeArray($sql);
                $tmp = array();
                foreach ($sql as $item) {
                    $tmp[] = "(" . $id . "," . $item['id'] . "," . $tv . ")";
                }
                $sql = "INSERT IGNORE into " . $tables['site_content_tags'] . " (`doc_id`,`tag_id`,`tv_id`) values " . implode(",", $tmp);
                $modx->db->query($sql);
            }
        }

        $sql = "SELECT t.id,t.name FROM " . $tables['tags'] . " as t LEFT JOIN " . $tables['site_content_tags'] . " as ct ON ct.tag_id=t.id WHERE ct.doc_id='" . $id . "' AND ct.tv_id='" . $tv . "' AND t.name NOT IN ('" . implode($out['new'], "','") . "')";
        $sql = $modx->db->query($sql);
        $sql = $modx->db->makeArray($sql);
        foreach ($sql as $item) {
            $out['del'][$item['id']] = $item['name'];
        }
        if (count($out['del']) > 0) {
            $keys = implode(",", array_keys($out['del']));

            $sql = "DELETE FROM " . $tables['site_content_tags'] . " WHERE doc_id = '" . $id . "' AND tag_id IN (" . $keys . ") AND tv_id = '" . $tv . "'";
            $modx->db->query($sql);

            $sql = "DELETE t FROM " . $tables['tags'] . " as t LEFT JOIN " . $tables['site_content_tags'] . " as ct ON ct.tag_id=t.id WHERE t.id IN (" . $keys . ") AND ct.doc_id IS NULL";
            $modx->db->query($sql);
        }
    }
}
