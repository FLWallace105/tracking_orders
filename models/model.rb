class EllieShopifyOrder < ActiveRecord::Base
    self.table_name = "ellie_shopify_orders"
end

class MarikaShopifyOrder < ActiveRecord::Base
    self.table_name = "marika_shopify_orders"
end

class EllieCollect < ActiveRecord::Base
    self.table_name = "ellie_collects"
end

class EllieCustomCollection < ActiveRecord::Base
    self.table_name = "ellie_custom_collections"
end

class EllieProduct < ActiveRecord::Base
    self.table_name = "ellie_products"
end

class EllieVariant < ActiveRecord::Base
    self.table_name = "ellie_variants"
end

class MarikaProduct < ActiveRecord::Base
    self.table_name = "marika_products"
end

class MarikaVariant < ActiveRecord::Base
    self.table_name = "marika_variants"
end

class ZobhaProduct < ActiveRecord::Base
    self.table_name = "zobha_products"
end

class ZobhaVariant < ActiveRecord::Base
    self.table_name = "zobha_variants"
end