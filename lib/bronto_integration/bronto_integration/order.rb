module BrontoIntegration
  class Order
    attr_reader :token, :bronto_client
    def initialize(token)         # let's use order object from spree 0.11 at this moment
      @bronto_client = Bronto.new(token)
      @token=token
    end

    def build(order)
      {
          :id => order.number,
          :email => order.checkout.email,
          :contactId => contact_id(order.checkout.email),
          :products => line_items(order.line_items),
          :orderDate => order.completed_at.iso8601()
      }
    end

    def create_or_update(order)
      bronto_client.add_or_update_orders build(order)
    end

    def line_items(line_items)
      line_items.inject([]) do |items, item|
        items << {
            :id => item.variant_id,
            :sku => item.variant.sku,
            :name => ERB::Util.html_escape(item.product.name.gsub!(/[^0-9A-Za-z]/, ' ')),      # some product may have special characot in name
            :quantity => item.quantity,
            :price => item.price#,
            #:url => 'http://www.' + item.product.store.name + '/products/' + item.product.permalink,
            #:image => 'http://dt1l4oh2o5aei.cloudfront.net/attachments/' + item.product.images.first.id.to_s + '/product.jpg'
        }

        items
      end
    end

    def contact_id(recipient_email)
      contact = Contact.new(token, bronto_client)
      contact.get_id_by_email recipient_email
    end
  end
end