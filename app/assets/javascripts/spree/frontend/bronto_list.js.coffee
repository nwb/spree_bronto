$(document).ready $('#retrieve_bronto_list').click(->
  $.getScript '/admin/bronto_lists/get_lists?list_id=' + $('#bronto_list_list_id').val() + '&store_id=' + $('#bronto_list_store_id').val()
  return
)
$(document).ready $('#bronto_list_store_id').change(->
  $.getScript '/admin/bronto_lists/get_lists?list_id=' + $('#bronto_list_list_id').val() + '&store_id=' + $('#bronto_list_store_id').val()
  return
)