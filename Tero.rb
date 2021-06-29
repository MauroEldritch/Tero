#!/usr/bin/ruby
#Tero - Leak Analysis Framework.
#MauroEldritch @ BCA - 2021.
require 'sinatra'
require 'thin'
require 'logger'
require_relative 'conf/settings.rb'

#Main Configuration
set :root, Proc.new { File.join(Dir.pwd, "www") }
set :public_folder, Proc.new { File.join(root, "static") }
set :views, Proc.new { File.join(root, "templates") }

#Calculations
$last_found = ""
$usuarios_afectados = 0
usuarios = []
$dominios_afectados = Hash.new(0)
dominios = []
$claves_mas_usadas = Hash.new(0)
claves = []
$db = File.readlines("db/leak.csv")
#Users
$usuarios_afectados = $db.count
#Domains
$db.each do |line|
    mail = line.split(",")
    dominios.push(mail[0].split("@")[1].to_s.downcase)
    usuarios.push(mail[0].to_s.downcase)
end
dominios.each { |dom| $dominios_afectados[dom] += 1 }
#Passwords
$db.each do |line|
    pass = line.split(",")
    claves.push(pass[1])
end
claves.each { |clv| $claves_mas_usadas[clv] += 1 }

#Logger Configuration
::Logger.class_eval { alias :write :'<<' }
$access_log = ::File.new("logs/access.log","a+")
$error_log = ::File.new("logs/error.log","a+")
$access_log.sync = true
$error_logger = ::Logger.new($error_log)
$error_log.sync = true

#Sinatra Configuration
class MyThinBackend < ::Thin::Backends::TcpServer
    def initialize(host, port, options)
        super(host, port)
        @ssl = true
        @ssl_options = options
    end
end
configure do
    set :environment, :production
    enable :run
    enable :sessions
    set :bind, "0.0.0.0"
    set :port, 443
    set :show_exceptions, false
    set :server_settings, :timeout => 5000    
    set :server, "thin"
    use ::Rack::CommonLogger, $access_log
    class << settings
      def server_settings
        {
          :backend          => MyThinBackend,
          :private_key_file => File.dirname(__FILE__) + "/ssl/bca.pem",
          :cert_chain_file  => File.dirname(__FILE__) + "/ssl/bca.crt",
          :verify_peer      => false
        }
      end
    end
end

#Functions
get ('/') {
    begin
        leak = params['leak']
        if !leak.empty?
            if usuarios.include? leak.to_s
                $last_found = leak.to_s
            else
                $last_found = ""
            end
        end
    rescue
        leak = ""
    end
    erb :index
}