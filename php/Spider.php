<?php

require_once 'autoload.php';

class Spider {
    public function get($url, $params){
        $ch = curl_init($url);
    }
} 