Deface::Override.new(
    :virtual_path => "spree/orders/show",
    :name => "add_keyword_signup_to_receipt",
    :insert_before => "div[id='social_panel']",
    :partial => "spree/shared/keyword_signup")
