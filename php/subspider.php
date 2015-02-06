<?php
    include 'Spider.php';
    class SubSpider extends Spider {
        function get_json($url="", $method ="", $referer="",$params=array()) {
            $pagina = parent::request($url, $method, '', $params);

            $pagina = utf8_encode("$pagina");
            $pagina = preg_replace("<!--[\s\S]*?-->", "", $pagina);
            $pagina = preg_replace("/&ccedil;/", 'c', $pagina);
            $pagina = preg_replace("/&atilde;/", 'a', $pagina);


            $info = array();
            $ultima_secao = "";
            while(true) {
                preg_match('/<table width[\s\S]*?>([\s\S]*?)<\/table>([\s\S]*)/', $pagina, $matches);
                $conteudo = $matches[1];
                $restante = $matches[2];
                preg_match('/<tr>\s*<td class="secao".*?>\s*(.*?)\s*<\/td>\s*<\/tr>/', $conteudo, $secao_match);
                $secao = $secao_match[1];

                if($secao) {
                    print_r($restante);
                    $ultima_secao = $secao;
                    $info[$secao] = $this->extrair_valores ($conteudo);
                }
                else {
                    $lista = $this->extrair_valores($restante);
                    $merge = $info[$ultima_secao] + $lista;
                    $info[$ultima_secao] = $merge;
                    break;
                }
                $pagina = $restante;

            }
            return json_encode($info, JSON_UNESCAPED_UNICODE);
        }
        function extrair_valores ($conteudo) {
            preg_match_all('/<td[\s\S]*?class="titulo"[\s\S]*?>(?:&nbsp;)?([\s\S]*?):(?:&nbsp;)?<\/td>\s*<td .*?class="valor"[\s\S]*?>(?:&nbsp;)?([\s\S]*?)<\/td>/', $conteudo, $valores_match);
            $titulos = $valores_match[1];
            $valores = $valores_match[2];

            for ($i = 0; $i < count($titulos); $i++) {
                $lista[$titulos[$i]] = $valores[$i];
            }
            return array_combine($titulos, $valores);
        }
    }

?>
