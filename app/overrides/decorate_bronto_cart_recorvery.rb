Deface::Override.new(
    :virtual_path => "spree/orders/edit",
    :name => "bronto_cart_recovery_tags",
    :insert_after => "[data-hook='cart_container']",
    :partial => "spree/shared/bronto_tags",
    :disabled => Spree::BrontoConfiguration.account['disable_cart_recovery'])
