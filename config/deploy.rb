# config valid only for current version of Capistrano
lock "3.11.0"

require "capistrano/maintenance"

set :application, "annex-ims"
set :repo_url, "git@github.com:ndlib/annex-ims.git"


# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
if ENV["SCM_BRANCH"] && ENV["SCM_BRANCH"] != ""
  set :branch, ENV["SCM_BRANCH"]
elsif fetch(:stage).to_s == "production"
  ask :branch, "master"
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/home/app/annex-ims"

set :ssh_options, {
  verify_host_key: :never,
}

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push("config/database.yml")
# set :linked_files, fetch(:linked_files, []).push("config/secrets.yml")
set :linked_files, fetch(:linked_files, []).push("config/database.yml")
set :linked_files, fetch(:linked_files, []).push("config/secrets.yml")
# set :linked_files, fetch(:linked_files, []).push("config/sunspot.yml")

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push("bin", "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "public/system")
set :linked_dirs, fetch(:linked_dirs, []).push("bin", "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "public/system", "solr")

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { path: "/opt/ruby/current/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do

  desc "Restart application"
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join("tmp/restart.txt")
    end
  end

  after :published, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, "cache:clear"
      # end
    end
  end

end

namespace :sneakers do
  task :restart do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rack_env) do
          execute :rake, "sneakers:restart"
        end
      end
    end
  end
end

after "deploy:started", "maintenance:enable"

after "deploy:published", "maintenance:disable"
after "deploy:reverted", "maintenance:disable"

after "deploy:finished", "sneakers:restart"

#after "deploy:finished"
