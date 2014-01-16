require 'rvm/capistrano'
set :rvm_path, "/usr/local/rvm"
set :rvm_bin_path, "/usr/local/rvm/bin"

require 'bundler/capistrano'
set :bundle_without,  [:development, :test]

default_run_options[:pty] = true

set :application, "migration_test"
set :repository,  "git@github.com:cuperman/migration_test.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :branch, "master"
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache
set :deploy_to, "/opt/rails/migration_test"
#set :user, "jmarch"
set :user, "jcooper"
set :use_sudo, true

role :web, "dataminer-s1"                          # Your HTTP server, Apache/etc
role :app, "dataminer-s1"                          # This may be the same as your `Web` server
role :db,  "dataminer-s1", :primary => true # This is where Rails migrations will run

#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# SSH forwarding must be turned on
# @note See tech-ops if you run into an SSH public_key error
on :start do
  'ssh-add ~/.ssh/id_rsa'
  'ssh-add -L'
end

after  :deploy, 'deploy:create_symlink', 'deploy:migrate'

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
