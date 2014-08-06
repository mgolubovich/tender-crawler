# Store for statistics purposes
class Statistics
  include Mongoid::Document
  include Mongoid::Timestamps

  field :global_sources_count, type: Integer
  field :global_cartridges_count, type: Integer
  field :global_selectors_count, type: Integer
  field :global_tenders_count, type: Integer
  field :global_rules_count, type: Integer
  field :global_page_managers_count, type: Integer
  field :global_cities_count, type: Integer
  field :global_regions_count, type: Integer
  field :moderation_today_count, type: Integer
  field :yandex_request_count, type: Integer

  def reset_yandex_counter
    self.yandex_request_count = 0
    save
  end

  def increment_yandex_counter(count = 1)
    self.yandex_request_count += count
    save
  end
end
