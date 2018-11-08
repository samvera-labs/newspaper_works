module NewspaperWorks
  module BreadcrumbHelper
    def newspaper_breadcrumbs(presenter, link_class = nil)
      breadcrumbs = []
      ancestors = { title: :publication_id, issue: :issue_id, page: :page_ids }
      ancestors.each do |k, v|
        breadcrumbs << create_breadcrumb_link(k, presenter, link_class) if presenter.respond_to?(v)
      end
      breadcrumbs.flatten
    end

    def create_breadcrumb_link(object_type, presenter, link_class = nil)
      links = []
      case object_type
      when :title
        links << breadcrumb_object_link(object_type, presenter.publication_id,
                                        presenter.publication_title, link_class)
      when :issue
        links << breadcrumb_object_link(object_type, presenter.issue_id,
                                        presenter.issue_title, link_class)
      when :page
        unless presenter.page_ids.blank? || presenter.page_titles.blank?
          presenter.page_ids.each_with_index do |id, index|
            links << breadcrumb_object_link(object_type, id, presenter.page_titles[index],
                                            link_class)
          end
        end
      end
    end

    def breadcrumb_object_link(object_type, id, title, link_class = nil)
      return [] unless id && title
      link_path = "hyrax_newspaper_#{object_type}_path"
      link_to(title,
              main_app.send(link_path, id),
              class: link_class)
    end
  end
end