require 'mixlib/config'
require 'chef/mixin/deep_merge'

module Supermarket
  # This module if for reading the config from /etc/supermarket/supermarket.rb
  #
  # A line in this config file looks like:
  #
  #     support_email_address 'test@test.com'
  #     webapp.port 4567
  #
  # Anything that is configurable by users needs to be defined here with
  # config_contexts and  or configurables.
  #
  # The attributes in here are the ones that are configurable in the config
  # file. A full list is in attributes/default.rb
  module Config
    extend Mixlib::Config

    config_strict_mode true

    configurable :fqdn

    # The URL for the Chef server. Used with the "Chef OAuth2 Settings" and
    # "Chef URL Settings" below. If this is not set, authentication and some of
    # the links in the application will not work.
    configurable :chef_server_url

    default :config_directory, '/etc/supermarket'
    default :install_directory, '/opt/supermarket'
    default :app_directory, '/opt/supermarket/embedded/service/supermarket'
    default :log_directory, '/var/log/supermarket'
    default :var_directory, '/var/opt/supermarket'
    default :data_directory, '/var/opt/supermarket/data'
    default :user, 'supermarket'
    default :group, 'supermarket'
    default :topology, 'standalone'

    config_context :nginx do
      default :enable, true
      default :directory, '/var/opt/supermarket/nginx/etc'
      default :log_directory, '/var/log/supermarket/nginx'

      config_context :cache do
        default :enable, false
        default :directory, '/var/opt/supermarket/nginx/cache'
      end
    end

    config_context :postgresql do
      default :enable, true
      default :data_directory, '/var/opt/supermarket/postgresql/9.3/data'
      default :log_directory, '/var/log/supermarket/postgresql'
      default :checkpoint_completion_target, 0.5
      default :checkpoint_segments, 3
      default :checkpoint_timeout, '5min'
      default :checkpoint_warning, '30s'
      default :listen_address, '127.0.0.1'
      default :max_connections, 350
      default :md5_auth_cidr_addresses, ['127.0.0.1/32', '::1/128']
      default :port, 15_432
      default :shmmax, 17_179_869_184
      default :shmall, 4_194_304

      # Memory settings
      configurable :effective_cache_size
      configurable :shared_buffers
      configurable :work_mem
    end

    config_context :rails do
      default :enable, true
      default :port, 13_000
      default :log_directory, '/var/log/supermarket/rails'
    end

    config_context :redis do
      default :enable, true
      default :bind, '127.0.0.1'
      default :directory, '/var/opt/supermarket/redis'
      default :log_directory, '/var/log/supermarket/redis'
      default :port, 16_379
    end

    config_context :sidekiq do
      default :enable, true
      default :concurrency, 25
      default :log_directory, '/var/log/supermarket/sidekiq'
      default :timeout, 30
    end

    config_context :ssl do
      default :directory, '/var/opt/supermarket/ssl'

      # This shouldn't be changed, but can be overriden in tests
      configurable :openssl_bin

      # Paths to the SSL certificate and key files. If these are not provided
      # we will attempt to generate a self-signed certificate and use tha
      # instead.
      configurable :certificate
      configurable :certificate_key

      # ### Cipher settings
      #
      # Based off of the Mozilla recommended cipher suite
      # https://wiki.mozilla.org/Security/Server_Side_TLS#Recommended_Ciphersuite
      #
      # SSLV3 was removed because of the poodle attack
      # (https://www.openssl.org/~bodo/ssl-poodle.pdf)
      #
      # If your infrastructure still has requirements for the
      # vulnerable/venerable SSLV3, you can add "SSLv3" to the below line.
      default :ciphers, 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA'
      default :protocols, 'TLSv1 TLSv1.1 TLSv1.2'
      default :session_cache, 'shared:SSL:4m'
      default :session_timeout, '5m'
    end

    config_context :unicorn do
      default :copy_on_write, true
      default :enable_stats, false
      configurable :listen
      default :pid, '/var/opt/supermarket/rails/run/unicorn.pid'
      default :preload_app, true
      default :worker_timeout, 15
      configurable :worker_processes
    end

    config_context :database do
      configurable :user
      configurable :name
      configurable :host
      configurable :port
      configurable :pool
      configurable :extensions
      configurable :password
    end

    # Top level keys that you probably don't need to configure
    configurable :fieri_url
    configurable :fieri_key
    configurable :from_email
    configurable :github_access_token
    configurable :github_key
    configurable :github_secret
    configurable :google_analytics_id
    configurable :host
    configurable :newrelic_agent_enabled
    configurable :newrelic_app_name
    configurable :newrelic_license_key
    configurable :port
    configurable :protocol
    configurable :pubsubhubbub_callback_url
    configurable :pubsubhubbub_secret
    configurable :redis_url
    configurable :sentry_url

    configurable :chef_identity_url
    configurable :chef_manage_url
    configurable :chef_profile_url
    configurable :chef_sign_up_url

    configurable :chef_domain
    configurable :chef_blog_url
    configurable :chef_docs_url
    configurable :chef_downloads_url
    configurable :chef_www_url
    configurable :learn_chef_url

    configurable :chef_oauth2_app_id
    configurable :chef_oauth2_secret
    configurable :chef_oauth2_url
    configurable :chef_oauth2_verify_ssl

    configurable :ccla_version
    configurable :cla_signature_notification_email
    configurable :cla_report_email
    configurable :curry_cla_location
    configurable :curry_success_label
    configurable :icla_location
    configurable :icla_version
    configurable :seed_cla_data

    configurable :robots_allow
    configurable :robots_disallow

    configurable :s3_access_key_id
    configurable :s3_bucket
    configurable :s3_secret_access_key
    configurable :cdn_url

    configurable :smtp_address
    configurable :smtp_password
    configurable :smtp_port
    configurable :smtp_user_name

    configurable :statsd_url
    configurable :statsd_port

    def self.parse_json_file(filename)
      Chef::JSONCompat.from_json(IO.read(filename))
    rescue Errno::ENOENT
      {}
    end

    def self.secrets_to_json(node)
      Chef::JSONCompat.to_json_pretty(
        'database' => {
          'user' => node['supermarket']['database']['user'],
          'password' => node['supermarket']['database']['password']
        }
      )
    end

    def self.from_files(config_file, secrets_file)
      from_file(config_file)
      config = save(true)
      secrets = parse_json_file(secrets_file)
      Chef::Mixin::DeepMerge.deep_merge!(secrets, config)
    end

    def self.oauth2_config_for(application)
      path = "/etc/opscode/oc-id-applications/#{application}.json"
      parse_json_file(path)
    end

    # Take some node attributes and return them on each line as:
    #
    # export ATTR_NAME="attr_value"
    #
    # If the value is a String or Number and the attribute name is attr_name.
    # Used to write out environment variables to a file.
    def self.environment_variables_from(attributes)
      attributes.reduce('') do |str, attr|
        if attr[1].is_a?(String) || attr[1].is_a?(Numeric) || attr[1] == true || attr[1] == false
          str << "export #{attr[0].upcase}=\"#{attr[1]}\"\n"
        else
          str << ''
        end
      end
    end
  end unless defined?(Supermarket::Config)
  # The cookbook compiler in Chef[0] calls Kernel.load, not require, for
  # every library in a given cookbook.  This essentially makes it impossible to
  # stub module and class methods for libraries in ChefSpec because they are
  # reloaded after the stubs have been evaluated.  What we're doing here is
  # preventing Chef from reloading the library so our stubs don't get whacked.
  #
  # [0] https://github.com/chef/chef/blob/master/lib/chef/run_context/cookbook_compiler.rb#L191
end
