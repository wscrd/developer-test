load "subspider.rb"
s = SubSpider.new('http://www.sintegra.es.gov.br')
puts s.json_from :post, '/resultado.php', {"num_cnpj" => "31.804.115-0002-43", "num_ie" => "", "botao" => "Consultar"}
