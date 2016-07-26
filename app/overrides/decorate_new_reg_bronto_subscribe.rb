Deface::Override.new(
    :virtual_path => "spree/user_registrations/new",
    :name => "new_reg_bronto_subscribe",
    :insert_before => "[data-hook='regsignup_below_password_fields']",
    :partial => "spree/bronto_lists/regsignup",
    :disabled => false)
