#
# Cookbook Name:: thinking_sphinx_3
# Recipe:: default
#

include_recipe "thinking_sphinx_3::cleanup"
include_recipe "thinking_sphinx_3::install"
include_recipe "thinking_sphinx_3::thinking_sphinx"
include_recipe "thinking_sphinx_3::setup"
