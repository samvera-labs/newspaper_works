module NewspaperWorks
  module Ingest
    module NDNP
      class IssueIngester
        attr_accessor :batch, :issue, :target

        delegate :path, to: :issue

        COPY_FIELDS = [
          :lccn,
          :edition,
          :volume,
          :publication_date,
          :held_by
        ].freeze

        # @param issue [NewspaperWorks::Ingest::NDNP::IssueIngest]
        #   source issue data
        # @param batch [NewspaperWorks::Ingest::NDNP::BatchIngest, NilClass]
        #   source batch data (optional)
        def initialize(issue, batch = nil)
          @issue = issue
          @batch = batch
          @target = nil
        end

        def ingest
          construct_issue
          ingest_pages
        end

        private

          def construct_issue
            create_issue
            find_or_create_linked_publication
          end

          def page_ingester(page_data)
            NewspaperWorks::Ingest::NDNP::PageIngester.new(
              page_data,
              target
            ).ingest
          end

          def ingest_pages
            issue.each do |page|
              NewspaperWorks::Ingest::NDNP::PageIngester.new(page, target).ingest
            end
          end

          def issue_title
            "#{pub_title} (#{issue.metadata.publication_date})"
          end

          def copy_issue_metadata
            metadata = issue.metadata
            # set (required, plural) title from single value obtained from reel:
            target.title = [issue_title]
            # copy all fields with singular (non-repeatable) values on both
            #   target NewspaperIssue object, and metadata source:
            COPY_FIELDS.each do |fieldname|
              target.send("#{fieldname}=", metadata.send(fieldname.to_s))
            end
            # For now treat issue number as one-off, as the PCDM profile
            #   spells this name differently than the NewspaperIssue model
            target.issue_number = metadata.issue
          end

          def create_issue
            target = NewspaperIssue.create
            copy_issue_metadata
            target.save!
          end

          # @param lccn [String] Library of Congress Control Number
          #   of Publication
          # @return [NewspaperTitle, NilClass] publication or nil if not found
          def find_publication(lccn)
            NewspaperTitle.where(lccn: lccn).first
          end

          def pub_title
            issue.container.metadata.title
          end

          def find_or_create_linked_publication
            lccn = issue.metadata.lccn
            publication = find_publication(lccn)
            publication = NewspaperTitle.create if publication.nil?
            publication.title = pub_title
            publication.lccn |= lccn
            publication.members << target.id
            publication.save!
          end
      end
    end
  end
end
