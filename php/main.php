<?php
    include 'subspider.php';
    $s = new SubSpider();
    $dados = $s -> get_json('http://www.sintegra.es.gov.br/resultado.php', 'POST', '', array("num_cnpj" => "31.804.115-0002-43", "num_ie" => "", "botao" => "Consultar"));
    print_r($dados);

?>
