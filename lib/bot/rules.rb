# frozen_string_literal: true

module Bot
  class Rules
    def initialize(rules_path)
      @rules = YAML.safe_load(File.read(rules_path))
    end

    def arena_atrs
      @rules.fetch('arena').slice('height', 'width').transform_keys(&:to_sym)
    end
  end
end
