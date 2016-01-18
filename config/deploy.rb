require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina_sidekiq/tasks'
require 'mina/unicorn'

set :rails_env, 'production'  
set :domain,  '10.4.13.64'
set :deploy_to, '/home/alif/www/todolist'
set :repository,  'https://github.com/juracisantos/todolist.git'
set :branch,  'master'
set :user,  'alif'
set :forward_agent, true
set :port,  '22'
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

task :set_proxy do
  queue 'echo "Setar proxy:"'
  queue "source ~/set_proxy.sh tjgo"
end

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  queue %{echo  "-----> Loading environment"}
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => [:set_proxy, :environment] do
    queue! %[mkdir -p  "#{deploy_to}/shared/log"]
    queue! %[chmod g+rx,u+rwx  "#{deploy_to}/shared/log"]
    queue! %[mkdir -p  "#{deploy_to}/shared/config"]
    queue! %[chmod g+rx,u+rwx  "#{deploy_to}/shared/config"]
    queue! %[touch "#{deploy_to}/shared/config/database.yml"]
    queue  %[echo  "-----> Be  sure  to  edit  'shared/config/database.yml'."]
    queue! %[touch "#{deploy_to}/shared/config/secrets.yml"]
    queue %[echo "-----> Be  sure  to  edit  'shared/config/secrets.yml'."]
    
    # sidekiq needs a place to  store its pid file  and log file
    queue!  %[mkdir -p  "#{deploy_to}/shared/pids/"]
    queue!  %[chmod g+rx,u+rwx  "#{deploy_to}/shared/pids"]

    queue!  %[mkdir -p  "#{deploy_to}/shared/sockets"]
    queue!  %[chmod g+rx,u+rwx  "#{deploy_to}/shared/sockets"]
end

desc "Deploys the current version to the server."
task :deploy => [:set_proxy, :environment] do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    #stop  accepting new workers
    invoke  :'sidekiq:quiet'
    invoke  :'git:clone'
    invoke  :'deploy:link_shared_paths'
    invoke  :'bundle:install'
    invoke  :'rails:db_migrate'
    invoke  :'rails:assets_precompile'
    #invoke :'deploy:cleanup'
    to :launch do
      #invoke  :'sidekiq:restart'
      invoke  :'unicorn:restart'

      queue "mkdir -p #{deploy_to}/tmp/"
      queue "touch #{deploy_to}/tmp/restart.txt"
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
