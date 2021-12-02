module DockerCookbook
  module DockerHelpers
    module Json
      def generate_json(new_resource)
      opts = { filters: ["dangling=#{new_resource.dangling}"] }
      opts[:filters].push("until=#{new_resource.prune_until}") if new_resource.property_is_set?(:prune_until)
      opts[:filters].push("label=#{new_resource.with_label}") if new_resource.property_is_set?(:with_label)
      opts[:filters].push("label!=#{new_resource.without_label}") if new_resource.property_is_set?(:without_label)
      opts.to_json
      end
    end
  end
end
