require 'net/http'
require 'json'
load "spider.rb"

class SubSpider < Spider
    alias :super_post :post
    alias :super_get :get
    def content_type (response)
        /charset=(?<ct>.+)/ =~ response['content-type']
        return ct
    end
    def valid_result (body)
        (/class="erro"/ =~ body) == nil
    end
    def string_encoded (method, path, params = {})
        if method == :post
            response = super_post path, params
        else
            response = super_get path, params
        end
        body = response.body
        contenttype = content_type(response)
        body = body.force_encoding(contenttype).encode('utf-8')
        #mudando algumas conjuntos de caracteres
        body.gsub!(/&ccedil;/, 'ç')
        body.gsub!(/&atilde;/, 'ã')
        return body
    end
    def json_from (method, path, params = {})
        body = string_encoded method, path, params
        #se a entrada for invalida
        if !valid_result body
            return nil
        end
        info = {}
        last_secao = nil
        loop do
        /<table width.*?>(?<conteudo>.*?)<\/table>(?<restante>.*)/m =~ body
        /<tr>\s*<td class="secao".*?>\s*(?<secao>.*?)\s*<\/td>\s*<\/tr>(?<conteudo>.*)/m =~conteudo
            break if secao == nil
            last_secao = secao
            loop do
                /<td .*?class="titulo".*?>(&nbsp;)?(?<titulo>.*?):(&nbsp;)?<\/td>\s*<td .*?class="valor".*?>(&nbsp;)?(?<valor>.*?)<\/td>(?<conteudo>.*)/m =~ conteudo
                break if titulo == nil
                if info[secao] == nil
                    info[secao] = {titulo => valor}
                else
                    info[secao][titulo] = valor
                end
            end
            body = restante
        end
        /<table width.*?>(?<conteudo>.*?)<\/table>(?<restante>.*)/m =~ body
        /<td .*?class="titulo".*?>(&nbsp;)?(?<titulo>.*?):(&nbsp;)?<\/td>\s*<td .*?class="valor".*?>(&nbsp;)?(?<valor>.*?)<\/td>/m =~ conteudo
        info[last_secao][titulo] = valor
        />\s*?<table width.*?>(?<conteudo>.*?)<\/table>/m =~ restante
        />\s*?<td .*?class="titulo".*?>(&nbsp;)?(?<titulo>.*?):(&nbsp;)?<\/td>\s*<td .*?class="valor".*?>(&nbsp;)?(?<valor>.*?)<\/td>/m =~ conteudo
        info[last_secao][titulo] = valor
        return info.to_json
    end
end
















