module Spree
  class BrontoConfiguration
    attr_reader :account

    def initialize
      @account= load_account
    end

    def self.account
      bronto_yml=File.join(Rails.root,'config/bronto.yml')
      if File.exist? bronto_yml
        bronto_yml=File.join(Rails.root,'config/bronto.yml')
        YAML.load(File.read(bronto_yml))
      end
    end

    private
    def load_account
      bronto_yml=File.join(Rails.root,'config/bronto.yml')
      if File.exist? bronto_yml
        bronto_yml=File.join(Rails.root,'config/bronto.yml')
        YAML.load(File.read(bronto_yml))
      end
    end
  end
end