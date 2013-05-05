# This class generates On-The-Fly Valid SSL Certificate with incoming certificate information.

require 'rubygems'
require 'openssl'

class Cert
  
  def initialize()
    @cert = OpenSSL::X509::Certificate.new
    @key = OpenSSL::PKey::RSA.generate(1024)  
	@ca_cert = generate_cacert   
  end
  
  def ssl_cert(real_cert)    
   
    #creates a new certificate with incoming valid certificate info and with RSA key.      
    @cert.version = real_cert.version
    @cert.serial = 1
    @cert.subject = OpenSSL::X509::Name.new(real_cert.subject)
    @cert.issuer = @ca_cert.subject
    @cert.public_key = @key.public_key
    @cert.not_before = real_cert.not_before
    @cert.not_after = real_cert.not_after 

    #added incoming certificate extension information to the new certificate
    real_cert.extensions.each do |extension_info|
        #puts "Extension Factory :" + extension_info
        if ! (extension_info.to_s =~ /basicConstraints|keyUsage|subjectKeyIdentifier/)
          puts "Real Cert - Extension: #{extension_info}"
          @cert.add_extension(extension_info) 
        end
    end

    #extension certificate factory information   
    ef = OpenSSL::X509::ExtensionFactory.new nil,@cert
    ef.subject_certificate = @cert
    ef.issuer_certificate = @ca_cert
    @cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', false))
    @cert.add_extension(ef.create_extension('keyUsage', 'cRLSign,keyCertSign', true))
    @cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))

    #printing fake certificate extension information
    @cert.extensions.each do |extension_info|
        #puts "Extension Factory :" + extension_info
        puts "Fake Cert - Extension: #{extension_info}"
    end
    
    #creating certificate signature with the RSA key and a SHA1 signature   
    @cert.sign(@key, OpenSSL::Digest::SHA1.new)
    
    raise 'Certificate cannot be verified!!!' unless @cert.verify @key
    
    return @cert,@key

  end

	def chiper_key
		#this part adds passphrase and cipher 
    		cipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
    		pass_phrase = "mbfuzzer"
    		key_secure = @key.export(cipher, pass_phrase)
		
		return key_secure	
	end


	def generate_cacert      
      		ca = OpenSSL::X509::Certificate.new
      		ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
      		ca.serial = 1
      		ca.subject = OpenSSL::X509::Name.parse "C=TR, ST=MBFuzzer, O=MBFuzzer Corp, OU=MBFuzzer Dev Team, CN=*.mbfuzzer.com/emailAddress=info@mbfuzzer.com"
      		ca.issuer = ca.subject # root CA's are "self-signed"
      		ca.public_key = @key.public_key
      		ca.not_before = Time.now
      		ca.not_after = ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
      
      		ef = OpenSSL::X509::ExtensionFactory.new
      		ef.subject_certificate = ca
      		ef.issuer_certificate = ca
      
      		ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
      		ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
      		ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
      		ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
      		ca.sign(@key, OpenSSL::Digest::SHA256.new)
      
      		return ca      
   	end
  
end

