//<?php
/**
 * Tags
 *
 * Tags
 *
 * @category    snippet
 * @internal    @overwrite true
*/

$params = array_merge([
    'from'      => 'param', // 'popular', 'param'
    'tags'      => '',
    'parameter' => 'tag',
    'count'     => 10,
    'tv'        => '',
    'url'       => $modx->makeUrl($modx->documentIdentifier),
    'api'       => 0,
    'tpl'       => '@CODE:<a href="[+url+]"[+class+]>[+name+]</a>',
    'ownerTPL'  => '@CODE:<div class="tags-list">[+wrap+]</div>',
], $params);

switch ($params['from']) {
    case 'popular': {
        $query = $modx->db->query("SELECT ct.tv_id, t.name, count(ct.tag_id) as count
            FROM " . $modx->getFullTableName('tags') . " as t
            LEFT JOIN " . $modx->getFullTableName('site_content_tags') . " as ct ON ct.tag_id = t.id
            LEFT JOIN " . $modx->getFullTableName('site_content') . " as c on c.id = ct.doc_id
            WHERE deleted = 0 AND published = 1 " . ($params['tv'] != '' ? "AND ct.tv_id = '" . $modx->db->escape($params['tv']) . "'" : '') . "
            GROUP BY tag_id
            ORDER BY count(ct.tag_id) DESC
            LIMIT " . intval($params['count']));

        $tags = [];

        while ($row = $modx->db->getRow($query)) {
            $tags[] = $row['name'];
        }

        break;
    }

    case 'param': {
        $tags = array_map('trim', explode(',', $params['tags']));
        break;
    }
}

$current = !empty($_GET[$params['parameter']]) && is_scalar($_GET[$params['parameter']]) ? $_GET[$params['parameter']] : false;
$connector = strpos($params['url'], '?') !== false ? '&' : '?';

$raw = [];

foreach ($tags as $tag) {
    $class = $row['name'] == $current ? 'current' : '';

    $raw[] = [
        'name'      => $tag,
        'url'       => $params['url'] . $connector . 'tag=' . urlencode($tag),
        'classname' => $class,
        'class'     => !empty($class) ? ' class="' . $class . '"' : '',
    ];
}

if ($params['api']) {
    return $raw;
}

require_once MODX_BASE_PATH . 'assets/snippets/DocLister/lib/DLTemplate.class.php';
$DLTemplate = DLTemplate::getInstance($modx);

$out = '';

foreach ($raw as $row) {
    $out .= $DLTemplate->parseChunk($params['tpl'], $row);
}

if (!empty($out)) {
    return $DLTemplate->parseChunk($params['ownerTPL'], ['wrap' => $out]);
}
