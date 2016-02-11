Deface::Override.new(
    :virtual_path => "spree/shared/_footer_wrapper",
    :name => "bronto_cart_recovery_tags",
    :insert_after => "[data-hook='footer']",
    :partial => "spree/shared/bronto_tags",
    :disabled => Spree::BrontoConfiguration.account['disable_cart_recovery'])
