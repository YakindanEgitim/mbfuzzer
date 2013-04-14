require 'rubygems'
require 'openssl'


def ssl_cert()
  
  #create a RSA key
  key = OpenSSL::PKey::RSA.new 2048
 
  #creates a self-signed certificate using an RSA key and a SHA1 signature. 
 name = OpenSSL::X509::Name.parse "CN=test.com/
                                          O=Test\ Inc./
                                          L=Asd\ Asd/
                                          ST=Kent/
                                          C=TR"

  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 2
  cert.subject = name
  cert.issuer = name
  cert.public_key = key.public_key
  cert.not_before = Time.now
  cert.not_after = cert.not_before + 1 * 365 * 24 * 60 * 60 
  
  ef = OpenSSL::X509::ExtensionFactory.new nil,cert
  ef.subject_certificate = cert
  ef.issuer_certificate = cert
  cert.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
  cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
  cert.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
  cert.sign(key, OpenSSL::Digest::SHA1.new)
  
  raise 'Certificate cannot be verified!!!' unless cert.verify key
  
  return cert.to_pem  
end

