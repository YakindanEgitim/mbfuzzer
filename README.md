mbfuzzer
========

<b>Mobile Application Fuzzer via SSL MITM</b>
<br>Development Platform : Ruby 2.0

MBFuzzer will be developed for MITM (Man in the Middle) Fuzzing. Mobile applications use HTTP, SOAP, XML and JSON based data streams for communicate the servers. Many mobile applications use SSL Connect method for server communication. This method should be converted to HTTPS GET/POST method for MITM attacks. MBFuzzer will provide HTTP/HTTPS Proxy functionality and Real-Time Fuzzing feature with HTTP Connect conversion support. 

<b>Features</b>
* HTTP/HTTP Proxy Support
* HTTPS Connect Conversion Support
* On-The-Fly Valid SSL certificate generation for target server
* Real-Time Response/Request Fuzzing Support
* Fake Service Installation via XML/JSON Templates
* Supports Different Injection Payloads using Templates

