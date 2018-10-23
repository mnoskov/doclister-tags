//<?php
/**
 * PopularTags
 *
 * PopularTags
 *
 * @category    snippet
 * @internal    @overwrite true
*/

require_once MODX_BASE_PATH . 'assets/snippets/DocLister/lib/DLTemplate.class.php';
$DLTemplate = DLTemplate::getInstance($modx);

$params = array_merge([
    'parameter' => 'tag',
    'count'     => 10,
    'tv'        => '',
    'url'       => $modx->makeUrl($modx->documentIdentifier),
    'tpl'       => '@CODE:<a href="[+url+]"[+class+]>[+name+]</a>',
    'ownerTPL'  => '@CODE:<div class="socials">[+wrap+]</div>',
], $params);

$query = $modx->db->query("SELECT ct.tv_id, t.name, count(ct.tag_id) as count
    FROM " . $modx->getFullTableName('tags') . " as t
    LEFT JOIN " . $modx->getFullTableName('site_content_tags') . " as ct ON ct.tag_id = t.id
    LEFT JOIN " . $modx->getFullTableName('site_content') . " as c on c.id = ct.doc_id
    WHERE deleted = 0 AND published = 1 " . ($params['tv'] != '' ? "AND ct.tv_id = '" . $modx->db->escape($params['tv']) . "'" : '') . "
    GROUP BY tag_id
    ORDER BY count(ct.tag_id) DESC
    LIMIT " . intval($params['count']));

$current = !empty($_GET[$params['parameter']]) && is_scalar($_GET[$params['parameter']]) ? $_GET[$params['parameter']] : false;
$connector = strpos($params['url'], '?') !== false ? '&' : '?';
$out = '';

while ($row = $modx->db->getRow($query)) {
    $class = $row['name'] == $current ? 'current' : '';

    $out .= $DLTemplate->parseChunk($params['tpl'], array_merge($row, [
        'url'       => $params['url'] . $connector . 'tag=' . $row['name'],
        'classname' => $class,
        'class'     => !empty($class) ? ' class="' . $class . '"' : '',
    ]));
}

if (!empty($out)) {
    return $DLTemplate->parseChunk($params['ownerTPL'], ['wrap' => $out]);
}
