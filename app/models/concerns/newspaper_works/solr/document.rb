module NewspaperWorks::Solr::Document
  # newspaper_core_metadata attributes
  def alternative_title
    self[Solrizer.solr_name('alternative_title')]
  end

  def genre
    self[Solrizer.solr_name('genre')]
  end

  def place_of_publication
    self[Solrizer.solr_name('place_of_publication')]
  end

  def issn
    self[Solrizer.solr_name('issn')]
  end

  def lccn
    self[Solrizer.solr_name('lccn')]
  end

  def oclcnum
    self[Solrizer.solr_name('oclcnum')]
  end

  def held_by
    self[Solrizer.solr_name('held_by')]
  end

  # newspaper_core_metadata attributes
  def text_direction
    self[Solrizer.solr_name('text_direction')]
  end

  def page_number
    self[Solrizer.solr_name('page_number')]
  end

  def section
    self[Solrizer.solr_name('section')]
  end

  # newspaper_article attributes
  def author
    self[Solrizer.solr_name('author')]
  end

  def photographer
    self[Solrizer.solr_name('photographer')]
  end

  def volume
    self[Solrizer.solr_name('volume')]
  end

  def issue_number
    self[Solrizer.solr_name('issue_number')]
  end

  def geographic_coverage
    self[Solrizer.solr_name('geographic_coverage')]
  end

  def extent
    self[Solrizer.solr_name('extent')]
  end

  def publication_date
    self[Solrizer.solr_name('publication_date')]
  end

  # newspaper_page attributes
  def height
    self[Solrizer.solr_name('height')]
  end

  def width
    self[Solrizer.solr_name('width')]
  end

  # newspaper_title attributes
  def edition
    self[Solrizer.solr_name('edition')]
  end

  def frequency
    self[Solrizer.solr_name('frequency')]
  end

  def preceded_by
    self[Solrizer.solr_name('preceded_by')]
  end

  def succeeded_by
    self[Solrizer.solr_name('succeeded_by')]
  end

  def publication_date_start
    self[Solrizer.solr_name('publication_date_start')]
  end

  def publication_date_end
    self[Solrizer.solr_name('publication_date_end')]
  end
end
