require 'bundler/capistrano'
#require "rvm/capistrano"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application, "contratoabierto"
set :repository,  "https://github.com/alvaromolina/contratoabierto.git"

set :scm, :git
set :branch, "master"
set :user, "root"
set :rails_env, "production"
set :deploy_via, :remote_cache
set :keep_releases, 3
set :deploy_to, "/var/www/contratoabierto"


set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-2.0.0-p643/bin:/usr/local/rvm/gems/ruby-2.0.0-p643@global/bin:/usr/local/rvm/rubies/ruby-2.0.0-p643/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/rvm/bin",
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-2.0.0-p643:/usr/local/rvm/gems/ruby-2.0.0-p643@global'
}

# Target ruby version
#set :rvm_ruby_string, '2.0.0'
 
# System-wide RVM installation
#set :rvm_type, :system
 
# We use sudo (root) for system-wide RVM installation
#set :rvm_install_with_sudo, true

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "162.243.7.211"                          # Your HTTP server, Apache/etc
role :app, "162.243.7.211"                          # This may be the same as your `Web` server
role :db,  "162.243.7.211", :primary => true # This is where Rails migrations will run
role :db,  "162.243.7.211"


namespace :deploy do
  task :start do ; end
  task :stop do ; end


  desc "Symlink shared config files"
  task :symlink_config_files do
      run "#{ try_sudo } ln -s #{ deploy_to }/shared/config/database.yml #{ current_path }/config/database.yml"
  end

  # NOTE: I don't use this anymore, but this is how I used to do it.
  desc "Precompile assets after deploy"
  task :precompile_assets do
    run <<-CMD
      cd #{ current_path } &&
      bundle exec rake assets:precompile RAILS_ENV=#{ rails_env }
    CMD
  end

  #task :set_rvm_version, :roles => :app, :except => { :no_release => true } do
  #  run "source /etc/profile.d/rvm.sh && rvm use #{rvm_ruby_string} --default"
  #end

  desc "reload the database with seed data"
  task :migrate do
    run "cd #{current_path}; bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
  end

  desc "Restart applicaiton"
  task :restart do
    run "#{ try_sudo } touch #{ File.join(current_path, 'tmp', 'restart.txt') }"
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
  desc "reload the database"
  task :load_schema do
    run "cd #{current_path}; bundle exec rake db:schema:load RAILS_ENV=#{rails_env}"
  end

end

after "deploy", "deploy:symlink_config_files"
after "deploy", "deploy:precompile_assets"
after "deploy", "deploy:restart"
after "deploy", "deploy:migrate"
after "deploy", "deploy:cleanup"