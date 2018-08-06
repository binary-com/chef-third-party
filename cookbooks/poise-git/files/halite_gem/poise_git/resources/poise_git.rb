#
# Copyright 2015-2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'shellwords'
require 'zlib'

require 'chef/provider/git'
require 'chef/resource/git'
require 'poise'

require 'poise_git/git_command_mixin'
require 'poise_git/safe_string'


module PoiseGit
  module Resources
    # (see PoiseGit::Resource)
    # @since 1.0.0
    module PoiseGit
     # A `poise_git` resource to manage Python installations using pip.
      #
      # @provides poise_git
      # @action checkout
      # @action export
      # @action sync
      # @example
      #   poise_git '/srv/myapp' do
      #     repository 'https://...'
      #     deploy_key data_bag_item('deploy_keys', 'myapp')['key']
      #   end
      class Resource < Chef::Resource::Git
        include Poise
        include ::PoiseGit::GitCommandMixin
        provides(:poise_git)
        # Manually create matchers because #actions is unreliable.
        %i{checkout export sync}.each do |action|
          Poise::Helpers::ChefspecMatchers.create_matcher(:poise_git, action)
        end

        # @api private
        def initialize(*args)
          super
          # Because the superclass declares this, we have to as well. Should be
          # removable at some point when Chef makes everything use the provider
          # resolver system instead.
          @resource_name = :poise_git if defined?(@resource_name) && @resource_name
          @provider = ::PoiseGit::Resources::PoiseGit::Provider if defined?(@provider) && @provider
        end

        # @!attribute strict_ssh
        #   Enable strict SSH host key checking. Defaults to false.
        #   @return [Boolean]
        attribute(:strict_ssh, equal_to: [true, false], default: false)

        # @!attribute deploy_key
        #   SSH deploy key as either a string value or a path to a key file.
        #   @return [String]
        def deploy_key(val=nil)
          # Use a SafeString for literal deploy keys so they aren't shown.
          val = SafeString.new(val) if val && !deploy_key_is_local?(val)
          set_or_return(:deploy_key, val, kind_of: String)
        end

        # Default SSH wrapper path.
        #
        # @api private
        # @return [String]
        def ssh_wrapper_path
          @ssh_wrapper_path ||=  "#{Chef::Config[:file_cache_path]}/poise_git_wrapper_#{Zlib.crc32(name)}"
        end

        # Guess if the deploy key is a local path or literal value.
        #
        # @api private
        # @param key [String, nil] Key value to check. Defaults to self.key.
        # @return [Boolean]
        def deploy_key_is_local?(key=nil)
          key ||= deploy_key
          # Try to be mindful of Windows-y paths here even though they almost
          # certainly won't actually work later on with ssh.
          key && key =~ /\A(\/|[a-zA-Z]:)/
        end

        # Path to deploy key.
        #
        # @api private
        # @return [String]
        def deploy_key_path
          @deploy_key_path ||= if deploy_key_is_local?
            deploy_key
          else
            "#{Chef::Config[:file_cache_path]}/poise_git_deploy_#{Zlib.crc32(name)}"
          end
        end

        # Hook to force the git install via recipe if needed.
        def after_created
          if !parent_git && node['poise-git']['default_recipe']
            # Use the default recipe to give us a parent the next time we ask.
            run_context.include_recipe(node['poise-git']['default_recipe'])
            # Force it to re-expand the cache next time.
            @parent_git = nil
          end
          super
        end

      end

      # The default provider for the `poise_git` resource.
      #
      # @see Resource
      class Provider < Chef::Provider::Git
        include Poise
        include ::PoiseGit::GitCommandMixin
        provides(:poise_git)

        # @api private
        def initialize(*args)
          super
          # Set the SSH wrapper path in a late-binding kind of way. This better
          # supports situations where the user doesn't exist until Chef converges.
          new_resource.ssh_wrapper(new_resource.ssh_wrapper_path) if new_resource.deploy_key
        end

        # Hack our special login in before load_current_resource runs because that
        # needs access to the git remote.
        #
        # @api private
        def load_current_resource
          create_deploy_key if new_resource.deploy_key
          super
        end

        # Like {#load_current_resource}, make sure git is installed since we might
        # need it depending on the version of Chef.
        #
        # @api private
        def define_resource_requirements
          create_deploy_key if new_resource.deploy_key
          super
        end

        private

        # Install git and set up the deploy key if needed. Safe to call multiple
        # times if needed.
        #
        # @api private
        # @return [void]
        def create_deploy_key
          return if @create_deploy_key
          Chef::Log.debug("[#{new_resource}] Creating deploy key")
          old_why_run = Chef::Config[:why_run]
          begin
            # Forcibly disable why run support so these will always run, since
            # we need to be able to talk to the git remote even just for the
            # whyrun checks.
            Chef::Config[:why_run] = false
            notifying_block do
              write_deploy_key
              write_ssh_wrapper
            end
          ensure
            Chef::Config[:why_run] = old_why_run
          end
          @create_deploy_key = true
        end

        # Copy the deploy key to a file if needed.
        #
        # @api private
        # @return [void]
        def write_deploy_key
          # Check if we have a local path or some actual content
          return if new_resource.deploy_key_is_local?
          file new_resource.deploy_key_path do
            owner new_resource.user
            group new_resource.group
            mode '600'
            content new_resource.deploy_key
            sensitive true
          end
        end

        # Create the SSH wrapper script.
        #
        # @api private
        # @return [void]
        def write_ssh_wrapper
          # Write out the GIT_SSH script, it should already be enabled above
          file new_resource.ssh_wrapper_path do
            owner new_resource.user
            group new_resource.group
            mode '700'
            content %Q{#!/bin/sh\n/usr/bin/env ssh #{'-o "StrictHostKeyChecking=no" ' unless new_resource.strict_ssh}-i "#{new_resource.deploy_key_path}" $@\n}
          end
        end

        # Patch back in the `#git` from the git provider. This otherwise conflicts
        # with the `#git` defined by the DSL, which gets included in such a way
        # that the DSL takes priority.
        #
        # @api private
        def git(*args, &block)
          self.class.superclass.instance_method(:git).bind(self).call(*args, &block)
        end

        # Trick all shell_out related things in the base class in to using
        # my git_shell_out instead.
        #
        # @api private
        def shell_out(*cmd, **options)
          if @shell_out_hack_inner
            # This is the real call.
            super
          else
            # This ia call we want to intercept and send to our method.
            begin
              @shell_out_hack_inner = true
              # Remove nils and flatten for compat with how core uses this method.
              cmd.compact!
              cmd.flatten!
              # Reparse the command to get a clean array.
              cmd = Shellwords.split(cmd.join(' '))
              # We'll add the git command back in ourselves.
              cmd.shift if cmd.first == 'git'
              # Push the yak stack.
              git_shell_out(*cmd, **options)
            ensure
              @shell_out_hack_inner = false
            end
          end
        end

      end

    end
  end
end
