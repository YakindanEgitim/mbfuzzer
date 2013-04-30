# This class generates On-The-Fly Valid SSL Certificate with incoming certificate information.

require 'rubygems'
require 'openssl'

class Cert
  
  def ssl_cert(real_cert)
    
    #create a RSA key
    key = OpenSSL::PKey::RSA.generate(1024) 
    
    #this part adds passphrase and cipher, but it could not yet include  
    cipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
    pass_phrase = "mbfuzzer"
    key_secure = key.export(cipher, pass_phrase)
   
    #creates a new certificate with incoming valid certificate info and with RSA key.    
    cert = OpenSSL::X509::Certificate.new
    cert.version = real_cert.version
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.new(real_cert.subject)
    cert.issuer = OpenSSL::X509::Name.new(real_cert.issuer)
    cert.public_key = key.public_key
    cert.not_before = real_cert.not_before
    cert.not_after = real_cert.not_after 

    #added incoming certificate extension information to the new certificate
    real_cert.extensions.each do |extension_info|
        #puts "Extension Factory :" + extension_info
	if ! (extension_info.to_s =~ /basicConstraints|keyUsage|subjectKeyIdentifier/)
	puts "Real Cert - Extension: #{extension_info}"
        cert.add_extension(extension_info) 
	end
    end

    #extension certificate factory information   
    ef = OpenSSL::X509::ExtensionFactory.new nil,cert
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', false))
    cert.add_extension(ef.create_extension('keyUsage', 'cRLSign,keyCertSign', true))
    cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))

    #printing fake certificate extension information
    cert.extensions.each do |extension_info|
        #puts "Extension Factory :" + extension_info
	puts "Fake Cert - Extension: #{extension_info}"
    end
    
    #creating certificate signature with the RSA key and a SHA1 signature   
    cert.sign(key, OpenSSL::Digest::SHA1.new)
    
    raise 'Certificate cannot be verified!!!' unless cert.verify key

    return cert,key
  end
  
end
