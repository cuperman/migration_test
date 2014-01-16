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
set :deploy_to, "/opt/rails/report_tool"
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

before 'deploy:update_code', 'deploy:files_steal'
after  :deploy, 'deploy:create_symlink', 'deploy:symlink_shared', 'deploy:migrate'
after  'deploy:update_code', 'deploy:files_give_back'

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  # Symlinks
  task :symlink_shared do
    # Use yml files in source control
    #run "cp #{release_path}/config/database.yml #{release_path}/config/database.src.yml"
    #run "cp #{release_path}/config/google.yml #{release_path}/config/google.src.yml"
    #run "ln -nfs #{shared_path}/system/database.yml #{release_path}/config/database.yml"
    #run "ln -nfs #{shared_path}/system/google.yml #{release_path}/config/google.yml"
    run "ln -nfs #{shared_path}/system/track.log #{release_path}/log/track.log"
    run "ln -nfs #{shared_path}/system/cache #{release_path}/cache"
  end

  # Claim all files from Apache
  task :files_steal do
    run "#{try_sudo} chown -R #{user} /opt/rails/report_tool"
  end

  # Give all files back to Apache after process is complete
  task :files_give_back do
    run "#{try_sudo} chown -R www-data /opt/rails/report_tool"
  end
end
