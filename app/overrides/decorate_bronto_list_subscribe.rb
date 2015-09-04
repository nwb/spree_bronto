Deface::Override.new(
    :virtual_path => "spree/checkout/_address",
    :name => "bronto_list_subscribe",
    :insert_before => "[data-hook='billing_fieldset_wrapper']",
    :partial => "spree/bronto_lists/signup",
    :disabled => false)
