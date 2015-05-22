module Spree
  class BrontoConfiguration

    def self.account
      bronto_yml=File.join(Rails.root,'config/bronto.yml')
      if File.exist? bronto_yml
        bronto_yml=File.join(Rails.root,'config/bronto.yml')
        YAML.load(File.read(bronto_yml))
      end
    end
  end
end