# frozen_string_literal: true

module Pdflayer
  # Missing arguments
  class MissingArgumentException < RuntimeError
    attr_accessor :argument

    def initialize(argument)
      self.argument = argument
    end
  end
end
