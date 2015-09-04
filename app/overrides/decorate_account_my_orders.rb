Deface::Override.new(
    :virtual_path => "spree/users/show",
    :name => "bronto_lists_edit_form",
    :insert_before => "[data-hook='account_my_orders']",
    :partial => "spree/bronto_lists/edit",
    :disabled => false)