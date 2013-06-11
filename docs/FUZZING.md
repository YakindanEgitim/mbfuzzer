Fuzzing sisteme beklenmedik, yarı geçerli, sıralı verilerin gönderimi gibi yöntemlerle sistemin iç yapısındaki hataları bulmayı hedefleyen Kapalı-Kutu yazılım test etme yöntemidir. Fuzzing için çeşitli test yöntemleri isimlendirilmektedir:

    Olumsuz test yöntemi;

    Protokol mutasyon;

    Güvenilirlik test yöntemi;

    Sözdizimi test yöntemi;

    Hata enjeksiyonu;

    Yağmurlu-gün test yöntemi;

    Kirli test yöntemi.

Fuzzing yöntemlerinin uygulanması sağlamak için geliştirilen programlara ise Fuzzer denilmektedir.

## Tarihçe

Fuzzing bazı yazılım mühendisleri tarafından yazılım testlerinde benzer yöntemler kullanılsa da, 1989 yılında Prof. Barton Miller ve öğrencileri tarafından geliştirilmiştir.

## Fuzzing Çalışma Yöntemi

Bir fuzzing aracının çalışma prensibi sistemin beklediği geçerli bir cevabın bütünlüğü bozmadan beklenmedik veriler ile değiştirilmesi sonucu sistemin çökmesini sağlamaktır. Bu duruma uygun bir 
senaryo olarak; mobil uygulamaya kullanıcı adı ve parola ile geçerli bir giriş yapıldıktan sonra 
sunucudan dönen cevabın içerisinde kullanıcının gerçek ismi bulunduğu düşünülsün. Geçerli bir giriş 
işlemi gerçekleştikten sonra kullanıcının gerçek adının yerine bir milyon karakterin mobil uygulamaya gönderilmesi, ortaya bu veriyi tutan değişkenin saklayabileceği veri boyutu sorusunu ortaya çıkartır. 
Bu nedenle mobil uygulamanın çökmesi gerçekleşebilir.


## Kullanılan Yöntemler

### Bellek Taşması Hataları

Sistemin programlama aşamasında geçerli veri kontrollerin yapılmasını kontrol etmeyi hedefleyen 
hafızayı bozma saldırısıdır. Fuzzer aracı hafızada kaplayacağı yer olarak  büyük veriler gönderir:

> A

> A * 257

> A * 513

> A * 1024

> A * 2049

> A * 524289

> A * 1048577

### Karakter Biçem Hataları

Sistemin kullandığı sözdizimini hedef alan ve gelen verinin kontrol edilmemesi ile oluşan 
hatalardır. Bir Fuzzer aracı aşağıdaki yapıları kullanarak sistemin çökmesine yol açabilir:

> %p%p%p%p

> %p%p%p%p%p%p%p%p%p%p

> %p * 257

> %p * 513

> %x%x%x%x

> %x%x%x%x%x%x%x%x%x%x

> %x * 257

> %x * 513

> %s%p%x%d

> %s%p%x%d%s%p%x%d%s%p%x%d


### Sayısal İşlem Hataları

Hafızada kullandığı alan dışına çıkmasına sebep olan saldırı türlerinden kaynaklanan bir 
hata türüdür.Buffer Overflows iişleyiş mantığı ile benzerdir.

> -1

> 0

> 0x100

> 0x7fffffff

> 0x80000000

### SQL Sorguları Değişimi

Web uygulamalarının sahip oldukları veritabanlarından sorgu dilini kullanarak hata mesajlarını 
elde etmek için kullanılır. Saldırgan yetkisi olmamasına rağmen elde edilen hata mesajları 
sayesinde veritabınından bilgi toplar. Kullanıcı arayüzünden gelen verilerin kontrol edilmemesinden 
dolayı bilgilere erişim kolaylıkla sağlanabilir:

> durum:= "SELECT * FROM kullanıcılar WHERE isim= '" + kullanıcıAdı+ "';"

> kullanıcıAdı = a' or 'a'='a


> ' or 1=1--

> ) UNION SELECT%20*%20FROM%20INFORMATION_SCHEMA.TABLES;

> Password:*/=1--

> UNI/**/ON SEL/**/ECT

> '; EXECUTE IMMEDIATE 'SEL' || 'ECT US' || 'ER'


## Kaynak ve Referanslar
* Fuzzing - https://www.owasp.org/index.php/Fuzzing‎
* OWASP Fuzzing Code Database - https://www.owasp.org/index.php/Category:OWASP_Fuzzing_Code_Database
* Fuzz Vectors - https://www.owasp.org/index.php/OWASP_Testing_Guide_Appendix_C:_Fuzz_Vectors
* Ari Takanen, Jared DeMott, Charlie Miller : Fuzzing for Software - Security Testing 
and Quality Assurance. ARTECH HOUSE
* Wikipedia article - http://en.wikipedia.org/wiki/Fuzz_testing
* Fuzzing-related papers - http://www.threatmind.net/secwiki/FuzzingPapers



