# frozen_string_literal: true
FactoryBot.define do
  factory :newspaper_issue_ingest, class: NewspaperWorks::Ingest::NewspaperIssueIngest do
    newspaper_issue
    initialize_with { new(newspaper_issue) }
  end
end
