module GpArticle::Model::Rel::Category
  extend ActiveSupport::Concern

  included do
    attr_accessor :in_category_ids, :in_event_category_ids, :in_marker_category_ids
    after_save :save_categories, if: 'in_category_ids.present?'
    after_save :save_event_categories, if: 'in_event_category_ids.present?'
    after_save :save_marker_categories, if: 'in_marker_category_ids.present?'
  end

  def in_category_params
    return @in_category_params if defined? @in_category_params
    @in_category_params =
      if in_category_ids.present?
        in_category_ids
      else
        make_category_params(categories)
      end
  end

  def in_event_category_params
    return @in_event_category_params if defined? @in_event_category_params
    @in_event_category_params =
      if in_event_category_ids.present?
        in_event_category_ids
      else
        make_category_params(event_categories)
      end
  end

  def in_marker_category_params
    return @in_marker_category_params if defined? @in_marker_category_params
    @in_marker_category_params =
      if in_marker_category_ids.present?
        in_marker_category_ids
      else
        make_category_params(marker_categories)
      end
  end

  private

  def make_category_params(categories)
    params = categories.group_by { |c| c.category_type_id.to_s }
    params.each { |ctid, cats| params[ctid] = cats.to_a.map {|c| c.id.to_s } }
    params
  end

  def save_categories
    category_ids = in_category_ids.values.flatten.select(&:present?).map(&:to_i).uniq

    if content.category_types.include?(content.group_category_type) && creator && creator.group
      group_category = content.group_category_type.categories.find_by(group_code: creator.group.code)
      category_ids |= [group_category.id]
    end

    if content.default_category && content.category_types.include?(content.default_category_type)
      category_ids |= [content.default_category.id]
    end

    self.category_ids = category_ids
  end

  def save_event_categories
    self.event_category_ids = in_event_category_ids.values.flatten.select(&:present?).map(&:to_i).uniq
  end

  def save_marker_categories
    self.marker_category_ids = in_marker_category_ids.values.flatten.select(&:present?).map(&:to_i).uniq
  end
end