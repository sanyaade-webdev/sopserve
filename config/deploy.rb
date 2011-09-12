require "bundler/vlad"

set :application, "sopserve"
set :domain, "brighton.kirkconsulting.co.uk"
set :deploy_to, "/home/jkp/apps/#{application}"
set :repository, "git@github.com:jkp/#{application}.git"
set :skip_scm, false
set :bundle_cmd, ["source ~/.rvm/scripts/rvm",
                  "rvm rvmrc untrust #{release_path}",
                  "bundle"].join(" && ")
