Mobile Application Fuzzer via SSL MITM (mbfuzzer)
========

Development Platform : Ruby 2.0

MBFuzzer will be developed for MITM (Man in the Middle) Fuzzing. Mobile applications use HTTP, SOAP, XML and JSON based data streams for communicate the servers. Many mobile applications use SSL Connect method for server communication. This method should be converted to HTTPS GET/POST method for MITM attacks. MBFuzzer will provide HTTP/HTTPS Proxy functionality and Real-Time Fuzzing feature with HTTP Connect conversion support. 

## Features
* HTTP/HTTP Proxy Support
* HTTPS Connect Conversion Support (not fully functional)
* On-The-Fly Valid SSL certificate generation for target server (Under
* Development)
* Real-Time Response/Request Fuzzing Support
* Fake Service Installation via XML/JSON Templates (Under Development)
* Supports Different Injection Payloads using Templates

## Inspired Projects
* Android Proxy - https://code.google.com/p/androidproxy

## Project Team Requirements
* Good Understanding of SSL/TLS Technology
* Ruby Development Skills
* JSON & XML Knowledge 
* Fuzzing Knowledge 

## Installation
* Please make sure that your system has necessary packages installed before installation.
* For development platform Ruby in Ubuntu: sudo apt-get install ruby1.9.3
* git clone git@github.com:YakindanEgitim/mbfuzzer.git

## Fuzzing Templates

### Search & Replace

Purpose of the search & replace structure is finding target element name and changing value of
the element according to url. The url field could be any key in the url instead of whole address.

    <searchreplace>
        <url> [target url address] </url>
        <target> [element name ] </target>
        <newdata> [replaced data] </newdata>
    </searchreplace>


### Big Data Entry

Big Data Entry structure aims that applying big character set inorder to give vulnerability
information with using data and count tags by element name. Url feature is the same like search and
replace structure.

    <bigdata>
        <url> [target url address] </url>
        <name> [element name] </name>
        <data> [repeated data] </data>
        <count> [number of repetitions] </count>
    </bigdata>

## Usage
* Before starting MBFuzzer, mbconfig.cfg file, which is in config directory, should be updated with 
using fuzzing templates under MBFuzzer tag.
* MBFuzzer requires proxy address & port number in starting. 
* By default, it is running on address 127.0.0.1 & port 8080. 
* Running command of MBFuzzer Project: 

       `ruby mbfuzzer.rb [address] [port]`
